import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/hub_repository.dart';
import 'portfolio_gateway.dart';
import 'private_portfolio.dart';

@immutable
class PortfolioState {
  final bool supported;
  final bool exists;
  final bool busy;
  final PrivatePortfolioPayload? payload;
  final String? errorCode;

  const PortfolioState({
    this.supported = true,
    this.exists = false,
    this.busy = false,
    this.payload,
    this.errorCode,
  });

  bool get unlocked => payload != null;

  PortfolioState copyWith({
    bool? supported,
    bool? exists,
    bool? busy,
    PrivatePortfolioPayload? payload,
    bool clearPayload = false,
    String? errorCode,
    bool clearError = false,
  }) => PortfolioState(
    supported: supported ?? this.supported,
    exists: exists ?? this.exists,
    busy: busy ?? this.busy,
    payload: clearPayload ? null : payload ?? this.payload,
    errorCode: clearError ? null : errorCode ?? this.errorCode,
  );
}

class PortfolioCubit extends Cubit<PortfolioState> {
  final HubRepository hubRepository;
  final PortfolioGateway gateway;
  final DateTime Function() clock;

  PortfolioCubit(
    this.hubRepository,
    this.gateway, {
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now,
       super(PortfolioState(supported: gateway.supported));

  Future<void> initialize() async {
    if (!gateway.supported) {
      emit(const PortfolioState(supported: false));
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
        clearError: true,
      ),
    );
  });

  Future<void> lock() async {
    if (state.busy) return;
    await gateway.lock();
    if (!isClosed) {
      emit(state.copyWith(clearPayload: true, clearError: true));
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

  void dismissError() => emit(state.copyWith(clearError: true));

  @override
  Future<void> close() async {
    await gateway.lock();
    gateway.dispose();
    return super.close();
  }
}
