import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import 'vault_crypto.dart';
import 'vault_device_key_store_secure.dart';
import 'vault_session.dart';
import 'vault_store.dart';

bool _sameBytes(Uint8List left, Uint8List right) {
  if (left.length != right.length) return false;
  for (var i = 0; i < left.length; i++) {
    if (left[i] != right[i]) return false;
  }
  return true;
}

void _require(bool condition, String code) {
  if (!condition) throw StateError(code);
}

Future<void> _writeReport(File file, Map<String, Object?> report) async {
  await file.parent.create(recursive: true);
  await file.writeAsString(jsonEncode(report), flush: true);
}

/// Real packaged-app macOS smoke for the Keychain-backed vault foundation.
///
/// This must never be treated as a unit-test substitute: it is called from the
/// packaged macOS executable so flutter_secure_storage reaches the real Keychain
/// plugin. The unique vault id keeps the test isolated; the finally block removes
/// only keys/files created by this run.
Future<int> runMacOsVaultRuntimeSmoke(File reportFile) async {
  final report = <String, Object?>{
    'platform': Platform.operatingSystem,
    'success': false,
    'keychainRoundTrip': false,
    'sessionLockReopen': false,
    'backupRestore': false,
    'recoveryRotation': false,
    'cleanup': false,
  };

  if (!Platform.isMacOS) {
    report['error'] = 'vault.macos_runtime_smoke_wrong_platform';
    await _writeReport(reportFile, report);
    return 2;
  }

  final root = await Directory.systemTemp.createTemp(
    'ovdp-macos-keychain-smoke-',
  );
  final vaultId =
      'macos-smoke-$pid-${DateTime.now().microsecondsSinceEpoch}';
  const firstRecoverySecret = 'OVDP macOS runtime smoke recovery secret A';
  const secondRecoverySecret = 'OVDP macOS runtime smoke recovery secret B';
  final initialPayload = Uint8List.fromList(
    utf8.encode('OVDP macOS Keychain runtime payload v1'),
  );
  final updatedPayload = Uint8List.fromList(
    utf8.encode('OVDP macOS Keychain runtime payload v2'),
  );
  const deviceKeyStore = FlutterSecureStorageVaultDeviceKeyStore();
  final crypto = await SodiumVaultCrypto.create();
  final store = LocalVaultStore(
    directory: Directory(p.join(root.path, 'vault')),
    crypto: crypto,
    deviceKeyStore: deviceKeyStore,
  );
  VaultSessionController? session;

  try {
    final created = await store.create(
      vaultId: vaultId,
      plainText: initialPayload,
      recoverySecret: firstRecoverySecret,
      recoveryParameters: VaultRecoveryKdfParameters.interactive,
    );
    _require(created.revision == 1, 'vault.macos_smoke_create_revision');
    _require(
      _sameBytes(created.plainText, initialPayload),
      'vault.macos_smoke_create_payload',
    );
    created.plainText.fillRange(0, created.plainText.length, 0);

    final storedDek = await deviceKeyStore.loadDek(vaultId: vaultId);
    _require(storedDek != null, 'vault.macos_smoke_keychain_missing_dek');
    storedDek!.fillRange(0, storedDek.length, 0);
    _require(
      await deviceKeyStore.loadHighestAcceptedRevision(vaultId: vaultId) == 1,
      'vault.macos_smoke_keychain_missing_revision',
    );
    report['keychainRoundTrip'] = true;

    session = VaultSessionController(
      store: store,
      policy: VaultSessionPolicy(
        inactivityTimeout: const Duration(hours: 1),
        backgroundGrace: const Duration(minutes: 5),
      ),
    );
    await session.unlock(vaultId: vaultId);
    _require(session.state.isUnlocked, 'vault.macos_smoke_unlock_failed');
    var plain = session.readPlainTextCopy();
    _require(
      _sameBytes(plain, initialPayload),
      'vault.macos_smoke_open_payload',
    );
    plain.fillRange(0, plain.length, 0);

    await session.lock();
    _require(!session.state.isUnlocked, 'vault.macos_smoke_lock_failed');
    await session.unlock(vaultId: vaultId);
    _require(session.state.isUnlocked, 'vault.macos_smoke_reopen_failed');
    plain = session.readPlainTextCopy();
    _require(
      _sameBytes(plain, initialPayload),
      'vault.macos_smoke_reopen_payload',
    );
    plain.fillRange(0, plain.length, 0);

    await session.save(updatedPayload);
    _require(session.state.revision == 2, 'vault.macos_smoke_save_revision');
    await session.lock();
    session.dispose();
    session = null;
    report['sessionLockReopen'] = true;

    final firstBackup = File(p.join(root.path, 'backup-a.ovdp-vault.json'));
    await store.createEncryptedBackup(
      vaultId: vaultId,
      destination: firstBackup,
    );
    _require(await firstBackup.exists(), 'vault.macos_smoke_backup_missing');

    await store.deleteLocalVault(vaultId: vaultId);
    _require(
      !await store.fileFor(vaultId).exists(),
      'vault.macos_smoke_delete_file_failed',
    );
    final deletedDek = await deviceKeyStore.loadDek(vaultId: vaultId);
    _require(deletedDek == null, 'vault.macos_smoke_delete_key_failed');

    final restored = await store.restoreEncryptedBackup(
      vaultId: vaultId,
      source: firstBackup,
      recoverySecret: firstRecoverySecret,
    );
    _require(
      _sameBytes(restored.plainText, updatedPayload),
      'vault.macos_smoke_restore_payload',
    );
    restored.plainText.fillRange(0, restored.plainText.length, 0);
    final restoredDek = await deviceKeyStore.loadDek(vaultId: vaultId);
    _require(restoredDek != null, 'vault.macos_smoke_restore_key_missing');
    restoredDek!.fillRange(0, restoredDek.length, 0);
    report['backupRestore'] = true;

    await store.rotateRecovery(
      vaultId: vaultId,
      recoverySecret: secondRecoverySecret,
      recoveryParameters: VaultRecoveryKdfParameters.interactive,
    );
    final secondBackup = File(p.join(root.path, 'backup-b.ovdp-vault.json'));
    await store.createEncryptedBackup(
      vaultId: vaultId,
      destination: secondBackup,
    );
    await store.deleteLocalVault(vaultId: vaultId);

    var oldSecretRejected = false;
    try {
      final unexpected = await store.restoreEncryptedBackup(
        vaultId: vaultId,
        source: secondBackup,
        recoverySecret: firstRecoverySecret,
      );
      unexpected.plainText.fillRange(0, unexpected.plainText.length, 0);
    } on FormatException {
      oldSecretRejected = true;
    }
    _require(
      oldSecretRejected,
      'vault.macos_smoke_old_recovery_secret_accepted',
    );
    _require(
      await deviceKeyStore.loadDek(vaultId: vaultId) == null,
      'vault.macos_smoke_failed_restore_changed_keychain',
    );

    final rotatedRestore = await store.restoreEncryptedBackup(
      vaultId: vaultId,
      source: secondBackup,
      recoverySecret: secondRecoverySecret,
    );
    _require(
      _sameBytes(rotatedRestore.plainText, updatedPayload),
      'vault.macos_smoke_rotated_restore_payload',
    );
    rotatedRestore.plainText.fillRange(
      0,
      rotatedRestore.plainText.length,
      0,
    );
    final reopened = await store.open(vaultId: vaultId);
    _require(
      _sameBytes(reopened.plainText, updatedPayload),
      'vault.macos_smoke_final_reopen_payload',
    );
    reopened.plainText.fillRange(0, reopened.plainText.length, 0);
    report['recoveryRotation'] = true;

    await store.deleteLocalVault(vaultId: vaultId);
    _require(
      await deviceKeyStore.loadDek(vaultId: vaultId) == null,
      'vault.macos_smoke_final_key_cleanup',
    );
    _require(
      await deviceKeyStore.loadHighestAcceptedRevision(vaultId: vaultId) ==
          null,
      'vault.macos_smoke_final_revision_cleanup',
    );
    report['cleanup'] = true;
    report['success'] = true;
    report['vaultId'] = vaultId;
    await _writeReport(reportFile, report);
    return 0;
  } catch (error, stackTrace) {
    report['error'] = error.toString();
    report['stackTrace'] = stackTrace.toString();
    await _writeReport(reportFile, report);
    return 1;
  } finally {
    session?.dispose();
    initialPayload.fillRange(0, initialPayload.length, 0);
    updatedPayload.fillRange(0, updatedPayload.length, 0);
    try {
      await deviceKeyStore.deleteDek(vaultId: vaultId);
    } catch (_) {
      // Best-effort cleanup for this unique smoke id only.
    }
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
  }
}
