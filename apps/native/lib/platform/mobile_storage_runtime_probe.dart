import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'mobile_external_storage.dart';
import 'mobile_external_workspace.dart';

enum MobileStorageRuntimeProbePhase {
  idle,
  restartRequired,
  readyAfterRestart,
  passed,
  permissionLost,
  failed,
}

class MobileStorageRuntimeProbeSnapshot {
  final MobileStorageRuntimeProbePhase phase;
  final String? folderLabel;
  final String? errorCode;

  const MobileStorageRuntimeProbeSnapshot(
    this.phase, {
    this.folderLabel,
    this.errorCode,
  });
}

final String mobileStorageRuntimeLaunchId = _newProbeId();

class MobileStorageRuntimeProbe {
  static const _stateSchema = 1;
  static const _probeSchema = 1;
  static const probeDirectory =
      '${MobileExternalWorkspace.rootDirectory}/runtime-validation';
  static const probeFileName = 'probe.json';
  static const probeRelativePath = '$probeDirectory/$probeFileName';
  static const _maxProbeBytes = 64 * 1024;

  final MobileExternalStorage storage;
  final File stateFile;
  final String launchId;

  const MobileStorageRuntimeProbe({
    required this.storage,
    required this.stateFile,
    required this.launchId,
  });

  static Future<MobileStorageRuntimeProbe> platform({
    MobileExternalStorage? storage,
  }) async {
    final directory = await getApplicationSupportDirectory();
    return MobileStorageRuntimeProbe(
      storage: storage ?? const MethodChannelMobileExternalStorage(),
      stateFile: File(
        p.join(directory.path, 'mobile-storage-runtime-probe.json'),
      ),
      launchId: mobileStorageRuntimeLaunchId,
    );
  }

  Future<MobileStorageRuntimeProbeSnapshot> load() async {
    if (!storage.supported) {
      return const MobileStorageRuntimeProbeSnapshot(
        MobileStorageRuntimeProbePhase.failed,
        errorCode: 'workspace.external_unsupported',
      );
    }
    try {
      final record = await _readRecord();
      if (record == null) {
        return const MobileStorageRuntimeProbeSnapshot(
          MobileStorageRuntimeProbePhase.idle,
        );
      }
      final available = await storage.workspaceFolderAvailable(record.grantId);
      if (!available) {
        return MobileStorageRuntimeProbeSnapshot(
          MobileStorageRuntimeProbePhase.permissionLost,
          folderLabel: record.label,
          errorCode: 'workspace.external_permission_lost',
        );
      }
      return MobileStorageRuntimeProbeSnapshot(
        record.launchId == launchId
            ? MobileStorageRuntimeProbePhase.restartRequired
            : MobileStorageRuntimeProbePhase.readyAfterRestart,
        folderLabel: record.label,
      );
    } catch (error) {
      return _failure(error);
    }
  }

  Future<MobileStorageRuntimeProbeSnapshot> begin() async {
    if (!storage.supported) {
      return const MobileStorageRuntimeProbeSnapshot(
        MobileStorageRuntimeProbePhase.failed,
        errorCode: 'workspace.external_unsupported',
      );
    }
    try {
      await reset();
      final grant = await storage.chooseWorkspaceFolder();
      if (grant == null) {
        return const MobileStorageRuntimeProbeSnapshot(
          MobileStorageRuntimeProbePhase.idle,
        );
      }

      final token = _newProbeId();
      final createdAt = DateTime.now().toUtc().toIso8601String();
      final content = _probeJson(
        token: token,
        preparedLaunchId: launchId,
        phase: 'prepared',
        updatedAt: createdAt,
      );
      await storage.writeWorkspaceText(
        grantId: grant.id,
        relativePath: probeRelativePath,
        content: content,
        replace: true,
      );
      final readBack = await storage.readWorkspaceText(
        grantId: grant.id,
        relativePath: probeRelativePath,
        maxBytes: _maxProbeBytes,
      );
      _validateProbe(
        readBack,
        token: token,
        preparedLaunchId: launchId,
        expectedPhase: 'prepared',
      );
      final names = await storage.listWorkspaceFiles(
        grantId: grant.id,
        relativeDirectory: probeDirectory,
      );
      if (!names.contains(probeFileName)) {
        throw StateError('workspace.runtime_probe_list_failed');
      }

      await _writeRecord(
        _ProbeRecord(
          grantId: grant.id,
          label: grant.label,
          launchId: launchId,
          token: token,
          startedAt: createdAt,
        ),
      );
      return MobileStorageRuntimeProbeSnapshot(
        MobileStorageRuntimeProbePhase.restartRequired,
        folderLabel: grant.label,
      );
    } catch (error) {
      return _failure(error);
    }
  }

