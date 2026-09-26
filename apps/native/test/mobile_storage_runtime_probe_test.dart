import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/platform/mobile_external_storage.dart';
import 'package:ovdp_hub/platform/mobile_storage_runtime_probe.dart';

class FakeProbeStorage implements MobileExternalStorage {
  final Map<String, String> files = {};
  bool available = true;
  bool cancelPick = false;

  @override
  bool get supported => true;

  @override
  Future<ExternalFolderGrant?> chooseWorkspaceFolder() async => cancelPick
      ? null
      : const ExternalFolderGrant(id: '12345678', label: 'Device folder');

  @override
  Future<bool> workspaceFolderAvailable(String grantId) async => available;

  @override
  Future<String?> readWorkspaceText({
    required String grantId,
    required String relativePath,
    required int maxBytes,
  }) async {
    if (!available) throw StateError('workspace.external_permission_lost');
    final value = files[relativePath];
    if (value != null && value.codeUnits.length > maxBytes) {
      throw StateError('workspace.file_too_large');
    }
    return value;
  }

  @override
  Future<void> writeWorkspaceText({
    required String grantId,
    required String relativePath,
    required String content,
    required bool replace,
  }) async {
    if (!available) throw StateError('workspace.external_permission_lost');
    if (!replace && files.containsKey(relativePath)) {
      throw StateError('workspace.external_file_exists');
    }
    files[relativePath] = content;
  }

  @override
  Future<List<String>> listWorkspaceFiles({
    required String grantId,
    required String relativeDirectory,
  }) async {
    if (!available) throw StateError('workspace.external_permission_lost');
    final prefix = '$relativeDirectory/';
    return files.keys
        .where((path) => path.startsWith(prefix))
        .map((path) => path.substring(prefix.length))
        .where((name) => !name.contains('/'))
        .toList();
  }

  @override
  Future<void> deleteWorkspaceFile({
    required String grantId,
    required String relativePath,
  }) async {
    if (!available) throw StateError('workspace.external_permission_lost');
    files.remove(relativePath);
  }

  @override
  Future<String?> exportEncryptedBackup({
    required String suggestedName,
    required Uint8List bytes,
  }) async => suggestedName;

  @override
  Future<Uint8List?> importEncryptedBackup({required int maxBytes}) async => null;
}

void main() {
  late Directory temporary;
  late File stateFile;
  late FakeProbeStorage storage;

  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('ovdp-runtime-probe-');
    stateFile = File('${temporary.path}/probe-state.json');
    storage = FakeProbeStorage();
  });

  tearDown(() async {
    if (await temporary.exists()) {
      await temporary.delete(recursive: true);
    }
  });

  test('phase one writes and verifies probe then requires relaunch', () async {
    final probe = MobileStorageRuntimeProbe(
      storage: storage,
      stateFile: stateFile,
      launchId: 'launch-a',
    );

    final started = await probe.begin();
    expect(started.phase, MobileStorageRuntimeProbePhase.restartRequired);
    expect(started.folderLabel, 'Device folder');
    expect(await stateFile.exists(), isTrue);
    expect(
      storage.files.containsKey(MobileStorageRuntimeProbe.probeRelativePath),
      isTrue,
    );

    final sameLaunch = await probe.complete();
    expect(sameLaunch.phase, MobileStorageRuntimeProbePhase.restartRequired);
    expect(
      sameLaunch.errorCode,
      'workspace.runtime_probe_restart_required',
    );
  });

  test('new launch validates persisted grant then cleans probe', () async {
    final firstLaunch = MobileStorageRuntimeProbe(
      storage: storage,
      stateFile: stateFile,
      launchId: 'launch-a',
    );
    expect(
      (await firstLaunch.begin()).phase,
      MobileStorageRuntimeProbePhase.restartRequired,
    );

    final secondLaunch = MobileStorageRuntimeProbe(
      storage: storage,
      stateFile: stateFile,
      launchId: 'launch-b',
    );
    final restored = await secondLaunch.load();
    expect(restored.phase, MobileStorageRuntimeProbePhase.readyAfterRestart);
    expect(restored.folderLabel, 'Device folder');

    final completed = await secondLaunch.complete();
    expect(completed.phase, MobileStorageRuntimeProbePhase.passed);
    expect(completed.folderLabel, 'Device folder');
    expect(await stateFile.exists(), isFalse);
    expect(
      storage.files.containsKey(MobileStorageRuntimeProbe.probeRelativePath),
      isFalse,
    );
  });

  test('revoked persisted grant is surfaced fail closed', () async {
    final firstLaunch = MobileStorageRuntimeProbe(
      storage: storage,
      stateFile: stateFile,
      launchId: 'launch-a',
    );
    await firstLaunch.begin();
    storage.available = false;

    final secondLaunch = MobileStorageRuntimeProbe(
      storage: storage,
      stateFile: stateFile,
      launchId: 'launch-b',
    );
    final restored = await secondLaunch.load();
    expect(restored.phase, MobileStorageRuntimeProbePhase.permissionLost);
    expect(restored.errorCode, 'workspace.external_permission_lost');
  });

  test('cancelled folder picker leaves no pending runtime probe', () async {
    storage.cancelPick = true;
    final probe = MobileStorageRuntimeProbe(
      storage: storage,
      stateFile: stateFile,
      launchId: 'launch-a',
    );

    final result = await probe.begin();
    expect(result.phase, MobileStorageRuntimeProbePhase.idle);
    expect(await stateFile.exists(), isFalse);
    expect(storage.files, isEmpty);
  });

  test('reset clears local state and best-effort remote probe', () async {
    final probe = MobileStorageRuntimeProbe(
      storage: storage,
      stateFile: stateFile,
      launchId: 'launch-a',
    );
    await probe.begin();

    final reset = await probe.reset();
    expect(reset.phase, MobileStorageRuntimeProbePhase.idle);
    expect(await stateFile.exists(), isFalse);
    expect(
      storage.files.containsKey(MobileStorageRuntimeProbe.probeRelativePath),
      isFalse,
    );
  });
}
