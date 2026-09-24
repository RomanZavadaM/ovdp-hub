import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/build_info.dart';
import 'package:ovdp_hub/main.dart';
import 'package:ovdp_hub/models.dart';
import 'package:ovdp_hub/release_contract.dart';
import 'package:ovdp_hub/ui/dashboard_design.dart';
import 'package:ovdp_hub/ui/studio_design.dart';

import 'support/fake_portfolio_gateway.dart';
import 'support/fake_repository.dart';

void main() {
  late Catalog catalog;

  setUpAll(() {
    final data =
        jsonDecode(File('assets/nbu-snapshot.json').readAsStringSync())
            as Map<String, dynamic>;
    data['assets'] = [(data['assets'] as List).last];
    catalog = Catalog.parse(jsonEncode(data));
  });

  test('compiled release contract declares all three appearances', () {
    final contract = releaseContract();
    expect(contract['version'], appVersion);
    expect(contract['displayVersion'], appDisplayVersion);
    expect(
      contract['appearances'],
      ['classic', 'studio', 'dashboard'],
    );
    expect(contract['defaultAppearance'], 'studio');
    expect(
      contract['appearanceLabelsUk'],
      {
        'classic': 'Класичний дизайн',
        'studio': 'Дизайн «Робочий кабінет»',
        'dashboard': 'Дизайн «Світла панель»',
      },
    );
  });

  testWidgets('user can see and switch all three designs', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      OvdpApp(
        repository: FakeRepository(catalog),
        portfolioGateway: FakePortfolioGateway(supported: false),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(StudioSidebar), findsOneWidget);
    expect(
      find.text('Тестова версія $appDisplayVersion'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Дизайн інтерфейсу'));
    await tester.pumpAndSettle();

    expect(find.text('Класичний дизайн'), findsOneWidget);
    expect(find.text('Дизайн «Робочий кабінет»'), findsOneWidget);
    expect(find.text('Дизайн «Світла панель»'), findsOneWidget);

    await tester.tap(find.text('Дизайн «Світла панель»'));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardHeader), findsOneWidget);
    expect(find.byType(DashboardStatusBar), findsOneWidget);
    expect(find.byType(StudioSidebar), findsNothing);

    await tester.tap(find.byTooltip('Дизайн інтерфейсу'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Класичний дизайн'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(DashboardHeader), findsNothing);
    expect(find.byType(StudioSidebar), findsNothing);

    await tester.tap(find.byTooltip('Дизайн інтерфейсу'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Дизайн «Робочий кабінет»'));
    await tester.pumpAndSettle();
    expect(find.byType(StudioSidebar), findsOneWidget);
    expect(find.byType(DashboardHeader), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
