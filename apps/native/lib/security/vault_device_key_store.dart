import 'dart:typed_data';

import 'vault_crypto.dart';

abstract interface class VaultDeviceKeyStore {
  Future<void> storeDek({
    required String vaultId,
    required Uint8List dek,
  });

  Future<Uint8List?> loadDek({required String vaultId});

  Future<void> deleteDek({required String vaultId});

  Future<int?> loadHighestAcceptedRevision({required String vaultId});

  Future<void> storeHighestAcceptedRevision({
    required String vaultId,
    required int revision,
  });
}

void validateDekBytes(Uint8List dek) {
  if (dek.length != 32) {
    throw const FormatException('vault.invalid_device_key');
  }
}

int parseStoredRevision(String? value) {
  if (value == null) return -1;
  final parsed = int.tryParse(value);
  if (parsed == null || parsed < 0) {
    throw const FormatException('vault.invalid_revision_state');
  }
  return parsed;
}

void validateRevision(int revision) {
  if (revision < 0) {
    throw const FormatException('vault.invalid_revision_state');
  }
}

String vaultStorageKey(String vaultId, String suffix) {
  validateVaultId(vaultId);
  return 'ovdp.vault.v1.$vaultId.$suffix';
}
