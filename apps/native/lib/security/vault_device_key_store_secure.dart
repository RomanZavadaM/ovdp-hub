import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'vault_device_key_store.dart';

class FlutterSecureStorageVaultDeviceKeyStore implements VaultDeviceKeyStore {
  static const AndroidOptions androidOptions = AndroidOptions(
    resetOnError: false,
    migrateOnAlgorithmChange: false,
    migrateWithBackup: false,
    keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
    storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    storageNamespace: 'ovdp_hub_vault_v1',
  );

  static const IOSOptions iosOptions = IOSOptions(
    accountName: 'ua.ovdphub.vault',
    accessibility: KeychainAccessibility.unlocked_this_device,
    synchronizable: false,
    useSecureEnclave: false,
  );

  static const MacOsOptions macOsOptions = MacOsOptions(
    accountName: 'ua.ovdphub.vault',
    accessibility: KeychainAccessibility.unlocked_this_device,
    synchronizable: false,
    usesDataProtectionKeychain: true,
    useSecureEnclave: false,
  );

  final FlutterSecureStorage storage;

  const FlutterSecureStorageVaultDeviceKeyStore({
    this.storage = const FlutterSecureStorage(),
  });

  void _ensureSupported() {
    if (kIsWeb ||
        !const {
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        }.contains(defaultTargetPlatform)) {
      throw UnsupportedError('vault.device_store_unsupported');
    }
  }

  Future<void> _write(String key, String? value) {
    _ensureSupported();
    return storage.write(
      key: key,
      value: value,
      aOptions: androidOptions,
      iOptions: iosOptions,
      mOptions: macOsOptions,
    );
  }

  Future<String?> _read(String key) {
    _ensureSupported();
    return storage.read(
      key: key,
      aOptions: androidOptions,
      iOptions: iosOptions,
      mOptions: macOsOptions,
    );
  }

  @override
  Future<void> storeDek({
    required String vaultId,
    required Uint8List dek,
  }) async {
    validateDekBytes(dek);
    final key = vaultStorageKey(vaultId, 'dek');
    if (await _read(key) != null) {
      throw StateError('vault.device_key_exists');
    }
    await _write(key, base64UrlEncode(dek));
  }

  @override
  Future<Uint8List?> loadDek({required String vaultId}) async {
    final value = await _read(vaultStorageKey(vaultId, 'dek'));
    if (value == null) return null;
    try {
      final bytes = Uint8List.fromList(base64Url.decode(value));
      validateDekBytes(bytes);
      return bytes;
    } on FormatException {
      throw const FormatException('vault.invalid_device_key');
    }
  }

  @override
  Future<void> deleteDek({required String vaultId}) =>
      _write(vaultStorageKey(vaultId, 'dek'), null);

  @override
  Future<int?> loadHighestAcceptedRevision({required String vaultId}) async {
    final value = await _read(vaultStorageKey(vaultId, 'revision'));
    if (value == null) return null;
    return parseStoredRevision(value);
  }

  @override
  Future<void> storeHighestAcceptedRevision({
    required String vaultId,
    required int revision,
  }) async {
    validateRevision(revision);
    final key = vaultStorageKey(vaultId, 'revision');
    final previous = await _read(key);
    if (previous != null && revision < parseStoredRevision(previous)) {
      throw StateError('vault.revision_regression');
    }
    await _write(key, '$revision');
  }
}
