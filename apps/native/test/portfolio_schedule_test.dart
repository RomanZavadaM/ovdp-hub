import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/portfolio/portfolio_schedule.dart';
import 'package:ovdp_hub/features/portfolio/private_portfolio.dart';
import 'package:ovdp_hub/main.dart';
import 'package:ovdp_hub/models.dart';
import 'package:ovdp_hub/ui/studio_design.dart';

import 'support/fake_portfolio_gateway.dart';
import 'support/fake_repository.dart';

const _isin = 'UA4000000017';

Catalog _catalog() => Catalog.parse(
  jsonEncode({
    'schemaVersion': 1,
    'retrievedAt': '2025-09-01T00:00:00Z',
    'assets': [
      {
        'isin': _isin,
        'currency': 'UAH',
        'nominal': '1000',
        'nominalRate': '11.94',
        'issueDate': '2025-06-25',
        'maturityDate': '2026-06-24',
        'description': 'Test',
        'couponPeriodDays': 182,
        'payments': [
          {'date': '2025-12-24', 'kind': 'COUPON', 'amount': '59.70'},
          {'date': '2026-06-24', 'kind': 'COUPON', 'amount': '59.70'},
          {'date': '2026-06-24', 'kind': 'REDEMPTION', 'amount': '1000'},
        ],
      },
    ],
  }),
);

PrivatePortfolioPayload _payload({bool recordFirstCoupon = true}) =>
    PrivatePortfolioPayload(
      portfolioId: 'primary',
      acquisitionLots: [
        PrivateAcquisitionLot(
          id: 'lot-1',
          isin: _isin,
          units: 5,
          acquiredOn: '2025-07-01',
          currency: 'UAH',
          tradeAmount: Decimal.parse('5010'),
          feeStatus: AcquisitionFeeStatus.known,
          feeTotal: Decimal.zero,
        ),
      ],
      disposals: [
        PrivateDisposal(
          id: 'sale-1',
          isin: _isin,
          disposedOn: '2026-01-10',
          units: 2,
          currency: 'UAH',
          proceedsAmount: Decimal.parse('2010'),
          feeStatus: DisposalFeeStatus.known,
          feeTotal: Decimal.zero,
          allocations: [PrivateDisposalLotAllocation(lotId: 'lot-1', units: 2)],
        ),
      ],
      cashEvents: [
        if (recordFirstCoupon)
          PrivateCashEvent(
            id: 'coupon-1',
            isin: _isin,
            kind: PrivateCashEventKind.coupon,
            date: '2025-12-26',
            currency: 'UAH',
            amount: Decimal.parse('298.50'),
          ),
      ],
    );

void main() {
  test('units held follow purchases and sales before the payment day', () {
    final payload = _payload();
    expect(unitsHeldBefore(payload, _isin, '2025-07-01'), 0);
    expect(unitsHeldBefore(payload, _isin, '2025-07-02'), 5);
    expect(unitsHeldBefore(payload, _isin, '2026-01-10'), 5);
    expect(unitsHeldBefore(payload, _isin, '2026-01-11'), 3);
  });

  test('expected payments scale the schedule by units held on the date', () {
    final expected = expectedPortfolioPayments(
      _payload(),
      _catalog(),
      from: '2025-07-01',
      until: '2026-12-31',
    );
    expect(
      expected.map((e) => '${e.date} ${e.kind.name} ${e.units} ${e.amount}'),
      [
        '2025-12-24 coupon 5 298.5',
        '2026-06-24 coupon 3 179.1',
        '2026-06-24 redemption 3 3000',
      ],
    );
    expect(
      expectedPortfolioPayments(
        _payload(),
        _catalog(),
        from: '2026-01-01',
        until: '2026-03-01',
      ),
      isEmpty,
    );
  });

  test('past payments without a matching record are flagged as hints', () {
    final hints = possiblyUnrecordedPayments(
      _payload(),
      _catalog(),
      today: '2026-07-01',
    );
    expect(
      hints.map((e) => '${e.date} ${e.kind.name}'),
      ['2026-06-24 coupon', '2026-06-24 redemption'],
    );

    final withoutFirst = possiblyUnrecordedPayments(
      _payload(recordFirstCoupon: false),
      _catalog(),
      today: '2026-01-01',
    );
    expect(withoutFirst.single.date, '2025-12-24');
    expect(withoutFirst.single.amount, Decimal.parse('298.50'));
  });

  testWidgets('expected receipts and unrecorded hints use visible controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    String iso(DateTime value) => value.toIso8601String().substring(0, 10);
    final now = DateTime.now();
    final pastCoupon = iso(now.subtract(const Duration(days: 30)));
    final futureCoupon = iso(now.add(const Duration(days: 60)));
    final maturity = iso(now.add(const Duration(days: 240)));
    final catalog = Catalog.parse(
      jsonEncode({
        'schemaVersion': 1,
        'retrievedAt': '2025-09-01T00:00:00Z',
        'assets': [
          {
            'isin': _isin,
            'currency': 'UAH',
            'nominal': '1000',
            'nominalRate': '11.94',
            'issueDate': iso(now.subtract(const Duration(days: 400))),
            'maturityDate': maturity,
            'description': 'Test',
            'couponPeriodDays': 182,
            'payments': [
              {'date': pastCoupon, 'kind': 'COUPON', 'amount': '59.70'},
              {'date': futureCoupon, 'kind': 'COUPON', 'amount': '59.70'},
              {'date': maturity, 'kind': 'REDEMPTION', 'amount': '1000'},
            ],
          },
        ],
      }),
    );
    final gateway = FakePortfolioGateway(
      stored: PrivatePortfolioPayload(
        portfolioId: 'primary',
        acquisitionLots: [
          PrivateAcquisitionLot(
            id: 'lot-1',
            isin: _isin,
            units: 4,
            acquiredOn: iso(now.subtract(const Duration(days: 100))),
            currency: 'UAH',
            tradeAmount: Decimal.parse('4000'),
            feeStatus: AcquisitionFeeStatus.known,
            feeTotal: Decimal.zero,
          ),
        ],
      ),
    );
    await tester.pumpWidget(
      OvdpApp(repository: FakeRepository(catalog), portfolioGateway: gateway),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(StudioSidebar),
        matching: find.byIcon(Icons.account_balance_wallet_outlined),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('portfolio-open')));
    await tester.pumpAndSettle();

    expect(find.text('Очікувані надходження (12 місяців)'), findsOneWidget);
    expect(find.byKey(const ValueKey('portfolio-expected')), findsOneWidget);
    expect(find.textContaining('4238.80 UAH'), findsOneWidget);

    final record = find.byKey(ValueKey('portfolio-record-$_isin-$pastCoupon'));
    await tester.ensureVisible(record);
    await tester.tap(record);
    await tester.pumpAndSettle();

    final amount = tester.widget<TextField>(
      find.byKey(const ValueKey('portfolio-coupon-amount')),
    );
    expect(amount.controller!.text, '238.80');
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
