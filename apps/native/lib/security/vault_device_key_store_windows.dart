import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import 'vault_crypto.dart';
import 'vault_device_key_store.dart';

abstract interface class DpapiProtector {
  Uint8List protect(Uint8List plainText);
  Uint8List unprotect(Uint8List cipherText);
}

class WindowsVaultDeviceKeyStore implements VaultDeviceKeyStore {
  static const int _schemaVersion = 1;

  final Directory directory;
  final DpapiProtector protector;

  WindowsVaultDeviceKeyStore({
    required this.directory,
    required this.protector,
  });

  File _target(String vaultId) {
    validateVaultId(vaultId);
    return File(p.join(directory.path, '$vaultId.device.dpapi'));
  }

  File _pending(String vaultId) => File('${_target(vaultId).path}.pending');
  File _backup(String vaultId) => File('${_target(vaultId).path}.backup');

  Future<void> _recoverInterruptedReplace(String vaultId) async {
    final target = _target(vaultId);
    final backup = _backup(vaultId);
    if (!await target.exists() && await backup.exists()) {
      await backup.rename(target.path);
    }
  }

  Future<_WindowsDeviceState?> _readState(String vaultId) async {
    await _recoverInterruptedReplace(vaultId);
    final target = _target(vaultId);
    if (!await target.exists()) return null;

    final protectedBytes = await target.readAsBytes();
    final plainText = protector.unprotect(
      Uint8List.fromList(protectedBytes),
    );
    try {
      final decoded = jsonDecode(utf8.decode(plainText));
      if (decoded is! Map) {
        throw const FormatException('vault.invalid_device_state');
      }
      return _WindowsDeviceState.fromJson(
        vaultId,
        Map<String, dynamic>.from(decoded),
      );
    } on FormatException {
      // Never delete or replace the protected record on decode failure.
      throw const FormatException('vault.invalid_device_state');
    }
  }

  Future<void> _writeState(String vaultId, _WindowsDeviceState state) async {
    await directory.create(recursive: true);
    await _recoverInterruptedReplace(vaultId);
    final target = _target(vaultId);
    final pending = _pending(vaultId);
    final backup = _backup(vaultId);

    final plainText = Uint8List.fromList(
      utf8.encode(jsonEncode(state.toJson())),
    );
    final protectedBytes = protector.protect(plainText);
    await pending.writeAsBytes(protectedBytes, flush: true);

    // Validate the staged record before replacing the known-good file.
    final stagedPlain = protector.unprotect(
      Uint8List.fromList(await pending.readAsBytes()),
    );
    _WindowsDeviceState.fromJson(
      vaultId,
      Map<String, dynamic>.from(
        jsonDecode(utf8.decode(stagedPlain)) as Map,
      ),
    );

    try {
      if (await backup.exists()) await backup.delete();
      if (await target.exists()) {
        await target.rename(backup.path);
      }
      await pending.rename(target.path);

      // Validate the committed record before dropping the previous copy.
      await _readState(vaultId);
      if (await backup.exists()) await backup.delete();
    } catch (_) {
      if (!await target.exists() && await backup.exists()) {
        await backup.rename(target.path);
      }
      rethrow;
    } finally {
      if (await pending.exists()) await pending.delete();
    }
  }

  @override
  Future<void> storeDek({
    required String vaultId,
    required Uint8List dek,
  }) async {
    validateDekBytes(dek);
    final current = await _readState(vaultId);
    if (current?.dek != null) {
      throw StateError('vault.device_key_exists');
    }
    await _writeState(
      vaultId,
      _WindowsDeviceState(
        vaultId: vaultId,
        dek: Uint8List.fromList(dek),
        highestRevision: current?.highestRevision ?? 0,
      ),
    );
  }

  @override
  Future<Uint8List?> loadDek({required String vaultId}) async {
    final value = (await _readState(vaultId))?.dek;
    return value == null ? null : Uint8List.fromList(value);
  }

  @override
  Future<void> deleteDek({required String vaultId}) async {
    validateVaultId(vaultId);
    for (final file in [_pending(vaultId), _backup(vaultId), _target(vaultId)]) {
      if (await file.exists()) await file.delete();
    }
  }

  @override
  Future<int?> loadHighestAcceptedRevision({required String vaultId}) async =>
      (await _readState(vaultId))?.highestRevision;

  @override
  Future<void> storeHighestAcceptedRevision({
    required String vaultId,
    required int revision,
  }) async {
    validateRevision(revision);
    final current = await _readState(vaultId);
    if (current?.dek == null) {
      throw StateError('vault.device_key_missing');
    }
    if (revision < current!.highestRevision) {
      throw StateError('vault.revision_regression');
    }
    if (revision == current.highestRevision) return;
    await _writeState(
      vaultId,
      _WindowsDeviceState(
        vaultId: vaultId,
        dek: current.dek,
        highestRevision: revision,
      ),
    );
  }
}

class _WindowsDeviceState {
  final String vaultId;
  final Uint8List? dek;
  final int highestRevision;

  _WindowsDeviceState({
    required this.vaultId,
    required this.dek,
    required this.highestRevision,
  });

  Map<String, Object?> toJson() => {
    'schemaVersion': WindowsVaultDeviceKeyStore._schemaVersion,
    'vaultId': vaultId,
    'dek': dek == null ? null : base64UrlEncode(dek!),
    'highestRevision': highestRevision,
  };

  factory _WindowsDeviceState.fromJson(
    String expectedVaultId,
    Map<String, dynamic> json,
  ) {
    if (json['schemaVersion'] != WindowsVaultDeviceKeyStore._schemaVersion ||
        json['vaultId'] != expectedVaultId) {
      throw const FormatException('vault.invalid_device_state');
    }
    final revision = json['highestRevision'];
    if (revision is! int || revision < 0) {
      throw const FormatException('vault.invalid_device_state');
    }

    Uint8List? dek;
    final encodedDek = json['dek'];
    if (encodedDek != null) {
      if (encodedDek is! String) {
        throw const FormatException('vault.invalid_device_state');
      }
      try {
        dek = Uint8List.fromList(base64Url.decode(encodedDek));
        validateDekBytes(dek);
      } on FormatException {
        throw const FormatException('vault.invalid_device_state');
      }
    }
    return _WindowsDeviceState(
      vaultId: expectedVaultId,
      dek: dek,
      highestRevision: revision,
    );
  }
}
