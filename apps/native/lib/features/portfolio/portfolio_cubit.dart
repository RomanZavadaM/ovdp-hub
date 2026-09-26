import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/hub_repository.dart';
import 'legacy_plaintext_migration.dart';
import 'portfolio_gateway.dart';
import 'private_portfolio.dart';

@immutable
class PortfolioState {
  final bool supported;
  final bool portableBackupSupported;
  final bool exists;
  final bool busy;
  final PrivatePortfolioPayload? payload;
  final LegacyPlaintextMigrationReport? migrationReport;
  final String? errorCode;

  const PortfolioState({
    this.supported = true,
    this.portableBackupSupported = false,
    this.exists = false,
    this.busy = false,
    this.payload,
    this.migrationReport,
    this.errorCode,
  });

  bool get unlocked => payload != null;

  PortfolioState copyWith({
    bool? supported,
    bool? portableBackupSupported,
    bool? exists,
    bool? busy,
    PrivatePortfolioPayload? payload,
    bool clearPayload = false,
    LegacyPlaintextMigrationReport? migrationReport,
    bool clearMigrationReport = false,
    String? errorCode,
    bool clearError = false,
  }) => PortfolioState(
    supported: supported ?? this.supported,
    portableBackupSupported:
        portableBackupSupported ?? this.portableBackupSupported,
    exists: exists ?? this.exists,
    busy: busy ?? this.busy,
    payload: clearPayload ? null : payload ?? this.payload,
    migrationReport: clearMigrationReport
        ? null
        : migrationReport ?? this.migrationReport,
    errorCode: clearError ? null : errorCode ?? this.errorCode,
  );
}

class PortfolioCubit extends Cubit<PortfolioState> {
  final HubRepository hubRepository;
  final PortfolioGateway gateway;
  final DateTime Function() clock;
  late final StreamSubscription<bool> _lockSubscription;

