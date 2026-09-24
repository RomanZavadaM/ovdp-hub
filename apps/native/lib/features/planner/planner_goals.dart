import 'package:decimal/decimal.dart';
import '../../pricing.dart';
import '../../models.dart';
import 'planner_engine.dart';
import 'planner_scenario.dart';

class CashExpense {
  final String name, date;
  final Decimal amount;
  final PlannerNeedType type;

  CashExpense(
    this.name,
    this.date,
    this.amount, {
    this.type = PlannerNeedType.oneOff,
  });

  bool get isReserveFloor => type == PlannerNeedType.reserveFloor;
}

int _cashRequirementCompare(CashExpense a, CashExpense b) {
  final byDate = a.date.compareTo(b.date);
  if (byDate != 0) return byDate;
  if (a.isReserveFloor == b.isReserveFloor) return 0;
  return a.isReserveFloor ? -1 : 1;
}

Decimal _maxDecimal(Decimal a, Decimal b) => a >= b ? a : b;

class ExpenseBalance {
  final CashExpense expense;
  final Decimal available, remaining, shortfall;
  ExpenseBalance(this.expense, this.available, this.remaining, this.shortfall);
}

DateTime addMonthsClamped(DateTime base, int months) {
  final target = DateTime.utc(base.year, base.month + months, 1);
  final lastDay = DateTime.utc(target.year, target.month + 1, 0).day;
  return DateTime.utc(
    target.year,
    target.month,
    base.day > lastDay ? lastDay : base.day,
  );
}

List<CashExpense> expandPlannerNeeds(
  Iterable<PlannerNeed> needs, {
  required String start,
}) {
  final startDate = isoDate(start);
  final expenses = <CashExpense>[];

  for (final need in needs) {
    switch (need.type) {
      case PlannerNeedType.oneOff:
        expenses.add(
          CashExpense(
            need.name,
            need.date,
            need.amount,
            type: PlannerNeedType.oneOff,
          ),
        );
        break;
      case PlannerNeedType.recurring:
        final base = isoDate(need.date);
        for (var i = 0; i < need.occurrences!; i++) {
          final date = addMonthsClamped(base, need.everyMonths! * i)
              .toIso8601String()
              .substring(0, 10);
          expenses.add(
            CashExpense(
              need.occurrences == 1
                  ? need.name
                  : '${need.name} · ${i + 1}/${need.occurrences}',
              date,
              need.amount,
              type: PlannerNeedType.recurring,
            ),
          );
        }
        break;
      case PlannerNeedType.reserveFloor:
        expenses.add(
          CashExpense(
            need.name,
            need.date,
            need.amount,
            type: PlannerNeedType.reserveFloor,
          ),
        );
    }
  }

  for (final expense in expenses) {
    if (isoDate(expense.date).isBefore(startDate)) {
      throw const FormatException('planner.expenses_before_start');
    }
  }
  expenses.sort(_cashRequirementCompare);
  return List.unmodifiable(expenses);
}

List<CashExpense> readExpenses(Map<String, String> c) =>
    expandPlannerNeeds(
      plannerNeedsFromCriteria(c),
      start: c['start']!,
    );

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
  var activeFloor = Decimal.zero;
  final result = <ExpenseBalance>[];
  final ordered = [...expenses]..sort(_cashRequirementCompare);
  for (final e in ordered) {
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

    if (e.isReserveFloor) {
      activeFloor = e.amount;
      final shortfall = cash < activeFloor
          ? activeFloor - cash
          : Decimal.zero;
      result.add(ExpenseBalance(e, cash, cash, shortfall));
      continue;
    }

    final remaining = cash - e.amount;
    final shortfall = remaining < activeFloor
        ? activeFloor - remaining
        : Decimal.zero;
    result.add(ExpenseBalance(e, cash, remaining, shortfall));

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
  final orderedExpenses = [...expenses]..sort(_cashRequirementCompare);
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
    var activeFloor = reserve;
    final balances = orderedExpenses.map((e) {
      if (e.isReserveFloor) {
        activeFloor = _maxDecimal(reserve, e.amount);
      } else {
        spent += e.amount;
      }
      return budget - spent - activeFloor;
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
    final calendar = expenseCalendar(
      selected,
      budget,
      start,
      orderedExpenses,
      delay,
    );
    if (balances.every((v) => v >= Decimal.zero) &&
        calendar.every(
          (row) =>
              row.shortfall == Decimal.zero &&
              row.remaining >= reserve,
        ) &&
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
