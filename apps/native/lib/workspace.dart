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
  static String uniqueId() =>
      '${DateTime.now().toUtc().microsecondsSinceEpoch}-${List.generate(16, (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0')).join()}';

  static Future<Workspace> open(
    Directory directory, {
    bool create = false,
  }) async {
    if (!await directory.exists()) {
      if (!create) throw const FileSystemException('Робоча папка недоступна');
      await directory.create(recursive: true);
    }
    final markerFile = File(p.join(directory.path, marker));
    if (!await markerFile.exists()) {
      if (!create || await directory.list().isEmpty == false) {
        throw const FileSystemException(
          'Оберіть порожню папку або папку ОВДП Hub',
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
      throw const FormatException('Невідома версія робочої папки');
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
      throw const FormatException('Файл більший за 20 МБ');
    }
    return file.readAsString();
  }

  Future<void> saveCatalog(Catalog catalog) =>
      writeRecord('catalogs', catalog.json);
  Future<void> saveSet(SavedSet set) => writeRecord('sets', set.toJson());

  /// Copy only validated application records; preserve source, never merge silently.
  Future<Workspace> copyTo(Directory destination) async {
    final sourcePath = p.normalize(p.absolute(directory.path));
    final targetPath = p.normalize(p.absolute(destination.path));
    if (p.equals(sourcePath, targetPath) ||
        p.isWithin(sourcePath, targetPath)) {
      throw const FileSystemException('Нова папка має бути поза поточною');
    }
    if (await destination.exists() && !await destination.list().isEmpty) {
      throw const FileSystemException('Для копіювання потрібна порожня папка');
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
