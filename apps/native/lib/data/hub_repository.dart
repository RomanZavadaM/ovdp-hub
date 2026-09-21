import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models.dart';
import '../workspace.dart';

@immutable
class WorkspaceSnapshot {
  final String path;
  final Catalog catalog;
  final List<SavedSet> sets;
  WorkspaceSnapshot(this.path, this.catalog, Iterable<SavedSet> sets)
    : sets = List.unmodifiable(sets);
}

abstract interface class HubRepository {
  Stream<WorkspaceSnapshot> get changes;
  WorkspaceSnapshot? get current;
  bool get supportsExternalFolders;
  Future<void> initialize();
  Future<bool> chooseWorkspace({bool copy = false});
  Future<void> refreshCatalog();
  Future<void> reloadCollections();
  Future<void> saveCollection(SavedSet collection);
  Future<void> dispose();
}

class FileHubRepository implements HubRepository {
  final http.Client _client;
  final _changes = StreamController<WorkspaceSnapshot>.broadcast(sync: true);
  Future<void> _tail = Future.value();
  Workspace? _workspace;
  WorkspaceSnapshot? _current;
  bool _disposed = false;
  FileHubRepository({http.Client? client}) : _client = client ?? http.Client();
  @override
  Stream<WorkspaceSnapshot> get changes => _changes.stream;
  @override
  WorkspaceSnapshot? get current => _current;
  @override
  bool get supportsExternalFolders =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  // Switches and writes share a queue. An in-flight save cannot land in a
  // different workspace, and switching never publishes a half-loaded session.
  Future<T> _exclusive<T>(Future<T> Function() operation) {
    final result = _tail.then((_) {
      if (_disposed) throw StateError('Сховище закрито');
      return operation();
    });
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<File> _settings() async => File(
    p.join(
      (await getApplicationSupportDirectory()).path,
      'workspace-path.json',
    ),
  );
  Workspace get _opened =>
      _workspace ?? (throw StateError('Відкрийте робочу папку'));
  void _publish(WorkspaceSnapshot snapshot) {
    _current = snapshot;
    if (!_disposed) _changes.add(snapshot);
  }

  Future<void> _activate(Workspace candidate) async {
    var catalog = await candidate.catalog();
    if (catalog == null) {
      catalog = Catalog.parse(
        await rootBundle.loadString('assets/nbu-snapshot.json'),
      );
      await candidate.saveCatalog(catalog);
    }
    final sets = await candidate.sets();
    final config = await _settings();
    await config.parent.create(recursive: true);
    final temporary = File('${config.path}.pending');
    await temporary.writeAsString(
      jsonEncode({'path': candidate.directory.path}),
      flush: true,
    );
    await temporary.rename(config.path);
    _workspace = candidate;
    _publish(WorkspaceSnapshot(candidate.directory.path, catalog, sets));
  }

  @override
  Future<void> initialize() => _exclusive(() async {
    final config = await _settings();
    final saved = await config.exists()
        ? (jsonDecode(await config.readAsString()) as Map)['path'] as String?
        : null;
    final defaultPath = p.join(
      (await getApplicationSupportDirectory()).path,
      'OVDP Hub',
    );
    await _activate(
      await Workspace.open(
        Directory(saved ?? defaultPath),
        create: saved == null,
      ),
    );
  });
  @override
  Future<bool> chooseWorkspace({bool copy = false}) => _exclusive(() async {
    if (!supportsExternalFolders) {
      throw UnsupportedError(
        'Зовнішні папки ще не підтримуються на цій платформі',
      );
    }
    final path = await getDirectoryPath(
      confirmButtonText: copy ? 'Копіювати сюди' : 'Відкрити папку',
    );
    if (path == null) return false;
    final candidate = copy
        ? await _opened.copyTo(Directory(path))
        : await Workspace.open(Directory(path), create: true);
    await _activate(candidate);
    return true;
  });
  @override
  Future<void> refreshCatalog() => _exclusive(() async {
    final workspace = _opened;
    final response = await _client
        .get(Uri.parse('https://bank.gov.ua/depo_securities?json'))
        .timeout(const Duration(seconds: 30));
    if (response.statusCode != 200 ||
        response.bodyBytes.length > 20 * 1024 * 1024) {
      throw const FormatException('Не вдалося отримати каталог НБУ');
    }
    final catalog = Catalog.fromNbu(utf8.decode(response.bodyBytes));
    await workspace.saveCatalog(catalog);
    _publish(
      WorkspaceSnapshot(workspace.directory.path, catalog, current!.sets),
    );
  });
  @override
  Future<void> reloadCollections() => _exclusive(() async {
    final sets = await _opened.sets();
    _publish(WorkspaceSnapshot(current!.path, current!.catalog, sets));
  });
  @override
  Future<void> saveCollection(SavedSet collection) => _exclusive(() async {
    await _opened.saveSet(collection);
    // A successful durable write must not be reported as a failed save merely
    // because reading some unrelated synced file fails afterwards.
    _publish(
      WorkspaceSnapshot(current!.path, current!.catalog, [
        collection,
        ...current!.sets,
      ]),
    );
  });
  @override
  Future<void> dispose() async {
    await _tail;
    _disposed = true;
    _client.close();
    await _changes.close();
  }
}
