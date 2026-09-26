import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/workspace/mobile_storage_runtime_probe_panel.dart';
import 'package:ovdp_hub/l10n/hub_locale.dart';
import 'package:ovdp_hub/platform/mobile_external_storage.dart';
import 'package:ovdp_hub/platform/mobile_storage_runtime_probe.dart';

class FakePanelStorage implements MobileExternalStorage {
  final Map<String, String> files = {};
  bool available = true;

  @override
  bool get supported => true;

  @override
  Future<ExternalFolderGrant?> chooseWorkspaceFolder() async =>
      const ExternalFolderGrant(id: '12345678', label: 'Test Drive');

  @override
  Future<bool> workspaceFolderAvailable(String grantId) async => available;

  @override
  Future<String?> readWorkspaceText({
    required String grantId,
    required String relativePath,
    required int maxBytes,
  }) async {
    if (!available) throw StateError('workspace.external_permission_lost');
    return files[relativePath];
  }

  @override
  Future<void> writeWorkspaceText({
    required String grantId,
    required String relativePath,
    required String content,
    required bool replace,
  }) async {
    if (!available) throw StateError('workspace.external_permission_lost');
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
    final directory = await Directory.systemTemp.createTemp('ovdp-probe-panel-');
    addTearDown(() async {
      if (await directory.exists()) await directory.delete(recursive: true);
    });
    final stateFile = File('${directory.path}/probe-state.json');
    final storage = FakePanelStorage();

    await tester.pumpWidget(
      testApp(
        MobileStorageRuntimeProbe(
          storage: storage,
          stateFile: stateFile,
          launchId: 'launch-a',
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
        MobileStorageRuntimeProbe(
          storage: storage,
          stateFile: stateFile,
          launchId: 'launch-b',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Новий запуск підтверджено'), findsOneWidget);
    expect(find.text('Продовжити після перезапуску'), findsOneWidget);

    await tester.tap(find.text('Продовжити після перезапуску'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Перевірка пройдена'), findsOneWidget);
    expect(await stateFile.exists(), isFalse);
  });
}
