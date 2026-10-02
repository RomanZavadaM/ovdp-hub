import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/planner/planner_engine.dart';
import 'package:ovdp_hub/features/planner/planner_goals.dart';
import 'package:ovdp_hub/models.dart';

Bond _bond(String isin, String maturity, List<Map<String, String>> payments) =>
    Bond({
      'isin': isin,
      'currency': 'UAH',
      'nominal': '1000',
      'nominalRate': '12',
      'issueDate': '2025-01-01',
      'maturityDate': maturity,
      'description': 'Test',
      'couponPeriodDays': 182,
      'payments': payments,
    });

void main() {
  test('plan annual yield matches a single zero-coupon position', () {
    // 1000 paid back after exactly 365 days for 900 => 11.111...% a year.
    final bond = _bond('UA4000000017', '2027-01-01', [
      {'date': '2027-01-01', 'kind': 'REDEMPTION', 'amount': '1000'},
    ]);
    final value = planAnnualYield(
      [PlanPosition(bond, 2, Decimal.parse('900'))],
      '2026-01-01',
    );
    expect(value, closeTo(1000 / 900 - 1, 0.000001));
  });

  test('purchase fee lowers the plan yield and long bonds are annualized', () {
    final short = _bond('UA4000000017', '2027-01-01', [
      {'date': '2027-01-01', 'kind': 'REDEMPTION', 'amount': '1000'},
    ]);
    final long = _bond('UA4000000025', '2029-01-01', [
      {'date': '2029-01-01', 'kind': 'REDEMPTION', 'amount': '1300'},
    ]);
    final shortYield = planAnnualYield(
      [PlanPosition(short, 1, Decimal.parse('900'))],
      '2026-01-01',
    )!;
    final longYield = planAnnualYield(
      [PlanPosition(long, 1, Decimal.parse('900'))],
      '2026-01-01',
    )!;
    // The long bond earns more in total (400 vs 100) but less per year.
    expect(longYield, lessThan(shortYield));

    final withFee = planAnnualYield(
      [PlanPosition(short, 1, Decimal.parse('900'))],
      '2026-01-01',
      extraCost: Decimal.parse('10'),
    )!;
    expect(withFee, lessThan(shortYield));
    expect(withFee, closeTo(1000 / 910 - 1, 0.000001));
  });

  test('no future inflows gives no yield', () {
    final matured = _bond('UA4000000017', '2026-01-01', [
      {'date': '2026-01-01', 'kind': 'REDEMPTION', 'amount': '1000'},
    ]);
    expect(planAnnualYield(const [], '2026-01-01'), isNull);
    expect(
      planAnnualYield(
        [PlanPosition(matured, 1, Decimal.parse('900'))],
        '2026-01-01',
      ),
      isNull,
    );
  });
}
