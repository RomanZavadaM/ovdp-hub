import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/security/vault_crypto.dart';
import 'package:ovdp_hub/security/vault_device_key_store.dart';
import 'package:ovdp_hub/security/vault_store.dart';
import 'package:path/path.dart' as p;

class MemoryVaultDeviceKeyStore implements VaultDeviceKeyStore {
  final Map<String, Uint8List> keys = {};
  final Map<String, int> revisions = {};

  @override
  Future<void> storeDek({
    required String vaultId,
    required Uint8List dek,
  }) async {
    if (keys.containsKey(vaultId)) {
      throw StateError('vault.device_key_exists');
    }
    validateDekBytes(dek);
    keys[vaultId] = Uint8List.fromList(dek);
  }

  @override
  Future<Uint8List?> loadDek({required String vaultId}) async {
    final value = keys[vaultId];
    return value == null ? null : Uint8List.fromList(value);
  }

  @override
  Future<void> deleteDek({required String vaultId}) async {
    keys.remove(vaultId);
    revisions.remove(vaultId);
  }

  @override
  Future<int?> loadHighestAcceptedRevision({required String vaultId}) async =>
      revisions[vaultId];

  @override
  Future<void> storeHighestAcceptedRevision({
    required String vaultId,
    required int revision,
  }) async {
    validateRevision(revision);
    final previous = revisions[vaultId];
    if (previous != null && revision < previous) {
      throw StateError('vault.revision_regression');
    }
    revisions[vaultId] = revision;
  }
}

Uint8List bytes(String text) => Uint8List.fromList(text.codeUnits);

