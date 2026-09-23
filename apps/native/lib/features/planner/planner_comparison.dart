import 'package:decimal/decimal.dart';

import '../../models.dart';
import 'planner_engine.dart';
import 'planner_fees.dart';
import 'planner_fx.dart';
import 'planner_goals.dart';
import 'planner_scenario.dart';
import 'planner_taxes.dart';

enum ComparisonProfitBasis {
  grossBeforeFees,
  afterFeesBeforeTax,
  verifiedAfterTax,
}

class ComparisonVariant {
  final String label;
  final String name;
  final PlannerStrategy strategy;
  final List<PlanPosition> positions;
  final PlannerFeeImpact feeImpact;
  final PlannerTaxImpact taxImpact;
  final PlannerFxImpact fxImpact;
  final List<PositionExitAssumption> exits;
  final List<ExpenseBalance> expenseBalances;
  final Decimal displayedProfit;
  final ComparisonProfitBasis profitBasis;
  final Decimal reserveAfterKnownPurchaseFee;
  final Decimal totalShortfall;

  ComparisonVariant({
    required this.label,
    required this.name,
    required this.strategy,
    required Iterable<PlanPosition> positions,
    required this.feeImpact,
    required this.taxImpact,
    required this.fxImpact,
    required Iterable<PositionExitAssumption> exits,
    required Iterable<ExpenseBalance> expenseBalances,
    required this.displayedProfit,
    required this.profitBasis,
    required this.reserveAfterKnownPurchaseFee,
    required this.totalShortfall,
  }) : positions = List.unmodifiable(positions),
       exits = List.unmodifiable(exits),
       expenseBalances = List.unmodifiable(expenseBalances);

  String get composition => positions
      .map((p) => '${p.bond.isin} × ${p.quantity}')
      .join(', ');
}

class ScenarioComparison {
  final String currency;
  final Decimal budget;
  final Decimal reserve;
  final String startDate;
  final String minMaturity;
  final String maxMaturity;
  final int settlementDelayDays;
  final List<ComparisonVariant> variants;

  ScenarioComparison({
    required this.currency,
    required this.budget,
    required this.reserve,
    required this.startDate,
    required this.minMaturity,
    required this.maxMaturity,
    required this.settlementDelayDays,
    required Iterable<ComparisonVariant> variants,
  }) : variants = List.unmodifiable(variants);
}

String _needSignature(PlannerNeed need) =>
    '${need.type.name}|${need.date}|${need.amount}|'
    '${need.everyMonths ?? ''}|${need.occurrences ?? ''}';

List<String> _needSignatures(PlannerScenario scenario) =>
    scenario.needs.map(_needSignature).toList()..sort();

void _ensureComparable(
  PlannerScenario base,
  PlannerScenario candidate,
) {
  if (base.currency != candidate.currency ||
      base.budget != candidate.budget ||
      base.reserve != candidate.reserve ||
      base.startDate != candidate.startDate ||
      base.minMaturity != candidate.minMaturity ||
      base.maxMaturity != candidate.maxMaturity ||
      base.settlementDelayDays != candidate.settlementDelayDays ||
      _needSignatures(base).join('||') !=
          _needSignatures(candidate).join('||')) {
    throw const FormatException('planner.comparison_assumptions_mismatch');
  }
  if (base.groupId != null &&
      candidate.groupId != null &&
      base.groupId != candidate.groupId) {
    throw const FormatException('planner.comparison_group_mismatch');
  }
}

List<CashExpense> _comparisonExpenses(PlannerScenario scenario) {
  if (scenario.needs.any((n) => n.type == PlannerNeedType.reserveFloor)) {
    throw const FormatException('planner.comparison_need_model_unsupported');
  }
  return expandPlannerNeeds(
    scenario.needs,
    start: scenario.startDate,
  );
}

List<PlanPosition> _positionsFor(
  SavedSet saved,
  PlannerScenario scenario,
) {
  final bonds = {for (final b in saved.bonds) b.isin: b};
  return scenario.positions.map((draft) {
    final bond = bonds[draft.isin];
    if (bond == null) {
      throw const FormatException('planner.comparison_missing_bond');
    }
    return PlanPosition(
      bond,
      draft.quantity,
      draft.unitCost,
      nominalEstimate: draft.price.kind == PriceValueKind.nominalEstimate,
    );
  }).toList(growable: false);
}

