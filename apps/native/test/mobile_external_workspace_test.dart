import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/models.dart';
import 'package:ovdp_hub/platform/mobile_external_storage.dart';
import 'package:ovdp_hub/platform/mobile_external_workspace.dart';

class FakeMobileExternalStorage implements MobileExternalStorage {
  final Map<String, String> files = {};
  bool available = true;

  @override
  bool get supported => true;

  @override
  Future<ExternalFolderGrant?> chooseWorkspaceFolder() async =>
      const ExternalFolderGrant(id: '12345678', label: 'Drive');

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
  late FakeMobileExternalStorage storage;
  const grant = ExternalFolderGrant(id: '12345678', label: 'Drive');

  setUp(() {
    storage = FakeMobileExternalStorage();
  });

  test('external workspace survives reopening through opaque grant', () async {
    final catalog = Catalog.parse(
      await File('assets/nbu-snapshot.json').readAsString(),
    );
    final workspace = await MobileExternalWorkspace.open(
      storage: storage,
      grant: grant,
      create: true,
    );
    await workspace.saveCatalog(catalog);
    await workspace.saveSet(
      SavedSet(
        'Mobile',
        'note',
        '2026-09-26T00:00:00.000Z',
        [catalog.bonds.first],
      ),
    );

    final reopened = await MobileExternalWorkspace.open(
      storage: storage,
      grant: grant,
    );
    expect((await reopened.catalog())!.bonds.length, catalog.bonds.length);
    expect((await reopened.sets()).single.name, 'Mobile');
    expect(reopened.displayLocation, 'Drive/OVDP-Hub-Workspace');
  });

  test('lost grant fails closed instead of recreating workspace', () async {
    await MobileExternalWorkspace.open(
      storage: storage,
      grant: grant,
      create: true,
    );
    storage.available = false;

    await expectLater(
      MobileExternalWorkspace.open(storage: storage, grant: grant),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'workspace.external_permission_lost',
        ),
      ),
    );
  });
}
