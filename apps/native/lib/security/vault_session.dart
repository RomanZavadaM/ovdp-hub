import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'vault_store.dart';

enum VaultSessionPhase {
  locked,
  unlocking,
  unlocked,
  locking,
  error,
}

class VaultSessionPolicy {
  final Duration inactivityTimeout;
  final Duration backgroundGrace;

  const VaultSessionPolicy({
    required this.inactivityTimeout,
    required this.backgroundGrace,
  }) : assert(inactivityTimeout > Duration.zero),
       assert(!backgroundGrace.isNegative);
}

abstract interface class VaultSessionTimer {
  void cancel();
}

typedef VaultSessionTimerFactory =
    VaultSessionTimer Function(Duration delay, void Function() callback);

class _DartVaultSessionTimer implements VaultSessionTimer {
  final Timer _timer;

  _DartVaultSessionTimer(Duration delay, void Function() callback)
      : _timer = Timer(delay, callback);

  @override
  void cancel() => _timer.cancel();
}

VaultSessionTimer defaultVaultSessionTimerFactory(
  Duration delay,
  void Function() callback,
) =>
    _DartVaultSessionTimer(delay, callback);

@immutable
class VaultSessionState {
  final VaultSessionPhase phase;
  final String? vaultId;
  final int? revision;
  final bool recoveryEnabled;
  final String? errorCode;

  const VaultSessionState({
    required this.phase,
    this.vaultId,
    this.revision,
    this.recoveryEnabled = false,
    this.errorCode,
  });

  static const locked = VaultSessionState(phase: VaultSessionPhase.locked);

  bool get isUnlocked => phase == VaultSessionPhase.unlocked;
}

class VaultSessionController extends ChangeNotifier {
  final VaultContentStore store;
  final VaultSessionPolicy policy;
  final DateTime Function() now;
  final VaultSessionTimerFactory timerFactory;

  VaultSessionState _state = VaultSessionState.locked;
  Uint8List? _plainText;
  DateTime? _lastActivityAt;
  DateTime? _backgroundedAt;
  VaultSessionTimer? _inactivityTimer;
  VaultSessionTimer? _backgroundTimer;
  int _generation = 0;
  bool _disposed = false;

  VaultSessionController({
    required this.store,
    required this.policy,
    DateTime Function()? now,
    VaultSessionTimerFactory? timerFactory,
  }) : now = now ?? DateTime.now,
       timerFactory = timerFactory ?? defaultVaultSessionTimerFactory;

  VaultSessionState get state => _state;

  Future<void> unlock({required String vaultId}) async {
    final token = ++_generation;
    _cancelTimers();
    _clearPlainText();
    _backgroundedAt = null;
    _setState(
      VaultSessionState(
        phase: VaultSessionPhase.unlocking,
        vaultId: vaultId,
      ),
    );

    try {
      final opened = await store.open(vaultId: vaultId);
      if (_disposed || token != _generation) {
        opened.plainText.fillRange(0, opened.plainText.length, 0);
        return;
      }

      _plainText = Uint8List.fromList(opened.plainText);
      opened.plainText.fillRange(0, opened.plainText.length, 0);
      _lastActivityAt = now();
      _setState(
        VaultSessionState(
          phase: VaultSessionPhase.unlocked,
          vaultId: vaultId,
          revision: opened.revision,
          recoveryEnabled: opened.recoveryEnabled,
        ),
      );
      _scheduleInactivity();
    } catch (error) {
      if (!_disposed && token == _generation) {
        _fail(error, vaultId: vaultId);
      }
    }
  }

  Future<void> lock() async {
    ++_generation;
    _cancelTimers();
    _backgroundedAt = null;
    _lastActivityAt = null;

    if (_state.phase == VaultSessionPhase.locked) {
      _clearPlainText();
      return;
    }

    _setState(
      VaultSessionState(
        phase: VaultSessionPhase.locking,
        vaultId: _state.vaultId,
        revision: _state.revision,
        recoveryEnabled: _state.recoveryEnabled,
      ),
    );
    _clearPlainText();
    _setState(VaultSessionState.locked);
  }

