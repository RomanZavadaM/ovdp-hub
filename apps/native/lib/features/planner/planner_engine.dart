import 'package:decimal/decimal.dart';
import '../../models.dart';
import '../../pricing.dart';

class PlanPosition {
  final Bond bond;
  final int quantity;
  final Decimal unitCost;
  final bool nominalEstimate;
  PlanPosition(
    this.bond,
    this.quantity,
    this.unitCost, {
    this.nominalEstimate = true,
  });
  Decimal get cost => (unitCost * Decimal.fromInt(quantity)).round(scale: 2);
  Map<String, dynamic> toJson() => {
    'isin': bond.isin,
    'quantity': quantity,
    'unitCost': unitCost.toString(),
    'nominalEstimate': nominalEstimate,
  };
}

class MonthlyFlow {
  final String month;
  final Decimal coupons, principal;
  MonthlyFlow(this.month, this.coupons, this.principal);
  Decimal get total => coupons + principal;
}

class PlanSummary {
  final Decimal cost,
      reserve,
      couponsByNeed,
      principalByNeed,
      availableByNeed,
      shortfall;
  final List<MonthlyFlow> months;
  final bool containsEstimates, hasConditionalPayments;
  PlanSummary({
    required this.cost,
    required this.reserve,
    required this.couponsByNeed,
    required this.principalByNeed,
    required this.availableByNeed,
    required this.shortfall,
    required Iterable<MonthlyFlow> months,
    required this.containsEstimates,
    required this.hasConditionalPayments,
  }) : months = List.unmodifiable(months);
}

List<Bond> eligibleBonds(
  Catalog catalog,
  String currency,
  String start,
  String minDate,
  String maxDate,
) {
  final after = isoDate(start), min = isoDate(minDate), max = isoDate(maxDate);
  if (!['UAH', 'USD', 'EUR'].contains(currency) ||
      min.isAfter(max) ||
      !max.isAfter(after)) {
    throw const FormatException('Перевірте валюту та діапазон погашення');
  }
  return catalog.bonds.where((b) {
    final maturity = isoDate(b.maturity);
    return b.currency == currency &&
        maturity.isAfter(after) &&
        !maturity.isBefore(min) &&
        !maturity.isAfter(max);
  }).toList()..sort((a, b) {
    final result = a.maturity.compareTo(b.maturity);
    return result == 0 ? a.isin.compareTo(b.isin) : result;
  });
}

List<PlanPosition> makeLadder(
  List<Bond> candidates,
  Decimal budget,
  Decimal desiredReserve,
) {
  if (budget <= Decimal.zero ||
      desiredReserve < Decimal.zero ||
      desiredReserve >= budget) {
    throw const FormatException('Бюджет має перевищувати резерв');
  }
  final investable = budget - desiredReserve;
  final byDate = <String, Bond>{};
  for (final bond in candidates) {
    if (money(bond.json['nominal'].toString()) <= investable) {
      byDate.putIfAbsent(bond.maturity, () => bond);
    }
  }
  final ordered = byDate.values.toList()
    ..sort((a, b) => a.maturity.compareTo(b.maturity));
  if (ordered.isEmpty) {
    throw const FormatException(
      'Немає випусків, які відповідають строкам і бюджету за номіналом',
    );
  }
  final slots = {
    0,
    ordered.length ~/ 2,
    ordered.length - 1,
  }.map((i) => ordered[i]).toList();
  final positions = <PlanPosition>[];
  for (final bond in slots) {
    final price = money(bond.json['nominal'].toString());
    final quantity = (investable / (price * Decimal.fromInt(slots.length)))
        .floor()
        .toInt();
    if (quantity > 0) positions.add(PlanPosition(bond, quantity, price));
  }
  if (positions.isEmpty) {
    final bond = ordered.first,
        price = money(ordered.first.json['nominal'].toString());
    positions.add(
      PlanPosition(bond, (investable / price).floor().toInt(), price),
    );
  }
  return positions;
}

PlanSummary summarizePlan({
  required List<PlanPosition> positions,
  required String currency,
  required Decimal budget,
  required String start,
  required String needDate,
  required Decimal needAmount,
}) {
  final startDate = isoDate(start), need = isoDate(needDate);
  if (budget <= Decimal.zero ||
      needAmount < Decimal.zero ||
      need.isBefore(startDate)) {
    throw const FormatException('Перевірте бюджет, дату та суму потреби');
  }
  final unique = <String>{};
  var cost = Decimal.zero,
      couponsByNeed = Decimal.zero,
      principalByNeed = Decimal.zero;
  var last = need;
  var conditional = false;
  final amounts = <String, (Decimal, Decimal)>{};
  for (final position in positions) {
    final b = position.bond;
    if (!unique.add(b.isin) ||
        b.currency != currency ||
        position.quantity < 1 ||
        position.quantity > 1000000 ||
        position.unitCost <= Decimal.zero ||
        !isoDate(b.maturity).isAfter(startDate)) {
      throw const FormatException('Некоректна позиція або змішані валюти');
    }
    cost += position.cost;
    if (isoDate(b.maturity).isAfter(last)) last = isoDate(b.maturity);
    for (final payment in b.payments) {
      final date = isoDate(payment['date'] as String);
      if (!date.isAfter(startDate) || date.isAfter(isoDate(b.maturity))) {
        continue;
      }
      if (payment['kind'] == 'EARLY_REDEMPTION') {
        conditional = true;
        continue;
      }
      final amount =
          (money(payment['amount'].toString()) *
                  Decimal.fromInt(position.quantity))
              .round(scale: 2);
      final coupon = payment['kind'] == 'COUPON';
      final month = (payment['date'] as String).substring(0, 7);
      final existing = amounts[month] ?? (Decimal.zero, Decimal.zero);
      amounts[month] = (
        existing.$1 + (coupon ? amount : Decimal.zero),
        existing.$2 + (coupon ? Decimal.zero : amount),
      );
      if (!date.isAfter(need)) {
        if (coupon) {
          couponsByNeed += amount;
        } else {
          principalByNeed += amount;
        }
      }
    }
  }
  if (cost > budget) {
    throw const FormatException(
      'Вартість позицій перевищує бюджет — зменште кількість або змініть бюджет',
    );
  }
  if (last.year - startDate.year > 100) {
    throw const FormatException('Горизонт календаря перевищує 100 років');
  }
  final months = <MonthlyFlow>[];
  for (
    var d = DateTime.utc(startDate.year, startDate.month);
    !d.isAfter(DateTime.utc(last.year, last.month));
    d = DateTime.utc(d.year, d.month + 1)
  ) {
    final month = d.toIso8601String().substring(0, 7),
        values =
            amounts[d.toIso8601String().substring(0, 7)] ??
            (Decimal.zero, Decimal.zero);
    months.add(MonthlyFlow(month, values.$1, values.$2));
  }
  final reserve = budget - cost,
      available = reserve + couponsByNeed + principalByNeed;
  return PlanSummary(
    cost: cost,
    reserve: reserve,
    couponsByNeed: couponsByNeed,
    principalByNeed: principalByNeed,
    availableByNeed: available,
    shortfall: needAmount > available ? needAmount - available : Decimal.zero,
    months: months,
    containsEstimates: positions.any((p) => p.nominalEstimate),
    hasConditionalPayments: conditional,
  );
}