void main() {
  late Directory root;
  late SodiumVaultCrypto crypto;

  setUpAll(() async {
    crypto = await SodiumVaultCrypto.create();
  });

  setUp(() async {
    root = await Directory.systemTemp.createTemp('ovdp-vault-store-');
  });

  tearDown(() async {
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
  });

  test('recovery slot unwraps the original DEK and rejects wrong secret', () {
    final dek = crypto.generateDek();
    addTearDown(dek.dispose);
    final slot = crypto.wrapDekForRecovery(
      vaultId: 'recovery-1',
      dek: dek,
      recoverySecret: 'a long recovery secret',
      parameters: VaultRecoveryKdfParameters.interactive,
    );

    final restored = crypto.unwrapDekFromRecovery(
      slot: VaultRecoverySlotV1.fromJson(slot.toJson()),
      recoverySecret: 'a long recovery secret',
    );
    addTearDown(restored.dispose);
    expect(restored, dek);

    expect(
      () => crypto.unwrapDekFromRecovery(
        slot: slot,
        recoverySecret: 'wrong secret',
      ),
      throwsFormatException,
    );

    final tampered = Map<String, dynamic>.from(slot.toJson())
      ..['vaultId'] = 'other-vault';
    final parsedTampered = VaultRecoverySlotV1.fromJson(tampered);
    expect(
      () => crypto.unwrapDekFromRecovery(
        slot: parsedTampered,
        recoverySecret: 'a long recovery secret',
      ),
      throwsFormatException,
    );
  });

  test('create open and save keep encrypted file and monotonic revisions', () async {
    final device = MemoryVaultDeviceKeyStore();
    final store = LocalVaultStore(
      directory: Directory(p.join(root.path, 'active')),
      crypto: crypto,
      deviceKeyStore: device,
    );

    final created = await store.create(
      vaultId: 'vault-main',
      plainText: bytes('first'),
      recoverySecret: 'portable recovery secret',
      recoveryParameters: VaultRecoveryKdfParameters.interactive,
    );
    expect(created.revision, 1);
    expect(created.recoveryEnabled, true);
    expect(await store.fileFor('vault-main').readAsString(), isNot(contains('first')));

    final opened = await store.open(vaultId: 'vault-main');
    expect(String.fromCharCodes(opened.plainText), 'first');

    final saved = await store.save(
      vaultId: 'vault-main',
      plainText: bytes('second'),
    );
    expect(saved.revision, 2);
    expect(device.revisions['vault-main'], 2);
    expect(String.fromCharCodes((await store.open(vaultId: 'vault-main')).plainText), 'second');
  });

  test('failed post-replace validation restores previous known-good vault', () async {
    final device = MemoryVaultDeviceKeyStore();
    var failAfterReplace = false;
    final store = LocalVaultStore(
      directory: Directory(p.join(root.path, 'active')),
      crypto: crypto,
      deviceKeyStore: device,
      afterReplaceBeforeValidation: (_) {
        if (failAfterReplace) {
          throw StateError('test.injected_commit_failure');
        }
      },
    );

    await store.create(
      vaultId: 'vault-atomic',
      plainText: bytes('known-good'),
      recoverySecret: 'recovery secret long enough',
      recoveryParameters: VaultRecoveryKdfParameters.interactive,
    );
    failAfterReplace = true;

    await expectLater(
      store.save(
        vaultId: 'vault-atomic',
        plainText: bytes('must-not-commit'),
      ),
      throwsStateError,
    );
    failAfterReplace = false;

    final opened = await store.open(vaultId: 'vault-atomic');
    expect(opened.revision, 1);
    expect(String.fromCharCodes(opened.plainText), 'known-good');
    expect(device.revisions['vault-atomic'], 1);
  });

  test('lower local revision is rejected as rollback after newer revision accepted', () async {
    final device = MemoryVaultDeviceKeyStore();
    final store = LocalVaultStore(
      directory: Directory(p.join(root.path, 'active')),
      crypto: crypto,
      deviceKeyStore: device,
    );

    await store.create(
      vaultId: 'vault-rollback',
      plainText: bytes('r1'),
      recoverySecret: 'rollback recovery secret',
      recoveryParameters: VaultRecoveryKdfParameters.interactive,
    );
    final r1 = await store.fileFor('vault-rollback').readAsBytes();

    await store.save(
      vaultId: 'vault-rollback',
      plainText: bytes('r2'),
    );
    expect(device.revisions['vault-rollback'], 2);

    await store.fileFor('vault-rollback').writeAsBytes(r1, flush: true);
    await expectLater(
      store.open(vaultId: 'vault-rollback'),
      throwsA(
        isA<VaultRollbackException>()
            .having((e) => e.foundRevision, 'foundRevision', 1)
            .having((e) => e.highestAcceptedRevision, 'highest', 2),
      ),
    );
  });

  test('portable encrypted backup restores on fresh device key store', () async {
    final sourceDevice = MemoryVaultDeviceKeyStore();
    final sourceStore = LocalVaultStore(
      directory: Directory(p.join(root.path, 'source')),
      crypto: crypto,
      deviceKeyStore: sourceDevice,
    );
    await sourceStore.create(
      vaultId: 'vault-portable',
      plainText: bytes('portable private bytes'),
      recoverySecret: 'portable recovery secret',
      recoveryParameters: VaultRecoveryKdfParameters.interactive,
    );
    await sourceStore.save(
      vaultId: 'vault-portable',
      plainText: bytes('portable private bytes v2'),
    );

    final backup = File(p.join(root.path, 'backup', 'portable.ovdp-vault.json'));
    await sourceStore.createEncryptedBackup(
      vaultId: 'vault-portable',
      destination: backup,
    );
    expect(await backup.exists(), true);

    final freshDevice = MemoryVaultDeviceKeyStore();
    final freshStore = LocalVaultStore(
      directory: Directory(p.join(root.path, 'fresh')),
      crypto: crypto,
      deviceKeyStore: freshDevice,
    );
    final restored = await freshStore.restoreEncryptedBackup(
      vaultId: 'vault-portable',
      source: backup,
      recoverySecret: 'portable recovery secret',
    );
    expect(restored.revision, 2);
    expect(String.fromCharCodes(restored.plainText), 'portable private bytes v2');
    expect(freshDevice.keys['vault-portable'], isNotNull);
    expect(freshDevice.revisions['vault-portable'], 2);

    final reopened = await freshStore.open(vaultId: 'vault-portable');
    expect(String.fromCharCodes(reopened.plainText), 'portable private bytes v2');
  });

  test('wrong or corrupt backup never replaces current vault', () async {
    final device = MemoryVaultDeviceKeyStore();
    final store = LocalVaultStore(
      directory: Directory(p.join(root.path, 'active')),
      crypto: crypto,
      deviceKeyStore: device,
    );
    await store.create(
      vaultId: 'vault-restore-guard',
      plainText: bytes('current'),
      recoverySecret: 'restore guard secret',
      recoveryParameters: VaultRecoveryKdfParameters.interactive,
    );

    final corrupt = File(p.join(root.path, 'corrupt.ovdp-vault.json'));
    await corrupt.writeAsString('{"broken":true}', flush: true);

    await expectLater(
      store.restoreEncryptedBackup(
        vaultId: 'vault-restore-guard',
        source: corrupt,
        recoverySecret: 'restore guard secret',
      ),
      throwsFormatException,
    );
    expect(
      String.fromCharCodes(
        (await store.open(vaultId: 'vault-restore-guard')).plainText,
      ),
      'current',
    );

    final backup = File(p.join(root.path, 'backup.ovdp-vault.json'));
    await store.createEncryptedBackup(
      vaultId: 'vault-restore-guard',
      destination: backup,
    );
    await expectLater(
      store.restoreEncryptedBackup(
        vaultId: 'vault-restore-guard',
        source: backup,
        recoverySecret: 'wrong secret',
      ),
      throwsFormatException,
    );
    expect(
      String.fromCharCodes(
        (await store.open(vaultId: 'vault-restore-guard')).plainText,
      ),
      'current',
    );
  });

  test('portable backup is refused until recovery is configured', () async {
    final device = MemoryVaultDeviceKeyStore();
    final store = LocalVaultStore(
      directory: Directory(p.join(root.path, 'active')),
      crypto: crypto,
      deviceKeyStore: device,
    );
    await store.create(
      vaultId: 'vault-no-recovery',
      plainText: bytes('private'),
    );

    await expectLater(
      store.createEncryptedBackup(
        vaultId: 'vault-no-recovery',
        destination: File(p.join(root.path, 'backup.json')),
      ),
      throwsStateError,
    );
  });
}
