import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/workspace/mobile_storage_runtime_probe_panel.dart';
import 'package:ovdp_hub/l10n/hub_locale.dart';
import 'package:ovdp_hub/platform/mobile_external_storage.dart';
import 'package:ovdp_hub/platform/mobile_storage_runtime_probe.dart';

class SupportedFakeStorage implements MobileExternalStorage {
  const SupportedFakeStorage();

  @override
  bool get supported => true;

  @override
  Future<ExternalFolderGrant?> chooseWorkspaceFolder() =>
      throw UnimplementedError();

  @override
  Future<bool> workspaceFolderAvailable(String grantId) =>
      throw UnimplementedError();

  @override
  Future<String?> readWorkspaceText({
    required String grantId,
    required String relativePath,
    required int maxBytes,
  }) => throw UnimplementedError();

  @override
  Future<void> writeWorkspaceText({
    required String grantId,
    required String relativePath,
    required String content,
    required bool replace,
  }) => throw UnimplementedError();

  @override
  Future<List<String>> listWorkspaceFiles({
    required String grantId,
    required String relativeDirectory,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteWorkspaceFile({
    required String grantId,
    required String relativePath,
  }) => throw UnimplementedError();

  @override
  Future<String?> exportEncryptedBackup({
    required String suggestedName,
    required Uint8List bytes,
  }) => throw UnimplementedError();

  @override
  Future<Uint8List?> importEncryptedBackup({required int maxBytes}) =>
      throw UnimplementedError();
}

class ScriptedProbe extends MobileStorageRuntimeProbe {
  MobileStorageRuntimeProbeSnapshot snapshot;

  ScriptedProbe(this.snapshot)
    : super(
        storage: const SupportedFakeStorage(),
        stateFile: File('/unused-runtime-probe-state.json'),
        launchId: 'widget-test',
      );

  @override
  Future<MobileStorageRuntimeProbeSnapshot> load() async => snapshot;

  @override
  Future<MobileStorageRuntimeProbeSnapshot> begin() async {
    snapshot = const MobileStorageRuntimeProbeSnapshot(
      MobileStorageRuntimeProbePhase.restartRequired,
      folderLabel: 'Test Drive',
    );
    return snapshot;
  }

  @override
  Future<MobileStorageRuntimeProbeSnapshot> complete() async {
    snapshot = const MobileStorageRuntimeProbeSnapshot(
      MobileStorageRuntimeProbePhase.passed,
      folderLabel: 'Test Drive',
    );
    return snapshot;
  }

  @override
  Future<MobileStorageRuntimeProbeSnapshot> reset() async {
    snapshot = const MobileStorageRuntimeProbeSnapshot(
      MobileStorageRuntimeProbePhase.idle,
    );
    return snapshot;
  }
}

Widget testApp(MobileStorageRuntimeProbe probe) => BlocProvider(
  create: (_) => LocaleCubit(),
  child: MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: MobileStorageRuntimeProbePanel(
          probe: probe,
          supportedOverride: true,
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('visible probe requires relaunch then reports pass', (tester) async {
    await tester.pumpWidget(
      testApp(
        ScriptedProbe(
          const MobileStorageRuntimeProbeSnapshot(
            MobileStorageRuntimeProbePhase.idle,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Почати перевірку'), findsOneWidget);

    await tester.tap(find.text('Почати перевірку'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Етап 1 пройдено'), findsOneWidget);
    expect(find.textContaining('Папка: Test Drive'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(
      testApp(
        ScriptedProbe(
          const MobileStorageRuntimeProbeSnapshot(
            MobileStorageRuntimeProbePhase.readyAfterRestart,
            folderLabel: 'Test Drive',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Новий запуск підтверджено'), findsOneWidget);
    expect(find.text('Продовжити після перезапуску'), findsOneWidget);

    await tester.tap(find.text('Продовжити після перезапуску'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Перевірка пройдена'), findsOneWidget);
  });
}
