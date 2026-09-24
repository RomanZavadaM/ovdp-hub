import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as p;
import 'models.dart';

/// Immutable records avoid silent last-writer-wins overwrites in synced folders.
/// A provider must expose a real filesystem directory; cloud APIs are not used.
class Workspace {
  final Directory directory;
  Workspace(this.directory);
  static const marker = 'ovdp-workspace.json';
  static const catalogRetention = 12;
  static String uniqueId() =>
      '${DateTime.now().toUtc().microsecondsSinceEpoch}-${List.generate(16, (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0')).join()}';

  static Future<Workspace> open(
    Directory directory, {
    bool create = false,
  }) async {
    if (!await directory.exists()) {
      if (!create) throw const FileSystemException('workspace.unavailable');
      await directory.create(recursive: true);
    }
    final markerFile = File(p.join(directory.path, marker));
    if (!await markerFile.exists()) {
      if (!create || await directory.list().isEmpty == false) {
        throw const FileSystemException(
          'workspace.empty_or_hub_required',
        );
      }
      await markerFile.writeAsString(
        jsonEncode({'schemaVersion': 1, 'application': 'ovdp-hub'}),
        flush: true,
      );
    }
    final metadata = jsonDecode(await markerFile.readAsString());
    if (metadata['schemaVersion'] != 1 ||
        metadata['application'] != 'ovdp-hub') {
      throw const FormatException('workspace.unknown_version');
    }
    return Workspace(directory);
  }

  Future<void> checkAvailable() async {
    await Workspace.open(directory);
  }

  Future<void> writeRecord(String category, Map<String, dynamic> data) async {
    await checkAvailable();
    final folder = Directory(p.join(directory.path, category));
    await folder.create();
    final id = uniqueId();
    final temporary = File(p.join(folder.path, '$id.pending'));
    try {
      await temporary.writeAsString(jsonEncode(data), flush: true);
      await temporary.rename(p.join(folder.path, '$id.json'));
    } finally {
      if (await temporary.exists()) await temporary.delete();
    }
  }

  Future<List<File>> records(String category) async {
    await checkAvailable();
    final folder = Directory(p.join(directory.path, category));
    if (!await folder.exists()) return [];
    final entries = await folder.list(followLinks: false).toList();
    return entries
        .whereType<File>()
        .where((e) => p.extension(e.path) == '.json')
        .toList()
      ..sort((a, b) => b.path.compareTo(a.path));
  }

  Future<Catalog?> catalog() async {
    final files = await records('catalogs');
    if (files.isEmpty) return null;
    // Surface corrupt/conflicting files instead of silently resetting the workspace.
    return Catalog.parse(await readLimited(files.first));
  }

  Future<List<SavedSet>> sets() async {
    final results = <SavedSet>[];
    for (final file in await records('sets')) {
      results.add(SavedSet.parse(await readLimited(file)));
    }
    return results;
  }

  static Future<String> readLimited(File file) async {
    if (await file.length() > 20 * 1024 * 1024) {
      throw const FormatException('workspace.file_too_large');
    }
    return file.readAsString();
  }

  Future<void> saveCatalog(Catalog catalog) async {
    await writeRecord('catalogs', catalog.json);
    final files = await records('catalogs');
    for (final file in files.skip(catalogRetention)) {
      try {
        await file.delete();
      } on FileSystemException {
        // Retention is best-effort: a durable new public snapshot must not be
        // reported as a failed refresh only because an old cache file is locked.
      }
    }
  }
  Future<void> saveSet(SavedSet set) => writeRecord('sets', set.toJson());

  Future<String> writeTextBundle(
    String folderName,
    Map<String, String> files,
  ) async {
    await checkAvailable();
    if (folderName.trim().isEmpty ||
        p.basename(folderName) != folderName ||
        folderName == '.' ||
        folderName == '..' ||
        folderName.length > 120 ||
        files.isEmpty) {
      throw const FormatException('workspace.invalid_export_name');
    }
    for (final name in files.keys) {
      if (name.trim().isEmpty ||
          p.basename(name) != name ||
          name == '.' ||
          name == '..' ||
          name.length > 120) {
        throw const FormatException('workspace.invalid_export_name');
      }
    }

    final exports = Directory(p.join(directory.path, 'exports'));
    await exports.create();
    var candidate = Directory(p.join(exports.path, folderName));
    var suffix = 2;
    while (await candidate.exists()) {
      candidate = Directory(p.join(exports.path, '$folderName-$suffix'));
      suffix++;
    }

    await candidate.create();
    try {
      for (final entry in files.entries) {
        final pending = File(p.join(candidate.path, '${entry.key}.pending'));
        final target = File(p.join(candidate.path, entry.key));
        await pending.writeAsString(entry.value, flush: true);
        await pending.rename(target.path);
      }
      return candidate.path;
    } catch (_) {
      if (await candidate.exists()) {
        await candidate.delete(recursive: true);
      }
      rethrow;
    }
  }

  /// Copy only validated application records; preserve source, never merge silently.
  Future<Workspace> copyTo(Directory destination) async {
    final sourcePath = p.normalize(p.absolute(directory.path));
    final targetPath = p.normalize(p.absolute(destination.path));
    if (p.equals(sourcePath, targetPath) ||
        p.isWithin(sourcePath, targetPath)) {
      throw const FileSystemException('workspace.destination_outside');
    }
    if (await destination.exists() && !await destination.list().isEmpty) {
      throw const FileSystemException('workspace.destination_empty');
    }
    final catalogs = <Catalog>[];
    for (final file in await records('catalogs')) {
      catalogs.add(Catalog.parse(await readLimited(file)));
    }
    final savedSets = await sets();
    final target = await Workspace.open(destination, create: true);
    for (final catalog in catalogs.reversed) {
      await target.saveCatalog(catalog);
    }
    for (final set in savedSets.reversed) {
      await target.saveSet(set);
    }
    return target;
  }
}
