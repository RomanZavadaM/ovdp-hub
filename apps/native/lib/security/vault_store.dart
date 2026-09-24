import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:sodium/sodium.dart';

import 'vault_crypto.dart';
import 'vault_device_key_store.dart';

const String vaultFileMagic = 'OVDP-HUB-VAULT-FILE';
const int vaultFileVersion = 1;

String? _recoveryBinding(VaultRecoverySlotV1? slot) =>
    slot == null ? null : jsonEncode(slot.toJson());

class VaultRollbackException implements Exception {
  final String vaultId;
  final int foundRevision;
  final int highestAcceptedRevision;

  const VaultRollbackException({
    required this.vaultId,
    required this.foundRevision,
    required this.highestAcceptedRevision,
  });

  @override
  String toString() =>
      'VaultRollbackException($vaultId: $foundRevision < '
      '$highestAcceptedRevision)';
}

class VaultFileV1 {
  final String vaultId;
  final int revision;
  final VaultEnvelopeV1 payload;
  final VaultRecoverySlotV1? recoverySlot;

  VaultFileV1({
    required this.vaultId,
    required this.revision,
    required this.payload,
    required this.recoverySlot,
  }) {
    validateVaultId(vaultId);
    if (revision < 1 ||
        payload.vaultId != vaultId ||
        payload.revision != revision ||
        (recoverySlot != null && recoverySlot!.vaultId != vaultId) ||
        payload.recoverySlotBinding != _recoveryBinding(recoverySlot)) {
      throw const FormatException('vault.invalid_file');
    }
  }

  Map<String, Object?> toJson() => {
    'application': vaultFileMagic,
    'fileVersion': vaultFileVersion,
    'vaultId': vaultId,
    'revision': revision,
    'payload': payload.toJson(),
    'recoverySlot': recoverySlot?.toJson(),
  };

  factory VaultFileV1.fromJson(Map<String, dynamic> json) {
    if (json['application'] != vaultFileMagic ||
        json['fileVersion'] != vaultFileVersion) {
      throw const FormatException('vault.unsupported_file');
    }
    final vaultId = json['vaultId'];
    final revision = json['revision'];
    final payloadJson = json['payload'];
    final recoveryJson = json['recoverySlot'];
    if (vaultId is! String || revision is! int || payloadJson is! Map) {
      throw const FormatException('vault.invalid_file');
    }
    return VaultFileV1(
      vaultId: vaultId,
      revision: revision,
      payload: VaultEnvelopeV1.fromJson(
        Map<String, dynamic>.from(payloadJson),
      ),
      recoverySlot: recoveryJson == null
          ? null
          : recoveryJson is Map
          ? VaultRecoverySlotV1.fromJson(
              Map<String, dynamic>.from(recoveryJson),
            )
          : throw const FormatException('vault.invalid_file'),
    );
  }
}

class VaultOpenResult {
  final String vaultId;
  final int revision;
  final Uint8List plainText;
  final bool recoveryEnabled;

  VaultOpenResult({
    required this.vaultId,
    required this.revision,
    required Uint8List plainText,
    required this.recoveryEnabled,
  }) : plainText = Uint8List.fromList(plainText);
}

class VaultLifecycleResult {
  final String vaultId;
  final int revision;
  final bool recoveryEnabled;

  const VaultLifecycleResult({
    required this.vaultId,
    required this.revision,
    required this.recoveryEnabled,
  });
}

abstract interface class VaultContentStore {
  Future<VaultOpenResult> open({required String vaultId});

  Future<VaultOpenResult> save({
    required String vaultId,
    required Uint8List plainText,
  });
}

abstract interface class VaultLifecycleStore implements VaultContentStore {
  Future<VaultLifecycleResult> enableRecovery({
    required String vaultId,
    required String recoverySecret,
    VaultRecoveryKdfParameters recoveryParameters,
  });

  Future<VaultLifecycleResult> rotateRecovery({
    required String vaultId,
    required String recoverySecret,
    VaultRecoveryKdfParameters recoveryParameters,
  });

  Future<VaultLifecycleResult> removeRecovery({
    required String vaultId,
  });

