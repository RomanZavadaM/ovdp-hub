import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/models.dart';
import 'package:ovdp_hub/workspace.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;
  late Catalog catalog;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('ovdp-test-');
    catalog = Catalog.parse(
      await File('assets/nbu-snapshot.json').readAsString(),
    );
  });
  tearDown(() async {
    await root.delete(recursive: true);
  });
  test('catalog and saved set survive reopening without a network', () async {
    final workspace = await Workspace.open(
      Directory(p.join(root.path, 'source')),
      create: true,
    );
    await workspace.saveCatalog(catalog);
    await workspace.saveSet(
      SavedSet(
        'Короткий горизонт',
        'Нотатка',
        DateTime.now().toUtc().toIso8601String(),
        [catalog.bonds.first],
      ),
    );
    final reopened = await Workspace.open(workspace.directory);
    expect((await reopened.catalog())!.bonds.length, catalog.bonds.length);
    expect((await reopened.sets()).single.note, 'Нотатка');
  });
  test('copy preserves source and validates destination', () async {
    final source = await Workspace.open(
      Directory(p.join(root.path, 'source')),
      create: true,
    );
    await source.saveCatalog(catalog);
    await source.saveSet(
      SavedSet('Сценарій', '', DateTime.now().toUtc().toIso8601String(), [
        catalog.bonds.first,
      ]),
    );
    final destination = await source.copyTo(
      Directory(p.join(root.path, 'destination')),
    );
    expect((await destination.sets()).single.name, 'Сценарій');
    expect((await source.sets()).length, 1);
    await expectLater(
      source.copyTo(destination.directory),
      throwsA(isA<FileSystemException>()),
    );
    await expectLater(
      source.copyTo(Directory(p.join(source.directory.path, 'nested'))),
      throwsA(isA<FileSystemException>()),
    );
  });
  test('unavailable workspace is not silently recreated', () async {
    final source = await Workspace.open(
      Directory(p.join(root.path, 'network')),
      create: true,
    );
    await source.directory.rename(p.join(root.path, 'disconnected'));
    await expectLater(
      source.saveCatalog(catalog),
      throwsA(isA<FileSystemException>()),
    );
    expect(await source.directory.exists(), false);
  });
  test('foreign and future-version folders are rejected', () async {
    await File(p.join(root.path, 'unrelated.txt')).writeAsString('keep');
    await expectLater(
      Workspace.open(root, create: true),
      throwsA(isA<FileSystemException>()),
    );
    await File(
      p.join(root.path, Workspace.marker),
    ).writeAsString('{"schemaVersion":99,"application":"ovdp-hub"}');
    await expectLater(Workspace.open(root), throwsFormatException);
    expect(
      await File(p.join(root.path, 'unrelated.txt')).readAsString(),
      'keep',
    );
  });
  test('parallel writers preserve separate immutable records', () async {
    final source = await Workspace.open(
      Directory(p.join(root.path, 'shared')),
      create: true,
    );
    await Future.wait(
      List.generate(
        20,
        (i) => source.saveSet(
          SavedSet('Set $i', '', DateTime.now().toUtc().toIso8601String(), [
            catalog.bonds.first,
          ]),
        ),
      ),
    );
    expect((await source.sets()).length, 20);
  });
  test(
    'corruption surfaces instead of resetting to an empty collection',
    () async {
      final source = await Workspace.open(
        Directory(p.join(root.path, 'source')),
        create: true,
      );
      await Directory(p.join(source.directory.path, 'sets')).create();
      await File(
        p.join(source.directory.path, 'sets', 'corrupt.json'),
      ).writeAsString('broken');
      await expectLater(source.sets(), throwsFormatException);
    },
  );
}