  Future<MobileStorageRuntimeProbeSnapshot> complete() async {
    if (!storage.supported) {
      return const MobileStorageRuntimeProbeSnapshot(
        MobileStorageRuntimeProbePhase.failed,
        errorCode: 'workspace.external_unsupported',
      );
    }
    try {
      final record = await _readRecord();
      if (record == null) {
        return const MobileStorageRuntimeProbeSnapshot(
          MobileStorageRuntimeProbePhase.failed,
          errorCode: 'workspace.runtime_probe_not_started',
        );
      }
      if (record.launchId == launchId) {
        return MobileStorageRuntimeProbeSnapshot(
          MobileStorageRuntimeProbePhase.restartRequired,
          folderLabel: record.label,
          errorCode: 'workspace.runtime_probe_restart_required',
        );
      }
      final available = await storage.workspaceFolderAvailable(record.grantId);
      if (!available) {
        return MobileStorageRuntimeProbeSnapshot(
          MobileStorageRuntimeProbePhase.permissionLost,
          folderLabel: record.label,
          errorCode: 'workspace.external_permission_lost',
        );
      }

      final prepared = await storage.readWorkspaceText(
        grantId: record.grantId,
        relativePath: probeRelativePath,
        maxBytes: _maxProbeBytes,
      );
      _validateProbe(
        prepared,
        token: record.token,
        preparedLaunchId: record.launchId,
        expectedPhase: 'prepared',
      );
      var names = await storage.listWorkspaceFiles(
        grantId: record.grantId,
        relativeDirectory: probeDirectory,
      );
      if (!names.contains(probeFileName)) {
        throw StateError('workspace.runtime_probe_list_failed');
      }

      final verifiedAt = DateTime.now().toUtc().toIso8601String();
      await storage.writeWorkspaceText(
        grantId: record.grantId,
        relativePath: probeRelativePath,
        content: _probeJson(
          token: record.token,
          preparedLaunchId: record.launchId,
          phase: 'verified',
          updatedAt: verifiedAt,
          verifiedLaunchId: launchId,
        ),
        replace: true,
      );
      final verified = await storage.readWorkspaceText(
        grantId: record.grantId,
        relativePath: probeRelativePath,
        maxBytes: _maxProbeBytes,
      );
      _validateProbe(
        verified,
        token: record.token,
        preparedLaunchId: record.launchId,
        expectedPhase: 'verified',
        verifiedLaunchId: launchId,
      );

      await storage.deleteWorkspaceFile(
        grantId: record.grantId,
        relativePath: probeRelativePath,
      );
      names = await storage.listWorkspaceFiles(
        grantId: record.grantId,
        relativeDirectory: probeDirectory,
      );
      if (names.contains(probeFileName)) {
        throw StateError('workspace.runtime_probe_delete_failed');
      }
      await _clearState();
      return MobileStorageRuntimeProbeSnapshot(
        MobileStorageRuntimeProbePhase.passed,
        folderLabel: record.label,
      );
    } catch (error) {
      return _failure(error);
    }
  }

  Future<MobileStorageRuntimeProbeSnapshot> reset() async {
    final record = await _readRecordSafely();
    if (record != null && storage.supported) {
      try {
        if (await storage.workspaceFolderAvailable(record.grantId)) {
          await storage.deleteWorkspaceFile(
            grantId: record.grantId,
            relativePath: probeRelativePath,
          );
        }
      } catch (_) {
        // Best-effort external cleanup. Local state must always be reset so a
        // revoked provider grant cannot permanently block a fresh validation.
      }
    }
    await _clearState();
    return const MobileStorageRuntimeProbeSnapshot(
      MobileStorageRuntimeProbePhase.idle,
    );
  }

  Future<_ProbeRecord?> _readRecordSafely() async {
    try {
      return await _readRecord();
    } catch (_) {
      return null;
    }
  }

