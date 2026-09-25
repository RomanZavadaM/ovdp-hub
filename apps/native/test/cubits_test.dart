import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/models.dart';
import 'package:ovdp_hub/features/navigation/navigation_cubit.dart';
import 'package:ovdp_hub/features/catalog/catalog_cubit.dart';
import 'package:ovdp_hub/features/collections/editor_cubit.dart';
import 'package:ovdp_hub/features/collections/collections_cubit.dart';
import 'package:ovdp_hub/features/workspace/workspace_cubit.dart';
import 'package:ovdp_hub/features/calculator/calculator_cubit.dart';
import 'support/fake_repository.dart';

void main() {
  test('navigation accepts the seventh user-facing portfolio destination', () {
    final cubit = NavigationCubit();
    cubit.select(6);
    expect(cubit.state.index, 6);
    cubit.select(7);
    expect(cubit.state.index, 6);
    cubit.close();
  });


  late Catalog catalog;
  late FakeRepository repository;
  setUp(() async {
    catalog = Catalog.parse(
      await File('assets/nbu-snapshot.json').readAsString(),
    );
    repository = FakeRepository(catalog);
  });
  tearDown(() async {
    await repository.dispose();
  });
  test(
    'failed save preserves draft; retry saves once and updates list',
    () async {
      final editor = CollectionEditorCubit(repository);
      final collections = CollectionsCubit(repository);
      editor.toggle(catalog.bonds.first, true);
      editor.edit(name: 'План', note: 'Нотатка');
      repository.saveError = StateError('Диск від’єднаний');
      expect(await editor.save(), false);
      expect(editor.state.name, 'План');
      expect(editor.state.selected.length, 1);
      expect(editor.state.error?.code, 'common.unexpected');
      repository.saveError = null;
      expect(await editor.save(), true);
      expect(editor.state.dirty, false);
      expect(collections.state.sets.single.note, 'Нотатка');
      await editor.close();
      await collections.close();
    },
  );
  test('collection variant keeps user-authored name without locale suffix', () async {
    final editor = CollectionEditorCubit(repository);
    final source = SavedSet(
      'My saved set',
      'note',
      '2026-09-25T00:00:00Z',
      [catalog.bonds.first],
    );

    editor.variant(source);

    expect(editor.state.name, 'My saved set');
    expect(editor.state.name.contains('варіант'), false);
    expect(editor.state.selected.keys, contains(catalog.bonds.first.isin));

    await editor.close();
  });

  test('cancelled and failed switches keep draft and active path', () async {
    final editor = CollectionEditorCubit(repository)..edit(name: 'Не втратити');
    final workspace = WorkspaceCubit(repository, editor);
    await workspace.choose();
    expect(repository.switches, 0);
    await workspace.choose(discardDraft: true);
    expect(editor.state.name, 'Не втратити');
    repository.switchError = StateError('Папка недоступна');
    await workspace.choose(discardDraft: true);
    expect(workspace.state.path, 'local');
    expect(editor.state.name, 'Не втратити');
    repository.switchError = null;
    repository.switchAccepted = true;
    await workspace.choose(discardDraft: true);
    expect(workspace.state.path, 'new');
    expect(editor.state.dirty, false);
    await workspace.close();
    await editor.close();
  });
  test(
    'switch locks draft; duplicate save and switch during save are rejected',
    () async {
      final editor = CollectionEditorCubit(repository)
        ..toggle(catalog.bonds.first, true)
        ..edit(name: 'План');
      final workspace = WorkspaceCubit(repository, editor);
      repository.gate = Completer<void>();
      final switching = workspace.choose(discardDraft: true);
      editor.edit(name: 'Lost edit');
      expect(editor.state.name, 'План');
      expect(await editor.save(), false);
      repository.gate!.complete();
      await switching;
      repository.gate = Completer<void>();
      final saving = editor.save();
      expect(await editor.save(), false);
      await workspace.choose(discardDraft: true);
      expect(repository.switches, 1);
      repository.gate!.complete();
      expect(await saving, true);
      expect(repository.saves, 1);
      await workspace.close();
      await editor.close();
    },
  );
  test('failed refresh preserves catalog and active filters', () async {
    final cubit = CatalogCubit(
      repository,
      clock: () => DateTime.utc(2026, 9, 21),
    );
    cubit.filter(currency: 'USD', horizon: 'long');
    final before = cubit.state.visible;
    repository.refreshError = StateError('НБУ недоступний');
    await cubit.refresh();
    expect(cubit.state.visible, before);
    expect(cubit.state.currency, 'USD');
    expect(cubit.state.busy, false);
    expect(cubit.state.error, isNotNull);
    expect(
      before.every(
        (b) => b.currency == 'USD' && b.maturity.compareTo('2028-09-21') >= 0,
      ),
      true,
    );
    await cubit.close();
  });
  test('models and state nested collections cannot mutate previous state', () {
    expect(() => catalog.json['assets'].clear(), throwsUnsupportedError);
    expect(
      () => catalog.bonds.first.json['payments'][0]['amount'] = '1',
      throwsUnsupportedError,
    );
    final state = EditorState(
      selected: {catalog.bonds.first.isin: catalog.bonds.first},
    );
    expect(() => state.selected.clear(), throwsUnsupportedError);
    expect(state.copyWith(name: 'Нова').selected.length, 1);
    expect(state.name, '');
  });
  test(
    'calculator invalidates stale result and recovers after invalid input',
    () async {
      final cubit = CalculatorCubit()..calculate();
      expect(cubit.state.result!.cost.toStringAsFixed(2), '99550.00');
      cubit.edit(quantity: 'bad');
      expect(cubit.state.result, isNull);
      cubit.calculate();
      expect(cubit.state.error, isNotNull);
      cubit.edit(quantity: '117');
      cubit.calculate();
      expect(cubit.state.error, isNull);
      await cubit.close();
    },
  );
  test('closing editor during save does not emit after close', () async {
    final editor = CollectionEditorCubit(repository)
      ..toggle(catalog.bonds.first, true)
      ..edit(name: 'План');
    repository.gate = Completer<void>();
    final saving = editor.save();
    await editor.close();
    repository.gate!.complete();
    expect(await saving, true);
  });
}
