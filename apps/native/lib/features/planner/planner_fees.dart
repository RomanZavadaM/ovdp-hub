import 'package:decimal/decimal.dart';

import 'planner_engine.dart';
import 'planner_goals.dart';
import 'planner_scenario.dart';

class PlannerFeeImpact {
  final bool known;
  final Decimal? purchaseFee;
  final Decimal grossPositionCost;
  final Decimal? totalInitialCost;
  final Decimal grossReserve;
  final Decimal? reserveAfterPurchaseFee;
  final Decimal grossProfit;
  final Decimal? profitAfterPurchaseFee;
  final bool simpleAggregateEditable;
  final bool hasDeferredRules;

  const PlannerFeeImpact({
    required this.known,
    required this.purchaseFee,
    required this.grossPositionCost,
    required this.totalInitialCost,
    required this.grossReserve,
    required this.reserveAfterPurchaseFee,
    required this.grossProfit,
    required this.profitAfterPurchaseFee,
    required this.simpleAggregateEditable,
    required this.hasDeferredRules,
  });
}

Decimal _sumPositionCost(Iterable<PlanPosition> positions) =>
    positions.fold(Decimal.zero, (sum, p) => sum + p.cost);

int _sumUnits(Iterable<PlanPosition> positions) =>
    positions.fold(0, (sum, p) => sum + p.quantity);

Decimal? purchaseFeeAmount({
  required FeeAssumptions fees,
  required Iterable<PlanPosition> positions,
  required String currency,
}) {
  if (fees.status == FeeAssumptionStatus.unknown) return null;

  final materialized = positions.toList(growable: false);
  final tradeValue = _sumPositionCost(materialized);
  final units = _sumUnits(materialized);
  var result = Decimal.zero;

  for (final rule in fees.rules.where((r) => r.event == FeeEvent.purchase)) {
    switch (rule.kind) {
      case FeeKind.flat:
        if (rule.currency != currency) {
          throw const FormatException('planner.fee_currency_mismatch');
        }
        result += rule.value;
      case FeeKind.perUnit:
        if (rule.currency != currency) {
          throw const FormatException('planner.fee_currency_mismatch');
        }
        result += rule.value * Decimal.fromInt(units);
      case FeeKind.percentOfTrade:
        result +=
            (tradeValue * rule.value / Decimal.fromInt(100)).toDecimal(
              scaleOnInfinitePrecision: 8,
            );
      case FeeKind.recurring:
        throw const FormatException('planner.unsupported_purchase_fee_rule');
    }
  }
  return result.round(scale: 2);
}

bool isSimpleAggregatePurchaseFee(FeeAssumptions fees, String currency) {
  if (fees.status == FeeAssumptionStatus.unknown || fees.rules.isEmpty) {
    return true;
  }
  if (fees.rules.length != 1) return false;
  final rule = fees.rules.single;
  return rule.id == 'ui-purchase-fee' &&
      rule.kind == FeeKind.flat &&
      rule.event == FeeEvent.purchase &&
      rule.currency == currency;
}

Decimal? simpleAggregatePurchaseFee(FeeAssumptions fees, String currency) {
  if (fees.status == FeeAssumptionStatus.unknown) return null;
  if (fees.rules.isEmpty) return Decimal.zero;
  if (!isSimpleAggregatePurchaseFee(fees, currency)) return null;
  return fees.rules.single.value.round(scale: 2);
}

PlannerFeeImpact evaluatePurchaseFeeImpact({
  required FeeAssumptions fees,
  required Iterable<PlanPosition> positions,
  required String currency,
  required Decimal budget,
  required String start,
}) {
  final materialized = positions.toList(growable: false);
  final grossCost = _sumPositionCost(materialized);
  final grossReserve = budget - grossCost;
  final grossProfit = totalProfit(materialized, start);
  final fee = purchaseFeeAmount(
    fees: fees,
    positions: materialized,
    currency: currency,
  );
  final known = fee != null;
  final total = known ? grossCost + fee! : null;
  final reserve = known ? budget - total! : null;
  final netProfit = known ? grossProfit - fee! : null;
  final deferred = fees.status == FeeAssumptionStatus.known &&
      fees.rules.any((r) => r.event != FeeEvent.purchase);

  return PlannerFeeImpact(
    known: known,
    purchaseFee: fee,
    grossPositionCost: grossCost,
    totalInitialCost: total,
    grossReserve: grossReserve,
    reserveAfterPurchaseFee: reserve,
    grossProfit: grossProfit,
    profitAfterPurchaseFee: netProfit,
    simpleAggregateEditable: isSimpleAggregatePurchaseFee(fees, currency),
    hasDeferredRules: deferred,
  );
}