ComparisonVariant _variant(
  SavedSet saved,
  PlannerScenario scenario,
  String label,
) {
  final positions = _positionsFor(saved, scenario);
  if (positions.isEmpty) {
    throw const FormatException('planner.comparison_empty_scenario');
  }
  final exits = scenario.effectivePositionExits;
  final exitOverrides = <String, PlanExitOverride>{
    for (final exit in exits)
      exit.isin: PlanExitOverride(
        exit.isin,
        exit.date,
        exit.price.effectiveUnitCost!,
      ),
  };
  final primaryNeed = scenario.needs.first;
  summarizePlan(
    positions: positions,
    currency: scenario.currency,
    budget: scenario.budget,
    start: scenario.startDate,
    needDate: primaryNeed.date,
    needAmount: primaryNeed.amount,
    exits: exitOverrides,
  );
  final feeImpact = evaluatePurchaseFeeImpact(
    fees: scenario.fees,
    positions: positions,
    currency: scenario.currency,
    budget: scenario.budget,
    start: scenario.startDate,
    exits: exitOverrides,
  );
  final profitBeforeTax =
      feeImpact.known ? feeImpact.profitAfterPurchaseFee : null;
  final taxImpact = evaluateTaxImpact(
    taxes: scenario.taxes,
    scenarioDate: scenario.startDate,
    profitBeforeTax: profitBeforeTax,
  );

  final displayedProfit =
      taxImpact.known && taxImpact.profitAfterTax != null
      ? taxImpact.profitAfterTax!
      : feeImpact.known && feeImpact.profitAfterPurchaseFee != null
      ? feeImpact.profitAfterPurchaseFee!
      : feeImpact.grossProfit;
  final profitBasis =
      taxImpact.known && taxImpact.profitAfterTax != null
      ? ComparisonProfitBasis.verifiedAfterTax
      : feeImpact.known
      ? ComparisonProfitBasis.afterFeesBeforeTax
      : ComparisonProfitBasis.grossBeforeFees;

  final reserveAfterFee =
      feeImpact.reserveAfterPurchaseFee ?? feeImpact.grossReserve;
  final fxImpact = evaluateFxImpact(
    fx: scenario.fx,
    scenarioCurrency: scenario.currency,
    invested: feeImpact.totalInitialCost ?? feeImpact.grossPositionCost,
    reserve: reserveAfterFee,
    profit: displayedProfit,
  );

  final calendarBudget = feeImpact.purchaseFee == null
      ? scenario.budget
      : scenario.budget - feeImpact.purchaseFee!;
  final expenses = _comparisonExpenses(scenario);
  final balances = expenseCalendar(
    positions,
    calendarBudget,
    scenario.startDate,
    expenses,
    scenario.settlementDelayDays,
    exits: exitOverrides,
  );
  final totalShortfall = balances.fold(
    Decimal.zero,
    (sum, row) => sum + row.shortfall,
  );

  return ComparisonVariant(
    label: label,
    name: scenario.name,
    strategy: scenario.strategy,
    positions: positions,
    feeImpact: feeImpact,
    taxImpact: taxImpact,
    fxImpact: fxImpact,
    exits: exits,
    expenseBalances: balances,
    displayedProfit: displayedProfit,
    profitBasis: profitBasis,
    reserveAfterKnownPurchaseFee: reserveAfterFee,
    totalShortfall: totalShortfall,
  );
}

ScenarioComparison compareSavedScenarios(
  List<SavedSet> savedSets, {
  required DateTime now,
}) {
  if (savedSets.length < 2 || savedSets.length > 3) {
    throw const FormatException('planner.comparison_two_or_three');
  }
  final scenarios = savedSets
      .map((saved) => PlannerScenario.fromSavedSet(saved, now: now))
      .toList(growable: false);
  final base = scenarios.first;
  if (base.needs.isEmpty) {
    throw const FormatException('planner.comparison_empty_needs');
  }
  for (final scenario in scenarios.skip(1)) {
    _ensureComparable(base, scenario);
  }
  final labels = ['A', 'B', 'C'];
  final variants = <ComparisonVariant>[];
  for (var i = 0; i < scenarios.length; i++) {
    variants.add(_variant(savedSets[i], scenarios[i], labels[i]));
  }

  return ScenarioComparison(
    currency: base.currency,
    budget: base.budget,
    reserve: base.reserve,
    startDate: base.startDate,
    minMaturity: base.minMaturity,
    maxMaturity: base.maxMaturity,
    settlementDelayDays: base.settlementDelayDays,
    variants: variants,
  );
}
