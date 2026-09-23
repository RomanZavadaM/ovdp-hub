import 'package:decimal/decimal.dart';

import '../../pricing.dart';
import 'planner_scenario.dart';

class PlannerTaxImpact {
  final bool known;
  final Decimal? taxAmount;
  final Decimal? profitBeforeTax;
  final Decimal? profitAfterTax;

  const PlannerTaxImpact({
    required this.known,
    required this.taxAmount,
    required this.profitBeforeTax,
    required this.profitAfterTax,
  });
}

String _ruleKey(TaxRule rule) => '${rule.tax.name}:${rule.income.name}';

PlannerTaxImpact evaluateTaxImpact({
  required TaxScenario taxes,
  required String scenarioDate,
  required Decimal? profitBeforeTax,
}) {
  if (taxes.status == TaxAssumptionStatus.unknown) {
    return PlannerTaxImpact(
      known: false,
      taxAmount: null,
      profitBeforeTax: profitBeforeTax,
      profitAfterTax: null,
    );
  }

  final date = isoDate(scenarioDate);
  final expected = <String>{
    '${TaxKind.personalIncomeTax.name}:${TaxIncomeKind.interest.name}',
    '${TaxKind.personalIncomeTax.name}:${TaxIncomeKind.investmentProfit.name}',
    '${TaxKind.militaryLevy.name}:${TaxIncomeKind.interest.name}',
    '${TaxKind.militaryLevy.name}:${TaxIncomeKind.investmentProfit.name}',
  };
  final rules = <String, TaxRule>{};
  for (final rule in taxes.rules) {
    final key = _ruleKey(rule);
    if (rules.containsKey(key)) {
      throw const FormatException('planner.incomplete_tax_rules');
    }
    rules[key] = rule;
  }
  if (rules.keys.toSet().difference(expected).isNotEmpty ||
      expected.difference(rules.keys.toSet()).isNotEmpty) {
    throw const FormatException('planner.incomplete_tax_rules');
  }

  for (final rule in rules.values) {
    final from = isoDate(rule.scopeFrom);
    final to = isoDate(rule.scopeTo);
    if (date.isBefore(from) || date.isAfter(to)) {
      throw const FormatException('planner.tax_rules_out_of_scope');
    }
    if (rule.ratePercent != Decimal.zero) {
      // A non-zero percentage cannot be applied safely until the product has
      // an explicit tax-base model for each income kind.
      throw const FormatException('planner.unsupported_tax_base');
    }
  }

  return PlannerTaxImpact(
    known: true,
    taxAmount: Decimal.zero,
    profitBeforeTax: profitBeforeTax,
    profitAfterTax: profitBeforeTax,
  );
}