  Future<void> deleteLocalVault({required String vaultId});
}

enum _RecoveryChange { enable, rotate, remove }

typedef VaultCommitProbe = FutureOr<void> Function(File committedFile);
typedef VaultDeleteProbe = FutureOr<void> Function(File stagedForDeletion);

class LocalVaultStore implements VaultLifecycleStore {
  final Directory directory;
  final VaultCrypto crypto;
  final VaultDeviceKeyStore deviceKeyStore;
  final VaultCommitProbe? afterReplaceBeforeValidation;
  final VaultDeleteProbe? afterDeviceKeyDeleteBeforeFileDelete;

  LocalVaultStore({
    required this.directory,
    required this.crypto,
    required this.deviceKeyStore,
    this.afterReplaceBeforeValidation,
    this.afterDeviceKeyDeleteBeforeFileDelete,
  });

  File fileFor(String vaultId) {
    validateVaultId(vaultId);
    return File(p.join(directory.path, '$vaultId.ovdp-vault.json'));
  }

  File _pending(String vaultId) => File('${fileFor(vaultId).path}.pending');
  File _backup(String vaultId) => File('${fileFor(vaultId).path}.backup');
  File _deleting(String vaultId) => File('${fileFor(vaultId).path}.deleting');

  Future<VaultOpenResult> create({
    required String vaultId,
    required Uint8List plainText,
    String? recoverySecret,
    VaultRecoveryKdfParameters recoveryParameters =
        VaultRecoveryKdfParameters.moderate,
  }) async {
    validateVaultId(vaultId);
    await directory.create(recursive: true);
    await _recoverInterruptedReplace(vaultId);
    if (await _deleting(vaultId).exists()) {
      throw StateError('vault.deletion_pending');
    }
    if (await fileFor(vaultId).exists()) {
      throw StateError('vault.already_exists');
    }
    if (await deviceKeyStore.loadDek(vaultId: vaultId) != null) {
      throw StateError('vault.device_key_exists');
    }

    final dek = crypto.generateDek();
    var deviceKeyStored = false;
    var fileCommitted = false;
    try {
      VaultRecoverySlotV1? recoverySlot;
      if (recoverySecret != null) {
        recoverySlot = crypto.wrapDekForRecovery(
          vaultId: vaultId,
          dek: dek,
          recoverySecret: recoverySecret,
          parameters: recoveryParameters,
        );
      }
      final payload = crypto.encrypt(
        vaultId: vaultId,
        revision: 1,
        plainText: plainText,
        dek: dek,
        recoverySlotBinding: _recoveryBinding(recoverySlot),
      );
      final vaultFile = VaultFileV1(
        vaultId: vaultId,
        revision: 1,
        payload: payload,
        recoverySlot: recoverySlot,
      );

      await _storeDeviceDek(vaultId, dek);
      deviceKeyStored = true;
      await _commitVaultFile(vaultFile, dek);
      fileCommitted = true;
      await deviceKeyStore.storeHighestAcceptedRevision(
        vaultId: vaultId,
        revision: 1,
      );
      return VaultOpenResult(
        vaultId: vaultId,
        revision: 1,
        plainText: plainText,
        recoveryEnabled: recoverySlot != null,
      );
    } catch (_) {
      if (deviceKeyStored && !fileCommitted) {
        await deviceKeyStore.deleteDek(vaultId: vaultId);
      }
      rethrow;
    } finally {
      dek.dispose();
    }
  }

  @override
  Future<VaultOpenResult> open({required String vaultId}) async {
    final rawDek = await deviceKeyStore.loadDek(vaultId: vaultId);
    if (rawDek == null) {
      throw StateError('vault.device_key_missing');
    }
    final dek = _secureKeyFromRaw(rawDek);
    rawDek.fillRange(0, rawDek.length, 0);
    try {
      final vaultFile = await _readValidatedCurrent(vaultId, dek);
      await _acceptRevision(vaultFile);
      await _cleanupArtifacts(vaultId);
      final plainText = crypto.decrypt(
        envelope: vaultFile.payload,
        dek: dek,
      );
      return VaultOpenResult(
        vaultId: vaultId,
        revision: vaultFile.revision,
        plainText: plainText,
        recoveryEnabled: vaultFile.recoverySlot != null,
      );
    } finally {
      dek.dispose();
    }
  }

