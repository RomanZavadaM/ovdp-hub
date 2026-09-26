import 'dart:convert';
import 'dart:math';

import '../models.dart';
import 'mobile_external_storage.dart';

class MobileExternalWorkspace {
  static const rootDirectory = 'OVDP-Hub-Workspace';
  static const marker = 'ovdp-workspace.json';
  static const catalogRetention = 12;
  static const _maxTextBytes = 20 * 1024 * 1024;

  final MobileExternalStorage storage;
  final ExternalFolderGrant grant;

  const MobileExternalWorkspace({required this.storage, required this.grant});

  String get displayLocation => '${grant.label}/$rootDirectory';

  static String uniqueId() =>
      '${DateTime.now().toUtc().microsecondsSinceEpoch}-'
      '${List.generate(16, (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0')).join()}';

  static Future<MobileExternalWorkspace> open({
    required MobileExternalStorage storage,
    required ExternalFolderGrant grant,
    bool create = false,
  }) async {
    if (!storage.supported) {
      throw UnsupportedError('workspace.external_unsupported');
    }
    final workspace = MobileExternalWorkspace(storage: storage, grant: grant);
    await workspace.checkAvailable();

    if (create) {
      try {
        await storage.writeWorkspaceText(
          grantId: grant.id,
          relativePath: '$rootDirectory/$marker',
          content: jsonEncode({'schemaVersion': 1, 'application': 'ovdp-hub'}),
          replace: false,
        );
        await workspace._ensureCategoryDirectories();
        return workspace;
      } on StateError catch (error) {
        if (error.message != 'workspace.external_file_exists') rethrow;
      }
    }

    final markerText = await storage.readWorkspaceText(
      grantId: grant.id,
      relativePath: '$rootDirectory/$marker',
      maxBytes: 64 * 1024,
    );
    if (markerText == null) {
      throw StateError('workspace.empty_or_hub_required');
    }
    final metadata = jsonDecode(markerText);
    if (metadata is! Map ||
        metadata['schemaVersion'] != 1 ||
        metadata['application'] != 'ovdp-hub') {
      throw const FormatException('workspace.unknown_version');
    }
    return workspace;
  }

  Future<void> _ensureCategoryDirectories() async {
    for (final category in const ['catalogs', 'sets', 'exports']) {
      await storage.writeWorkspaceText(
        grantId: grant.id,
        relativePath: '$rootDirectory/$category/.keep',
        content: '',
        replace: true,
      );
    }
  }

  Future<void> checkAvailable() async {
    final available = await storage.workspaceFolderAvailable(grant.id);
    if (!available) {
      throw StateError('workspace.external_permission_lost');
    }
  }

  Future<List<String>> records(String category) async {
    await checkAvailable();
    final names = await storage.listWorkspaceFiles(
      grantId: grant.id,
      relativeDirectory: '$rootDirectory/$category',
    );
    return names.where((name) => name.endsWith('.json')).toList()
      ..sort((a, b) => b.compareTo(a));
  }

  Future<String> _readRequired(String relativePath) async {
    final value = await storage.readWorkspaceText(
      grantId: grant.id,
      relativePath: relativePath,
      maxBytes: _maxTextBytes,
    );
    if (value == null) {
      throw StateError('workspace.unavailable');
    }
    return value;
  }

  Future<Catalog?> catalog() async {
    final files = await records('catalogs');
    if (files.isEmpty) return null;
    return Catalog.parse(
      await _readRequired('$rootDirectory/catalogs/${files.first}'),
    );
  }

  Future<List<SavedSet>> sets() async {
    final results = <SavedSet>[];
    for (final name in await records('sets')) {
      results.add(
        SavedSet.parse(
          await _readRequired('$rootDirectory/sets/$name'),
        ),
      );
    }
    return results;
  }

  Future<void> saveCatalog(Catalog catalog) async {
    await checkAvailable();
    final name = '${uniqueId()}.json';
    await storage.writeWorkspaceText(
      grantId: grant.id,
      relativePath: '$rootDirectory/catalogs/$name',
      content: jsonEncode(catalog.json),
      replace: false,
    );
    final files = await records('catalogs');
    for (final old in files.skip(catalogRetention)) {
      await storage.deleteWorkspaceFile(
        grantId: grant.id,
        relativePath: '$rootDirectory/catalogs/$old',
      );
    }
  }

  Future<void> saveSet(SavedSet set) async {
    await checkAvailable();
    final name = '${uniqueId()}.json';
    await storage.writeWorkspaceText(
      grantId: grant.id,
      relativePath: '$rootDirectory/sets/$name',
      content: jsonEncode(set.toJson()),
      replace: false,
    );
  }

  Future<String> writeTextExport(String fileName, String content) async {
    _validateExportName(fileName);
    await checkAvailable();
    await storage.writeWorkspaceText(
      grantId: grant.id,
      relativePath: '$rootDirectory/exports/$fileName',
      content: content,
      replace: true,
    );
    return '$displayLocation/exports/$fileName';
  }

  Future<void> copySnapshot({
    required Catalog catalog,
    required Iterable<SavedSet> sets,
  }) async {
    await saveCatalog(catalog);
    for (final set in sets.toList().reversed) {
      await saveSet(set);
    }
  }

  static void _validateExportName(String fileName) {
    final safeCharacters = RegExp(r'^[A-Za-z0-9._-]+');
    final lower = fileName.toLowerCase();
    final supportedExtension =
        lower.endsWith('.csv') || lower.endsWith('.ics');
    if (fileName.isEmpty ||
        fileName.length > 160 ||
        !safeCharacters.hasMatch(fileName) ||
        safeCharacters.firstMatch(fileName)!.group(0) != fileName ||
        !supportedExtension ||
        fileName.contains('..')) {
      throw const FormatException('workspace.invalid_export_name');
    }
  }
}
