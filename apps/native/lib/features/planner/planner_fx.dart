import 'package:decimal/decimal.dart';

import 'planner_scenario.dart';

class PlannerFxImpact {
  final bool active;
  final bool deferred;
  final FxAssumption? assumption;
  final Decimal? invested;
  final Decimal? reserve;
  final Decimal? profit;

  const PlannerFxImpact({
    required this.active,
    required this.deferred,
    required this.assumption,
    required this.invested,
    required this.reserve,
    required this.profit,
  });
}

PlannerFxImpact evaluateFxImpact({
  required List<FxAssumption> fx,
  required String scenarioCurrency,
  required Decimal invested,
  required Decimal reserve,
  required Decimal profit,
}) {
  if (fx.isEmpty) {
    return const PlannerFxImpact(
      active: false,
      deferred: false,
      assumption: null,
      invested: null,
      reserve: null,
      profit: null,
    );
  }

  if (fx.length != 1 || fx.single.fromCurrency != scenarioCurrency) {
    return const PlannerFxImpact(
      active: false,
      deferred: true,
      assumption: null,
      invested: null,
      reserve: null,
      profit: null,
    );
  }

  final assumption = fx.single;
  return PlannerFxImpact(
    active: true,
    deferred: false,
    assumption: assumption,
    invested: (invested * assumption.rate).round(scale: 2),
    reserve: (reserve * assumption.rate).round(scale: 2),
    profit: (profit * assumption.rate).round(scale: 2),
  );
}