  Future<_ProbeRecord?> _readRecord() async {
    if (!await stateFile.exists()) return null;
    final decoded = jsonDecode(await stateFile.readAsString());
    if (decoded is! Map) {
      throw const FormatException('workspace.runtime_probe_state_invalid');
    }
    final map = Map<String, dynamic>.from(decoded);
    if (map['schemaVersion'] != _stateSchema) {
      throw const FormatException('workspace.runtime_probe_state_invalid');
    }
    String field(String name) {
      final value = map[name];
      if (value is! String || value.isEmpty) {
        throw const FormatException('workspace.runtime_probe_state_invalid');
      }
      return value;
    }

    return _ProbeRecord(
      grantId: field('grantId'),
      label: field('label'),
      launchId: field('launchId'),
      token: field('token'),
      startedAt: field('startedAt'),
    );
  }

  Future<void> _writeRecord(_ProbeRecord record) async {
    await stateFile.parent.create(recursive: true);
    final pending = File('${stateFile.path}.pending');
    try {
      await pending.writeAsString(
        jsonEncode({
          'schemaVersion': _stateSchema,
          'grantId': record.grantId,
          'label': record.label,
          'launchId': record.launchId,
          'token': record.token,
          'startedAt': record.startedAt,
        }),
        flush: true,
      );
      if (await stateFile.exists()) await stateFile.delete();
      await pending.rename(stateFile.path);
    } finally {
      if (await pending.exists()) await pending.delete();
    }
  }

  Future<void> _clearState() async {
    if (await stateFile.exists()) await stateFile.delete();
    final pending = File('${stateFile.path}.pending');
    if (await pending.exists()) await pending.delete();
  }

  static String _probeJson({
    required String token,
    required String preparedLaunchId,
    required String phase,
    required String updatedAt,
    String? verifiedLaunchId,
  }) => jsonEncode({
    'schemaVersion': _probeSchema,
    'application': 'ovdp-hub',
    'purpose': 'mobile-external-storage-runtime-validation',
    'token': token,
    'preparedLaunchId': preparedLaunchId,
    'phase': phase,
    'updatedAt': updatedAt,
    if (verifiedLaunchId != null) 'verifiedLaunchId': verifiedLaunchId,
  });

  static void _validateProbe(
    String? text, {
    required String token,
    required String preparedLaunchId,
    required String expectedPhase,
    String? verifiedLaunchId,
  }) {
    if (text == null) {
      throw StateError('workspace.runtime_probe_read_failed');
    }
    final decoded = jsonDecode(text);
    if (decoded is! Map) {
      throw const FormatException('workspace.runtime_probe_file_invalid');
    }
    final map = Map<String, dynamic>.from(decoded);
    if (map['schemaVersion'] != _probeSchema ||
        map['application'] != 'ovdp-hub' ||
        map['purpose'] != 'mobile-external-storage-runtime-validation' ||
        map['token'] != token ||
        map['preparedLaunchId'] != preparedLaunchId ||
        map['phase'] != expectedPhase ||
        (verifiedLaunchId != null &&
            map['verifiedLaunchId'] != verifiedLaunchId)) {
      throw const FormatException('workspace.runtime_probe_file_invalid');
    }
  }

  static MobileStorageRuntimeProbeSnapshot _failure(Object error) {
    final code = switch (error) {
      StateError() => error.message.toString(),
      FormatException() => error.message.toString(),
      _ => 'workspace.runtime_probe_failed',
    };
    return MobileStorageRuntimeProbeSnapshot(
      code == 'workspace.external_permission_lost'
          ? MobileStorageRuntimeProbePhase.permissionLost
          : MobileStorageRuntimeProbePhase.failed,
      errorCode: code,
    );
  }
}

class _ProbeRecord {
  final String grantId;
  final String label;
  final String launchId;
  final String token;
  final String startedAt;

  const _ProbeRecord({
    required this.grantId,
    required this.label,
    required this.launchId,
    required this.token,
    required this.startedAt,
  });
}

String _newProbeId() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  final hex = bytes.map((value) => value.toRadixString(16).padLeft(2, '0')).join();
  return '${DateTime.now().toUtc().microsecondsSinceEpoch}-$hex';
}
