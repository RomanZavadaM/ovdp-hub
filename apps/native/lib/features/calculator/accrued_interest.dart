import 'package:decimal/decimal.dart';

import '../../models.dart';
import '../../pricing.dart';

/// Accrued coupon interest per bond on [settlement] (ISO `YYYY-MM-DD`).
///
/// Uses the common OVDP convention: the next coupon amount multiplied by the
/// days elapsed since the previous coupon date (or the issue date in the first
/// period) and divided by the days of the current coupon period, rounded to
/// two decimals. The value is indicative; the seller's settlement amount
/// prevails.
Decimal accruedInterestPerBond(Bond bond, String settlement) {
  final date = isoDate(settlement);
  final issue = isoDate(bond.json['issueDate'] as String);
  final maturity = isoDate(bond.maturity);
  if (date.isBefore(issue)) {
    throw const FormatException('calculator.before_issue');
  }
  if (!date.isBefore(maturity)) {
    throw const FormatException('calculator.after_maturity');
  }

  final coupons = bond.payments
      .where((payment) => payment['kind'] == 'COUPON')
      .map(
        (payment) => (
          date: isoDate(payment['date'] as String),
          amount: money(payment['amount'].toString()),
        ),
      )
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  final nextIndex = coupons.indexWhere((coupon) => coupon.date.isAfter(date));
  if (nextIndex < 0) return Decimal.zero;
  final next = coupons[nextIndex];
  final previousDate = nextIndex == 0 ? issue : coupons[nextIndex - 1].date;
  final periodDays = next.date.difference(previousDate).inDays;
  final elapsedDays = date.difference(previousDate).inDays;
  if (periodDays <= 0 || elapsedDays <= 0) return Decimal.zero;

  return (next.amount *
          Decimal.fromInt(elapsedDays) /
          Decimal.fromInt(periodDays))
      .toDecimal(scaleOnInfinitePrecision: 10)
      .round(scale: 2);
}

/// Future cash flows per bond strictly after [settlement], excluding
/// conditional early redemptions.
List<Map<String, String>> futureBondPayments(Bond bond, String settlement) {
  final date = isoDate(settlement);
  return [
    for (final payment in bond.payments)
      if (payment['kind'] != 'EARLY_REDEMPTION' &&
          isoDate(payment['date'] as String).isAfter(date))
        {
          'date': payment['date'] as String,
          'amount': payment['amount'].toString(),
        },
  ]..sort((a, b) => a['date']!.compareTo(b['date']!));
}

bool bondHasConditionalRedemption(Bond bond) =>
    bond.payments.any((payment) => payment['kind'] == 'EARLY_REDEMPTION');