  @override
  Future<VaultOpenResult> save({
    required String vaultId,
    required Uint8List plainText,
  }) async {
    final rawDek = await deviceKeyStore.loadDek(vaultId: vaultId);
    if (rawDek == null) {
      throw StateError('vault.device_key_missing');
    }
    final dek = _secureKeyFromRaw(rawDek);
    rawDek.fillRange(0, rawDek.length, 0);
    try {
      final current = await _readValidatedCurrent(vaultId, dek);
      await _assertNotRollback(current);
      await _cleanupArtifacts(vaultId);
      final nextRevision = current.revision + 1;
      final next = VaultFileV1(
        vaultId: vaultId,
        revision: nextRevision,
        payload: crypto.encrypt(
          vaultId: vaultId,
          revision: nextRevision,
          plainText: plainText,
          dek: dek,
          recoverySlotBinding: _recoveryBinding(current.recoverySlot),
        ),
        recoverySlot: current.recoverySlot,
      );
      await _commitVaultFile(next, dek);
      await deviceKeyStore.storeHighestAcceptedRevision(
        vaultId: vaultId,
        revision: nextRevision,
      );
      return VaultOpenResult(
        vaultId: vaultId,
        revision: nextRevision,
        plainText: plainText,
        recoveryEnabled: next.recoverySlot != null,
      );
    } finally {
      dek.dispose();
    }
  }

  @override
  Future<VaultLifecycleResult> enableRecovery({
    required String vaultId,
    required String recoverySecret,
    VaultRecoveryKdfParameters recoveryParameters =
        VaultRecoveryKdfParameters.moderate,
  }) =>
      _changeRecovery(
        vaultId: vaultId,
        mode: _RecoveryChange.enable,
        recoverySecret: recoverySecret,
        recoveryParameters: recoveryParameters,
      );

  @override
  Future<VaultLifecycleResult> rotateRecovery({
    required String vaultId,
    required String recoverySecret,
    VaultRecoveryKdfParameters recoveryParameters =
        VaultRecoveryKdfParameters.moderate,
  }) =>
      _changeRecovery(
        vaultId: vaultId,
        mode: _RecoveryChange.rotate,
        recoverySecret: recoverySecret,
        recoveryParameters: recoveryParameters,
      );

  @override
  Future<VaultLifecycleResult> removeRecovery({
    required String vaultId,
  }) =>
      _changeRecovery(
        vaultId: vaultId,
        mode: _RecoveryChange.remove,
      );

  @override
  Future<void> deleteLocalVault({required String vaultId}) async {
    validateVaultId(vaultId);
    await directory.create(recursive: true);

    final target = fileFor(vaultId);
    final deleting = _deleting(vaultId);
    final rawDek = await deviceKeyStore.loadDek(vaultId: vaultId);

    if (rawDek == null) {
      if (await target.exists()) {
        throw StateError('vault.device_key_missing');
      }
      if (await deleting.exists()) {
        await deleting.delete();
      }
      await _cleanupArtifacts(vaultId);
      return;
    }

    final dek = _secureKeyFromRaw(rawDek);
    try {
      final current = await _readValidatedCurrent(vaultId, dek);
      await _assertNotRollback(current);
      await _cleanupArtifacts(vaultId);

      if (await deleting.exists()) {
        throw StateError('vault.deletion_pending');
      }
      await target.rename(deleting.path);

      try {
        await deviceKeyStore.deleteDek(vaultId: vaultId);
        await afterDeviceKeyDeleteBeforeFileDelete?.call(deleting);
        await deleting.delete();
      } catch (_) {
        await _restoreDeleteFailure(
          vaultId: vaultId,
          rawDek: rawDek,
          revision: current.revision,
        );
        rethrow;
      }
    } finally {
      rawDek.fillRange(0, rawDek.length, 0);
      dek.dispose();
    }
  }

