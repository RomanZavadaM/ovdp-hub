import 'package:decimal/decimal.dart';
import '../../pricing.dart';
import '../../models.dart';
import 'planner_engine.dart';

class CashExpense {
  final String name, date;
  final Decimal amount;
  CashExpense(this.name, this.date, this.amount);
}

class ExpenseBalance {
  final CashExpense expense;
  final Decimal available, remaining, shortfall;
  ExpenseBalance(this.expense, this.available, this.remaining, this.shortfall);
}

List<CashExpense> readExpenses(Map<String, String> c) {
  final expenses = <CashExpense>[
    CashExpense(
      c['needName'] ?? 'Основна потреба',
      c['needDate']!,
      money(c['needAmount']!),
    ),
  ];
  final count = int.parse(c['expenseCount'] ?? '0');
  if (count < 0 || count > 50) {
    throw const FormatException('planner.too_many_expenses');
  }
  for (var i = 0; i < count; i++) {
    expenses.add(
      CashExpense(
        c['expenseName$i'] ?? 'Витрата ${i + 2}',
        c['expenseDate$i']!,
        money(c['expenseAmount$i']!),
      ),
    );
  }
  for (final e in expenses) {
    if (isoDate(e.date).isBefore(isoDate(c['start']!))) {
      throw const FormatException(
        'planner.expenses_before_start',
      );
    }
  }
  expenses.sort((a, b) => a.date.compareTo(b.date));
  return List.unmodifiable(expenses);
}

// Only contractual, unconditional payments count. A delay models cash reaching
// the account later than the issuer's payment date; no early-sale assumption.
Decimal receiptsBy(
  PlanPosition p,
  String start,
  String end,
  int delay, {
  PlanExitOverride? exit,
}) {
  if (exit != null) validatePlanExit(p, exit, start);
  var sum = Decimal.zero;
  final saleDate = exit == null ? null : isoDate(exit.date);
  for (final payment in p.bond.payments) {
    if (!['COUPON', 'REDEMPTION'].contains(payment['kind'])) continue;
    final date = isoDate(payment['date'] as String);
    if (date.isAfter(isoDate(start)) &&
        !date.isAfter(isoDate(p.bond.maturity)) &&
        (saleDate == null || date.isBefore(saleDate)) &&
        !date.add(Duration(days: delay)).isAfter(isoDate(end))) {
      sum += (money(payment['amount'].toString()) * Decimal.fromInt(p.quantity))
          .round(scale: 2);
    }
  }
  if (exit != null &&
      !saleDate!.add(Duration(days: delay)).isAfter(isoDate(end))) {
    sum +=
        (exit.unitPrice * Decimal.fromInt(p.quantity)).round(scale: 2);
  }
  return sum;
}

List<ExpenseBalance> expenseCalendar(
  List<PlanPosition> positions,
  Decimal budget,
  String start,
  List<CashExpense> expenses,
  int delay, {
  Map<String, PlanExitOverride> exits = const {},
}) {
  final cost = positions.fold(Decimal.zero, (s, p) => s + p.cost);
  var spent = Decimal.zero;
  final result = <ExpenseBalance>[];
  for (final e in expenses) {
    final cash =
        budget -
        cost +
        positions.fold(
          Decimal.zero,
          (s, p) =>
              s +
              receiptsBy(
                p,
                start,
                e.date,
                delay,
                exit: exits[p.bond.isin],
              ),
        ) -
        spent;
    final remaining = cash - e.amount;
    result.add(
      ExpenseBalance(
        e,
        cash,
        remaining,
        remaining < Decimal.zero ? -remaining : Decimal.zero,
      ),
    );
    // Keep a negative balance: an unfunded earlier expense is never silently
    // forgotten or treated as an external cash injection.
    spent += e.amount;
  }
  return List.unmodifiable(result);
}

Decimal totalProfit(
  List<PlanPosition> positions,
  String start, {
  Map<String, PlanExitOverride> exits = const {},
}) =>
    positions.fold(Decimal.zero, (s, p) {
      final exit = exits[p.bond.isin];
      final end = exit?.date ?? p.bond.maturity;
      return s + receiptsBy(p, start, end, 0, exit: exit) - p.cost;
    });

