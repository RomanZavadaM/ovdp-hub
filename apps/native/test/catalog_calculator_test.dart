import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/calculator/accrued_interest.dart';
import 'package:ovdp_hub/features/calculator/calculator_cubit.dart';
import 'package:ovdp_hub/main.dart';
import 'package:ovdp_hub/models.dart';
import 'package:ovdp_hub/ui/studio_design.dart';

import 'support/fake_repository.dart';

const _isin = 'UA4000000017';

Map<String, dynamic> _bondJson({bool earlyRedemption = false}) => {
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
    if (earlyRedemption)
      {'date': '2026-03-01', 'kind': 'EARLY_REDEMPTION', 'amount': '1000'},
  ],
};

Catalog _catalog() => Catalog.parse(
  jsonEncode({
    'schemaVersion': 1,
    'retrievedAt': '2025-09-01T00:00:00Z',
    'assets': [_bondJson()],
  }),
);

void main() {
  group('accrued interest', () {
    final bond = Bond(_bondJson());

    test('is zero on the issue date and on a coupon date', () {
      expect(accruedInterestPerBond(bond, '2025-06-25'), Decimal.zero);
      expect(accruedInterestPerBond(bond, '2025-12-24'), Decimal.zero);
    });

    test('grows linearly inside the coupon period', () {
      // 91 of 182 days in the first period.
      expect(
        accruedInterestPerBond(bond, '2025-09-24'),
        Decimal.parse('29.85'),
      );
      // 90 of 182 days in the second period: 59.70 * 90 / 182 = 29.5219...
      expect(
        accruedInterestPerBond(bond, '2026-03-24'),
        Decimal.parse('29.52'),
      );
    });

    test('rejects dates outside the issue lifetime', () {
      expect(
        () => accruedInterestPerBond(bond, '2025-06-24'),
        throwsFormatException,
      );
      expect(
        () => accruedInterestPerBond(bond, '2026-06-24'),
        throwsFormatException,
      );
    });

    test('future payments exclude past and conditional cash flows', () {
      final withEarly = Bond(_bondJson(earlyRedemption: true));
      expect(futureBondPayments(withEarly, '2025-12-24'), [
        {'date': '2026-06-24', 'amount': '59.70'},
        {'date': '2026-06-24', 'amount': '1000'},
      ]);
      expect(bondHasConditionalRedemption(withEarly), isTrue);
      expect(bondHasConditionalRedemption(bond), isFalse);
    });
  });

  test('catalog bond mode prices the real schedule with accrued interest', () async {
    final repository = FakeRepository(_catalog());
    final cubit = CalculatorCubit(
      repository: repository,
      clock: () => DateTime(2025, 9, 24, 10),
    );

    cubit.selectBond(_isin);
    expect(cubit.state.isin, _isin);
    expect(cubit.state.price, '1000');
    expect(cubit.state.settlement, '2025-09-24');

    cubit.edit(quantity: '10', fee: '0');
    cubit.calculate();
    expect(cubit.state.error, isNull);
    expect(cubit.state.accruedPerBond, Decimal.parse('29.85'));
    final result = cubit.state.result!;
    expect(result.cost, Decimal.parse('10298.50'));
    expect(result.receipts, Decimal.parse('11194.00'));
    expect(result.profit, Decimal.parse('895.50'));
    expect(result.yield, greaterThan(0.11));
    expect(result.yield, lessThan(0.13));

    cubit.edit(settlement: '2026-06-24');
    cubit.calculate();
    expect(cubit.state.result, isNull);
    expect(cubit.state.error!.code, 'calculator.after_maturity');

    cubit.selectBond(null);
    expect(cubit.state.isin, isNull);
    cubit.edit(quantity: '117', fee: '100');
    cubit.calculate();
    expect(cubit.state.result!.cost.toStringAsFixed(2), '99550.00');

    await cubit.close();
    await repository.dispose();
  });

  testWidgets('calculator prices a catalog bond through visible controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final future = _bondJson()
      ..['maturityDate'] = '2035-06-20'
      ..['payments'] = _payments2035();
    final repository = FakeRepository(
      Catalog.parse(
        jsonEncode({
          'schemaVersion': 1,
          'retrievedAt': '2025-09-01T00:00:00Z',
          'assets': [future],
        }),
      ),
    );
    await tester.pumpWidget(OvdpApp(repository: repository));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(StudioSidebar),
        matching: find.byIcon(Icons.calculate_outlined),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('calculator-bond')));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining(_isin).last);
    await tester.pumpAndSettle();

    expect(find.text('Калькулятор облігації з каталогу'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('calculator-run')));
    await tester.pumpAndSettle();

    expect(find.textContaining('НКД на одну облігацію'), findsOneWidget);
    expect(find.textContaining('Дохідність до погашення'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}

List<Map<String, String>> _payments2035() => [
  for (var year = 2026; year < 2035; year++) ...[
    {'date': '$year-06-20', 'kind': 'COUPON', 'amount': '59.70'},
    {'date': '$year-12-20', 'kind': 'COUPON', 'amount': '59.70'},
  ],
  {'date': '2035-06-20', 'kind': 'COUPON', 'amount': '59.70'},
  {'date': '2035-06-20', 'kind': 'REDEMPTION', 'amount': '1000'},
];