  PortfolioCubit(
    this.hubRepository,
    this.gateway, {
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now,
       super(
         PortfolioState(
           supported: gateway.supported,
           portableBackupSupported: gateway.portableBackupSupported,
         ),
       ) {
    _lockSubscription = gateway.unlockChanges.listen((unlocked) {
      if (!unlocked && !isClosed && state.payload != null) {
        emit(state.copyWith(clearPayload: true, clearMigrationReport: true));
      }
    });
  }

  Future<void> initialize() async {
    if (!gateway.supported) {
      emit(
        PortfolioState(
          supported: false,
          portableBackupSupported: gateway.portableBackupSupported,
        ),
      );
      return;
    }
    await _run(() async {
      final exists = await gateway.exists();
      emit(state.copyWith(exists: exists, busy: false, clearError: true));
    });
  }

  Future<void> create(String recoverySecret) => _run(() async {
    final payload = await gateway.create(recoverySecret: recoverySecret);
    emit(
      state.copyWith(
        exists: true,
        payload: payload,
        busy: false,
        clearMigrationReport: true,
        clearError: true,
      ),
    );
  });

  Future<void> open() => _run(() async {
    final payload = await gateway.open();
    emit(
      state.copyWith(
        exists: true,
        payload: payload,
        busy: false,
        clearMigrationReport: true,
        clearError: true,
      ),
    );
  });

  Future<void> lock() async {
    if (state.busy) return;
    await gateway.lock();
    if (!isClosed) {
      emit(
        state.copyWith(
          clearPayload: true,
          clearMigrationReport: true,
          clearError: true,
        ),
      );
    }
  }

  Future<void> addAcquisition({
    required String isin,
    required int units,
    required String acquiredOn,
    required String tradeAmount,
    required bool feeKnown,
    String? feeTotal,
    String? brokerAccountLabel,
  }) => _run(() async {
    final current = state.payload;
    if (current == null) {
      throw StateError('vault.session_locked');
    }
    final normalizedIsin = isin.trim().toUpperCase();
    final bonds = hubRepository.current?.catalog.bonds
            .where((bond) => bond.isin == normalizedIsin)
            .toList() ??
        const [];
    if (bonds.length != 1) {
      throw const FormatException('portfolio.issue_not_in_catalog');
    }
    final now = clock().toUtc();
    final id =
        'lot:${now.microsecondsSinceEpoch}:${current.acquisitionLots.length + 1}';
    final label = brokerAccountLabel?.trim();
    final lot = PrivateAcquisitionLot(
      id: id,
      isin: normalizedIsin,
      units: units,
      acquiredOn: acquiredOn,
      currency: bonds.single.currency,
      tradeAmount: Decimal.parse(tradeAmount.trim()),
      feeStatus:
          feeKnown ? AcquisitionFeeStatus.known : AcquisitionFeeStatus.unknown,
      feeTotal: feeKnown ? Decimal.parse((feeTotal ?? '0').trim()) : null,
      brokerAccountLabel:
          label == null || label.isEmpty ? null : label,
    );
    final next = PrivatePortfolioPayload(
      portfolioId: current.portfolioId,
      acquisitionLots: [...current.acquisitionLots, lot],
      cashEvents: current.cashEvents,
      disposals: current.disposals,
      legacyCollections: current.legacyCollections,
    );
    await gateway.save(next);
    emit(state.copyWith(payload: next, busy: false, clearError: true));
  });

  Future<void> addDisposal({
    required String isin,
    required String disposedOn,
    required String proceedsAmount,
    required bool feeKnown,
    String? feeTotal,
    required Map<String, int> lotAllocations,
    String? note,
  }) => _run(() async {
    final current = state.payload;
    if (current == null) {
      throw StateError('vault.session_locked');
    }
    final normalizedIsin = isin.trim().toUpperCase();
    final lots = current.acquisitionLots
        .where((lot) => lot.isin == normalizedIsin)
        .toList();
    if (lots.isEmpty) {
      throw const FormatException('portfolio.disposal_without_acquisition');
    }
    final allocations = lotAllocations.entries
        .where((entry) => entry.value > 0)
        .map(
          (entry) => PrivateDisposalLotAllocation(
            lotId: entry.key,
            units: entry.value,
          ),
        )
        .toList();
    if (allocations.isEmpty) {
      throw const FormatException('portfolio.disposal_allocation_required');
    }
    final units = allocations.fold<int>(
      0,
      (sum, allocation) => sum + allocation.units,
    );
    final now = clock().toUtc();
    final trimmedNote = note?.trim();
    final disposal = PrivateDisposal(
      id: 'sale:${now.microsecondsSinceEpoch}:${current.disposals.length + 1}',
      isin: normalizedIsin,
      disposedOn: disposedOn,
      units: units,
      currency: lots.first.currency,
      proceedsAmount: Decimal.parse(proceedsAmount.trim()),
      feeStatus:
          feeKnown ? DisposalFeeStatus.known : DisposalFeeStatus.unknown,
      feeTotal: feeKnown ? Decimal.parse((feeTotal ?? '0').trim()) : null,
      allocations: allocations,
      note: trimmedNote == null || trimmedNote.isEmpty ? null : trimmedNote,
    );
    final next = PrivatePortfolioPayload(
      portfolioId: current.portfolioId,
      acquisitionLots: current.acquisitionLots,
      cashEvents: current.cashEvents,
      disposals: [...current.disposals, disposal],
      legacyCollections: current.legacyCollections,
    );
    await gateway.save(next);
    emit(state.copyWith(payload: next, busy: false, clearError: true));
  });

  Future<void> addCoupon({
    required String isin,
    required String date,
    required String amount,
    String? note,
  }) => _run(() async {
    final current = state.payload;
    if (current == null) {
      throw StateError('vault.session_locked');
    }
    final normalizedIsin = isin.trim().toUpperCase();
    final lots = current.acquisitionLots
        .where((lot) => lot.isin == normalizedIsin)
        .toList();
    if (lots.isEmpty) {
      throw const FormatException('portfolio.event_without_acquisition');
    }
    final now = clock().toUtc();
    final trimmedNote = note?.trim();
    final event = PrivateCashEvent(
      id: 'coupon:${now.microsecondsSinceEpoch}:${current.cashEvents.length + 1}',
      isin: normalizedIsin,
      kind: PrivateCashEventKind.coupon,
      date: date,
      currency: lots.first.currency,
      amount: Decimal.parse(amount.trim()),
      note: trimmedNote == null || trimmedNote.isEmpty ? null : trimmedNote,
    );
    final next = PrivatePortfolioPayload(
      portfolioId: current.portfolioId,
      acquisitionLots: current.acquisitionLots,
      cashEvents: [...current.cashEvents, event],
      disposals: current.disposals,
      legacyCollections: current.legacyCollections,
    );
    await gateway.save(next);
    emit(state.copyWith(payload: next, busy: false, clearError: true));
  });

  Future<void> addRedemption({
    required String isin,
    required int units,
    required String date,
    required String amount,
    String? note,
  }) => _run(() async {
    final current = state.payload;
    if (current == null) {
      throw StateError('vault.session_locked');
    }
    final normalizedIsin = isin.trim().toUpperCase();
    final lots = current.acquisitionLots
        .where((lot) => lot.isin == normalizedIsin)
        .toList();
    if (lots.isEmpty) {
      throw const FormatException('portfolio.event_without_acquisition');
    }
    final now = clock().toUtc();
    final trimmedNote = note?.trim();
    final event = PrivateCashEvent(
      id: 'redemption:${now.microsecondsSinceEpoch}:${current.cashEvents.length + 1}',
      isin: normalizedIsin,
      kind: PrivateCashEventKind.redemption,
      date: date,
      currency: lots.first.currency,
      amount: Decimal.parse(amount.trim()),
      units: units,
      note: trimmedNote == null || trimmedNote.isEmpty ? null : trimmedNote,
    );
    final next = PrivatePortfolioPayload(
      portfolioId: current.portfolioId,
      acquisitionLots: current.acquisitionLots,
      cashEvents: [...current.cashEvents, event],
      disposals: current.disposals,
      legacyCollections: current.legacyCollections,
    );
    await gateway.save(next);
    emit(state.copyWith(payload: next, busy: false, clearError: true));
  });

  Future<String?> createPortableBackup() async {
    if (state.busy ||
        !gateway.supported ||
        !gateway.portableBackupSupported ||
        state.payload == null) {
      return null;
    }
    emit(state.copyWith(busy: true, clearError: true));
    try {
      final path = await gateway.createPortableBackup();
      if (!isClosed) emit(state.copyWith(busy: false, clearError: true));
      return path;
    } catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            busy: false,
            errorCode: _safeErrorCode(error),
          ),
        );
      }
      return null;
    }
  }

  Future<bool?> restorePortableBackup(String recoverySecret) async {
    if (state.busy ||
        !gateway.supported ||
        !gateway.portableBackupSupported) {
      return false;
    }
    emit(state.copyWith(busy: true, clearError: true));
    try {
      final payload = await gateway.restorePortableBackup(
        recoverySecret: recoverySecret,
      );
      if (payload == null) {
        if (!isClosed) emit(state.copyWith(busy: false, clearError: true));
        return null;
      }
      if (!isClosed) {
        emit(
          state.copyWith(
            exists: true,
            payload: payload,
            busy: false,
            clearMigrationReport: true,
            clearError: true,
          ),
        );
      }
      return true;
    } catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            busy: false,
            clearPayload: true,
            errorCode: _safeErrorCode(error),
          ),
        );
      }
      return false;
    }
  }

  Future<bool> rotateRecovery(String recoverySecret) async {
    if (state.busy || !gateway.supported || state.payload == null) {
      return false;
    }
    emit(state.copyWith(busy: true, clearError: true));
    try {
      final payload = await gateway.rotateRecovery(
        recoverySecret: recoverySecret,
      );
      if (!isClosed) {
        emit(
          state.copyWith(
            payload: payload,
            busy: false,
            clearMigrationReport: true,
            clearError: true,
          ),
        );
      }
      return true;
    } catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            busy: false,
            clearPayload: true,
            errorCode: _safeErrorCode(error),
          ),
        );
      }
      return false;
    }
  }

  Future<void> migrateLegacy() => _run(() async {
    if (state.payload == null) {
      throw StateError('vault.session_locked');
    }
    final workspacePath = hubRepository.current?.localPath;
    if (workspacePath == null || workspacePath.isEmpty) {
      throw StateError('workspace.not_open');
    }
    final result = await gateway.migrateLegacy(workspacePath: workspacePath);
    emit(
      state.copyWith(
        payload: result.payload,
        migrationReport: result.report,
        busy: false,
        clearError: true,
      ),
    );
  });

  Future<void> _run(Future<void> Function() operation) async {
    if (state.busy || !gateway.supported) return;
    emit(state.copyWith(busy: true, clearError: true));
    try {
      await operation();
      if (!isClosed && state.busy) {
        emit(state.copyWith(busy: false));
      }
    } catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            busy: false,
            errorCode: _safeErrorCode(error),
          ),
        );
      }
    }
  }

  String _safeErrorCode(Object error) {
    if (error is FormatException) return error.message.toString();
    if (error is StateError) return error.message.toString();
    if (error is UnsupportedError) return error.message.toString();
    return 'portfolio.operation_failed';
  }

  void onBackground() => gateway.onBackground();

  Future<void> onForeground() async {
    await gateway.onForeground();
    if (!gateway.unlocked && !isClosed && state.payload != null) {
      emit(state.copyWith(clearPayload: true, clearMigrationReport: true));
    }
  }

  void dismissError() => emit(state.copyWith(clearError: true));

  void dismissMigrationReport() =>
      emit(state.copyWith(clearMigrationReport: true));

  @override
  Future<void> close() async {
    await _lockSubscription.cancel();
    await gateway.lock();
    await gateway.dispose();
    return super.close();
  }
}
