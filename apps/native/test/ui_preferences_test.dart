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

  testWidgets('language and appearance survive an app restart', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final directory = await Directory.systemTemp.createTemp(
      'ovdp-ui-preferences-widget-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/ui-preferences.json');
    final store = await UiPreferencesStore.open(file);

    await tester.pumpWidget(
      OvdpApp(
        repository: FakeRepository(catalog),
        initialUiPreferences: store.current,
        uiPreferencesStore: store,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Каталог'), findsWidgets);
    await tester.tap(find.byTooltip('Мова / Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Catalog'), findsWidgets);
    await tester.tap(find.byTooltip('Interface design'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Light Dashboard design'));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardHeader), findsOneWidget);
    expect(store.current.language, AppLanguage.en);
    expect(store.current.appearance, HubAppearance.dashboard);
    await store.flush();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    final reopened = await UiPreferencesStore.open(file);
    expect(reopened.current.language, AppLanguage.en);
    expect(reopened.current.appearance, HubAppearance.dashboard);

    await tester.pumpWidget(
      OvdpApp(
        repository: FakeRepository(catalog),
        initialUiPreferences: reopened.current,
        uiPreferencesStore: reopened,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DashboardHeader), findsOneWidget);
    expect(find.text('Catalog'), findsWidgets);
    expect(find.text('Каталог'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
