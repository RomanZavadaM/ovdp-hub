import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

import '../../data/source_observation.dart';
import '../../models.dart';
import '../../pricing.dart';
import 'planner_engine.dart';

abstract final class PlannerGeneratedCopy {
  static const planName = '@ovdp-hub:planner:generated-plan-name';
  static const primaryNeedName = '@ovdp-hub:planner:generated-primary-need';
  static const aggregatePurchaseFeeRuleName =
      '@ovdp-hub:planner:aggregate-purchase-fee';
  static const taxUnknownLabel = '@ovdp-hub:planner:tax-unknown';
  static const taxUkraineResidentOvdp2026Label =
      '@ovdp-hub:planner:tax-ua-resident-ovdp-2026';
  static const scenarioNote = '@ovdp-hub:planner:generated-scenario-note-v1';

  static String expenseName(int ordinal) =>
      '@ovdp-hub:planner:generated-expense:$ordinal';

  static int? expenseOrdinal(String value) {
    const prefix = '@ovdp-hub:planner:generated-expense:';
    if (!value.startsWith(prefix)) return null;
    final ordinal = int.tryParse(value.substring(prefix.length));
    return ordinal != null && ordinal >= 2 ? ordinal : null;
  }
}

T _readEnum<T extends Enum>(List<T> values, Object? raw) {
  if (raw is String) {
    for (final value in values) {
      if (value.name == raw) return value;
    }
  }
  throw const FormatException('planner.invalid_enum');
}

Decimal _decimal(Object? raw, {bool positive = false}) {
  try {
    final value = Decimal.parse(decimalText(raw));
    if (positive ? value <= Decimal.zero : value < Decimal.zero) {
      throw const FormatException('planner.invalid_number');
    }
    return value;
  } catch (_) {
    throw const FormatException('planner.invalid_number');
  }
}

String _date(Object? raw) {
  if (raw is! String) throw const FormatException('planner.invalid_date');
  try {
    isoDate(raw);
    return raw;
  } catch (_) {
    throw const FormatException('planner.invalid_date');
  }
}

enum PlannerNeedType { oneOff, recurring, reserveFloor }

@immutable
class PlannerNeed {
  final String id;
  final String name;
  final PlannerNeedType type;
  final String date;
  final Decimal amount;
  final int? everyMonths;
  final int? occurrences;

  PlannerNeed({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
    required this.amount,
    this.everyMonths,
    this.occurrences,
  }) {
    if (id.trim().isEmpty || name.trim().isEmpty || amount < Decimal.zero) {
      throw const FormatException('planner.invalid_need');
    }
    isoDate(date);
    if (type == PlannerNeedType.recurring) {
      if (everyMonths == null ||
          occurrences == null ||
          everyMonths! < 1 ||
          everyMonths! > 120 ||
          occurrences! < 2 ||
          occurrences! > 600) {
        throw const FormatException('planner.invalid_repeat');
      }
    } else if (everyMonths != null || occurrences != null) {
      throw const FormatException('planner.repeat_requires_recurring');
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'date': date,
    'amount': amount.toString(),
    if (everyMonths != null) 'everyMonths': everyMonths,
    if (occurrences != null) 'occurrences': occurrences,
  };

  factory PlannerNeed.fromJson(Map<String, dynamic> json) => PlannerNeed(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    type: _readEnum(PlannerNeedType.values, json['type']),
    date: _date(json['date']),
    amount: _decimal(json['amount']),
    everyMonths: json['everyMonths'] as int?,
    occurrences: json['occurrences'] as int?,
  );
}

List<PlannerNeed> plannerNeedsFromCriteria(Map<String, String> criteria) {
  final count = int.tryParse(criteria['expenseCount'] ?? '0');
  if (count == null || count < 0 || count > 50) {
    throw const FormatException('planner.invalid_need_count');
  }

  final recurring = criteria['needRecurring'] == 'true';
  int? everyMonths;
  int? occurrences;
  if (recurring) {
    everyMonths = int.tryParse(criteria['needEveryMonths'] ?? '1');
    occurrences = int.tryParse(criteria['needOccurrences'] ?? '6');
    if (everyMonths == null || occurrences == null) {
      throw const FormatException('planner.invalid_repeat');
    }
  }

  final needs = <PlannerNeed>[
    PlannerNeed(
      id: 'need-0',
      name: (criteria['needName'] ?? PlannerGeneratedCopy.primaryNeedName).trim(),
      type: recurring ? PlannerNeedType.recurring : PlannerNeedType.oneOff,
      date: criteria['needDate']!,
      amount: money(criteria['needAmount']!),
      everyMonths: everyMonths,
      occurrences: occurrences,
    ),
  ];

  for (var i = 0; i < count; i++) {
    needs.add(
      PlannerNeed(
        id: 'need-${i + 1}',
        name: (criteria['expenseName$i'] ?? PlannerGeneratedCopy.expenseName(i + 2)).trim(),
        type: PlannerNeedType.oneOff,
        date: criteria['expenseDate$i']!,
        amount: money(criteria['expenseAmount$i']!),
      ),
    );
  }

  return List.unmodifiable(needs);
}

enum PriceValueKind { fullPrice, cleanPrice, yieldOnly, nominalEstimate }
enum PriceSide { ask, bid, manual }

@immutable
class PriceObservation {
  final String isin;
  final String currency;
  final PriceValueKind kind;
  final PriceSide side;
  final Decimal? price;
  final Decimal? accruedInterest;
  final Decimal? yieldPercent;
  final SourceObservationMeta meta;