  Future<File> createEncryptedBackup({
    required String vaultId,
    required File destination,
  }) async {
    final rawDek = await deviceKeyStore.loadDek(vaultId: vaultId);
    if (rawDek == null) {
      throw StateError('vault.device_key_missing');
    }
    final dek = _secureKeyFromRaw(rawDek);
    rawDek.fillRange(0, rawDek.length, 0);
    try {
      final current = await _readValidatedCurrent(vaultId, dek);
      await _assertNotRollback(current);
      await _cleanupArtifacts(vaultId);
      if (current.recoverySlot == null) {
        throw StateError('vault.recovery_not_configured');
      }
      if (_isAppOwnedVaultPath(vaultId, destination)) {
        throw StateError('vault.backup_target_reserved');
      }
      await destination.parent.create(recursive: true);
      await destination.writeAsString(
        jsonEncode(current.toJson()),
        flush: true,
      );
      final written = await _readVaultFile(destination);
      _validateFileIdentity(written, vaultId);
      crypto.decrypt(envelope: written.payload, dek: dek);
      return destination;
    } finally {
      dek.dispose();
    }
  }

  Future<VaultOpenResult> restoreEncryptedBackup({
    required String vaultId,
    required File source,
    required String recoverySecret,
  }) async {
    validateVaultId(vaultId);
    if (_isAppOwnedVaultPath(vaultId, source)) {
      throw StateError('vault.restore_source_reserved');
    }
    final candidate = await _readVaultFile(source);
    _validateFileIdentity(candidate, vaultId);
    final slot = candidate.recoverySlot;
    if (slot == null) {
      throw StateError('vault.recovery_not_configured');
    }

    final recoveredDek = crypto.unwrapDekFromRecovery(
      slot: slot,
      recoverySecret: recoverySecret,
    );
    var storedNewDeviceKey = false;
    try {
      final plainText = crypto.decrypt(
        envelope: candidate.payload,
        dek: recoveredDek,
      );
      await _assertNotRollback(candidate);

      final existingRaw = await deviceKeyStore.loadDek(vaultId: vaultId);
      if (existingRaw != null) {
        final existingDek = _secureKeyFromRaw(existingRaw);
        existingRaw.fillRange(0, existingRaw.length, 0);
        try {
          if (existingDek != recoveredDek) {
            throw StateError('vault.device_key_conflict');
          }
        } finally {
          existingDek.dispose();
        }
      } else {
        if (await fileFor(vaultId).exists()) {
          throw StateError('vault.orphaned_local_vault');
        }
        await _storeDeviceDek(vaultId, recoveredDek);
        storedNewDeviceKey = true;
      }

      await _commitVaultFile(candidate, recoveredDek);
      await deviceKeyStore.storeHighestAcceptedRevision(
        vaultId: vaultId,
        revision: candidate.revision,
      );
      return VaultOpenResult(
        vaultId: vaultId,
        revision: candidate.revision,
        plainText: plainText,
        recoveryEnabled: true,
      );
    } catch (_) {
      if (storedNewDeviceKey && !await fileFor(vaultId).exists()) {
        await deviceKeyStore.deleteDek(vaultId: vaultId);
      }
      rethrow;
    } finally {
      recoveredDek.dispose();
    }
  }

