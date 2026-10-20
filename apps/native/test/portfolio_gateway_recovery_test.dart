import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show MethodChannel;
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/portfolio/portfolio_gateway.dart';
import 'package:ovdp_hub/features/portfolio/private_portfolio.dart';
import 'package:ovdp_hub/security/vault_crypto.dart';
import 'package:ovdp_hub/security/vault_session.dart';
import 'package:ovdp_hub/security/vault_store.dart';
import 'package:ovdp_hub/platform/mobile_external_storage.dart';
import 'package:sodium/sodium_sumo.dart';

import 'vault_store_test.dart' show MemoryVaultDeviceKeyStore;

class PickerStorage extends MethodChannelMobileExternalStorage {
  final Future<Uint8List?> Function() pick;
  PickerStorage(this.pick) : super(supportedOverride: true);

  @override
  Future<Uint8List?> importEncryptedBackup({required int maxBytes}) => pick();
}

class BackupTestGateway extends LocalEncryptedPortfolioGateway {
  BackupTestGateway({
    required super.store,
    required super.session,
    required super.storage,
  }) : super.forTesting();

  @override
  bool get portableBackupSupported => true;
}

/// Pause a real recovery result before the store can cache its DEK.
class PausedRecoveryCrypto extends SodiumVaultCrypto {
  Completer<void>? entered;
  Completer<void>? resume;
  bool pauseWrapping = false;

  PausedRecoveryCrypto(super.sodium);

  void pause() {
    entered = Completer<void>();
    resume = Completer<void>();
  }

  @override
  Future<VaultRecoverySlotV1> wrapDekForRecoveryAsync({
    required String vaultId,
    required SecureKey dek,
    required String recoverySecret,
    required VaultRecoveryKdfParameters parameters,
  }) async {
    final slot = await super.wrapDekForRecoveryAsync(
      vaultId: vaultId,
      dek: dek,
      recoverySecret: recoverySecret,
      parameters: parameters,
    );
    if (pauseWrapping && resume != null) {
      entered!.complete();
      await resume!.future;
      resume = null;
    }
    return slot;
  }