  PriceObservation({
    required this.isin,
    required this.currency,
    required this.kind,
    required this.side,
    required this.meta,
    this.price,
    this.accruedInterest,
    this.yieldPercent,
  }) {
    if (!RegExp(r'^UA[A-Z0-9]{9}\d$').hasMatch(isin) ||
        !['UAH', 'USD', 'EUR'].contains(currency)) {
      throw const FormatException('planner.invalid_price_observation');
    }
    if (kind == PriceValueKind.fullPrice ||
        kind == PriceValueKind.nominalEstimate) {
      if (price == null || price! <= Decimal.zero || accruedInterest != null) {
        throw const FormatException('planner.full_price_required');
      }
    } else if (kind == PriceValueKind.cleanPrice) {
      if (price == null ||
          price! <= Decimal.zero ||
          accruedInterest == null ||
          accruedInterest! < Decimal.zero) {
        throw const FormatException('planner.clean_price_required');
      }
    } else if (kind == PriceValueKind.yieldOnly) {
      if (price != null ||
          accruedInterest != null ||
          yieldPercent == null ||
          yieldPercent! < Decimal.zero) {
        throw const FormatException('planner.yield_not_price');
      }
    }
  }

  Decimal? get effectiveUnitCost {
    if (kind == PriceValueKind.yieldOnly) return null;
    if (kind == PriceValueKind.cleanPrice) return price! + accruedInterest!;
    return price;
  }

  bool get isExplicitPurchasePrice =>
      kind != PriceValueKind.yieldOnly &&
      kind != PriceValueKind.nominalEstimate &&
      effectiveUnitCost != null &&
      (side == PriceSide.ask || side == PriceSide.manual);

  String get sourceId => meta.sourceId;

  Map<String, dynamic> toJson() => {
    'isin': isin,
    'currency': currency,
    'kind': kind.name,
    'side': side.name,
    if (price != null) 'price': price.toString(),
    if (accruedInterest != null) 'accruedInterest': accruedInterest.toString(),
    if (yieldPercent != null) 'yieldPercent': yieldPercent.toString(),
    'meta': meta.toJson(),
  };

  factory PriceObservation.fromJson(Map<String, dynamic> json) {
    Decimal? optionalDecimal(String key) =>
        json[key] == null ? null : _decimal(json[key]);
    return PriceObservation(
      isin: json['isin'] as String? ?? '',
      currency: json['currency'] as String? ?? '',
      kind: _readEnum(PriceValueKind.values, json['kind']),
      side: _readEnum(PriceSide.values, json['side']),
      price: optionalDecimal('price'),
      accruedInterest: optionalDecimal('accruedInterest'),
      yieldPercent: optionalDecimal('yieldPercent'),
      meta: SourceObservationMeta.fromJson(
        Map<String, dynamic>.from(json['meta'] as Map),
      ),
    );
  }

  factory PriceObservation.manualFullPrice({
    required Bond bond,
    required String sourceId,
    required Decimal unitCost,
    required String observedAt,
  }) {
    final cleanSource = sourceId.trim();
    if (cleanSource.isEmpty || cleanSource.length > 120) {
      throw const FormatException('planner.invalid_price_source');
    }
    return PriceObservation(
      isin: bond.isin,
      currency: bond.currency,
      kind: PriceValueKind.fullPrice,
      side: PriceSide.manual,
      price: unitCost,
      meta: SourceObservationMeta(
        sourceId: cleanSource,
        sourceUrl: 'local://price-source',
        retrievedAt: observedAt,
        kind: ObservationKind.manual,
        confidence: ObservationConfidence.userAssumption,
      ),
    );
  }

  factory PriceObservation.legacy({
    required Bond bond,
    required Decimal unitCost,
    required bool nominalEstimate,
    required String observedAt,
  }) => PriceObservation(
    isin: bond.isin,
    currency: bond.currency,
    kind: nominalEstimate
        ? PriceValueKind.nominalEstimate
        : PriceValueKind.fullPrice,
    side: PriceSide.manual,
    price: unitCost,
    meta: SourceObservationMeta(
      sourceId: nominalEstimate ? 'nbu-nominal-estimate' : 'manual-price',
      sourceUrl: nominalEstimate
          ? 'https://bank.gov.ua/ua/markets/ovdp'
          : 'local://manual',
      retrievedAt: observedAt,
      kind: nominalEstimate
          ? ObservationKind.instrument
          : ObservationKind.manual,
      confidence: nominalEstimate
          ? ObservationConfidence.publicIndicative
          : ObservationConfidence.userAssumption,
    ),
  );
}

bool _samePriceObservation(PriceObservation a, PriceObservation b) =>
    a.isin == b.isin &&
    a.currency == b.currency &&
    a.kind == b.kind &&
    a.side == b.side &&
    a.price == b.price &&
    a.accruedInterest == b.accruedInterest &&
    a.yieldPercent == b.yieldPercent &&
    a.meta.sourceId == b.meta.sourceId &&
    a.meta.sourceUrl == b.meta.sourceUrl &&
    a.meta.sourceDate == b.meta.sourceDate &&
    a.meta.retrievedAt == b.meta.retrievedAt &&
    a.meta.validUntil == b.meta.validUntil &&
    a.meta.kind == b.meta.kind &&
    a.meta.confidence == b.meta.confidence;

@immutable
class PriceSourcePriority {
  final List<String> sourceIds;

