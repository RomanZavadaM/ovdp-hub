import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/portfolio/portfolio_cubit.dart';
import 'package:ovdp_hub/features/portfolio/private_portfolio.dart';
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

  test('portfolio keeps factual purchase sale redemption through lock and reopen', () async {
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
      units: 5,
      acquiredOn: '2026-09-24',
      tradeAmount: '2960.50',
      feeKnown: true,
      feeTotal: '15.00',
      brokerAccountLabel: 'Test broker',
    );

    expect(cubit.state.payload!.acquisitionLots, hasLength(1));
    expect(cubit.state.payload!.holdings.single.isin, bond.isin);
    expect(cubit.state.payload!.holdings.single.units, 5);
    expect(gateway.stored!.holdings.single.units, 5);

    final lotId = cubit.state.payload!.acquisitionLots.single.id;
    await cubit.addDisposal(
      isin: bond.isin,
      disposedOn: '2026-09-24',
      proceedsAmount: '2010.00',
      feeKnown: true,
      feeTotal: '8.00',
      lotAllocations: {lotId: 2},
      note: 'Factual sale',
    );
    expect(cubit.state.payload!.disposals, hasLength(1));
    expect(cubit.state.payload!.holdings.single.units, 3);

    await cubit.addRedemption(
      isin: bond.isin,
      units: 1,
      date: '2026-09-25',
      amount: '1000.00',
      note: 'Factual redemption',
    );
    expect(cubit.state.payload!.cashEvents, hasLength(1));
    expect(cubit.state.payload!.holdings.single.units, 2);
    expect(gateway.stored!.holdings.single.units, 2);

    await cubit.migrateLegacy();
    expect(cubit.state.migrationReport!.encryptedCopyVerified, isTrue);
    expect(gateway.migrationCalls, 1);
    expect(gateway.lastMigrationWorkspacePath, 'local');

    await cubit.lock();
    expect(cubit.state.unlocked, isFalse);

    await cubit.open();
    expect(cubit.state.payload!.holdings.single.units, 2);

    await cubit.close();
    await hub.dispose();
  });

  testWidgets('sale redemption history and migration wizard use visible controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final bond = catalog.bonds.single;
    final payload = PrivatePortfolioPayload(
      portfolioId: 'primary',
      acquisitionLots: [
        PrivateAcquisitionLot(
          id: 'lot-test',
          isin: bond.isin,
          units: 5,
          acquiredOn: '2026-09-24',
          currency: bond.currency,
          tradeAmount: Decimal.parse('4900'),
          feeStatus: AcquisitionFeeStatus.known,
          feeTotal: Decimal.parse('10'),
        ),
      ],
    );
    final hub = FakeRepository(catalog);
    final gateway = FakePortfolioGateway(stored: payload);

    await tester.pumpWidget(
      OvdpApp(repository: hub, portfolioGateway: gateway),
    );
    await tester.pumpAndSettle();

    final portfolioNavigation = find.descendant(
      of: find.byType(StudioSidebar),
      matching: find.byIcon(Icons.account_balance_wallet_outlined),
    );
    await tester.tap(portfolioNavigation);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Відкрити портфель'));
    await tester.pumpAndSettle();

    final addSale = find.byKey(const ValueKey('portfolio-add-sale'));
    await tester.ensureVisible(addSale);
    await tester.tap(addSale);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('portfolio-sale-proceeds')),
      '2100',
    );
    await tester.enterText(
      find.byKey(const ValueKey('portfolio-sale-lot-lot-test')),
      '2',
    );
    await tester.tap(find.byKey(const ValueKey('portfolio-save-sale')));
    await tester.pumpAndSettle();

    expect(find.text('Продаж · ${bond.isin}'), findsOneWidget);
    expect(find.text('× 3'), findsOneWidget);

    final addRedemption =
        find.byKey(const ValueKey('portfolio-add-redemption'));
    await tester.ensureVisible(addRedemption);
    await tester.tap(addRedemption);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('portfolio-redemption-amount')),
      '1000',
    );
    await tester.tap(find.byKey(const ValueKey('portfolio-save-redemption')));
    await tester.pumpAndSettle();

    expect(find.text('Погашення · ${bond.isin}'), findsOneWidget);
    expect(find.text('× 2'), findsOneWidget);

    final migration = find.byKey(const ValueKey('portfolio-migration'));
    await tester.ensureVisible(migration);
    await tester.tap(migration);
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Вихідні JSON-файли залишаться на місці. Програма не видаляє їх автоматично.',
      ),
      findsWidgets,
    );

    await tester.tap(find.byKey(const ValueKey('portfolio-migration-run')));
    await tester.pumpAndSettle();

    expect(find.text('Зашифровану копію перевірено'), findsOneWidget);
    expect(find.text('Вихідних plaintext-файлів залишилось'), findsOneWidget);
    expect(gateway.migrationCalls, 1);
    expect(gateway.lastMigrationWorkspacePath, 'local');

    await tester.tap(find.byKey(const ValueKey('portfolio-migration-done')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
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