  Uint8List readPlainTextCopy() {
    final data = _plainText;
    if (!_state.isUnlocked || data == null) {
      throw StateError('vault.session_locked');
    }
    recordActivity();
    return Uint8List.fromList(data);
  }

  Future<void> save(Uint8List plainText) async {
    final vaultId = _state.vaultId;
    if (!_state.isUnlocked || vaultId == null || _plainText == null) {
      throw StateError('vault.session_locked');
    }
    final token = _generation;
    recordActivity();

    try {
      final saved = await store.save(
        vaultId: vaultId,
        plainText: plainText,
      );
      if (_disposed ||
          token != _generation ||
          _state.phase != VaultSessionPhase.unlocked) {
        saved.plainText.fillRange(0, saved.plainText.length, 0);
        return;
      }
      _clearPlainText();
      _plainText = Uint8List.fromList(saved.plainText);
      saved.plainText.fillRange(0, saved.plainText.length, 0);
      _lastActivityAt = now();
      _setState(
        VaultSessionState(
          phase: VaultSessionPhase.unlocked,
          vaultId: vaultId,
          revision: saved.revision,
          recoveryEnabled: saved.recoveryEnabled,
        ),
      );
      _scheduleInactivity();
    } catch (error) {
      if (!_disposed && token == _generation) {
        _fail(error, vaultId: vaultId);
      }
    }
  }

  void recordActivity() {
    if (!_state.isUnlocked || _disposed) return;
    _lastActivityAt = now();
    _scheduleInactivity();
  }

  void onBackground() {
    if (!_state.isUnlocked || _disposed) return;
    _backgroundedAt = now();
    _backgroundTimer?.cancel();
    _backgroundTimer = timerFactory(
      policy.backgroundGrace,
      () => unawaited(lock()),
    );
  }

  Future<void> onForeground() async {
    if (!_state.isUnlocked || _disposed) return;
    _backgroundTimer?.cancel();
    _backgroundTimer = null;

    final current = now();
    final backgroundedAt = _backgroundedAt;
    final lastActivityAt = _lastActivityAt;
    final backgroundExpired = backgroundedAt != null &&
        current.difference(backgroundedAt) >= policy.backgroundGrace;
    final inactivityExpired = lastActivityAt != null &&
        current.difference(lastActivityAt) >= policy.inactivityTimeout;

    if (backgroundExpired || inactivityExpired) {
      await lock();
      return;
    }

    _backgroundedAt = null;
    recordActivity();
  }

  void clearError() {
    if (_state.phase != VaultSessionPhase.error || _disposed) return;
    ++_generation;
    _cancelTimers();
    _clearPlainText();
    _backgroundedAt = null;
    _lastActivityAt = null;
    _setState(VaultSessionState.locked);
  }

  void _scheduleInactivity() {
    _inactivityTimer?.cancel();
    if (!_state.isUnlocked || _disposed) return;
    _inactivityTimer = timerFactory(
      policy.inactivityTimeout,
      () => unawaited(lock()),
    );
  }

  void _cancelTimers() {
    _inactivityTimer?.cancel();
    _backgroundTimer?.cancel();
    _inactivityTimer = null;
    _backgroundTimer = null;
  }

  void _clearPlainText() {
    final data = _plainText;
    if (data != null) {
      data.fillRange(0, data.length, 0);
      _plainText = null;
    }
  }

  void _fail(Object error, {String? vaultId}) {
    _cancelTimers();
    _clearPlainText();
    _backgroundedAt = null;
    _lastActivityAt = null;
    _setState(
      VaultSessionState(
        phase: VaultSessionPhase.error,
        vaultId: vaultId,
        errorCode: _safeErrorCode(error),
      ),
    );
  }

  String _safeErrorCode(Object error) {
    if (error is FormatException) {
      return error.message.toString();
    }
    if (error is StateError) {
      return error.message.toString();
    }
    if (error is VaultRollbackException) {
      return 'vault.rollback_detected';
    }
    return 'vault.session_error';
  }

  void _setState(VaultSessionState next) {
    if (_disposed) return;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    ++_generation;
    _cancelTimers();
    _clearPlainText();
    _backgroundedAt = null;
    _lastActivityAt = null;
    super.dispose();
  }
}