  Future<VaultLifecycleResult> _changeRecovery({
    required String vaultId,
    required _RecoveryChange mode,
    String? recoverySecret,
    VaultRecoveryKdfParameters recoveryParameters =
        VaultRecoveryKdfParameters.moderate,
  }) async {
    final rawDek = await deviceKeyStore.loadDek(vaultId: vaultId);
    if (rawDek == null) {
      throw StateError('vault.device_key_missing');
    }
    final dek = _secureKeyFromRaw(rawDek);
    rawDek.fillRange(0, rawDek.length, 0);
    Uint8List? plainText;
    try {
      final current = await _readValidatedCurrent(vaultId, dek);
      await _assertNotRollback(current);
      await _cleanupArtifacts(vaultId);

      switch (mode) {
        case _RecoveryChange.enable:
          if (current.recoverySlot != null) {
            throw StateError('vault.recovery_already_configured');
          }
        case _RecoveryChange.rotate:
          if (current.recoverySlot == null) {
            throw StateError('vault.recovery_not_configured');
          }
        case _RecoveryChange.remove:
          if (current.recoverySlot == null) {
            throw StateError('vault.recovery_not_configured');
          }
      }

      VaultRecoverySlotV1? nextSlot;
      if (mode != _RecoveryChange.remove) {
        final secret = recoverySecret;
        if (secret == null) {
          throw StateError('vault.recovery_secret_required');
        }
        nextSlot = crypto.wrapDekForRecovery(
          vaultId: vaultId,
          dek: dek,
          recoverySecret: secret,
          parameters: recoveryParameters,
        );
        final verified = crypto.unwrapDekFromRecovery(
          slot: nextSlot,
          recoverySecret: secret,
        );
        try {
          if (verified != dek) {
            throw StateError('vault.recovery_verification_failed');
          }
        } finally {
          verified.dispose();
        }
      }

      plainText = crypto.decrypt(
        envelope: current.payload,
        dek: dek,
      );
      final nextRevision = current.revision + 1;
      final next = VaultFileV1(
        vaultId: vaultId,
        revision: nextRevision,
        payload: crypto.encrypt(
          vaultId: vaultId,
          revision: nextRevision,
          plainText: plainText,
          dek: dek,
          recoverySlotBinding: _recoveryBinding(nextSlot),
        ),
        recoverySlot: nextSlot,
      );
      await _commitVaultFile(next, dek);
      await deviceKeyStore.storeHighestAcceptedRevision(
        vaultId: vaultId,
        revision: nextRevision,
      );
      return VaultLifecycleResult(
        vaultId: vaultId,
        revision: nextRevision,
        recoveryEnabled: nextSlot != null,
      );
    } finally {
      plainText?.fillRange(0, plainText.length, 0);
      dek.dispose();
    }
  }

  Future<void> _restoreDeleteFailure({
    required String vaultId,
    required Uint8List rawDek,
    required int revision,
  }) async {
    final target = fileFor(vaultId);
    final deleting = _deleting(vaultId);
    try {
      final currentKey = await deviceKeyStore.loadDek(vaultId: vaultId);
      if (currentKey == null) {
        await deviceKeyStore.storeDek(
          vaultId: vaultId,
          dek: Uint8List.fromList(rawDek),
        );
        await deviceKeyStore.storeHighestAcceptedRevision(
          vaultId: vaultId,
          revision: revision,
        );
      } else {
        currentKey.fillRange(0, currentKey.length, 0);
      }

      if (await deleting.exists()) {
        if (await target.exists()) {
          await target.delete();
        }
        await deleting.rename(target.path);
      }
    } catch (_) {
      throw StateError('vault.delete_rollback_failed');
    }
  }

  bool _isAppOwnedVaultPath(String vaultId, File file) {
    final candidate = p.normalize(p.absolute(file.path));
    final reserved = [
      fileFor(vaultId),
      _pending(vaultId),
      _backup(vaultId),
      _deleting(vaultId),
    ];
    return reserved.any(
      (item) => p.equals(candidate, p.normalize(p.absolute(item.path))),
    );
  }

  Future<void> _storeDeviceDek(String vaultId, SecureKey dek) async {
    final raw = dek.extractBytes();
    try {
      await deviceKeyStore.storeDek(vaultId: vaultId, dek: raw);
    } finally {
      raw.fillRange(0, raw.length, 0);
    }
  }

  SecureKey _secureKeyFromRaw(Uint8List raw) {
    if (raw.length != crypto.dekBytes) {
      throw const FormatException('vault.invalid_device_key');
    }
    final key = crypto.generateDek();
    key.runUnlockedSync(
      (data) => data.setAll(0, raw),
      writable: true,
    );
    return key;
  }

  Future<void> _recoverInterruptedReplace(String vaultId) async {
    final target = fileFor(vaultId);
    final backup = _backup(vaultId);
    if (!await target.exists() && await backup.exists()) {
      await backup.rename(target.path);
    }
  }

  Future<void> _recoverInterruptedDelete(String vaultId) async {
    final target = fileFor(vaultId);
    final deleting = _deleting(vaultId);
    if (!await target.exists() && await deleting.exists()) {
      await deleting.rename(target.path);
    }
  }

