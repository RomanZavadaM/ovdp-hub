import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/security/vault_crypto.dart';
import 'package:ovdp_hub/security/vault_session.dart';
import 'package:ovdp_hub/security/vault_store.dart';

class FakeVaultContentStore implements VaultLifecycleStore {
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
  Completer<VaultOpenResult>? saveCompleter;
  Object? openError;
  Object? saveError;
  Object? lifecycleError;
  final List<String> lifecycleCalls = [];

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
    final completer = saveCompleter;
    if (completer != null) return completer.future;
    return saveResult;
  }

  @override
  Future<VaultLifecycleResult> enableRecovery({
    required String vaultId,
    required String recoverySecret,
    required VaultRecoveryKdfParameters recoveryParameters,
  }) async {
    if (lifecycleError case final error?) throw error;
    lifecycleCalls.add('enable:$vaultId');
    return VaultLifecycleResult(
      vaultId: vaultId,
      revision: 2,
      recoveryEnabled: true,
    );
  }

  @override
  Future<VaultLifecycleResult> rotateRecovery({
    required String vaultId,
    required String recoverySecret,
    required VaultRecoveryKdfParameters recoveryParameters,
  }) async {
    if (lifecycleError case final error?) throw error;
    lifecycleCalls.add('rotate:$vaultId');
    return VaultLifecycleResult(
      vaultId: vaultId,
      revision: 2,
      recoveryEnabled: true,
    );
  }

  @override
  Future<VaultLifecycleResult> removeRecovery({
    required String vaultId,
  }) async {
    if (lifecycleError case final error?) throw error;
    lifecycleCalls.add('remove:$vaultId');
    return VaultLifecycleResult(
      vaultId: vaultId,
      revision: 2,
      recoveryEnabled: false,
    );
  }

  @override
  Future<void> deleteLocalVault({required String vaultId}) async {
    if (lifecycleError case final error?) throw error;
    lifecycleCalls.add('delete:$vaultId');
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

  test('in-flight save serializes lifecycle, second save and re-unlock', () async {
    final store = FakeVaultContentStore();
    final scheduler = FakeSessionScheduler();
    final controller = controllerFor(store, scheduler);
    addTearDown(controller.dispose);

    await controller.unlock(vaultId: 'vault-1');

    final saveCompleter = Completer<VaultOpenResult>();
    store.saveCompleter = saveCompleter;
    final saveFuture = controller.save(Uint8List.fromList([7, 8]));

    await expectLater(
      controller.save(Uint8List.fromList([9])),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'vault.session_busy',
        ),
      ),
    );
    await expectLater(
      controller.enableRecovery(
        vaultId: 'vault-1',
        recoverySecret: 'must wait for save',
        recoveryParameters: VaultRecoveryKdfParameters.interactive,
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'vault.session_busy',
        ),
      ),
    );

    await controller.lock();
    expect(controller.state.phase, VaultSessionPhase.locked);
    await expectLater(
      controller.unlock(vaultId: 'vault-1'),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'vault.session_busy',
        ),
      ),
    );

    final staleSave = VaultOpenResult(
      vaultId: 'vault-1',
      revision: 2,
      plainText: Uint8List.fromList([4, 5, 6]),
      recoveryEnabled: true,
    );
    saveCompleter.complete(staleSave);
    await saveFuture;

    expect(controller.state.phase, VaultSessionPhase.locked);
    expect(staleSave.plainText, [0, 0, 0]);

    store.saveCompleter = null;
    await controller.unlock(vaultId: 'vault-1');
    expect(controller.state.phase, VaultSessionPhase.unlocked);
  });

  test('lifecycle mutation requires unlocked matching session and locks first', () async {
    final store = FakeVaultContentStore();
    final scheduler = FakeSessionScheduler();
    final controller = controllerFor(store, scheduler);
    addTearDown(controller.dispose);

    await expectLater(
      controller.enableRecovery(
        vaultId: 'vault-1',
        recoverySecret: 'new recovery secret',
        recoveryParameters: VaultRecoveryKdfParameters.interactive,
      ),
      throwsStateError,
    );

    await controller.unlock(vaultId: 'vault-1');
    expect(controller.state.phase, VaultSessionPhase.unlocked);

    await controller.enableRecovery(
      vaultId: 'vault-1',
      recoverySecret: 'new recovery secret',
      recoveryParameters: VaultRecoveryKdfParameters.interactive,
    );

    expect(controller.state.phase, VaultSessionPhase.locked);
    expect(store.lifecycleCalls, ['enable:vault-1']);
    expect(() => controller.readPlainTextCopy(), throwsStateError);
  });

  test('lifecycle failure remains plaintext-free in error state', () async {
    final store = FakeVaultContentStore();
    final scheduler = FakeSessionScheduler();
    final controller = controllerFor(store, scheduler);
    addTearDown(controller.dispose);

    await controller.unlock(vaultId: 'vault-1');
    store.lifecycleError = StateError('vault.test_delete_failure');

    await controller.deleteLocalVault(vaultId: 'vault-1');

    expect(controller.state.phase, VaultSessionPhase.error);
    expect(controller.state.errorCode, 'vault.test_delete_failure');
    expect(() => controller.readPlainTextCopy(), throwsStateError);
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
