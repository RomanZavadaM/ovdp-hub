import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/portfolio/portfolio_cubit.dart';
import 'package:ovdp_hub/main.dart';
import 'package:ovdp_hub/models.dart';
import 'package:ovdp_hub/ui/studio_design.dart';

import 'support/fake_portfolio_gateway.dart';
import 'support/fake_repository.dart';

void main() {
  late Catalog catalog;

  setUpAll(() {
    final json =
        jsonDecode(File('assets/nbu-snapshot.json').readAsStringSync())
            as Map<String, dynamic>;
    json['assets'] = [(json['assets'] as List).last];
    catalog = Catalog.parse(jsonEncode(json));
  });

  test('portfolio keeps factual acquisition through lock and reopen', () async {
    final hub = FakeRepository(catalog);
    final gateway = FakePortfolioGateway();
    final cubit = PortfolioCubit(
      hub,
      gateway,
      clock: () => DateTime.utc(2026, 9, 24, 18),
    );

    await cubit.initialize();
    expect(cubit.state.exists, isFalse);

    await cubit.create('a-secure-recovery-secret');
    expect(cubit.state.unlocked, isTrue);

    final bond = catalog.bonds.single;
    await cubit.addAcquisition(
      isin: bond.isin,
      units: 3,
      acquiredOn: '2026-09-24',
      tradeAmount: '2960.50',
      feeKnown: true,
      feeTotal: '15.00',
      brokerAccountLabel: 'Test broker',
    );

    expect(cubit.state.payload!.acquisitionLots, hasLength(1));
    expect(cubit.state.payload!.holdings.single.isin, bond.isin);
    expect(cubit.state.payload!.holdings.single.units, 3);
    expect(gateway.stored!.holdings.single.units, 3);

    await cubit.lock();
    expect(cubit.state.unlocked, isFalse);

    await cubit.open();
    expect(cubit.state.payload!.holdings.single.units, 3);

    await cubit.close();
    await hub.dispose();
  });

  testWidgets('economic pulse is persistent and My portfolio is navigable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final hub = FakeRepository(catalog);
    final gateway = FakePortfolioGateway();
    await tester.pumpWidget(
      OvdpApp(
        repository: hub,
        portfolioGateway: gateway,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Економічний пульс'), findsOneWidget);
    expect(find.text('41.25 ₴'), findsOneWidget);
    expect(find.text('48.50 ₴'), findsOneWidget);
    expect(find.text('Мій портфель'), findsWidgets);

    final portfolioNavigation = find.descendant(
      of: find.byType(StudioSidebar),
      matching: find.byIcon(Icons.account_balance_wallet_outlined),
    );
    expect(portfolioNavigation, findsOneWidget);
    await tester.tap(portfolioNavigation);
    await tester.pumpAndSettle();

    expect(find.text('Створити захищений портфель'), findsOneWidget);
    expect(find.text('Економічний пульс'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
