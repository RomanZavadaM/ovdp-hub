import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/security/vault_device_key_store_secure.dart';
import 'package:ovdp_hub/security/vault_device_key_store_windows.dart';
import 'package:path/path.dart' as p;

class FakeDpapiProtector implements DpapiProtector {
  bool failUnprotect = false;
  int unprotectCalls = 0;
  int? failOnUnprotectCall;

  @override
  Uint8List protect(Uint8List plainText) =>
      Uint8List.fromList(plainText.reversed.toList());

  @override
  Uint8List unprotect(Uint8List cipherText) {
    unprotectCalls++;
    if (failUnprotect || unprotectCalls == failOnUnprotectCall) {
      throw StateError('vault.dpapi_unprotect_failed');
    }
    return Uint8List.fromList(cipherText.reversed.toList());
  }
}

void main() {
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('secure-storage options freeze non-destructive Android semantics', () {
    final android =
        FlutterSecureStorageVaultDeviceKeyStore.androidOptions.params;
    expect(android['resetOnError'], 'false');
    expect(android['migrateOnAlgorithmChange'], 'false');
    expect(android['migrateWithBackup'], 'false');
    expect(android['storageNamespace'], 'ovdp_hub_vault_v1');
    expect(
      android['keyCipherAlgorithm'],
      'RSA_ECB_OAEPwithSHA_256andMGF1Padding',
    );
    expect(android['storageCipherAlgorithm'], 'AES_GCM_NoPadding');
  });

  test('Apple options are non-synchronizing and device-only', () {
    final ios = FlutterSecureStorageVaultDeviceKeyStore.iosOptions.params;
    final mac = FlutterSecureStorageVaultDeviceKeyStore.macOsOptions.params;

    expect(ios['accessibility'], 'unlocked_this_device');
    expect(ios['synchronizable'], 'false');
    expect(ios['useSecureEnclave'], 'false');

    expect(mac['accessibility'], 'unlocked_this_device');
    expect(mac['synchronizable'], 'false');
    expect(mac['usesDataProtectionKeychain'], 'true');
    expect(mac['useSecureEnclave'], 'false');
  });

  test('Android secure-storage adapter preserves key and monotonic revision', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    FlutterSecureStorage.setMockInitialValues({});
    const store = FlutterSecureStorageVaultDeviceKeyStore();
    final dek = Uint8List.fromList(List<int>.generate(32, (i) => i));

    await store.storeDek(vaultId: 'vault-android', dek: dek);
    expect(await store.loadDek(vaultId: 'vault-android'), dek);
    await expectLater(
      store.storeDek(vaultId: 'vault-android', dek: dek),
      throwsStateError,
    );

    await store.storeHighestAcceptedRevision(
      vaultId: 'vault-android',
      revision: 7,
    );
    expect(
      await store.loadHighestAcceptedRevision(vaultId: 'vault-android'),
      7,
    );
    await expectLater(
      store.storeHighestAcceptedRevision(
        vaultId: 'vault-android',
        revision: 6,
      ),
      throwsStateError,
    );

    await store.deleteDek(vaultId: 'vault-android');
    expect(await store.loadDek(vaultId: 'vault-android'), isNull);
    expect(
      await store.loadHighestAcceptedRevision(vaultId: 'vault-android'),
      isNull,
    );
  });

  test('Windows failed committed write restores previous known-good record', () async {
    final root = await Directory.systemTemp.createTemp('ovdp-dpapi-rollback-');
    addTearDown(() => root.delete(recursive: true));
    final protector = FakeDpapiProtector();
    final store = WindowsVaultDeviceKeyStore(
      directory: root,
      protector: protector,
    );
    final dek = Uint8List.fromList(List<int>.filled(32, 17));

    await store.storeDek(vaultId: 'vault-rollback', dek: dek);
    final protectedFile = File(
      p.join(root.path, 'vault-rollback.device.dpapi'),
    );
    final before = await protectedFile.readAsBytes();

    protector.unprotectCalls = 0;
    protector.failOnUnprotectCall = 2;
    await expectLater(
      store.storeHighestAcceptedRevision(
        vaultId: 'vault-rollback',
        revision: 3,
      ),
      throwsStateError,
    );

    expect(await protectedFile.readAsBytes(), before);
    protector.failOnUnprotectCall = null;
    expect(
      await store.loadHighestAcceptedRevision(vaultId: 'vault-rollback'),
      0,
    );
    expect(await store.loadDek(vaultId: 'vault-rollback'), dek);
  });

  test('Windows protected record survives decrypt failure without deletion', () async {
    final root = await Directory.systemTemp.createTemp('ovdp-dpapi-');
    addTearDown(() => root.delete(recursive: true));
    final protector = FakeDpapiProtector();
    final store = WindowsVaultDeviceKeyStore(
      directory: root,
      protector: protector,
    );
    final dek = Uint8List.fromList(List<int>.filled(32, 42));

    await store.storeDek(vaultId: 'vault-win', dek: dek);
    await store.storeHighestAcceptedRevision(
      vaultId: 'vault-win',
      revision: 5,
    );

    final protectedFile = File(p.join(root.path, 'vault-win.device.dpapi'));
    expect(await protectedFile.exists(), true);
    final before = await protectedFile.readAsBytes();

    protector.failUnprotect = true;
    await expectLater(
      store.loadDek(vaultId: 'vault-win'),
      throwsStateError,
    );
    expect(await protectedFile.exists(), true);
    expect(await protectedFile.readAsBytes(), before);

    protector.failUnprotect = false;
    expect(await store.loadDek(vaultId: 'vault-win'), dek);
    expect(
      await store.loadHighestAcceptedRevision(vaultId: 'vault-win'),
      5,
    );
    await expectLater(
      store.storeHighestAcceptedRevision(
        vaultId: 'vault-win',
        revision: 4,
      ),
      throwsStateError,
    );
  });
}