  PriceSourcePriority(Iterable<String> sourceIds)
      : sourceIds = List.unmodifiable(sourceIds.map((e) => e.trim())) {
    if (this.sourceIds.any((e) => e.isEmpty || e.length > 120) ||
        this.sourceIds.toSet().length != this.sourceIds.length) {
      throw const FormatException('planner.invalid_price_source_priority');
    }
  }

  factory PriceSourcePriority.none() => PriceSourcePriority(const []);

  bool get isEmpty => sourceIds.isEmpty;

  PriceObservation? resolvePurchase(
    String isin,
    Iterable<PriceObservation> observations,
  ) {
    final eligible = observations
        .where((o) => o.isin == isin && o.isExplicitPurchasePrice)
        .toList(growable: false);
    for (final sourceId in sourceIds) {
      final matches = eligible
          .where((o) => o.meta.sourceId == sourceId)
          .toList(growable: false);
      if (matches.length > 1) {
        throw const FormatException('planner.ambiguous_price_source');
      }
      if (matches.length == 1) return matches.single;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {'sourceIds': sourceIds};

  factory PriceSourcePriority.fromJson(Map<String, dynamic> json) {
    final raw = json['sourceIds'];
    if (raw is! List || raw.any((e) => e is! String)) {
      throw const FormatException('planner.invalid_price_source_priority');
    }
    return PriceSourcePriority(raw.cast<String>());
  }
}

@immutable
class PlannerPositionDraft {
  final String isin;
  final int quantity;
  final PriceObservation price;
  final List<PriceObservation> priceObservations;

  PlannerPositionDraft({
    required this.isin,
    required this.quantity,
    required this.price,
    Iterable<PriceObservation>? priceObservations,
  }) : priceObservations = List.unmodifiable(
         priceObservations ?? [price],
       ) {
    if (isin != price.isin ||
        quantity < 1 ||
        quantity > 1000000 ||
        price.effectiveUnitCost == null ||
        this.priceObservations.isEmpty ||
        this.priceObservations.any(
          (o) => o.isin != isin || o.currency != price.currency,
        ) ||
        !this.priceObservations.any((o) => _samePriceObservation(o, price))) {
      throw const FormatException('planner.invalid_position');
    }
    final identities = this.priceObservations
        .map(
          (o) =>
              '${o.meta.sourceId}|${o.kind.name}|${o.side.name}|'
              '${o.meta.retrievedAt}|${o.price}|${o.accruedInterest}|'
              '${o.yieldPercent}',
        )
        .toList(growable: false);
    if (identities.toSet().length != identities.length) {
      throw const FormatException('planner.duplicate_price_observation');
    }
  }

  Decimal get unitCost => price.effectiveUnitCost!;

  Map<String, dynamic> toJson() => {
    'isin': isin,
    'quantity': quantity,
    'price': price.toJson(),
    if (priceObservations.length > 1)
      'priceObservations': priceObservations.map((e) => e.toJson()).toList(),
  };

  factory PlannerPositionDraft.fromJson(Map<String, dynamic> json) {
    final price = PriceObservation.fromJson(
      Map<String, dynamic>.from(json['price'] as Map),
    );
    final rawObservations = json['priceObservations'];
    final observations = rawObservations == null
        ? <PriceObservation>[price]
        : (rawObservations as List)
              .map(
                (e) => PriceObservation.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList();
    if (!observations.any((o) => _samePriceObservation(o, price))) {
      observations.insert(0, price);
    }
    return PlannerPositionDraft(
      isin: json['isin'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      price: price,
      priceObservations: observations,
    );
  }

  factory PlannerPositionDraft.fromLegacy(
    PlanPosition position, {
    required String observedAt,
  }) {
    final price = PriceObservation.legacy(
      bond: position.bond,
      unitCost: position.unitCost,
      nominalEstimate: position.nominalEstimate,
      observedAt: observedAt,
    );
    return PlannerPositionDraft(
      isin: position.bond.isin,
      quantity: position.quantity,
      price: price,
      priceObservations: [price],
    );
  }
}

enum FeeAssumptionStatus { unknown, known }
enum FeeKind { flat, perUnit, percentOfTrade, recurring }
enum FeeEvent { purchase, sale, periodic }

@immutable
class FeeRule {
  final String id;
  final String name;
  final FeeKind kind;
  final FeeEvent event;
  final Decimal value;
  final String? currency;
  final int? everyMonths;
  final String? sourceUrl;

  FeeRule({
    required this.id,
    required this.name,
    required this.kind,
    required this.event,
    required this.value,
    this.currency,
    this.everyMonths,
    this.sourceUrl,
  }) {
    if (id.trim().isEmpty || name.trim().isEmpty || value < Decimal.zero) {
      throw const FormatException('planner.invalid_fee');
    }
    if (kind == FeeKind.percentOfTrade && value > Decimal.fromInt(100)) {
      throw const FormatException('planner.fee_over_100');
    }
    if (kind == FeeKind.recurring) {
      if (everyMonths == null || everyMonths! < 1 || everyMonths! > 120) {
        throw const FormatException('planner.invalid_recurring_fee');
      }
    } else if (everyMonths != null) {
      throw const FormatException('planner.fee_period_mismatch');
    }
    if (kind != FeeKind.percentOfTrade &&
        (currency == null || !RegExp(r'^[A-Z]{3}$').hasMatch(currency!))) {
      throw const FormatException('planner.fee_currency_required');
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'kind': kind.name,
    'event': event.name,
    'value': value.toString(),
    if (currency != null) 'currency': currency,
    if (everyMonths != null) 'everyMonths': everyMonths,
    if (sourceUrl != null) 'sourceUrl': sourceUrl,
  };

  factory FeeRule.fromJson(Map<String, dynamic> json) => FeeRule(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    kind: _readEnum(FeeKind.values, json['kind']),
    event: _readEnum(FeeEvent.values, json['event']),
    value: _decimal(json['value']),
    currency: json['currency'] as String?,
    everyMonths: json['everyMonths'] as int?,
    sourceUrl: json['sourceUrl'] as String?,
  );
}

@immutable
class FeeAssumptions {
  final FeeAssumptionStatus status;
  final List<FeeRule> rules;

  FeeAssumptions({
    required this.status,
    Iterable<FeeRule> rules = const [],
  }) : rules = List.unmodifiable(rules) {
    if (status == FeeAssumptionStatus.unknown && this.rules.isNotEmpty) {
      throw const FormatException('planner.unknown_fee_has_rules');
    }
  }

  factory FeeAssumptions.unknown() =>
      FeeAssumptions(status: FeeAssumptionStatus.unknown);

  factory FeeAssumptions.confirmed(Iterable<FeeRule> rules) =>
      FeeAssumptions(status: FeeAssumptionStatus.known, rules: rules);

  Map<String, dynamic> toJson() => {
    'status': status.name,
    'rules': rules.map((e) => e.toJson()).toList(),
  };

  factory FeeAssumptions.fromJson(Map<String, dynamic> json) => FeeAssumptions(
    status: _readEnum(FeeAssumptionStatus.values, json['status']),
    rules: (json['rules'] as List? ?? const [])
        .map((e) => FeeRule.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
  );
}

enum TaxAssumptionStatus { unknown, known }
enum TaxKind { personalIncomeTax, militaryLevy }
enum TaxIncomeKind { interest, investmentProfit }

@immutable
class TaxRule {
  final String id;
  final TaxKind tax;
  final TaxIncomeKind income;
  final Decimal ratePercent;
  final String scopeFrom;
  final String scopeTo;
  final String verifiedOn;
  final String sourceUrl;

  TaxRule({
    required this.id,
    required this.tax,
    required this.income,
    required this.ratePercent,
    required this.scopeFrom,
    required this.scopeTo,
    required this.verifiedOn,
    required this.sourceUrl,
  }) {
    if (id.trim().isEmpty ||
        sourceUrl.trim().isEmpty ||
        ratePercent < Decimal.zero ||
        ratePercent > Decimal.fromInt(100)) {
      throw const FormatException('planner.invalid_tax_rule');
    }
    final from = isoDate(scopeFrom);
    final to = isoDate(scopeTo);
    isoDate(verifiedOn);
    if (from.isAfter(to)) {
      throw const FormatException('planner.invalid_tax_period');
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tax': tax.name,
    'income': income.name,
    'ratePercent': ratePercent.toString(),
    'scopeFrom': scopeFrom,
    'scopeTo': scopeTo,
    'verifiedOn': verifiedOn,
    'sourceUrl': sourceUrl,
  };

  factory TaxRule.fromJson(Map<String, dynamic> json) => TaxRule(
    id: json['id'] as String? ?? '',
    tax: _readEnum(TaxKind.values, json['tax']),
    income: _readEnum(TaxIncomeKind.values, json['income']),
    ratePercent: _decimal(json['ratePercent']),
    scopeFrom: _date(json['scopeFrom']),
    scopeTo: _date(json['scopeTo']),
    verifiedOn: _date(json['verifiedOn']),
    sourceUrl: json['sourceUrl'] as String? ?? '',
  );
}

@immutable
class TaxScenario {
  final TaxAssumptionStatus status;
  final String label;
  final List<TaxRule> rules;

  TaxScenario({
    required this.status,
    required this.label,
    Iterable<TaxRule> rules = const [],
  }) : rules = List.unmodifiable(rules) {
    if (label.trim().isEmpty ||
        (status == TaxAssumptionStatus.unknown && this.rules.isNotEmpty)) {
      throw const FormatException('planner.invalid_tax_scenario');
    }
  }

  factory TaxScenario.unknown() => TaxScenario(
    status: TaxAssumptionStatus.unknown,
    label: PlannerGeneratedCopy.taxUnknownLabel,
  );

  factory TaxScenario.ukraineResidentOvdp2026() => TaxScenario(
    status: TaxAssumptionStatus.known,
    label: PlannerGeneratedCopy.taxUkraineResidentOvdp2026Label,
    rules: [
      TaxRule(
        id: 'ua-2026-pit-interest',
        tax: TaxKind.personalIncomeTax,
        income: TaxIncomeKind.interest,
        ratePercent: Decimal.zero,
        scopeFrom: '2026-01-01',
        scopeTo: '2026-12-31',
        verifiedOn: '2026-09-23',
        sourceUrl: 'https://www.tax.gov.ua/nk/rozdil-iv--podatok-na-dohodi-fizichnih-o/',
      ),
      TaxRule(
        id: 'ua-2026-pit-investment-profit',
        tax: TaxKind.personalIncomeTax,
        income: TaxIncomeKind.investmentProfit,
        ratePercent: Decimal.zero,
        scopeFrom: '2026-01-01',
        scopeTo: '2026-12-31',
        verifiedOn: '2026-09-23',
        sourceUrl: 'https://cv.tax.gov.ua/media-ark/news-ark/print-1018909.html',
      ),
      TaxRule(
        id: 'ua-2026-military-interest',
        tax: TaxKind.militaryLevy,
        income: TaxIncomeKind.interest,
        ratePercent: Decimal.zero,
        scopeFrom: '2026-01-01',
        scopeTo: '2026-12-31',
        verifiedOn: '2026-09-23',
        sourceUrl: 'https://lv.tax.gov.ua/media-ark/news-ark/print-1002439.html',
      ),
      TaxRule(
        id: 'ua-2026-military-investment-profit',
        tax: TaxKind.militaryLevy,
        income: TaxIncomeKind.investmentProfit,
        ratePercent: Decimal.zero,
        scopeFrom: '2026-01-01',
        scopeTo: '2026-12-31',
        verifiedOn: '2026-09-23',
        sourceUrl: 'https://lv.tax.gov.ua/media-ark/news-ark/print-1002439.html',
      ),
    ],
  );

  Map<String, dynamic> toJson() => {
    'status': status.name,
    'label': label,
    'rules': rules.map((e) => e.toJson()).toList(),
  };

  factory TaxScenario.fromJson(Map<String, dynamic> json) => TaxScenario(
    status: _readEnum(TaxAssumptionStatus.values, json['status']),
    label: json['label'] as String? ?? '',
    rules: (json['rules'] as List? ?? const [])
        .map((e) => TaxRule.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
  );
}

@immutable
class FxAssumption {
  final String fromCurrency;
  final String toCurrency;
  final Decimal rate;
  final String asOf;
  final SourceObservationMeta? source;

  FxAssumption({
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.asOf,
    this.source,
  }) {
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(fromCurrency) ||
        !RegExp(r'^[A-Z]{3}$').hasMatch(toCurrency) ||
        fromCurrency == toCurrency ||
        rate <= Decimal.zero) {
      throw const FormatException('planner.invalid_fx');
    }
    isoDate(asOf);
  }

  Map<String, dynamic> toJson() => {
    'from': fromCurrency,
    'to': toCurrency,
    'rate': rate.toString(),
    'asOf': asOf,
    if (source != null) 'source': source!.toJson(),
  };

  factory FxAssumption.fromJson(Map<String, dynamic> json) => FxAssumption(
    fromCurrency: json['from'] as String? ?? '',
    toCurrency: json['to'] as String? ?? '',
    rate: _decimal(json['rate'], positive: true),
    asOf: _date(json['asOf']),
    source: json['source'] == null
        ? null
        : SourceObservationMeta.fromJson(
            Map<String, dynamic>.from(json['source'] as Map),
          ),
  );
}

enum ExitMode { holdToMaturity, earlySale }

@immutable
class ExitAssumption {
  final ExitMode mode;
  final String? date;
  final PriceObservation? price;

  ExitAssumption._(this.mode, this.date, this.price) {
    if (mode == ExitMode.holdToMaturity) {
      if (date != null || price != null) {
        throw const FormatException('planner.hold_has_no_sale_price');
      }
      return;
    }
    if (date == null ||
        price == null ||
        price!.effectiveUnitCost == null ||
        ![PriceSide.bid, PriceSide.manual].contains(price!.side)) {
      throw const FormatException(
        'planner.early_sale_requires_bid',
      );
    }
    isoDate(date!);
  }

  factory ExitAssumption.holdToMaturity() =>
      ExitAssumption._(ExitMode.holdToMaturity, null, null);

  factory ExitAssumption.earlySale(String date, PriceObservation price) =>
      ExitAssumption._(ExitMode.earlySale, date, price);

  Map<String, dynamic> toJson() => {
    'mode': mode.name,
    if (date != null) 'date': date,
    if (price != null) 'price': price!.toJson(),
  };

  factory ExitAssumption.fromJson(Map<String, dynamic> json) {
    final mode = _readEnum(ExitMode.values, json['mode']);
    if (mode == ExitMode.holdToMaturity) {
      return ExitAssumption.holdToMaturity();
    }
    return ExitAssumption.earlySale(
      _date(json['date']),
      PriceObservation.fromJson(
        Map<String, dynamic>.from(json['price'] as Map),
      ),
    );
  }
}

@immutable
class PositionExitAssumption {
  final String isin;
  final String date;
  final PriceObservation price;

  PositionExitAssumption({
    required this.isin,
    required this.date,
    required this.price,
  }) {
    if (isin != price.isin ||
        price.effectiveUnitCost == null ||
        ![PriceSide.bid, PriceSide.manual].contains(price.side)) {
      throw const FormatException('planner.invalid_position_exit');
    }
    isoDate(date);
  }

  Map<String, dynamic> toJson() => {
    'isin': isin,
    'date': date,
    'price': price.toJson(),
  };

  factory PositionExitAssumption.fromJson(Map<String, dynamic> json) =>
      PositionExitAssumption(
        isin: json['isin'] as String? ?? '',
        date: _date(json['date']),
        price: PriceObservation.fromJson(
          Map<String, dynamic>.from(json['price'] as Map),
        ),
      );
}

enum PlannerStrategy { ladder, profit, expenses }

@immutable
class PlannerScenario {
  static const schemaVersion = 3;

  final String id;
  final String name;
  final String? groupId;
  final String variantLabel;
  final String currency;
  final Decimal budget;
  final Decimal reserve;
  final String startDate;
  final String minMaturity;
  final String maxMaturity;
  final PlannerStrategy strategy;
  final List<PlannerNeed> needs;
  final List<PlannerPositionDraft> positions;
  final PriceSourcePriority priceSourcePriority;
  final int settlementDelayDays;
  final bool pricedOnly;
  final FeeAssumptions fees;
  final TaxScenario taxes;
  final List<FxAssumption> fx;
  final ExitAssumption exit;
  final List<PositionExitAssumption> positionExits;

  PlannerScenario({
    required this.id,
    required this.name,
    required this.currency,
    required this.budget,
    required this.reserve,
    required this.startDate,
    required this.minMaturity,
    required this.maxMaturity,
    required this.strategy,
    required Iterable<PlannerNeed> needs,
    required Iterable<PlannerPositionDraft> positions,
    PriceSourcePriority? priceSourcePriority,
    required this.settlementDelayDays,
    required this.pricedOnly,
    required this.fees,
    required this.taxes,
    Iterable<FxAssumption> fx = const [],
    ExitAssumption? exit,
    Iterable<PositionExitAssumption> positionExits = const [],
    this.groupId,
    this.variantLabel = 'A',
  }) : needs = List.unmodifiable(needs),
       positions = List.unmodifiable(positions),
       priceSourcePriority = priceSourcePriority ?? PriceSourcePriority.none(),
       fx = List.unmodifiable(fx),
       exit = exit ?? ExitAssumption.holdToMaturity(),
       positionExits = List.unmodifiable(positionExits) {
    if (id.trim().isEmpty ||
        name.trim().isEmpty ||
        variantLabel.trim().isEmpty ||
        !['UAH', 'USD', 'EUR'].contains(currency) ||
        budget <= Decimal.zero ||
        reserve < Decimal.zero ||
        reserve >= budget ||
        this.needs.isEmpty ||
        settlementDelayDays < 0 ||
        settlementDelayDays > 30) {
      throw const FormatException('planner.invalid_scenario');
    }
    final start = isoDate(startDate);
    final min = isoDate(minMaturity);
    final max = isoDate(maxMaturity);
    if (min.isAfter(max) || !max.isAfter(start)) {
      throw const FormatException('planner.invalid_horizon');
    }
    if (this.needs.map((e) => e.id).toSet().length != this.needs.length ||
        this.positions.map((e) => e.isin).toSet().length !=
            this.positions.length) {
      throw const FormatException('planner.duplicate_items');
    }
    final positionIsins = this.positions.map((e) => e.isin).toSet();
    final exitIsins = this.positionExits.map((e) => e.isin).toList();
    if (exitIsins.toSet().length != exitIsins.length ||
        this.positionExits.any(
          (e) =>
              !positionIsins.contains(e.isin) ||
              e.price.currency != currency ||
              !isoDate(e.date).isAfter(start),
        )) {
      throw const FormatException('planner.invalid_position_exit');
    }
    if (this.exit.mode == ExitMode.earlySale) {
      if (this.positionExits.isNotEmpty ||
          this.positions.length != 1 ||
          this.exit.price!.isin != this.positions.single.isin ||
          this.exit.price!.currency != currency ||
          !isoDate(this.exit.date!).isAfter(start)) {
        throw const FormatException('planner.legacy_exit_ambiguous');
      }
    }
    if (!this.priceSourcePriority.isEmpty) {
      for (final position in this.positions) {
        if (position.price.kind == PriceValueKind.nominalEstimate) continue;
        final resolved = this.priceSourcePriority.resolvePurchase(
          position.isin,
          position.priceObservations,
        );
        if (resolved == null || !_samePriceObservation(resolved, position.price)) {
          throw const FormatException('planner.selected_price_priority_mismatch');
        }
      }
    }
  }

  List<PositionExitAssumption> get effectivePositionExits {
    if (positionExits.isNotEmpty) return positionExits;
    if (exit.mode == ExitMode.earlySale) {
      return [
        PositionExitAssumption(
          isin: exit.price!.isin,
          date: exit.date!,
          price: exit.price!,
        ),
      ];
    }
    return const [];
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'id': id,
    'name': name,
    if (groupId != null) 'groupId': groupId,
    'variantLabel': variantLabel,
    'currency': currency,
    'budget': budget.toString(),
    'reserve': reserve.toString(),
    'startDate': startDate,
    'maturityRange': {'min': minMaturity, 'max': maxMaturity},
    'strategy': strategy.name,
    'needs': needs.map((e) => e.toJson()).toList(),
    'positions': positions.map((e) => e.toJson()).toList(),
    if (!priceSourcePriority.isEmpty)
      'priceSourcePriority': priceSourcePriority.toJson(),
    'settlementDelayDays': settlementDelayDays,
    'pricedOnly': pricedOnly,
    'fees': fees.toJson(),
    'taxes': taxes.toJson(),
    'fx': fx.map((e) => e.toJson()).toList(),
    // Keep the legacy field safe for older schema-3 readers. New per-position
    // exits are additive and authoritative when present.
    'exit': positionExits.isEmpty
        ? exit.toJson()
        : ExitAssumption.holdToMaturity().toJson(),
    if (positionExits.isNotEmpty)
      'positionExits': positionExits.map((e) => e.toJson()).toList(),
  };

  factory PlannerScenario.fromJson(Map<String, dynamic> json) {
    if (json['schemaVersion'] != schemaVersion) {
      throw const FormatException('planner.unsupported_schema');
    }
    final range = Map<String, dynamic>.from(json['maturityRange'] as Map);
    final positions = (json['positions'] as List? ?? const [])
        .map(
          (e) => PlannerPositionDraft.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
    final legacyExit = ExitAssumption.fromJson(
      Map<String, dynamic>.from(json['exit'] as Map),
    );
    final positionExits = (json['positionExits'] as List? ?? const [])
        .map(
          (e) => PositionExitAssumption.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
    return PlannerScenario(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      groupId: json['groupId'] as String?,
      variantLabel: json['variantLabel'] as String? ?? 'A',
      currency: json['currency'] as String? ?? '',
      budget: _decimal(json['budget'], positive: true),
      reserve: _decimal(json['reserve']),
      startDate: _date(json['startDate']),
      minMaturity: _date(range['min']),
      maxMaturity: _date(range['max']),
      strategy: _readEnum(PlannerStrategy.values, json['strategy']),
      needs: (json['needs'] as List)
          .map(
            (e) => PlannerNeed.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
      positions: positions,
      priceSourcePriority: json['priceSourcePriority'] == null
          ? PriceSourcePriority.none()
          : PriceSourcePriority.fromJson(
              Map<String, dynamic>.from(json['priceSourcePriority'] as Map),
            ),
      settlementDelayDays: json['settlementDelayDays'] as int? ?? 0,
      pricedOnly: json['pricedOnly'] as bool? ?? false,
      fees: FeeAssumptions.fromJson(
        Map<String, dynamic>.from(json['fees'] as Map),
      ),
      taxes: TaxScenario.fromJson(
        Map<String, dynamic>.from(json['taxes'] as Map),
      ),
      fx: (json['fx'] as List? ?? const [])
          .map(
            (e) => FxAssumption.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
      exit: legacyExit,
      positionExits: positionExits,
    );
  }

  factory PlannerScenario.fromCurrentUi({
    required Map<String, String> criteria,
    required Iterable<PlanPosition> positions,
    required String savedAt,
    FeeAssumptions? fees,
    TaxScenario? taxes,
    Iterable<FxAssumption> fx = const [],
    ExitAssumption? exit,
    Iterable<PositionExitAssumption> positionExits = const [],
    PriceSourcePriority? priceSourcePriority,
    String? groupId,
    String variantLabel = 'A',
  }) {
    final needs = plannerNeedsFromCriteria(criteria);
    final strategy = switch (criteria['strategy']) {
      'profit' => PlannerStrategy.profit,
      'expenses' => PlannerStrategy.expenses,
      _ => PlannerStrategy.ladder,
    };
    return PlannerScenario(
      id: 'scenario:$savedAt',
      name: criteria['name']?.trim() ?? '',
      groupId: groupId,
      variantLabel: variantLabel,
      currency: criteria['currency']!,
      budget: money(criteria['budget']!),
      reserve: money(criteria['reserve']!),
      startDate: criteria['start']!,
      minMaturity: criteria['minDate']!,
      maxMaturity: criteria['maxDate']!,
      strategy: strategy,
      needs: needs,
      positions: positions
          .map(
            (position) => PlannerPositionDraft.fromLegacy(
              position,
              observedAt: savedAt,
            ),
          )
          .toList(),
      priceSourcePriority: priceSourcePriority,
      settlementDelayDays: int.parse(criteria['delay'] ?? '2'),
      pricedOnly: criteria['pricedOnly'] == 'true',
      fees: fees ?? FeeAssumptions.unknown(),
      taxes: taxes ?? TaxScenario.unknown(),
      fx: fx,
      exit: exit,
      positionExits: positionExits,
    );
  }

  factory PlannerScenario.fromCurrentUiDrafts({
    required Map<String, String> criteria,
    required Iterable<PlannerPositionDraft> positions,
    required String savedAt,
    PriceSourcePriority? priceSourcePriority,
    FeeAssumptions? fees,
    TaxScenario? taxes,
    Iterable<FxAssumption> fx = const [],
    ExitAssumption? exit,
    Iterable<PositionExitAssumption> positionExits = const [],
    String? groupId,
    String variantLabel = 'A',
  }) {
    final needs = plannerNeedsFromCriteria(criteria);
    final strategy = switch (criteria['strategy']) {
      'profit' => PlannerStrategy.profit,
      'expenses' => PlannerStrategy.expenses,
      _ => PlannerStrategy.ladder,
    };
    return PlannerScenario(
      id: 'scenario:$savedAt',
      name: criteria['name']?.trim() ?? '',
      groupId: groupId,
      variantLabel: variantLabel,
      currency: criteria['currency']!,
      budget: money(criteria['budget']!),
      reserve: money(criteria['reserve']!),
      startDate: criteria['start']!,
      minMaturity: criteria['minDate']!,
      maxMaturity: criteria['maxDate']!,
      strategy: strategy,
      needs: needs,
      positions: positions,
      priceSourcePriority: priceSourcePriority,
      settlementDelayDays: int.parse(criteria['delay'] ?? '2'),
      pricedOnly: criteria['pricedOnly'] == 'true',
      fees: fees ?? FeeAssumptions.unknown(),
      taxes: taxes ?? TaxScenario.unknown(),
      fx: fx,
      exit: exit,
      positionExits: positionExits,
    );
  }

  factory PlannerScenario.fromSavedSet(
    SavedSet saved, {
    required DateTime now,
  }) {
    final raw = saved.scenario;
    if (raw == null) {
      throw const FormatException('planner.collection_has_no_scenario');
    }
    if (raw['schemaVersion'] == schemaVersion) {
      return PlannerScenario.fromJson(Map<String, dynamic>.from(raw));
    }
    if (![1, 2].contains(raw['schemaVersion'])) {
      throw const FormatException('planner.unknown_scenario_version');
    }
    final criteria = <String, String>{
      ..._defaultLegacyCriteria(now),
      ...Map<String, String>.from(raw['criteria'] as Map),
    };
    final positions = <PlanPosition>[];
    for (final item in raw['positions'] as List? ?? const []) {
      final position = Map<String, dynamic>.from(item as Map);
      final bond = saved.bonds.firstWhere(
        (candidate) => candidate.isin == position['isin'],
      );
      positions.add(
        PlanPosition(
          bond,
          int.parse(position['quantity'].toString()),
          money(position['unitCost'] as String),
          nominalEstimate: position['nominalEstimate'] as bool? ?? true,
        ),
      );
    }
    return PlannerScenario.fromCurrentUi(
      criteria: criteria,
      positions: positions,
      savedAt: saved.savedAt,
    );
  }

  Map<String, String> toCurrentUiCriteria() {
    if (needs.isEmpty ||
        needs.first.type == PlannerNeedType.reserveFloor ||
        needs.skip(1).any((need) => need.type != PlannerNeedType.oneOff)) {
      throw UnsupportedError(
        'planner.typed_need_ui_unsupported',
      );
    }
    final primary = needs.first;
    final recurring = primary.type == PlannerNeedType.recurring;
    final result = <String, String>{
      'currency': currency,
      'budget': budget.toString(),
      'reserve': reserve.toString(),
      'start': startDate,
      'minDate': minMaturity,
      'maxDate': maxMaturity,
      'needName': primary.name,
      'needDate': primary.date,
      'needAmount': primary.amount.toString(),
      'needRecurring': '$recurring',
      'needEveryMonths': '${primary.everyMonths ?? 1}',
      'needOccurrences': '${primary.occurrences ?? 6}',
      'name': name,
      'strategy': strategy.name,
      'expenseCount': '${needs.length - 1}',
      'delay': '$settlementDelayDays',
      'pricedOnly': '$pricedOnly',
    };
    for (var i = 1; i < needs.length; i++) {
      final need = needs[i];
      final index = i - 1;
      result['expenseName$index'] = need.name;
      result['expenseDate$index'] = need.date;
      result['expenseAmount$index'] = need.amount.toString();
    }
    for (final position in positions) {
      if (position.price.kind != PriceValueKind.nominalEstimate) {
        result['unitPrice:${position.isin}'] = position.unitCost.toString();
      }
    }
    return result;
  }

  static Map<String, String> _defaultLegacyCriteria(DateTime now) {
    String date(DateTime d) => d.toIso8601String().substring(0, 10);
    return {
      'currency': 'UAH',
      'budget': '100000',
      'reserve': '10000',
      'start': date(now),
      'minDate': date(now.add(const Duration(days: 1))),
      'maxDate': date(DateTime(now.year + 2, now.month, now.day)),
      'needName': PlannerGeneratedCopy.primaryNeedName,
      'needDate': date(DateTime(now.year, now.month + 6, now.day)),
      'needAmount': '10000',
      'needRecurring': 'false',
      'needEveryMonths': '1',
      'needOccurrences': '6',
      'name': PlannerGeneratedCopy.planName,
      'strategy': 'ladder',
      'expenseCount': '0',
      'delay': '2',
      'pricedOnly': 'false',
    };
  }
}
