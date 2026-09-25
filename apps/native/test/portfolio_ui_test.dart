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

  test('portfolio keeps factual purchase sale coupon redemption through lock and reopen', () async {
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

    expect(await cubit.createPortableBackup(), gateway.backupPath);
    expect(gateway.backupCalls, 1);
    expect(await cubit.rotateRecovery('a-new-secure-recovery-secret'), isTrue);
    expect(gateway.rotateRecoveryCalls, 1);
    expect(gateway.lastRecoverySecret, 'a-new-secure-recovery-secret');

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

    await cubit.addCoupon(
      isin: bond.isin,
      date: '2026-09-25',
      amount: '125.50',
      note: 'Factual coupon',
    );
    expect(cubit.state.payload!.cashEvents, hasLength(1));
    expect(cubit.state.payload!.cashEvents.single.kind, PrivateCashEventKind.coupon);
    expect(cubit.state.payload!.holdings.single.units, 3);

    await cubit.addRedemption(
      isin: bond.isin,
      units: 1,
      date: '2026-09-26',
      amount: '1000.00',
      note: 'Factual redemption',
    );
    expect(cubit.state.payload!.cashEvents, hasLength(2));
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

  testWidgets('portfolio recovery confirmation backup and rotation use visible controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final hub = FakeRepository(catalog);
    final gateway = FakePortfolioGateway(portableBackupSupported: true);
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

    await tester.tap(find.byKey(const ValueKey('portfolio-create')));
    await tester.pumpAndSettle();

    const secret = 'a-secure-recovery-secret';
    await tester.enterText(
      find.byKey(const ValueKey('portfolio-create-recovery-secret')),
      secret,
    );
    await tester.enterText(
      find.byKey(const ValueKey('portfolio-create-recovery-confirm')),
      'a-different-recovery-secret',
    );
    await tester.tap(find.byKey(const ValueKey('portfolio-create-save')));
    await tester.pumpAndSettle();
    expect(find.text('Паролі відновлення не збігаються.'), findsOneWidget);
    expect(gateway.stored, isNull);

    await tester.enterText(
      find.byKey(const ValueKey('portfolio-create-recovery-confirm')),
      secret,
    );
    await tester.tap(find.byKey(const ValueKey('portfolio-create-save')));
    await tester.pumpAndSettle();

    expect(find.text('Відновлення та резервна копія'), findsOneWidget);

    final backup = find.byKey(const ValueKey('portfolio-create-backup'));
    await tester.ensureVisible(backup);
    await tester.tap(backup);
    await tester.pumpAndSettle();
    expect(gateway.backupCalls, 1);
    expect(
      find.textContaining('OVDP-Hub-portfolio-backup.ovdp-vault.json'),
      findsOneWidget,
    );

    final rotate = find.byKey(const ValueKey('portfolio-rotate-recovery'));
    await tester.ensureVisible(rotate);
    await tester.tap(rotate);
    await tester.pumpAndSettle();

    const newSecret = 'another-secure-recovery-secret';
    await tester.enterText(
      find.byKey(const ValueKey('portfolio-rotate-recovery-secret')),
      newSecret,
    );
    await tester.enterText(
      find.byKey(const ValueKey('portfolio-rotate-recovery-confirm')),
      newSecret,
    );
    await tester.tap(
      find.byKey(const ValueKey('portfolio-rotate-recovery-save')),
    );
    await tester.pumpAndSettle();

    expect(gateway.rotateRecoveryCalls, 1);
    expect(gateway.lastRecoverySecret, newSecret);
    expect(find.text('Пароль відновлення оновлено.'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('portable encrypted backup can restore an empty local portfolio', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final hub = FakeRepository(catalog);
    final gateway = FakePortfolioGateway(portableBackupSupported: true);
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

    await tester.tap(find.byKey(const ValueKey('portfolio-restore-backup')));
    await tester.pumpAndSettle();

    const secret = 'a-secure-recovery-secret';
    await tester.enterText(
      find.byKey(const ValueKey('portfolio-restore-recovery-secret')),
      secret,
    );
    await tester.tap(find.byKey(const ValueKey('portfolio-restore-run')));
    await tester.pumpAndSettle();

    expect(gateway.restoreCalls, 1);
    expect(gateway.lastRecoverySecret, secret);
    expect(find.text('Відновлення та резервна копія'), findsOneWidget);
    expect(
      find.text('Портфель відновлено із зашифрованої резервної копії.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('sale redemption history and migration wizard use visible controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final bond = catalog.bonds.single;
    const closedIsin = 'UA4000999999';
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
        PrivateAcquisitionLot(
          id: 'lot-closed',
          isin: closedIsin,
          units: 1,
          acquiredOn: '2026-09-20',
          currency: bond.currency,
          tradeAmount: Decimal.parse('950'),
          feeStatus: AcquisitionFeeStatus.known,
          feeTotal: Decimal.parse('5'),
        ),
      ],
      disposals: [
        PrivateDisposal(
          id: 'sale-closed',
          isin: closedIsin,
          disposedOn: '2026-09-21',
          units: 1,
          currency: bond.currency,
          proceedsAmount: Decimal.parse('1000'),
          feeStatus: DisposalFeeStatus.known,
          feeTotal: Decimal.parse('2'),
          allocations: [
            PrivateDisposalLotAllocation(lotId: 'lot-closed', units: 1),
          ],
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

    expect(find.text('Фактичний грошовий підсумок'), findsOneWidget);
    expect(find.byKey(const ValueKey('portfolio-cash-UAH')), findsOneWidget);
    expect(find.byKey(const ValueKey('portfolio-closed-$closedIsin')), findsOneWidget);

    final addSale = find.byKey(const ValueKey('portfolio-add-sale'));
    await tester.ensureVisible(addSale);
    await tester.tap(addSale);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('portfolio-sale-date')),
      '24.09.2026',
    );
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
    expect(
      find.text('Невідомий через невідомі комісії'),
      findsOneWidget,
    );
    expect(find.text('Є невідомі комісії'), findsOneWidget);

    final addCoupon = find.byKey(const ValueKey('portfolio-add-coupon'));
    await tester.ensureVisible(addCoupon);
    await tester.tap(addCoupon);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('portfolio-coupon-date')),
      '25.09.2026',
    );
    await tester.enterText(
      find.byKey(const ValueKey('portfolio-coupon-amount')),
      '125.50',
    );
    await tester.enterText(
      find.byKey(const ValueKey('portfolio-coupon-note')),
      'Фактичний купон',
    );
    await tester.tap(find.byKey(const ValueKey('portfolio-save-coupon')));
    await tester.pumpAndSettle();

    expect(find.text('Купон · ${bond.isin}'), findsOneWidget);
    expect(find.text('× 3'), findsOneWidget);

    final addRedemption =
        find.byKey(const ValueKey('portfolio-add-redemption'));
    await tester.ensureVisible(addRedemption);
    await tester.tap(addRedemption);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('portfolio-redemption-date')),
      '26.09.2026',
    );
    await tester.enterText(
      find.byKey(const ValueKey('portfolio-redemption-amount')),
      '1000',
    );
    await tester.tap(find.byKey(const ValueKey('portfolio-save-redemption')));
    await tester.pumpAndSettle();

    expect(find.text('Погашення · ${bond.isin}'), findsOneWidget);
    expect(find.text('× 2'), findsOneWidget);

    final details = find.byKey(ValueKey('portfolio-details-${bond.isin}'));
    await tester.ensureVisible(details);
    await tester.tap(details);
    await tester.pumpAndSettle();

    final detailsDialog =
        find.byKey(ValueKey('portfolio-isin-dialog-${bond.isin}'));
    expect(detailsDialog, findsOneWidget);
    expect(
      find.descendant(
        of: detailsDialog,
        matching: find.text('Деталі позиції · ${bond.isin}'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailsDialog,
        matching: find.text('Поточна кількість: 2'),
      ),
      findsOneWidget,
    );
    for (final fact in ['Купівля', 'Продаж', 'Купон', 'Погашення']) {
      expect(
        find.descendant(
          of: detailsDialog,
          matching: find.text('$fact · ${bond.isin}'),
        ),
        findsOneWidget,
      );
    }

    await tester.tap(
      find.byKey(ValueKey('portfolio-details-close-${bond.isin}')),
    );
    await tester.pumpAndSettle();

    final closedDetails =
        find.byKey(const ValueKey('portfolio-closed-details-$closedIsin'));
    await tester.ensureVisible(closedDetails);
    await tester.tap(closedDetails);
    await tester.pumpAndSettle();

    final closedDialog =
        find.byKey(const ValueKey('portfolio-isin-dialog-$closedIsin'));
    expect(closedDialog, findsOneWidget);
    expect(
      find.descendant(
        of: closedDialog,
        matching: find.text('Поточна кількість: 0'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: closedDialog,
        matching: find.text('Закрита позиція'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: closedDialog,
        matching: find.text('Купівля · $closedIsin'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: closedDialog,
        matching: find.text('Продаж · $closedIsin'),
      ),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const ValueKey('portfolio-details-close-$closedIsin')),
    );
    await tester.pumpAndSettle();

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
