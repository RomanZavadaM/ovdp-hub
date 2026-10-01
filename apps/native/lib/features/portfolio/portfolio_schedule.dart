import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

import '../../models.dart';
import '../../pricing.dart';
import 'private_portfolio.dart';

/// A coupon or redemption the public NBU schedule implies for the units
/// recorded in the private portfolio. Amounts are per-bond schedule amounts
/// multiplied by the units held; they are expectations, not facts.
@immutable
class ExpectedPortfolioPayment {
  final String isin;
  final String date;
  final PrivateCashEventKind kind;
  final String currency;
  final int units;
  final Decimal amount;

  const ExpectedPortfolioPayment({
    required this.isin,
    required this.date,
    required this.kind,
    required this.currency,
    required this.units,
    required this.amount,
  });
}

/// Units of [isin] held at the start of [date]: acquisitions, sales and
/// redemptions recorded strictly before that day.
int unitsHeldBefore(PrivatePortfolioPayload payload, String isin, String date) {
  var units = 0;
  for (final lot in payload.acquisitionLots) {
    if (lot.isin == isin && lot.acquiredOn.compareTo(date) < 0) {
      units += lot.units;
    }
  }
  for (final disposal in payload.disposals) {
    if (disposal.isin == isin && disposal.disposedOn.compareTo(date) < 0) {
      units -= disposal.units;
    }
  }
  for (final event in payload.cashEvents) {
    if (event.isin == isin &&
        event.kind == PrivateCashEventKind.redemption &&
        event.date.compareTo(date) < 0) {
      units -= event.units ?? 0;
    }
  }
  return units < 0 ? 0 : units;
}

/// Scheduled coupons and redemptions between [from] and [until] (inclusive,
/// ISO dates) for issues recorded in the portfolio. Conditional early
/// redemptions and issues missing from [catalog] are skipped.
List<ExpectedPortfolioPayment> expectedPortfolioPayments(
  PrivatePortfolioPayload payload,
  Catalog catalog, {
  required String from,
  required String until,
}) {
  final isins = payload.acquisitionLots.map((lot) => lot.isin).toSet();
  final bonds = {
    for (final bond in catalog.bonds)
      if (isins.contains(bond.isin)) bond.isin: bond,
  };
  final result = <ExpectedPortfolioPayment>[];
  for (final bond in bonds.values) {
    for (final payment in bond.payments) {
      final kind = switch (payment['kind']) {
        'COUPON' => PrivateCashEventKind.coupon,
        'REDEMPTION' => PrivateCashEventKind.redemption,
        _ => null,
      };
      final date = payment['date'] as String;
      if (kind == null ||
          date.compareTo(from) < 0 ||
          date.compareTo(until) > 0) {
        continue;
      }
      final units = unitsHeldBefore(payload, bond.isin, date);
      if (units <= 0) continue;
      result.add(
        ExpectedPortfolioPayment(
          isin: bond.isin,
          date: date,
          kind: kind,
          currency: bond.currency,
          units: units,
          amount: (money(payment['amount'].toString()) * Decimal.fromInt(units))
              .round(scale: 2),
        ),
      );
    }
  }
  result.sort((a, b) {
    final byDate = a.date.compareTo(b.date);
    if (byDate != 0) return byDate;
    final byIsin = a.isin.compareTo(b.isin);
    if (byIsin != 0) return byIsin;
    return a.kind.index.compareTo(b.kind.index);
  });
  return result;
}

/// Past scheduled payments (before [today]) with no recorded fact of the same
/// kind for the same issue within a few days of the schedule date. They are
/// hints for the user to check their statement, never invented facts.
List<ExpectedPortfolioPayment> possiblyUnrecordedPayments(
  PrivatePortfolioPayload payload,
  Catalog catalog, {
  required String today,
  int daysBefore = 5,
  int daysAfter = 10,
}) {
  if (payload.acquisitionLots.isEmpty) return const [];
  final first = payload.acquisitionLots
      .map((lot) => lot.acquiredOn)
      .reduce((a, b) => a.compareTo(b) <= 0 ? a : b);
  final yesterday = isoDate(today)
      .subtract(const Duration(days: 1))
      .toIso8601String()
      .substring(0, 10);
  final expected = expectedPortfolioPayments(
    payload,
    catalog,
    from: first,
    until: yesterday,
  );
  return [
    for (final item in expected)
      if (!payload.cashEvents.any((event) {
        if (event.isin != item.isin || event.kind != item.kind) return false;
        final gap = isoDate(event.date).difference(isoDate(item.date)).inDays;
        return gap >= -daysBefore && gap <= daysAfter;
      }))
        item,
  ];
}
