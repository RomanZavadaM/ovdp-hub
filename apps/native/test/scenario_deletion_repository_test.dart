import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/data/hub_repository.dart';
import 'package:ovdp_hub/models.dart';
import 'package:ovdp_hub/workspace.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory root;
  late Catalog catalog;
  late Workspace a;
  late Workspace b;
  late FileHubRepository repository;

  SavedSet plan(String name) => SavedSet(
    name, 'Private', '2026-10-20T00:00:00Z', [catalog.bonds.first],
    scenario: {'schemaVersion': 99, 'budget': '250000'},
  );

  Future<void> select(Workspace workspace) async {
    await File(p.join(root.path, 'workspace-path.json'))
        .writeAsString(jsonEncode({'path': workspace.directory.path}));
  }

  setUp(() async {
    root = await Directory.systemTemp.createTemp('ovdp-guarded-delete-');
    catalog = Catalog.parse(
      File('assets/nbu-snapshot.json').readAsStringSync(),
    );
    a = await Workspace.open(Directory(p.join(root.path, 'A')), create: true);
    b = await Workspace.open(Directory(p.join(root.path, 'B')), create: true);
    await a.saveCatalog(catalog);
    await b.saveCatalog(catalog);
    await a.saveSet(plan('Original'));
    await select(a);
    repository = FileHubRepository(supportDirectory: () async => root);
    await repository.initialize();
  });

  tearDown(() async {
    await repository.dispose();
    await root.delete(recursive: true);
  });

  test('real repository refuses modified source before deleting any record', () async {
    final snapshot = repository.current!;
    final source = snapshot.sets.single;
    final file = (await a.records('sets')).single;
    await file.writeAsString(jsonEncode(plan('Changed').toJson()));

    await expectLater(
      repository.deleteCollections(
        [source.recordId!], expectedWorkspace: snapshot, expectedSets: [source],
      ),
      throwsStateError,
    );
    expect((await a.sets()).single.name, 'Changed');
  });

  test('expired vault authorization leaves the real source file untouched', () async {
    final source = repository.current!.sets.single;
    await expectLater(repository.deleteCollections([source.recordId!],
      expectedWorkspace: repository.current, expectedSets: [source],
      stillAuthorized: () => false), throwsStateError);
    expect((await a.sets()).single.name, 'Original');
  });

  test('unknown source fields cannot be silently discarded by verified deletion', () async {
    final source = repository.current!.sets.single;
    final file = (await a.records('sets')).single;
    final extended = source.toJson()..['privateExtraNote'] = 'must survive';
    await file.writeAsString(jsonEncode(extended));
    await expectLater(repository.deleteCollections([source.recordId!],
      expectedWorkspace: repository.current, expectedSets: [source]), throwsFormatException);
    expect(await file.exists(), isTrue);
    expect(await file.readAsString(), contains('must survive'));
  });

  test('queued workspace switch cannot redirect deletion to same-id record', () async {
    final snapshot = repository.current!;
    final source = snapshot.sets.single;
    final sourceFile = (await a.records('sets')).single;
    final bFolder = Directory(p.join(b.directory.path, 'sets'));
    await bFolder.create();
    await File(p.join(bFolder.path, p.basename(sourceFile.path)))
        .writeAsString(jsonEncode(plan('Destination').toJson()));
    await select(b);

    final switching = repository.initialize();
    final deleting = repository.deleteCollections(
      [source.recordId!], expectedWorkspace: snapshot, expectedSets: [source],
    );
    await expectLater(deleting, throwsStateError);
    await switching;
    expect((await a.sets()).single.name, 'Original');
    expect((await b.sets()).single.name, 'Destination');
  });

  test('verified deletion removes only the source and preserves other records', () async {
    await a.saveSet(SavedSet(
      'Public', '', '2026-10-20T00:00:00Z', [catalog.bonds.first],
    ));
    await repository.reloadCollections();
    final snapshot = repository.current!;
    final source = snapshot.sets.singleWhere((set) => set.scenario != null);
    await repository.deleteCollections(
      [source.recordId!], expectedWorkspace: snapshot, expectedSets: [source],
    );
    expect((await a.sets()).single.name, 'Public');
    expect(repository.current!.sets.single.name, 'Public');
  });
}