  Future<VaultFileV1> _readValidatedCurrent(
    String vaultId,
    SecureKey dek,
  ) async {
    await _recoverInterruptedDelete(vaultId);
    await _recoverInterruptedReplace(vaultId);
    final target = fileFor(vaultId);
    if (!await target.exists()) {
      throw StateError('vault.file_missing');
    }
    try {
      final vaultFile = await _readVaultFile(target);
      _validateFileIdentity(vaultFile, vaultId);
      crypto.decrypt(envelope: vaultFile.payload, dek: dek);
      return vaultFile;
    } catch (_) {
      final backup = _backup(vaultId);
      if (!await backup.exists()) rethrow;
      final knownGood = await _readVaultFile(backup);
      _validateFileIdentity(knownGood, vaultId);
      crypto.decrypt(envelope: knownGood.payload, dek: dek);
      if (await target.exists()) await target.delete();
      await backup.rename(target.path);
      return knownGood;
    }
  }

  Future<void> _cleanupArtifacts(String vaultId) async {
    final pending = _pending(vaultId);
    final backup = _backup(vaultId);
    if (await pending.exists()) await pending.delete();
    if (await backup.exists()) await backup.delete();
  }

  Future<VaultFileV1> _readVaultFile(File file) async {
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) {
        throw const FormatException('vault.invalid_file');
      }
      return VaultFileV1.fromJson(Map<String, dynamic>.from(decoded));
    } on FileSystemException {
      rethrow;
    } on FormatException {
      throw const FormatException('vault.invalid_file');
    }
  }

  void _validateFileIdentity(VaultFileV1 file, String vaultId) {
    if (file.vaultId != vaultId) {
      throw const FormatException('vault.file_identity_mismatch');
    }
  }

  Future<void> _assertNotRollback(VaultFileV1 file) async {
    final highest = await deviceKeyStore.loadHighestAcceptedRevision(
      vaultId: file.vaultId,
    );
    if (highest != null && file.revision < highest) {
      throw VaultRollbackException(
        vaultId: file.vaultId,
        foundRevision: file.revision,
        highestAcceptedRevision: highest,
      );
    }
  }

  Future<void> _acceptRevision(VaultFileV1 file) async {
    await _assertNotRollback(file);
    final highest = await deviceKeyStore.loadHighestAcceptedRevision(
      vaultId: file.vaultId,
    );
    if (highest == null || file.revision > highest) {
      await deviceKeyStore.storeHighestAcceptedRevision(
        vaultId: file.vaultId,
        revision: file.revision,
      );
    }
  }

  Future<void> _commitVaultFile(
    VaultFileV1 vaultFile,
    SecureKey dek,
  ) async {
    await directory.create(recursive: true);
    await _recoverInterruptedReplace(vaultFile.vaultId);

    final target = fileFor(vaultFile.vaultId);
    final pending = _pending(vaultFile.vaultId);
    final backup = _backup(vaultFile.vaultId);
    final hadTarget = await target.exists();

    await pending.writeAsString(
      jsonEncode(vaultFile.toJson()),
      flush: true,
    );
    final staged = await _readVaultFile(pending);
    _validateFileIdentity(staged, vaultFile.vaultId);
    crypto.decrypt(envelope: staged.payload, dek: dek);

    try {
      if (await backup.exists()) await backup.delete();
      if (hadTarget) {
        await target.rename(backup.path);
      }
      await pending.rename(target.path);
      await afterReplaceBeforeValidation?.call(target);

      final committed = await _readVaultFile(target);
      _validateFileIdentity(committed, vaultFile.vaultId);
      crypto.decrypt(envelope: committed.payload, dek: dek);

      if (await backup.exists()) await backup.delete();
    } catch (_) {
      if (await backup.exists()) {
        if (await target.exists()) await target.delete();
        await backup.rename(target.path);
      } else if (!hadTarget && await target.exists()) {
        await target.delete();
      }
      rethrow;
    } finally {
      if (await pending.exists()) await pending.delete();
    }
  }
}
