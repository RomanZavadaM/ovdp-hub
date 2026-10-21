import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/data/hub_repository.dart';
import 'package:ovdp_hub/features/collections/collections_cubit.dart';
import 'package:ovdp_hub/features/collections/editor_cubit.dart';
import 'package:ovdp_hub/features/portfolio/portfolio_cubit.dart';
import 'package:ovdp_hub/features/portfolio/private_portfolio.dart';
import 'package:ovdp_hub/models.dart';
import 'package:ovdp_hub/workspace.dart';
import 'package:path/path.dart' as p;
import 'support/fake_portfolio_gateway.dart';
import 'support/fake_repository.dart';

class CollectionGateway extends FakePortfolioGateway {
  Completer<void>? entered, resume;
  Object? failure;
  void Function()? afterSave;
  PrivatePortfolioPayload Function(PrivatePortfolioPayload)? afterOpen;
  CollectionGateway() : super(stored: PrivatePortfolioPayload(portfolioId: 'primary'));
  @override
  Future<void> save(PrivatePortfolioPayload payload) async {
    entered?.complete();
    await resume?.future;
    if (failure != null) throw failure!;
    await super.save(payload);
    afterSave?.call();
  }
  @override
  Future<PrivatePortfolioPayload> open({String? recoverySecret}) async {
    final value = await super.open(recoverySecret: recoverySecret);
    return afterOpen?.call(value) ?? value;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Catalog catalog;
  late FakeRepository hub;
  late CollectionGateway gateway;
  late PortfolioCubit portfolio;
  late CollectionEditorCubit editor;
  setUp(() async {
    catalog = Catalog.parse(File('assets/nbu-snapshot.json').readAsStringSync());
    hub = FakeRepository(catalog);
    gateway = CollectionGateway();
    portfolio = PortfolioCubit(hub, gateway);
    await portfolio.open();
    editor = CollectionEditorCubit(hub, portfolio: portfolio);
  });
  tearDown(() async {
    await editor.close();
    await portfolio.close();
    await hub.dispose();
  });
  SavedSet collection(String name) => SavedSet(name, 'secret note',
    '2026-10-21T12:00:00Z', [catalog.bonds.first]);
  void draft() {
    editor.toggle(catalog.bonds.first, true);
    editor.edit(name: 'Private title', note: 'Secret note');
  }

  test('private save and edit retain identity and never call workspace save', () async {
    draft();
    expect(await editor.save(), isTrue);
    expect(hub.saves, 0);
    final saved = portfolio.privateCollectionSets.single;
    expect(saved.storedInVault, isTrue);
    editor.variant(saved);
    editor.edit(name: 'Changed');
    expect(await editor.save(), isTrue);
    expect(portfolio.privateCollectionSets.single.recordId, saved.recordId);
    expect(gateway.stored!.privateCollections.single.set.name, 'Changed');
    expect(hub.current!.sets, isEmpty);
  });
  test('save failure preserves draft and allows retry', () async {
    draft();
    gateway.failure = StateError('portfolio.operation_failed');
    expect(await editor.save(), isFalse);
    expect(editor.state.note, 'Secret note');
    expect(editor.state.busy, isFalse);
    gateway.failure = null;
    expect(await editor.save(), isTrue);
    expect(gateway.stored!.privateCollections, hasLength(1));
  });
  test('lock during save purges draft and late completion cannot restore it', () async {
    draft();
    gateway.entered = Completer<void>();
    gateway.resume = Completer<void>();
    final saving = editor.save();
    await gateway.entered!.future;
    await gateway.lock();
    expect(editor.state.name, isEmpty);
    expect(editor.state.note, isEmpty);
    expect(editor.state.selected, isEmpty);
    gateway.resume!.complete();
    expect(await saving, isFalse);
    expect(portfolio.state.payload, isNull);
    expect(editor.state.error, isNull);
  });
  test('private save is refused before I/O when locked', () async {
    await gateway.lock();
    draft();
    expect(await editor.save(), isFalse);
    expect(gateway.stored!.privateCollections, isEmpty);
    expect(hub.saves, 0);
  });
  test('public list works without portfolio and cannot accept annotations', () async {
    final public = CollectionEditorCubit(hub)..selectPrivate(false);
    public.toggle(catalog.bonds.first, true);
    public.edit(name: 'Secret title', note: 'Secret note');
    expect(await public.save(), isTrue);
    expect(hub.current!.sets.single.note, isEmpty);
    expect(hub.current!.sets.single.name, startsWith('ISIN '));
    await public.close();
  });
  test('changing destination clears annotations before public save', () async {
    draft();
    editor.selectPrivate(false);
    expect(editor.state.note, isEmpty);
    expect(await editor.save(), isTrue);
    expect(hub.current!.sets.single.note, isEmpty);
    expect(hub.current!.sets.single.name, isNot(contains('Private title')));
  });
  test('lock hides collection list and reopen restores from vault', () async {
    draft();
    await editor.save();
    final collections = CollectionsCubit(hub, portfolio: portfolio);
    expect(collections.state.sets.single.name, 'Private title');
    await gateway.lock();
    await Future<void>.delayed(Duration.zero);
    expect(collections.state.sets, isEmpty);
    await portfolio.open();
    await Future<void>.delayed(Duration.zero);
    expect(collections.state.sets.single.name, 'Private title');
    await collections.close();
  });
  test('public draft survives vault lock', () async {
    editor.selectPrivate(false);
    editor.toggle(catalog.bonds.first, true);
    await gateway.lock();
    expect(editor.state.selected, hasLength(1));
    expect(await editor.save(), isTrue);
  });
  test('move verifies full content and removes only matching source', () async {
    await hub.saveCollection(collection('Legacy'));
    final source = hub.current!.sets.single;
    await portfolio.movePlaintextCollectionToVault(source);
    expect(hub.current!.sets, isEmpty);
    expect(savedSetContentEquals(gateway.stored!.privateCollections.single.set, source), isTrue);
  });
  test('conflicting existing id never deletes or overwrites source', () async {
    await hub.saveCollection(collection('Legacy'));
    final source = hub.current!.sets.single;
    gateway.stored = PrivatePortfolioPayload(portfolioId: 'primary', privateCollections: [
      PrivateCollectionRecord(id: 'workspace-${source.recordId}', set: collection('Other')),
    ]);
    await portfolio.open();
    await expectLater(portfolio.movePlaintextCollectionToVault(source), throwsStateError);
    expect(hub.deletedRecordIds, isEmpty);
    expect(gateway.stored!.privateCollections.single.set.name, 'Other');
  });
  test('reopened wrong content with matching id never deletes source', () async {
    await hub.saveCollection(collection('Legacy'));
    final source = hub.current!.sets.single;
    gateway.afterOpen = (payload) => PrivatePortfolioPayload(
      portfolioId: payload.portfolioId, privateCollections: [
        PrivateCollectionRecord(id: 'workspace-${source.recordId}', set: collection('Wrong')),
      ]);
    await expectLater(portfolio.movePlaintextCollectionToVault(source), throwsStateError);
    expect(hub.deletedRecordIds, isEmpty);
  });
  test('workspace change during save retains original source', () async {
    await hub.saveCollection(collection('Legacy'));
    final source = hub.current!.sets.single;
    gateway.afterSave = () {
      hub.current = WorkspaceSnapshot('B', catalog,
        [collection('B').withStorage(recordId: source.recordId)]);
    };
    await expectLater(portfolio.movePlaintextCollectionToVault(source), throwsStateError);
    expect(hub.deletedRecordIds, isEmpty);
    expect(hub.current!.sets.single.name, 'B');
  });
  test('lock after encrypted save prevents reopen and source deletion', () async {
    await hub.saveCollection(collection('Legacy'));
    final source = hub.current!.sets.single;
    gateway.afterSave = () { unawaited(gateway.lock()); };
    await expectLater(portfolio.movePlaintextCollectionToVault(source), throwsStateError);
    expect(hub.deletedRecordIds, isEmpty);
    expect(gateway.unlocked, isFalse);
  });
  test('real workspace files never receive private editor annotations', () async {
    final root = await Directory.systemTemp.createTemp('ovdp-private-collections-');
    final ws = await Workspace.open(Directory(p.join(root.path, 'workspace')), create: true);
    await ws.saveCatalog(catalog);
    await File(p.join(root.path, 'workspace-path.json')).writeAsString(jsonEncode({'path': ws.directory.path}));
    final files = FileHubRepository(supportDirectory: () async => root);
    await files.initialize();
    final fileGateway = CollectionGateway();
    final vault = PortfolioCubit(files, fileGateway);
    await vault.open();
    final privateEditor = CollectionEditorCubit(files, portfolio: vault);
    privateEditor.toggle(catalog.bonds.first, true);
    privateEditor.edit(name: 'unique-private-title-83', note: 'unique-private-note-83');
    expect(await privateEditor.save(), isTrue);
    for (final file in ws.directory.listSync(recursive: true).whereType<File>()) {
      final content = await file.readAsString();
      expect(content, isNot(contains('unique-private-title-83')));
      expect(content, isNot(contains('unique-private-note-83')));
    }
    await privateEditor.close();
    await vault.close();
    await files.dispose();
    await root.delete(recursive: true);
  });
}
