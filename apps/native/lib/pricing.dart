import 'dart:math' as math;
import 'package:decimal/decimal.dart';
import 'models.dart';

Decimal money(String value) {
  if (!RegExp(r'^\d{1,12}(\.\d{1,8})?$').hasMatch(value)) {
    throw const FormatException(
      'Введіть невід’ємну суму, десятковий роздільник — крапка',
    );
  }
  return Decimal.parse(value);
}

class BondResult {
  final Decimal cost, receipts, profit;
  final double yield;
  BondResult(this.cost, this.receipts, this.profit, this.yield);
}

BondResult calculateBond({
  required int quantity,
  required String cleanPrice,
  required String accruedInterest,
  required String fee,
  required String settlement,
  required List<Map<String, String>> payments,
}) {
  if (quantity < 1 ||
      quantity > 1000000 ||
      payments.isEmpty ||
      payments.length > 100) {
    throw const FormatException('Перевірте кількість та графік виплат');
  }
  final start = isoDate(settlement);
  final dirty = money(cleanPrice) + money(accruedInterest);
  if (dirty <= Decimal.zero) {
    throw const FormatException('Ціна має бути додатною');
  }
  final cost =
      (dirty * Decimal.fromInt(quantity)).round(scale: 2) +
      money(fee).round(scale: 2);
  var receipts = Decimal.zero;
  final future = <(double, double)>[];
  for (final payment in payments) {
    final days = isoDate(payment['date']!).difference(start).inDays;
    if (days <= 0) {
      throw const FormatException('Виплата має бути після дати розрахунку');
    }
    final amount = (money(payment['amount']!) * Decimal.fromInt(quantity))
        .round(scale: 2);
    receipts += amount;
    // Monetary operations above are decimal. Floating point is confined to the
    // numerical root solver for an indicative ACT/365F yield, never stored money.
    future.add((days / 365, amount.toDouble()));
  }
  if (receipts <= Decimal.zero) {
    throw const FormatException('Потрібна додатна виплата');
  }
  double npv(double rate) => future.fold(
    -cost.toDouble(),
    (sum, f) => sum + f.$2 / math.pow(1 + rate, f.$1),
  );
  var low = -0.999999, high = 1.0;
  while (npv(high) > 0 && high < 1000000) {
    high *= 2;
  }
  if (npv(low) < 0 || npv(high) > 0) {
    throw const FormatException('Дохідність поза діапазоном');
  }
  for (var i = 0; i < 150; i++) {
    final middle = (low + high) / 2;
    if (npv(middle) > 0) {
      low = middle;
    } else {
      high = middle;
    }
  }
  return BondResult(cost, receipts, receipts - cost, (low + high) / 2);
}
