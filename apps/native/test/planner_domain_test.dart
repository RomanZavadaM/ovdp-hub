import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/data/source_observation.dart';
import 'package:ovdp_hub/features/planner/planner_scenario.dart';
import 'package:ovdp_hub/models.dart';

Bond sampleBond() => Bond({
  'isin': 'UA4000239115',
  'currency': 'UAH',
  'nominal': '1000',
  'nominalRate': '15.17',
  'issueDate': '2026-01-01',
  'maturityDate': '2027-09-22',
  'payments': [
    {'date': '2027-09-22', 'kind': 'REDEMPTION', 'amount': '1000'},
  ],
});

SourceObservationMeta manualMeta() => const SourceObservationMeta(
  sourceId: 'manual',
  sourceUrl: 'local://manual',
  retrievedAt: '2026-09-22T10:00:00Z',
  kind: ObservationKind.manual,
  confidence: ObservationConfidence.userAssumption,
);

void main() {
  test('legacy schema 2 converts without inventing fees or taxes', () {
    final bond = sampleBond();
    final saved = SavedSet(
      'Старий план',
      '',
      '2026-09-22T10:00:00Z',
      [bond],
      scenario: {
        'schemaVersion': 2,
        'criteria': {
          'currency': 'UAH',
          'budget': '100000',
          'reserve': '10000',
          'start': '2026-09-22',
          'minDate': '2026-09-23',
          'maxDate': '2028-09-22',
          'needDate': '2027-03-22',
          'needAmount': '20000',
          'name': 'Старий план',
          'strategy': 'expenses',
          'expenseCount': '1',
          'expenseName0': 'Страховка',
          'expenseDate0': '2027-06-01',
          'expenseAmount0': '5000',
          'delay': '2',
          'pricedOnly': 'true',
        },
        'positions': [
          {
            'isin': bond.isin,
            'quantity': 3,
            'unitCost': '975.25',
            'nominalEstimate': false,
          },
        ],
      },
    );

    final typed = PlannerScenario.fromSavedSet(
      saved,
      now: DateTime.utc(2026, 9, 22),
    );

    expect(typed.positions.single.quantity, 3);
    expect(typed.positions.single.unitCost.toString(), '975.25');
    expect(
      typed.positions.single.price.meta.confidence,
      ObservationConfidence.userAssumption,
    );
    expect(typed.needs.length, 2);
    expect(typed.fees.status, FeeAssumptionStatus.unknown);
    expect(typed.taxes.status, TaxAssumptionStatus.unknown);
    expect(typed.exit.mode, ExitMode.holdToMaturity);

    final ui = typed.toCurrentUiCriteria();
    expect(ui['expenseName0'], 'Страховка');
    expect(ui['unitPrice:${bond.isin}'], '975.25');
  });

  test('typed scenario round-trips fees tax FX variants and early sale', () {
    final bond = sampleBond();
    final buy = PriceObservation(
      isin: bond.isin,
      currency: 'UAH',
      kind: PriceValueKind.fullPrice,
      side: PriceSide.manual,
      price: Decimal.parse('980.50'),
      meta: manualMeta(),
    );
    final sell = PriceObservation(
      isin: bond.isin,
      currency: 'UAH',
      kind: PriceValueKind.fullPrice,
      side: PriceSide.bid,
      price: Decimal.parse('990'),
      meta: const SourceObservationMeta(
        sourceId: 'seller-test',
        sourceUrl: 'https://example.invalid/quote',
        sourceDate: '2026-09-22',
        retrievedAt: '2026-09-22T10:00:00Z',
        kind: ObservationKind.secondaryQuote,
        confidence: ObservationConfidence.publicIndicative,
      ),
    );
    final scenario = PlannerScenario(
      id: 'scenario-1',
      name: 'Варіант B',
      groupId: 'compare-1',
      variantLabel: 'B',
      currency: 'UAH',
      budget: Decimal.parse('100000'),
      reserve: Decimal.parse('10000'),
      startDate: '2026-09-22',
      minMaturity: '2026-09-23',
      maxMaturity: '2028-09-22',
      strategy: PlannerStrategy.profit,
      needs: [
        PlannerNeed(
          id: 'need-1',
          name: 'Щомісячна потреба',
          type: PlannerNeedType.recurring,
          date: '2027-01-10',
          amount: Decimal.parse('5000'),
          everyMonths: 1,
          occurrences: 6,
        ),
      ],
      positions: [
        PlannerPositionDraft(isin: bond.isin, quantity: 5, price: buy),
      ],
      settlementDelayDays: 2,
      pricedOnly: true,
      fees: FeeAssumptions.confirmed([
        FeeRule(
          id: 'buy-fee',
          name: 'Комісія купівлі',
          kind: FeeKind.percentOfTrade,
          event: FeeEvent.purchase,
          value: Decimal.parse('0.5'),
        ),
      ]),
      taxes: TaxScenario.ukraineResidentOvdp2026(),
      fx: [
        FxAssumption(
          fromCurrency: 'USD',
          toCurrency: 'UAH',
          rate: Decimal.parse('42.25'),
          asOf: '2026-09-22',
        ),
      ],
      exit: ExitAssumption.earlySale('2027-05-01', sell),
    );

    final decoded = PlannerScenario.fromJson(
      jsonDecode(jsonEncode(scenario.toJson())) as Map<String, dynamic>,
    );

    expect(decoded.groupId, 'compare-1');
    expect(decoded.variantLabel, 'B');
    expect(decoded.needs.single.type, PlannerNeedType.recurring);
    expect(decoded.fees.status, FeeAssumptionStatus.known);
    expect(decoded.fees.rules.single.value.toString(), '0.5');
    expect(decoded.taxes.rules, hasLength(4));
    expect(decoded.taxes.rules.every((r) => r.ratePercent == Decimal.zero), true);
    expect(decoded.fx.single.rate.toString(), '42.25');
    expect(decoded.exit.mode, ExitMode.earlySale);
    expect(decoded.exit.price!.side, PriceSide.bid);
  });

  test('unknown fees are distinct from confirmed zero fees', () {
    final unknown = FeeAssumptions.unknown();
    final zero = FeeAssumptions.confirmed([]);

    expect(unknown.status, FeeAssumptionStatus.unknown);
    expect(zero.status, FeeAssumptionStatus.known);
    expect(unknown.toJson(), isNot(equals(zero.toJson())));
  });

  test('yield-only quote cannot become a planner position', () {
    final quote = PriceObservation(
      isin: 'UA4000239115',
      currency: 'UAH',
      kind: PriceValueKind.yieldOnly,
      side: PriceSide.ask,
      yieldPercent: Decimal.parse('15.2'),
      meta: const SourceObservationMeta(
        sourceId: 'seller-yield',
        sourceUrl: 'https://example.invalid/yield',
        sourceDate: '2026-09-22',
        retrievedAt: '2026-09-22T10:00:00Z',
        kind: ObservationKind.secondaryQuote,
        confidence: ObservationConfidence.publicIndicative,
      ),
    );

    expect(quote.effectiveUnitCost, isNull);
    expect(
      () => PlannerPositionDraft(isin: quote.isin, quantity: 1, price: quote),
      throwsFormatException,
    );
  });

  test('price source priority resolves only explicit purchase prices', () {
    final bond = sampleBond();
    PriceObservation full(String source, String price) => PriceObservation(
      isin: bond.isin,
      currency: 'UAH',
      kind: PriceValueKind.fullPrice,
      side: PriceSide.ask,
      price: Decimal.parse(price),
      meta: SourceObservationMeta(
        sourceId: source,
        sourceUrl: 'https://example.invalid/$source',
        sourceDate: '2026-09-23',
        retrievedAt: '2026-09-23T06:00:00Z',
        kind: ObservationKind.secondaryQuote,
        confidence: ObservationConfidence.publicIndicative,
      ),
    );
    final sourceA = full('source-a', '990');
    final sourceB = full('source-b', '995');
    final yieldOnly = PriceObservation(
      isin: bond.isin,
      currency: 'UAH',
      kind: PriceValueKind.yieldOnly,
      side: PriceSide.ask,
      yieldPercent: Decimal.parse('15.5'),
      meta: const SourceObservationMeta(
        sourceId: 'yield-source',
        sourceUrl: 'https://example.invalid/yield',
        sourceDate: '2026-09-23',
        retrievedAt: '2026-09-23T06:00:00Z',
        kind: ObservationKind.secondaryQuote,
        confidence: ObservationConfidence.publicIndicative,
      ),
    );
    final nominal = PriceObservation.legacy(
      bond: bond,
      unitCost: Decimal.parse('1000'),
      nominalEstimate: true,
      observedAt: '2026-09-23T06:00:00Z',
    );

    final priority = PriceSourcePriority(['yield-source', 'source-b', 'source-a']);
    final selected = priority.resolvePurchase(
      bond.isin,
      [sourceA, nominal, yieldOnly, sourceB],
    );

    expect(selected, same(sourceB));
    expect(selected!.effectiveUnitCost.toString(), '995');
  });

  test('schema 3 additively persists observations and explicit priority', () {
    final bond = sampleBond();
    PriceObservation price(String source, String value) => PriceObservation(
      isin: bond.isin,
      currency: 'UAH',
      kind: PriceValueKind.fullPrice,
      side: PriceSide.ask,
      price: Decimal.parse(value),
      meta: SourceObservationMeta(
        sourceId: source,
        sourceUrl: 'https://example.invalid/$source',
        sourceDate: '2026-09-23',
        retrievedAt: '2026-09-23T06:00:00Z',
        kind: ObservationKind.secondaryQuote,
        confidence: ObservationConfidence.publicIndicative,
      ),
    );
    final sourceA = price('source-a', '990');
    final sourceB = price('source-b', '995');
    final scenario = PlannerScenario(
      id: 'scenario-priority',
      name: 'Price sources',
      currency: 'UAH',
      budget: Decimal.parse('100000'),
      reserve: Decimal.parse('10000'),
      startDate: '2026-09-23',
      minMaturity: '2026-09-24',
      maxMaturity: '2028-09-23',
      strategy: PlannerStrategy.profit,
      needs: [
        PlannerNeed(
          id: 'need-1',
          name: 'Need',
          type: PlannerNeedType.oneOff,
          date: '2027-01-01',
          amount: Decimal.parse('5000'),
        ),
      ],
      positions: [
        PlannerPositionDraft(
          isin: bond.isin,
          quantity: 2,
          price: sourceB,
          priceObservations: [sourceA, sourceB],
        ),
      ],
      priceSourcePriority: PriceSourcePriority(['source-b', 'source-a']),
      settlementDelayDays: 2,
      pricedOnly: true,
      fees: FeeAssumptions.unknown(),
      taxes: TaxScenario.unknown(),
    );

    final encoded = scenario.toJson();
    expect(encoded['schemaVersion'], 3);
    expect(
      (encoded['positions'] as List).single['priceObservations'],
      hasLength(2),
    );
    final decoded = PlannerScenario.fromJson(
      jsonDecode(jsonEncode(encoded)) as Map<String, dynamic>,
    );

    expect(decoded.priceSourcePriority.sourceIds, ['source-b', 'source-a']);
    expect(decoded.positions.single.priceObservations, hasLength(2));
    expect(decoded.positions.single.price.meta.sourceId, 'source-b');
  });

  test('priority fails closed on duplicate eligible observations per source', () {
    final bond = sampleBond();
    PriceObservation quote(String value, String at) => PriceObservation(
      isin: bond.isin,
      currency: 'UAH',
      kind: PriceValueKind.fullPrice,
      side: PriceSide.ask,
      price: Decimal.parse(value),
      meta: SourceObservationMeta(
        sourceId: 'same-source',
        sourceUrl: 'https://example.invalid/quote',
        sourceDate: '2026-09-23',
        retrievedAt: at,
        kind: ObservationKind.secondaryQuote,
        confidence: ObservationConfidence.publicIndicative,
      ),
    );

    expect(
      () => PriceSourcePriority(['same-source']).resolvePurchase(
        bond.isin,
        [
          quote('990', '2026-09-23T06:00:00Z'),
          quote('991', '2026-09-23T07:00:00Z'),
        ],
      ),
      throwsFormatException,
    );
  });

  test('early sale requires BID or explicit manual price', () {
    final ask = PriceObservation(
      isin: 'UA4000239115',
      currency: 'UAH',
      kind: PriceValueKind.fullPrice,
      side: PriceSide.ask,
      price: Decimal.parse('1000'),
      meta: manualMeta(),
    );
    expect(
      () => ExitAssumption.earlySale('2027-01-01', ask),
      throwsFormatException,
    );
  });

  test('Ukraine 2026 OVDP tax preset is explicit and dated', () {
    final taxes = TaxScenario.ukraineResidentOvdp2026();

    expect(taxes.status, TaxAssumptionStatus.known);
    expect(taxes.rules, hasLength(4));
    expect(taxes.rules.every((r) => r.scopeFrom == '2026-01-01'), true);
    expect(taxes.rules.every((r) => r.scopeTo == '2026-12-31'), true);
    expect(taxes.rules.every((r) => r.verifiedOn == '2026-09-22'), true);
    expect(taxes.rules.every((r) => r.sourceUrl.startsWith('https://')), true);
  });
}