/// Bounded heuristic: compare several greedy whole-lot allocations, constrained
/// by cash at every expense date. It is deliberately not a global optimum claim.
List<PlanPosition> suggestProfitablePlan({
  required List<PlanPosition> offers,
  required Decimal budget,
  required Decimal reserve,
  required String start,
  required List<CashExpense> expenses,
  required int delay,
}) {
  if (budget <= Decimal.zero ||
      reserve < Decimal.zero ||
      reserve > budget ||
      delay < 0 ||
      delay > 30) {
    throw const FormatException(
      'planner.invalid_budget_reserve_delay',
    );
  }
  final orderedExpenses = [...expenses]
    ..sort((a, b) => a.date.compareTo(b.date));
  final profitByIsin = <String, Decimal>{};
  final drains = <String, List<Decimal>>{};
  final unique = <String>{};
  String? currency;
  for (final p in offers) {
    currency ??= p.bond.currency;
    if (p.quantity != 1 ||
        !unique.add(p.bond.isin) ||
        p.bond.currency != currency ||
        p.unitCost <= Decimal.zero ||
        p.unitCost != p.unitCost.round(scale: 2)) {
      throw const FormatException(
        'planner.unique_single_currency_positions',
      );
    }
    profitByIsin[p.bond.isin] = totalProfit([p], start);
    drains[p.bond.isin] = orderedExpenses
        .map((e) => p.unitCost - receiptsBy(p, start, e.date, delay))
        .toList();
  }
  final ranked = offers
      .where((p) => profitByIsin[p.bond.isin]! > Decimal.zero)
      .toList();
  ranked.sort((a, b) {
    final ratio = (profitByIsin[b.bond.isin]! * a.cost).compareTo(
      profitByIsin[a.bond.isin]! * b.cost,
    );
    return ratio == 0 ? a.bond.isin.compareTo(b.bond.isin) : ratio;
  });
  if (ranked.isEmpty) {
    throw const FormatException(
      'planner.no_profitable_positions',
    );
  }
  List<PlanPosition>? best;
  var bestProfit = Decimal.parse('-1');
  for (var seed = 0; seed < ranked.length && seed < 8; seed++) {
    final order = [ranked[seed], ...ranked.where((p) => p != ranked[seed])];
    final selected = <PlanPosition>[];
    var remaining = budget - reserve,
        spent = Decimal.zero,
        profit = Decimal.zero;
    final balances = orderedExpenses.map((e) {
      spent += e.amount;
      return budget - spent - reserve;
    }).toList();
    for (final offer in order) {
      if (remaining < offer.unitCost) continue;
      var qty = (remaining / offer.unitCost).floor().toInt().clamp(0, 1000000);
      final changes = drains[offer.bond.isin]!;
      for (var i = 0; i < balances.length; i++) {
        if (changes[i] > Decimal.zero) {
          final capacity = (balances[i] / changes[i]).floor().toInt();
          if (capacity < qty) qty = capacity;
        }
      }
      if (qty > 0) {
        selected.add(
          PlanPosition(
            offer.bond,
            qty,
            offer.unitCost,
            nominalEstimate: offer.nominalEstimate,
          ),
        );
        final n = Decimal.fromInt(qty);
        remaining -= offer.unitCost * n;
        profit += profitByIsin[offer.bond.isin]! * n;
        for (var i = 0; i < balances.length; i++) {
          balances[i] -= changes[i] * n;
        }
      }
    }
    if (balances.every((v) => v >= Decimal.zero) &&
        expenseCalendar(
          selected,
          budget,
          start,
          orderedExpenses,
          delay,
        ).every((row) => row.remaining >= reserve) &&
        profit > bestProfit) {
      best = selected;
      bestProfit = profit;
    }
  }
  if (best == null) {
    throw const FormatException(
      'planner.no_covering_variant',
    );
  }
  return best;
}
