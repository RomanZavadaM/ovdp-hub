import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/security/vault_session.dart';
import 'package:ovdp_hub/security/vault_store.dart';

class FakeVaultContentStore implements VaultContentStore {
  VaultOpenResult openResult = VaultOpenResult(
    vaultId: 'vault-1',
    revision: 1,
    plainText: Uint8List.fromList([1, 2, 3]),
    recoveryEnabled: true,
  );
  VaultOpenResult saveResult = VaultOpenResult(
    vaultId: 'vault-1',
    revision: 2,
    plainText: Uint8List.fromList([4, 5, 6]),
    recoveryEnabled: true,
  );
  Completer<VaultOpenResult>? openCompleter;
  Object? openError;
  Object? saveError;

  @override
  Future<VaultOpenResult> open({required String vaultId}) async {
    if (openError case final error?) throw error;
    final completer = openCompleter;
    if (completer != null) return completer.future;
    return openResult;
  }

  @override
  Future<VaultOpenResult> save({
    required String vaultId,
    required Uint8List plainText,
  }) async {
    if (saveError case final error?) throw error;
    return saveResult;
  }
}

class FakeSessionTimer implements VaultSessionTimer {
  final FakeSessionScheduler owner;
  final DateTime dueAt;
  final void Function() callback;
  bool cancelled = false;
  bool fired = false;

  FakeSessionTimer(this.owner, this.dueAt, this.callback);

  @override
  void cancel() => cancelled = true;
}

class FakeSessionScheduler {
  DateTime current = DateTime.utc(2026, 9, 24, 12);
  final List<FakeSessionTimer> timers = [];

  DateTime now() => current;

  VaultSessionTimer create(Duration delay, void Function() callback) {
    final timer = FakeSessionTimer(this, current.add(delay), callback);
    timers.add(timer);
    return timer;
  }

  void advance(Duration delta) {
    current = current.add(delta);
    var progressed = true;
    while (progressed) {
      progressed = false;
      for (final timer in timers) {
        if (!timer.cancelled && !timer.fired && !timer.dueAt.isAfter(current)) {
          timer.fired = true;
          timer.callback();
          progressed = true;
        }
      }
    }
  }
}

VaultSessionController controllerFor(
  FakeVaultContentStore store,
  FakeSessionScheduler scheduler, {
  Duration inactivity = const Duration(minutes: 5),
  Duration backgroundGrace = const Duration(seconds: 30),
}) =>
    VaultSessionController(
      store: store,
      policy: VaultSessionPolicy(
        inactivityTimeout: inactivity,
        backgroundGrace: backgroundGrace,
      ),
      now: scheduler.now,
      timerFactory: scheduler.create,
    );

