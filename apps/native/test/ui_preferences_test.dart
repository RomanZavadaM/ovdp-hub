import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/appearance/appearance_cubit.dart';
import 'package:ovdp_hub/l10n/hub_locale.dart';
import 'package:ovdp_hub/main.dart';
import 'package:ovdp_hub/models.dart';
import 'package:ovdp_hub/ui/dashboard_design.dart';
import 'package:ovdp_hub/ui_preferences.dart';

import 'support/fake_repository.dart';

Future<void> _pumpUi(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump(const Duration(milliseconds: 250));
}

class _MemoryUiPreferences implements UiPreferencesPersistence {
  UiPreferencesSnapshot _current;

  _MemoryUiPreferences([
    this._current = const UiPreferencesSnapshot(),
  ]);

  @override
  UiPreferencesSnapshot get current => _current;

  @override
  Future<void> selectLanguage(AppLanguage language) {
    _current = _current.copyWith(language: language);
    return Future<void>.value();
  }

  @override
  Future<void> selectAppearance(HubAppearance appearance) {
    _current = _current.copyWith(appearance: appearance);
    return Future<void>.value();
  }

  @override
  Future<void> flush() => Future<void>.value();
}

void main() {
  late Catalog catalog;

  setUpAll(() async {
    final data =
        jsonDecode(await File('assets/nbu-snapshot.json').readAsString())
            as Map<String, dynamic>;
    data['assets'] = [(data['assets'] as List).last];
    catalog = Catalog.parse(jsonEncode(data));
  });

  test('UI preferences round-trip and corrupt data fail safe', () async {
    final directory = await Directory.systemTemp.createTemp(
      'ovdp-ui-preferences-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/ui-preferences.json');

    final store = await UiPreferencesStore.open(file);
    expect(store.current.language, AppLanguage.uk);
    expect(store.current.appearance, HubAppearance.studio);

    await store.selectLanguage(AppLanguage.en);
    await store.selectAppearance(HubAppearance.dashboard);
    await store.flush();

    final reopened = await UiPreferencesStore.open(file);
    expect(reopened.current.language, AppLanguage.en);
    expect(reopened.current.appearance, HubAppearance.dashboard);

    await file.writeAsString('{broken json', flush: true);
    final recovered = await UiPreferencesStore.open(file);
    expect(recovered.current.language, AppLanguage.uk);
    expect(recovered.current.appearance, HubAppearance.studio);
  });

  testWidgets('visible controls update persisted preference contract', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final preferences = _MemoryUiPreferences();

    await tester.pumpWidget(
      OvdpApp(
        repository: FakeRepository(catalog),
        initialUiPreferences: preferences.current,
        uiPreferencesStore: preferences,
      ),
    );
    await _pumpUi(tester);

    await tester.tap(find.byTooltip('Мова / Language'));
    await _pumpUi(tester);
    await tester.tap(find.text('English'));
    await _pumpUi(tester);

    await tester.tap(find.byTooltip('Interface design'));
    await _pumpUi(tester);
    await tester.tap(find.text('Light Dashboard design'));
    await _pumpUi(tester);

    expect(find.byType(DashboardHeader), findsOneWidget);
    expect(find.text('Catalog'), findsWidgets);
    expect(preferences.current.language, AppLanguage.en);
    expect(preferences.current.appearance, HubAppearance.dashboard);

    await tester.pumpWidget(const SizedBox.shrink());
    await _pumpUi(tester);
  });

  testWidgets('restored snapshot is applied on a new app construction', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final restored = _MemoryUiPreferences(
      const UiPreferencesSnapshot(
        language: AppLanguage.en,
        appearance: HubAppearance.dashboard,
      ),
    );

    await tester.pumpWidget(
      OvdpApp(
        repository: FakeRepository(catalog),
        initialUiPreferences: restored.current,
        uiPreferencesStore: restored,
      ),
    );
    await _pumpUi(tester);

    expect(find.byType(DashboardHeader), findsOneWidget);
    expect(find.text('Catalog'), findsWidgets);
    expect(find.text('Каталог'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await _pumpUi(tester);
  });
}