  @override
  Future<SecureKey> unwrapDekFromRecoveryAsync({
    required VaultRecoverySlotV1 slot,
    required String recoverySecret,
  }) async {
    final key = await super.unwrapDekFromRecoveryAsync(
      slot: slot,
      recoverySecret: recoverySecret,
    );
    final gate = resume;
    if (gate != null) {
      entered!.complete();
      await gate.future;
      resume = null;
    }
    return key;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const secret = 'synthetic recovery secret';
  const vaultId = LocalEncryptedPortfolioGateway.vaultId;
  late Directory root;
  late PausedRecoveryCrypto crypto;
  late LocalVaultStore store;
  late VaultSessionController session;
  late LocalEncryptedPortfolioGateway gateway;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('ovdp-gateway-recovery-');
    crypto = PausedRecoveryCrypto((await SodiumVaultCrypto.create()).sodium);
    store = LocalVaultStore(
      directory: root,
      crypto: crypto,
      deviceKeyStore: MemoryVaultDeviceKeyStore(),
    );
    final payload = PrivatePortfolioPayload(
      portfolioId: LocalEncryptedPortfolioGateway.portfolioId,
    );
    final bytes = PrivatePortfolioPayloadCodec.encode(payload);
    try {
      final created = await store.create(
        vaultId: vaultId,
        plainText: bytes,
        recoverySecret: secret,
        recoveryParameters: VaultRecoveryKdfParameters.interactive,
      );
      created.plainText.fillRange(0, created.plainText.length, 0);
    } finally {
      bytes.fillRange(0, bytes.length, 0);
    }
    await store.requireRecoverySecretOnOpen(
      vaultId: vaultId,
      recoverySecret: secret,
    );
    store.forgetUnlockedKey(vaultId: vaultId);
    session = VaultSessionController(
      store: store,
      policy: VaultSessionPolicy(
        inactivityTimeout: const Duration(minutes: 15),
        backgroundGrace: const Duration(seconds: 15),
      ),
    );
    gateway = LocalEncryptedPortfolioGateway.forTesting(
      store: store,
      session: session,
    );
  });

  tearDown(() async {
    await gateway.dispose();
    store.forgetUnlockedKey(vaultId: vaultId);
    await root.delete(recursive: true);
  });

  test('lock during recovery cannot reopen or retain the recovered DEK', () async {
    crypto.pause();
    final opening = gateway.open(recoverySecret: secret);
    // Install the error handler before allowing asynchronous completion.
    final rejected = expectLater(opening, throwsStateError);
    await crypto.entered!.future;
    await gateway.lock();
    crypto.resume!.complete();
    await rejected;
    expect(gateway.unlocked, isFalse);
    expect(session.state.isUnlocked, isFalse);
    expect(store.hasUnlockedKey(vaultId: vaultId), isFalse);
    await expectLater(gateway.open(), throwsStateError);
    expect(gateway.unlocked, isFalse);
    expect(store.hasUnlockedKey(vaultId: vaultId), isFalse);
    // Explicitly retrying with the secret must still work.
    await gateway.open(recoverySecret: secret);
    expect(gateway.unlocked, isTrue);
  });

  for (final action in ['background', 'dispose', 'session lock']) {
    test('$action cancels an in-flight recovery opening', () async {
      // An already open session can hit its normal automatic lock callback
      // while a fresh recovery operation is awaiting its KDF result.
      if (action == 'session lock') {
        await gateway.open(recoverySecret: secret);
      }
      crypto.pause();
      final rejected = expectLater(
        gateway.open(recoverySecret: secret),
        throwsStateError,
      );
      await crypto.entered!.future;
      switch (action) {
        case 'background':
          gateway.onBackground();
          await gateway.onForeground();
        case 'dispose':
          await gateway.dispose();
        case 'session lock':
          await session.lock();
      }
      crypto.resume!.complete();
      await rejected;
      expect(gateway.unlocked, isFalse);
      expect(session.state.isUnlocked, isFalse);
      expect(store.hasUnlockedKey(vaultId: vaultId), isFalse);
      await expectLater(gateway.open(), throwsStateError);
    });
  }

  test('overlapping opens cannot consume or replace a pending recovery key', () async {
    crypto.pause();
    final opening = gateway.open(recoverySecret: secret);
    await crypto.entered!.future;
    await expectLater(gateway.open(), throwsStateError);
    await expectLater(
      gateway.open(recoverySecret: secret),
      throwsStateError,
    );
    crypto.resume!.complete();
    await opening;
    expect(gateway.unlocked, isTrue);
    expect(store.hasUnlockedKey(vaultId: vaultId), isTrue);
    await gateway.lock();
    expect(store.hasUnlockedKey(vaultId: vaultId), isFalse);
  });

  test('forgetting a key cancels a pending store recovery before caching', () async {
    crypto.pause();
    final rejected = expectLater(
      store.unlockWithRecoverySecret(vaultId: vaultId, recoverySecret: secret),
      throwsStateError,
    );
    await crypto.entered!.future;
    store.forgetUnlockedKey(vaultId: vaultId);
    crypto.resume!.complete();
    await rejected;
    expect(store.hasUnlockedKey(vaultId: vaultId), isFalse);
    await expectLater(store.open(vaultId: vaultId), throwsStateError);
  });

  test('ordinary recovery and locking preserve the recovery-only access mode', () async {
    expect(await gateway.requiresRecoverySecret(), isTrue);
    await expectLater(
      gateway.open(recoverySecret: 'wrong synthetic secret'),
      throwsA(anything),
    );
    expect(store.hasUnlockedKey(vaultId: vaultId), isFalse);
    final payload = await gateway.open(recoverySecret: secret);
    expect(payload.portfolioId, LocalEncryptedPortfolioGateway.portfolioId);
    await gateway.save(payload);
    expect(gateway.unlocked, isTrue);
    await gateway.lock();
    expect(await gateway.requiresRecoverySecret(), isTrue);
    await expectLater(gateway.open(), throwsStateError);
    await gateway.open(recoverySecret: secret);
    expect(gateway.unlocked, isTrue);
  });

  test('lock during recovery rotation prevents the internal reopen', () async {
    const newSecret = 'new synthetic recovery secret';
    await gateway.open(recoverySecret: secret);
    crypto.pauseWrapping = true;
    crypto.pause();
    final rejected = expectLater(
      gateway.rotateRecovery(recoverySecret: newSecret),
      throwsStateError,
    );
    await crypto.entered!.future;
    await gateway.lock();
    crypto.resume!.complete();
    await rejected;
    expect(gateway.unlocked, isFalse);
    expect(store.hasUnlockedKey(vaultId: vaultId), isFalse);
    await expectLater(gateway.open(), throwsStateError);
    // A durable rotation may finish, but must never undo the later lock.
    await gateway.open(recoverySecret: newSecret);
    expect(gateway.unlocked, isTrue);
  });

  for (final action in ['lock', 'dispose']) {
    test('$action during creation prevents its internal reopen', () async {
      await store.discardLocalVault(vaultId: vaultId);
      crypto.pauseWrapping = true;
      crypto.pause();
      final rejected = expectLater(
        gateway.create(recoverySecret: secret),
        throwsStateError,
      );
      await crypto.entered!.future;
      if (action == 'dispose') {
        await gateway.dispose();
      } else {
        await gateway.lock();
      }
      crypto.resume!.complete();
      await rejected;
      expect(gateway.unlocked, isFalse);
      expect(store.hasUnlockedKey(vaultId: vaultId), isFalse);
      // Creation may finish durably, but it must respect the later lock.
      expect(await store.fileFor(vaultId).exists(), isTrue);
      if (action == 'lock') {
        await gateway.open();
        expect(gateway.unlocked, isTrue);
      }
    });

    test('$action during protection change disposes its late recovery key', () async {
      await gateway.open(recoverySecret: secret);
      await gateway.setRecoverySecretRequired(enabled: false);
      expect(await gateway.requiresRecoverySecret(), isFalse);
      crypto.pause();
      final rejected = expectLater(
        gateway.setRecoverySecretRequired(enabled: true, recoverySecret: secret),
        throwsStateError,
      );
      await crypto.entered!.future;
      if (action == 'dispose') {
        await gateway.dispose();
      } else {
        await gateway.lock();
      }
      crypto.resume!.complete();
      await rejected;
      expect(gateway.unlocked, isFalse);
      expect(store.hasUnlockedKey(vaultId: vaultId), isFalse);
      await expectLater(gateway.open(), throwsStateError);
      if (action == 'dispose') {
        await expectLater(gateway.open(recoverySecret: secret), throwsStateError);
      } else {
        await gateway.open(recoverySecret: secret);
        expect(gateway.unlocked, isTrue);
      }
    });
  }

  for (final phase in ['picker', 'recovery']) {
    test('restore cancelled during $phase cannot reopen or retain a key', () async {
      final backup = await store.fileFor(vaultId).readAsBytes();
      final picked = Completer<Uint8List?>();
      final pickerEntered = Completer<void>();
      final storage = PickerStorage(() {
        pickerEntered.complete();
        return phase == 'picker' ? picked.future : Future.value(backup);
      });
      // Replace only the unused gateway listener; the isolated session/store
      // are still the same real encrypted test vault.
      await gateway.dispose();
      session = VaultSessionController(
        store: store,
        policy: VaultSessionPolicy(
          inactivityTimeout: const Duration(minutes: 15),
          backgroundGrace: const Duration(seconds: 15),
        ),
      );
      gateway = BackupTestGateway(store: store, session: session, storage: storage);
      const channel = MethodChannel('plugins.flutter.io/path_provider');
      final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(channel, (_) async => root.path);
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      await gateway.open(recoverySecret: secret);
      if (phase == 'recovery') crypto.pause();
      final rejected = expectLater(
        gateway.restorePortableBackup(recoverySecret: secret),
        throwsStateError,
      );
      await pickerEntered.future;
      if (phase == 'picker') {
        await gateway.lock();
        picked.complete(backup);
      } else {
        await crypto.entered!.future;
        await gateway.dispose();
        crypto.resume!.complete();
      }
      await rejected;
      expect(gateway.unlocked, isFalse);
      expect(store.hasUnlockedKey(vaultId: vaultId), isFalse);
      await expectLater(gateway.open(), throwsStateError);
    }, skip: Platform.isWindows);
  }
}