void main() {
  test('manual unlock and lock expose only unlocked plaintext copies', () async {
    final store = FakeVaultContentStore();
    final scheduler = FakeSessionScheduler();
    final controller = controllerFor(store, scheduler);
    addTearDown(controller.dispose);

    expect(controller.state.phase, VaultSessionPhase.locked);
    await controller.unlock(vaultId: 'vault-1');
    expect(controller.state.phase, VaultSessionPhase.unlocked);
    expect(controller.state.revision, 1);
    expect(controller.state.recoveryEnabled, true);
    expect(controller.readPlainTextCopy(), [1, 2, 3]);

    await controller.lock();
    expect(controller.state.phase, VaultSessionPhase.locked);
    expect(() => controller.readPlainTextCopy(), throwsStateError);
  });

  test('inactivity timer locks the session', () async {
    final store = FakeVaultContentStore();
    final scheduler = FakeSessionScheduler();
    final controller = controllerFor(
      store,
      scheduler,
      inactivity: const Duration(minutes: 2),
    );
    addTearDown(controller.dispose);

    await controller.unlock(vaultId: 'vault-1');
    scheduler.advance(const Duration(minutes: 1));
    controller.recordActivity();
    scheduler.advance(const Duration(minutes: 1, seconds: 59));
    expect(controller.state.phase, VaultSessionPhase.unlocked);

    scheduler.advance(const Duration(seconds: 1));
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.phase, VaultSessionPhase.locked);
  });

  test('foreground locks before private rendering after background grace', () async {
    final store = FakeVaultContentStore();
    final scheduler = FakeSessionScheduler();
    final controller = controllerFor(
      store,
      scheduler,
      inactivity: const Duration(minutes: 10),
      backgroundGrace: const Duration(seconds: 30),
    );
    addTearDown(controller.dispose);

    await controller.unlock(vaultId: 'vault-1');
    controller.onBackground();
    scheduler.advance(const Duration(seconds: 20));
    await controller.onForeground();
    expect(controller.state.phase, VaultSessionPhase.unlocked);

    controller.onBackground();
    scheduler.advance(const Duration(seconds: 31));
    await controller.onForeground();
    expect(controller.state.phase, VaultSessionPhase.locked);
  });

  test('background during pending unlock cannot bypass grace lock', () async {
    final store = FakeVaultContentStore();
    final scheduler = FakeSessionScheduler();
    final completer = Completer<VaultOpenResult>();
    store.openCompleter = completer;
    final controller = controllerFor(
      store,
      scheduler,
      backgroundGrace: const Duration(seconds: 30),
    );
    addTearDown(controller.dispose);

    final unlockFuture = controller.unlock(vaultId: 'vault-race-bg');
    expect(controller.state.phase, VaultSessionPhase.unlocking);

    controller.onBackground();
    scheduler.advance(const Duration(seconds: 31));
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.phase, VaultSessionPhase.locked);

    final stale = VaultOpenResult(
      vaultId: 'vault-race-bg',
      revision: 3,
      plainText: Uint8List.fromList([3, 3, 3]),
      recoveryEnabled: true,
    );
    completer.complete(stale);
    await unlockFuture;

    expect(controller.state.phase, VaultSessionPhase.locked);
    expect(stale.plainText, [0, 0, 0]);
  });

  test('foreground during pending unlock cancels background grace timer', () async {
    final store = FakeVaultContentStore();
    final scheduler = FakeSessionScheduler();
    final completer = Completer<VaultOpenResult>();
    store.openCompleter = completer;
    final controller = controllerFor(
      store,
      scheduler,
      backgroundGrace: const Duration(seconds: 30),
    );
    addTearDown(controller.dispose);

    final unlockFuture = controller.unlock(vaultId: 'vault-race-fg');
    controller.onBackground();
    scheduler.advance(const Duration(seconds: 10));
    await controller.onForeground();

    final opened = VaultOpenResult(
      vaultId: 'vault-race-fg',
      revision: 4,
      plainText: Uint8List.fromList([4, 4, 4]),
      recoveryEnabled: false,
    );
    completer.complete(opened);
    await unlockFuture;
    expect(controller.state.phase, VaultSessionPhase.unlocked);

    scheduler.advance(const Duration(seconds: 25));
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.phase, VaultSessionPhase.unlocked);
  });

  test('stale unlock completion cannot reopen after manual lock', () async {
    final store = FakeVaultContentStore();
    final scheduler = FakeSessionScheduler();
    final completer = Completer<VaultOpenResult>();
    store.openCompleter = completer;
    final controller = controllerFor(store, scheduler);
    addTearDown(controller.dispose);

    final unlockFuture = controller.unlock(vaultId: 'vault-race');
    expect(controller.state.phase, VaultSessionPhase.unlocking);

    await controller.lock();
    expect(controller.state.phase, VaultSessionPhase.locked);

    final stale = VaultOpenResult(
      vaultId: 'vault-race',
      revision: 9,
      plainText: Uint8List.fromList([9, 9, 9]),
      recoveryEnabled: false,
    );
    completer.complete(stale);
    await unlockFuture;

    expect(controller.state.phase, VaultSessionPhase.locked);
    expect(stale.plainText, [0, 0, 0]);
  });

  test('save updates revision while unlocked', () async {
    final store = FakeVaultContentStore();
    final scheduler = FakeSessionScheduler();
    final controller = controllerFor(store, scheduler);
    addTearDown(controller.dispose);

    await controller.unlock(vaultId: 'vault-1');
    await controller.save(Uint8List.fromList([7, 8]));
    expect(controller.state.phase, VaultSessionPhase.unlocked);
    expect(controller.state.revision, 2);
    expect(controller.readPlainTextCopy(), [4, 5, 6]);
  });

  test('store error clears private session and can return to locked', () async {
    final store = FakeVaultContentStore();
    final scheduler = FakeSessionScheduler();
    final controller = controllerFor(store, scheduler);
    addTearDown(controller.dispose);

    await controller.unlock(vaultId: 'vault-1');
    store.saveError = StateError('vault.test_save_failure');
    await controller.save(Uint8List.fromList([7]));

    expect(controller.state.phase, VaultSessionPhase.error);
    expect(controller.state.errorCode, 'vault.test_save_failure');
    expect(() => controller.readPlainTextCopy(), throwsStateError);

    controller.clearError();
    expect(controller.state.phase, VaultSessionPhase.locked);
  });

  test('foreground also enforces elapsed inactivity if timers were suspended', () async {
    final store = FakeVaultContentStore();
    final scheduler = FakeSessionScheduler();
    final controller = controllerFor(
      store,
      scheduler,
      inactivity: const Duration(minutes: 3),
      backgroundGrace: const Duration(minutes: 10),
    );
    addTearDown(controller.dispose);

    await controller.unlock(vaultId: 'vault-1');
    controller.onBackground();

    // Simulate an OS suspension by cancelling scheduled callbacks while time
    // still advances. Foreground must use timestamps, not trust timers.
    for (final timer in scheduler.timers) {
      timer.cancel();
    }
    scheduler.current = scheduler.current.add(const Duration(minutes: 4));

    await controller.onForeground();
    expect(controller.state.phase, VaultSessionPhase.locked);
  });
}
