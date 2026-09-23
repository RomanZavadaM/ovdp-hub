import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:ovdp_hub/data/source_observation.dart';
import 'package:ovdp_hub/features/planner/planner_scenario.dart';
import 'package:ovdp_hub/models.dart';

Catalog comparisonCatalog() => Catalog.parse(
      jsonEncode({
        'schemaVersion': 1,
        'source': 'https://bank.gov.ua/depo_securities?json',
        'sourcePage': 'https://bank.gov.ua/ua/markets/ovdp',
        'retrievedAt': '2026-09-23T12:00:00Z',
        'sourceAsOf': '2026-09-23',
        'assets': [
          {
            'isin': 'UA4000239115',
            'currency': 'UAH',
            'nominal': '1000',
            'nominalRate': '15',
            'issueDate': '2026-01-01',
            'maturityDate': '2027-09-23',
            'payments': [
              {'date': '2027-03-01', 'kind': 'COUPON', 'amount': '75'},
              {'date': '2027-09-23', 'kind': 'REDEMPTION', 'amount': '1000'},
            ],
          },
          {
            'isin': 'UA4000239116',
            'currency': 'UAH',
            'nominal': '1000',
            'nominalRate': '14',
            'issueDate': '2026-01-01',
            'maturityDate': '2028-03-01',
            'payments': [
              {'date': '2027-03-01', 'kind': 'COUPON', 'amount': '70'},
              {'date': '2028-03-01', 'kind': 'REDEMPTION', 'amount': '1000'},
            ],
          },
        ],
      }),
    );

SourceObservationMeta comparisonMeta(
  String sourceId, {
  String sourceUrl = 'local://comparison',
  ObservationKind kind = ObservationKind.manual,
  ObservationConfidence confidence = ObservationConfidence.userAssumption,
}) =>
    SourceObservationMeta(
      sourceId: sourceId,
      sourceUrl: sourceUrl,
      sourceDate: '2026-09-23',
      retrievedAt: '2026-09-23T12:00:00Z',
      kind: kind,
      confidence: confidence,
    );

PriceObservation comparisonBuy(
  Bond bond, {
  String price = '980',
  String sourceId = 'manual-price',
}) =>
    PriceObservation(
      isin: bond.isin,
      currency: bond.currency,
      kind: PriceValueKind.fullPrice,
      side: PriceSide.manual,
      price: Decimal.parse(price),
      meta: comparisonMeta(sourceId),
    );

PositionExitAssumption comparisonExit(
  Bond bond, {
  String date = '2027-05-01',
  String price = '990',
}) =>
    PositionExitAssumption(
      isin: bond.isin,
      date: date,
      price: PriceObservation(
        isin: bond.isin,
        currency: bond.currency,
        kind: PriceValueKind.fullPrice,
        side: PriceSide.bid,
        price: Decimal.parse(price),
        meta: comparisonMeta(
          'seller-bid',
          sourceUrl: 'https://example.invalid/bid',
          kind: ObservationKind.secondaryQuote,
          confidence: ObservationConfidence.publicIndicative,
        ),
      ),
    );

PlannerNeed comparisonNeed({
  PlannerNeedType type = PlannerNeedType.oneOff,
  String amount = '1000',
}) =>
    PlannerNeed(
      id: 'need-1',
      name: 'Потреба',
      type: type,
      date: '2027-06-01',
      amount: Decimal.parse(amount),
      everyMonths: type == PlannerNeedType.recurring ? 1 : null,
      occurrences: type == PlannerNeedType.recurring ? 2 : null,
    );

PlannerScenario comparisonScenario(
  Bond bond, {
  String name = 'План A',
  String groupId = 'compare-group',
  String variantLabel = 'A',
  String budget = '100000',
  String reserve = '10000',
  String purchasePrice = '980',
  int quantity = 1,
  PlannerStrategy strategy = PlannerStrategy.ladder,
  FeeAssumptions? fees,
  TaxScenario? taxes,
  List<FxAssumption> fx = const [],
  List<PositionExitAssumption> positionExits = const [],
  PlannerNeedType needType = PlannerNeedType.oneOff,
  String needAmount = '1000',
}) {
  final price = comparisonBuy(
    bond,
    price: purchasePrice,
    sourceId: 'manual-price-$variantLabel',
  );
  return PlannerScenario(
    id: 'scenario-$variantLabel',
    name: name,
    groupId: groupId,
    variantLabel: variantLabel,
    currency: 'UAH',
    budget: Decimal.parse(budget),
    reserve: Decimal.parse(reserve),
    startDate: '2026-09-23',
    minMaturity: '2026-09-24',
    maxMaturity: '2028-09-23',
    strategy: strategy,
    needs: [
      comparisonNeed(type: needType, amount: needAmount),
    ],
    positions: [
      PlannerPositionDraft(
        isin: bond.isin,
        quantity: quantity,
        price: price,
      ),
    ],
    settlementDelayDays: 2,
    pricedOnly: false,
    fees: fees ?? FeeAssumptions.unknown(),
    taxes: taxes ?? TaxScenario.unknown(),
    fx: fx,
    positionExits: positionExits,
  );
}

SavedSet comparisonSavedSet(
  Bond bond, {
  required String name,
  required String savedAt,
  String groupId = 'compare-group',
  String variantLabel = 'A',
  String budget = '100000',
  String reserve = '10000',
  String purchasePrice = '980',
  int quantity = 1,
  PlannerStrategy strategy = PlannerStrategy.ladder,
  FeeAssumptions? fees,
  TaxScenario? taxes,
  List<FxAssumption> fx = const [],
  List<PositionExitAssumption> positionExits = const [],
  PlannerNeedType needType = PlannerNeedType.oneOff,
  String needAmount = '1000',
}) {
  final scenario = comparisonScenario(
    bond,
    name: name,
    groupId: groupId,
    variantLabel: variantLabel,
    budget: budget,
    reserve: reserve,
    purchasePrice: purchasePrice,
    quantity: quantity,
    strategy: strategy,
    fees: fees,
    taxes: taxes,
    fx: fx,
    positionExits: positionExits,
    needType: needType,
    needAmount: needAmount,
  );
  return SavedSet(
    name,
    '',
    savedAt,
    [bond],
    scenario: scenario.toJson(),
  );
}
