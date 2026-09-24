import 'dart:async';
import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import '../../errors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/hub_repository.dart';
import '../../data/source_observation.dart';
import '../../models.dart';
import '../../pricing.dart';
import 'planner_engine.dart';
import 'planner_export.dart';
import 'planner_fees.dart';
import 'planner_fx.dart';
import 'planner_goals.dart';
import 'planner_scenario.dart';
import 'planner_taxes.dart';

@immutable
class PositionInput {
  final Bond bond;
  final String quantity, price;
  final bool nominalEstimate;
  final List<PriceObservation> observations;
  final String? selectedSourceId;

  PositionInput(
    this.bond,
    this.quantity,
    this.price, {
    this.nominalEstimate = true,
    Iterable<PriceObservation> observations = const [],
    this.selectedSourceId,
  }) : observations = List.unmodifiable(observations) {
    if (this.observations.any(
      (o) => o.isin != bond.isin || o.currency != bond.currency,
    )) {
      throw const FormatException('planner.invalid_price_observation');
    }
  }

  PositionInput copyWith({
    String? quantity,
    String? price,
    bool? nominalEstimate,
    Iterable<PriceObservation>? observations,
    String? selectedSourceId,
    bool clearSelectedSource = false,
  }) => PositionInput(
    bond,
    quantity ?? this.quantity,
    price ?? this.price,
    nominalEstimate: nominalEstimate ?? this.nominalEstimate,
    observations: observations ?? this.observations,
    selectedSourceId: clearSelectedSource
        ? null
        : selectedSourceId ?? this.selectedSourceId,
  );

  PlanPosition parse() => PlanPosition(
    bond,
    int.parse(quantity),
    money(price),
    nominalEstimate: nominalEstimate,
  );

  PriceObservation? selectedObservation() {
    if (nominalEstimate) {
      for (final observation in observations) {
        if (observation.kind == PriceValueKind.nominalEstimate) {
          return observation;
        }
      }
      return null;
    }
    if (selectedSourceId == null) return null;
    final matches = observations
        .where(
          (o) =>
              o.meta.sourceId == selectedSourceId &&
              o.isExplicitPurchasePrice &&
              o.effectiveUnitCost == money(price),
        )
        .toList(growable: false);
    if (matches.length > 1) {
      throw const FormatException('planner.ambiguous_price_source');
    }
    return matches.isEmpty ? null : matches.single;
  }

  PlannerPositionDraft toDraft({required String observedAt}) {
    var selected = selectedObservation();
    final all = observations.toList(growable: true);
    if (selected == null) {
      selected = PriceObservation.legacy(
        bond: bond,
        unitCost: money(price),
        nominalEstimate: nominalEstimate,
        observedAt: observedAt,
      );
      all.insert(0, selected);
    }
    return PlannerPositionDraft(
      isin: bond.isin,
      quantity: int.parse(quantity),
      price: selected,
      priceObservations: all,
    );
  }

  factory PositionInput.fromDraft(Bond bond, PlannerPositionDraft draft) =>
      PositionInput(
        bond,
        draft.quantity.toString(),
        draft.unitCost.toString(),
        nominalEstimate: draft.price.kind == PriceValueKind.nominalEstimate,
        observations: draft.priceObservations,
        selectedSourceId: draft.price.kind == PriceValueKind.nominalEstimate
            ? null
            : draft.price.meta.sourceId,
      );
}

@immutable
class PlannerState {
  final Map<String, String> criteria;
  final Map<String, PositionInput> inputs;
  final PriceSourcePriority priceSourcePriority;
  final FeeAssumptions fees;
  final PlannerFeeImpact? feeImpact;
  final TaxScenario taxes;
  final PlannerTaxImpact? taxImpact;
  final List<FxAssumption> fx;
  final PlannerFxImpact? fxImpact;
  final List<PositionExitAssumption> positionExits;
  final List<Bond> candidates;
  final PlanSummary? summary;
  final List<ExpenseBalance> expenseBalances;
  final String profit;
  final AppError? error;
  final bool busy, locked, saved, changed;
  final int revision;
  PlannerState({
    required Map<String, String> criteria,
    Map<String, PositionInput> inputs = const {},
    PriceSourcePriority? priceSourcePriority,
    FeeAssumptions? fees,
    this.feeImpact,
    TaxScenario? taxes,
    this.taxImpact,
    Iterable<FxAssumption> fx = const [],
    this.fxImpact,
    Iterable<PositionExitAssumption> positionExits = const [],
    Iterable<Bond> candidates = const [],
    this.summary,
    Iterable<ExpenseBalance> expenseBalances = const [],
    this.profit = '0',
    this.error,
    this.busy = false,
    this.locked = false,
    this.saved = false,
    this.changed = false,
    this.revision = 0,
  }) : expenseBalances = List.unmodifiable(expenseBalances),
       criteria = Map.unmodifiable(criteria),
       inputs = Map.unmodifiable(inputs),
       priceSourcePriority = priceSourcePriority ?? PriceSourcePriority.none(),
       fees = fees ?? FeeAssumptions.unknown(),
       taxes = taxes ?? TaxScenario.unknown(),
       fx = List.unmodifiable(fx),
       positionExits = List.unmodifiable(positionExits),
       candidates = List.unmodifiable(candidates);
  bool get dirty => (changed || inputs.isNotEmpty) && !saved;
  PlannerState copyWith({
    Map<String, String>? criteria,
    Map<String, PositionInput>? inputs,
    PriceSourcePriority? priceSourcePriority,
    FeeAssumptions? fees,
    PlannerFeeImpact? feeImpact,
    TaxScenario? taxes,
    PlannerTaxImpact? taxImpact,
    Iterable<FxAssumption>? fx,
    PlannerFxImpact? fxImpact,
    Iterable<PositionExitAssumption>? positionExits,
    Iterable<Bond>? candidates,
    PlanSummary? summary,
    Iterable<ExpenseBalance>? expenseBalances,
    String? profit,
    AppError? error,
    bool clearSummary = false,
    bool clearError = false,
    bool? busy,
    bool? locked,
    bool? saved,
    int? revision,
  }) => PlannerState(
    criteria: criteria ?? this.criteria,
    inputs: inputs ?? this.inputs,
    priceSourcePriority: priceSourcePriority ?? this.priceSourcePriority,
    fees: fees ?? this.fees,
    feeImpact: clearSummary ? null : feeImpact ?? this.feeImpact,
    taxes: taxes ?? this.taxes,
    taxImpact: clearSummary ? null : taxImpact ?? this.taxImpact,
    fx: fx ?? this.fx,
    fxImpact: clearSummary ? null : fxImpact ?? this.fxImpact,
    positionExits: positionExits ?? this.positionExits,
    candidates: candidates ?? this.candidates,
    summary: clearSummary ? null : summary ?? this.summary,
    expenseBalances: clearSummary
        ? []
        : expenseBalances ?? this.expenseBalances,
    profit: clearSummary ? '0' : profit ?? this.profit,
    error: clearError ? null : error ?? this.error,
    busy: busy ?? this.busy,
    locked: locked ?? this.locked,
    saved: saved ?? this.saved,
    changed: saved == false ? true : changed,
    revision: revision ?? this.revision,
  );
}

class PlannerCubit extends Cubit<PlannerState> {
  final HubRepository repository;
  final DateTime Function() clock;
  late final StreamSubscription<WorkspaceSnapshot> _subscription;
  static Map<String, String> defaults(DateTime now) {
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
      'reserveFloorEnabled': 'false',
      'reserveFloorName': PlannerGeneratedCopy.reserveFloorName,
      'reserveFloorDate': date(DateTime(now.year, now.month + 6, now.day)),
      'reserveFloorAmount': '10000',
      'name': PlannerGeneratedCopy.planName,
      'strategy': 'ladder',
      'expenseCount': '0',
      'delay': '2',
      'pricedOnly': 'false',
    };
  }

  PlannerCubit(this.repository, {DateTime Function()? clock})
    : clock = clock ?? DateTime.now,
      super(PlannerState(criteria: defaults((clock ?? DateTime.now)()))) {
    _subscription = repository.changes.listen((_) => _recalculate(state));
    _recalculate(state);
  }

  PositionInput _legacyInput(
    Bond bond,
    int quantity,
    String price, {
    required bool nominalEstimate,
    Iterable<PriceObservation>? observations,
    String? selectedSourceId,
  }) {
    final existing = observations?.toList(growable: true) ?? <PriceObservation>[];
    if (existing.isEmpty) {
      existing.add(
        PriceObservation.legacy(
          bond: bond,
          unitCost: money(price),
          nominalEstimate: nominalEstimate,
          observedAt: clock().toUtc().toIso8601String(),
        ),
      );
    }
    return PositionInput(
      bond,
      quantity.toString(),
      price,
      nominalEstimate: nominalEstimate,
      observations: existing,
      selectedSourceId:
          nominalEstimate ? null : selectedSourceId ?? existing.first.meta.sourceId,
    );
  }

  PriceSourcePriority _withSourceFirst(String sourceId) => PriceSourcePriority([
    sourceId,
    ...state.priceSourcePriority.sourceIds.where((id) => id != sourceId),
  ]);

  Map<String, PositionInput> _applyPriority(
    PriceSourcePriority priority,
    Map<String, PositionInput> inputs, {
    String? activateIsin,
  }) {
    final result = <String, PositionInput>{};
    for (final entry in inputs.entries) {
      var input = entry.value;
      final shouldUseMarket =
          !input.nominalEstimate || entry.key == activateIsin;
      if (shouldUseMarket && !priority.isEmpty) {
        final selected = priority.resolvePurchase(
          input.bond.isin,
          input.observations,
        );
        if (selected != null) {
          input = input.copyWith(
            price: selected.effectiveUnitCost!.toString(),
            nominalEstimate: false,
            selectedSourceId: selected.meta.sourceId,
          );
        } else if (entry.key == activateIsin) {
          throw const FormatException('planner.no_price_for_priority');
        }
      }
      result[entry.key] = input;
    }
    return result;
  }

  void edit(String key, String value) {
    if (state.busy || state.locked) return;
    final resetPositions = [
      'currency',
      'start',
      'minDate',
      'maxDate',
    ].contains(key);
    _recalculate(
      state.copyWith(
        criteria: {...state.criteria, key: value},
        inputs: resetPositions ? {} : null,
        fees: key == 'currency' ? FeeAssumptions.unknown() : null,
        fx: key == 'currency' ? const [] : null,
        positionExits: resetPositions ? const [] : null,
        saved: false,
        clearError: true,
      ),
    );
  }

  void _recalculate(PlannerState next) {
    try {
      final c = next.criteria;
      final catalog = repository.current?.catalog;
      final candidates = catalog == null
          ? <Bond>[]
          : eligibleBonds(
              catalog,
              c['currency']!,
              c['start']!,
              c['minDate']!,
              c['maxDate']!,
            );
      final budget = money(c['budget']!), reserve = money(c['reserve']!);
      if (reserve > budget) {
        throw const FormatException('planner.reserve_exceeds_budget');
      }
      final expenses = readExpenses(c);
      final delay = int.parse(c['delay'] ?? '2');
      if (delay < 0 || delay > 30) {
        throw const FormatException('planner.delay_range');
      }
      final positions = next.inputs.values.map((i) => i.parse()).toList();
      final activePositionExits = next.positionExits
          .where((e) => next.inputs.containsKey(e.isin))
          .toList(growable: false);
      final exitOverrides = <String, PlanExitOverride>{
        for (final e in activePositionExits)
          e.isin: PlanExitOverride(
            e.isin,
            e.date,
            e.price.effectiveUnitCost!,
          ),
      };
      final summary = summarizePlan(
        positions: positions,
        currency: c['currency']!,
        budget: budget,
        start: c['start']!,
        needDate: c['needDate']!,
        needAmount: money(c['needAmount']!),
        exits: exitOverrides,
      );
      final feeImpact = evaluatePurchaseFeeImpact(
        fees: next.fees,
        positions: positions,
        currency: c['currency']!,
        budget: budget,
        start: c['start']!,
        exits: exitOverrides,
      );
      final profitBeforeTax =
          feeImpact.known ? feeImpact.profitAfterPurchaseFee : null;
      final taxImpact = evaluateTaxImpact(
        taxes: next.taxes,
        scenarioDate: c['start']!,
        profitBeforeTax: profitBeforeTax,
      );
      final profitForFx = taxImpact.known && taxImpact.profitAfterTax != null
          ? taxImpact.profitAfterTax!
          : feeImpact.known && feeImpact.profitAfterPurchaseFee != null
              ? feeImpact.profitAfterPurchaseFee!
              : feeImpact.grossProfit;
      final investedForFx = feeImpact.known && feeImpact.totalInitialCost != null
          ? feeImpact.totalInitialCost!
          : summary.cost;
      final reserveForFx = feeImpact.reserveAfterPurchaseFee ?? summary.reserve;
      final fxImpact = evaluateFxImpact(
        fx: next.fx,
        scenarioCurrency: c['currency']!,
        invested: investedForFx,
        reserve: reserveForFx,
        profit: profitForFx,
      );
      final reserveForValidation =
          feeImpact.reserveAfterPurchaseFee ?? summary.reserve;
      if (reserveForValidation < reserve) {
        throw const FormatException('planner.reserve_spent');
      }
      final calendarBudget = feeImpact.purchaseFee == null
          ? budget
          : budget - feeImpact.purchaseFee!;
      emit(
        next.copyWith(
          candidates: candidates,
          positionExits: activePositionExits,
          summary: summary,
          feeImpact: feeImpact,
          taxImpact: taxImpact,
          fxImpact: fxImpact,
          expenseBalances: expenseCalendar(
            positions,
            calendarBudget,
            c['start']!,
            expenses,
            delay,
            exits: exitOverrides,
          ),
          profit: feeImpact.grossProfit.toStringAsFixed(2),
          clearError: true,
        ),
      );
    } catch (e) {
      emit(next.copyWith(error: AppError.from(e), clearSummary: true));
    }
  }

  void generate() {
    if (state.busy || state.locked) return;
    try {
      final c = state.criteria, catalog = repository.current?.catalog;
      if (catalog == null) throw StateError('planner.workspace_required');
      final candidates = eligibleBonds(
        catalog,
        c['currency']!,
        c['start']!,
        c['minDate']!,
        c['maxDate']!,
      );
      final strategy = c['strategy'] ?? 'ladder';
      final budget = money(c['budget']!);
      final reserve = money(c['reserve']!);
      final explicitAggregateFee = simpleAggregatePurchaseFee(
        state.fees,
        c['currency']!,
      );
      final planningBudget = explicitAggregateFee == null
          ? budget
          : budget - explicitAggregateFee;
      if (planningBudget < reserve) {
        throw const FormatException('planner.reserve_spent');
      }
      final offers = candidates
          .where(
            (b) =>
                c['pricedOnly'] != 'true' ||
                c.containsKey('unitPrice:${b.isin}') ||
                state.inputs[b.isin]?.nominalEstimate == false,
          )
          .map((b) {
            final old = state.inputs[b.isin];
            return PlanPosition(
              b,
              1,
              money(
                c['unitPrice:${b.isin}'] ??
                    old?.price ??
                    b.json['nominal'].toString(),
              ).round(scale: 2),
              nominalEstimate: c.containsKey('unitPrice:${b.isin}')
                  ? false
                  : old?.nominalEstimate ?? true,
            );
          })
          .toList();
      final positions = strategy == 'ladder'
          ? makeLadder(candidates, planningBudget, reserve)
          : suggestProfitablePlan(
              offers: offers,
              budget: planningBudget,
              reserve: reserve,
              start: c['start']!,
              expenses: strategy == 'expenses' ? readExpenses(c) : [],
              delay: int.parse(c['delay'] ?? '2'),
            );
      _recalculate(
        state.copyWith(
          inputs: {
            for (final p in positions)
              p.bond.isin: state.inputs[p.bond.isin] == null
                  ? _legacyInput(
                      p.bond,
                      p.quantity,
                      p.unitCost.toString(),
                      nominalEstimate: p.nominalEstimate,
                    )
                  : state.inputs[p.bond.isin]!.copyWith(
                      quantity: p.quantity.toString(),
                      price: p.unitCost.toString(),
                      nominalEstimate: p.nominalEstimate,
                      clearSelectedSource: p.nominalEstimate,
                    ),
          },
          saved: false,
          revision: state.revision + 1,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: AppError.from(e), clearSummary: true));
    }
  }

  void addExpense() {
    if (state.busy || state.locked) return;
    final n = int.parse(state.criteria['expenseCount'] ?? '0');
    if (n >= 50) return;
    _recalculate(
      state.copyWith(
        criteria: {
          ...state.criteria,
          'expenseCount': '${n + 1}',
          'expenseName$n': PlannerGeneratedCopy.expenseName(n + 2),
          'expenseDate$n': state.criteria['needDate']!,
          'expenseAmount$n': '0',
        },
        saved: false,
      ),
    );
  }

  void removeExpense(int index) {
    if (state.busy || state.locked) return;
    final c = {...state.criteria};
    final n = int.parse(c['expenseCount'] ?? '0');
    if (index < 0 || index >= n) return;
    for (var i = index; i < n - 1; i++) {
      for (final key in ['expenseName', 'expenseDate', 'expenseAmount']) {
        c['$key$i'] = c['$key${i + 1}']!;
      }
    }
    for (final key in ['expenseName', 'expenseDate', 'expenseAmount']) {
      c.remove('$key${n - 1}');
    }
    c['expenseCount'] = '${n - 1}';
    _recalculate(
      state.copyWith(criteria: c, saved: false, revision: state.revision + 1),
    );
  }

  void toggle(Bond bond, bool selected) {
    if (state.busy || state.locked) return;
    final inputs = {...state.inputs};
    if (selected) {
      final explicit = state.criteria['unitPrice:${bond.isin}'];
      inputs[bond.isin] = _legacyInput(
        bond,
        1,
        explicit ?? bond.json['nominal'].toString(),
        nominalEstimate: explicit == null,
      );
    } else {
      inputs.remove(bond.isin);
    }
    _recalculate(state.copyWith(inputs: inputs, saved: false));
  }

  void position(String isin, {String? quantity, String? price}) {
    if (state.busy || state.locked) return;
    final old = state.inputs[isin];
    if (old == null) return;
    try {
      var priority = state.priceSourcePriority;
      var updated = old.copyWith(quantity: quantity);
      Map<String, String>? criteria;
      if (price != null) {
        final manual = PriceObservation.manualFullPrice(
          bond: old.bond,
          sourceId: 'manual-price',
          unitCost: money(price),
          observedAt: clock().toUtc().toIso8601String(),
        );
        final observations = [
          ...old.observations.where((o) => o.meta.sourceId != 'manual-price'),
          manual,
        ];
        priority = PriceSourcePriority([
          'manual-price',
          ...priority.sourceIds.where((id) => id != 'manual-price'),
        ]);
        updated = updated.copyWith(
          price: price,
          nominalEstimate: false,
          observations: observations,
          selectedSourceId: 'manual-price',
        );
        criteria = {...state.criteria, 'unitPrice:$isin': price};
      }
      _recalculate(
        state.copyWith(
          criteria: criteria,
          priceSourcePriority: priority,
          inputs: {...state.inputs, isin: updated},
          saved: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: AppError.from(e)));
    }
  }

  void addManualPriceSource(String isin, String label, String price) {
    if (state.busy || state.locked) return;
    final old = state.inputs[isin];
    if (old == null) return;
    try {
      final cleanLabel = label.trim();
      if (cleanLabel.isEmpty) {
        throw const FormatException('planner.price_source_name_required');
      }
      final sourceId = 'user:$cleanLabel';
      final observation = PriceObservation.manualFullPrice(
        bond: old.bond,
        sourceId: sourceId,
        unitCost: money(price),
        observedAt: clock().toUtc().toIso8601String(),
      );
      final observations = [
        ...old.observations.where((o) => o.meta.sourceId != sourceId),
        observation,
      ];
      final priority = state.priceSourcePriority.sourceIds.contains(sourceId)
          ? state.priceSourcePriority
          : PriceSourcePriority([
              ...state.priceSourcePriority.sourceIds,
              sourceId,
            ]);
      final updated = old.copyWith(observations: observations);
      final inputs = _applyPriority(
        priority,
        {...state.inputs, isin: updated},
        activateIsin: isin,
      );
      _recalculate(
        state.copyWith(
          priceSourcePriority: priority,
          inputs: inputs,
          saved: false,
          revision: state.revision + 1,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: AppError.from(e)));
    }
  }

  void selectPriceSource(String isin, String sourceId) {
    if (state.busy || state.locked) return;
    try {
      final priority = _withSourceFirst(sourceId);
      final inputs = _applyPriority(
        priority,
        state.inputs,
        activateIsin: isin,
      );
      _recalculate(
        state.copyWith(
          priceSourcePriority: priority,
          inputs: inputs,
          saved: false,
          revision: state.revision + 1,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: AppError.from(e)));
    }
  }

  void movePriceSource(String sourceId, int delta) {
    if (state.busy || state.locked || delta == 0) return;
    final ids = state.priceSourcePriority.sourceIds.toList();
    final index = ids.indexOf(sourceId);
    final target = index + delta;
    if (index < 0 || target < 0 || target >= ids.length) return;
    final moved = ids.removeAt(index);
    ids.insert(target, moved);
    try {
      final priority = PriceSourcePriority(ids);
      final inputs = _applyPriority(priority, state.inputs);
      _recalculate(
        state.copyWith(
          priceSourcePriority: priority,
          inputs: inputs,
          saved: false,
          revision: state.revision + 1,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: AppError.from(e)));
    }
  }

  void useNominalEstimate(String isin) {
    if (state.busy || state.locked) return;
    final old = state.inputs[isin];
    if (old == null) return;
    PriceObservation? nominal;
    for (final observation in old.observations) {
      if (observation.kind == PriceValueKind.nominalEstimate) {
        nominal = observation;
        break;
      }
    }
    nominal ??= PriceObservation.legacy(
      bond: old.bond,
      unitCost: money(old.bond.json['nominal'].toString()),
      nominalEstimate: true,
      observedAt: clock().toUtc().toIso8601String(),
    );
    final observations = old.observations.any(
      (o) => o.kind == PriceValueKind.nominalEstimate,
    )
        ? old.observations
        : [...old.observations, nominal];
    _recalculate(
      state.copyWith(
        inputs: {
          ...state.inputs,
          isin: old.copyWith(
            price: nominal.effectiveUnitCost!.toString(),
            nominalEstimate: true,
            observations: observations,
            clearSelectedSource: true,
          ),
        },
        saved: false,
        revision: state.revision + 1,
      ),
    );
  }

  void setFeesUnknown() {
    if (state.busy || state.locked) return;
    _recalculate(
      state.copyWith(
        fees: FeeAssumptions.unknown(),
        saved: false,
        clearError: true,
      ),
    );
  }

  void confirmZeroPurchaseFees() {
    if (state.busy || state.locked) return;
    _recalculate(
      state.copyWith(
        fees: FeeAssumptions.confirmed(const []),
        saved: false,
        clearError: true,
      ),
    );
  }

  void setAggregatePurchaseFee(String value) {
    if (state.busy || state.locked) return;
    try {
      final amount = money(value);
      final fees = amount == Decimal.zero
          ? FeeAssumptions.confirmed(const [])
          : FeeAssumptions.confirmed([
              FeeRule(
                id: 'ui-purchase-fee',
                name: PlannerGeneratedCopy.aggregatePurchaseFeeRuleName,
                kind: FeeKind.flat,
                event: FeeEvent.purchase,
                value: amount,
                currency: state.criteria['currency']!,
              ),
            ]);
      _recalculate(
        state.copyWith(fees: fees, saved: false, clearError: true),
      );
    } catch (e) {
      emit(state.copyWith(error: AppError.from(e)));
    }
  }

  void setTaxesUnknown() {
    if (state.busy || state.locked) return;
    _recalculate(
      state.copyWith(
        taxes: TaxScenario.unknown(),
        saved: false,
        clearError: true,
      ),
    );
  }

  void useUkraineResidentOvdp2026Taxes() {
    if (state.busy || state.locked) return;
    _recalculate(
      state.copyWith(
        taxes: TaxScenario.ukraineResidentOvdp2026(),
        saved: false,
        clearError: true,
      ),
    );
  }

  void setFxComparison({
    required String targetCurrency,
    required String rate,
    required String asOf,
    required String sourceUrl,
  }) {
    if (state.busy || state.locked) return;
    try {
      final base = state.criteria['currency']!;
      final cleanTarget = targetCurrency.trim().toUpperCase();
      final cleanUrl = sourceUrl.trim();
      final parsedUrl = Uri.tryParse(cleanUrl);
      if (parsedUrl == null ||
          !['http', 'https'].contains(parsedUrl.scheme) ||
          parsedUrl.host.isEmpty) {
        throw const FormatException('planner.fx_source_url_required');
      }
      final parsedRate = Decimal.parse(rate.trim());
      if (parsedRate <= Decimal.zero) {
        throw const FormatException('planner.invalid_fx');
      }
      final date = isoDate(asOf.trim()).toIso8601String().substring(0, 10);
      final assumption = FxAssumption(
        fromCurrency: base,
        toCurrency: cleanTarget,
        rate: parsedRate,
        asOf: date,
        source: SourceObservationMeta(
          sourceId: 'manual-fx:$cleanTarget',
          sourceUrl: cleanUrl,
          sourceDate: date,
          retrievedAt: clock().toUtc().toIso8601String(),
          kind: ObservationKind.manual,
          confidence: ObservationConfidence.userAssumption,
        ),
      );
      _recalculate(
        state.copyWith(
          fx: [assumption],
          saved: false,
          clearError: true,
          revision: state.revision + 1,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: AppError.from(e)));
    }
  }

  void clearFxComparison() {
    if (state.busy || state.locked) return;
    _recalculate(
      state.copyWith(
        fx: const [],
        saved: false,
        clearError: true,
        revision: state.revision + 1,
      ),
    );
  }

  void setPositionExit({
    required String isin,
    required String date,
    required String price,
    required PriceSide side,
    String sourceUrl = '',
  }) {
    if (state.busy || state.locked) return;
    final input = state.inputs[isin];
    if (input == null) return;
    try {
      if (![PriceSide.bid, PriceSide.manual].contains(side)) {
        throw const FormatException('planner.early_sale_requires_bid');
      }
      final saleDate = isoDate(date.trim());
      final start = isoDate(state.criteria['start']!);
      final maturity = isoDate(input.bond.maturity);
      if (!saleDate.isAfter(start) ||
          !saleDate.isBefore(maturity) ||
          input.bond.payments.any(
            (payment) => isoDate(payment['date'] as String) == saleDate,
          )) {
        throw const FormatException('planner.invalid_exit_timing');
      }
      final unitPrice = money(price);
      final cleanUrl = sourceUrl.trim();
      if (side == PriceSide.bid) {
        final parsed = Uri.tryParse(cleanUrl);
        if (parsed == null ||
            !['http', 'https'].contains(parsed.scheme) ||
            parsed.host.isEmpty) {
          throw const FormatException('planner.exit_source_url_required');
        }
      }
      final observedAt = clock().toUtc().toIso8601String();
      final observation = PriceObservation(
        isin: input.bond.isin,
        currency: input.bond.currency,
        kind: PriceValueKind.fullPrice,
        side: side,
        price: unitPrice,
        meta: SourceObservationMeta(
          sourceId: side == PriceSide.bid
              ? 'exit-bid:${input.bond.isin}'
              : 'exit-manual:${input.bond.isin}',
          sourceUrl: cleanUrl.isEmpty ? 'local://manual-exit' : cleanUrl,
          retrievedAt: observedAt,
          kind: ObservationKind.manual,
          confidence: ObservationConfidence.userAssumption,
        ),
      );
      final assumption = PositionExitAssumption(
        isin: isin,
        date: saleDate.toIso8601String().substring(0, 10),
        price: observation,
      );
      _recalculate(
        state.copyWith(
          positionExits: [
            ...state.positionExits.where((e) => e.isin != isin),
            assumption,
          ],
          saved: false,
          clearError: true,
          revision: state.revision + 1,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: AppError.from(e)));
    }
  }

  void clearPositionExit(String isin) {
    if (state.busy || state.locked) return;
    _recalculate(
      state.copyWith(
        positionExits: state.positionExits.where((e) => e.isin != isin),
        saved: false,
        clearError: true,
        revision: state.revision + 1,
      ),
    );
  }

  void lock(bool value) {
    if (!isClosed) emit(state.copyWith(locked: value));
  }

  void reset() {
    if (state.busy || isClosed) return;
    _recalculate(
      PlannerState(
        criteria: defaults(clock()),
        locked: state.locked,
        revision: state.revision + 1,
      ),
    );
  }

  void load(SavedSet saved) {
    if (state.busy || state.locked) return;
    try {
      final scenario = PlannerScenario.fromSavedSet(saved, now: clock());
      final criteria = {
        ...defaults(clock()),
        ...scenario.toCurrentUiCriteria(),
      };
      final inputs = <String, PositionInput>{};
      for (final position in scenario.positions) {
        final bond = saved.bonds.firstWhere((b) => b.isin == position.isin);
        inputs[bond.isin] = PositionInput.fromDraft(bond, position);
      }
      _recalculate(
        state.copyWith(
          criteria: criteria,
          inputs: inputs,
          priceSourcePriority: scenario.priceSourcePriority,
          fees: scenario.fees,
          taxes: scenario.taxes,
          fx: scenario.fx,
          positionExits: scenario.effectivePositionExits,
          saved: true,
          revision: state.revision + 1,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          error: const AppError('planner.open_failed'),
          clearSummary: true,
        ),
      );
    }
  }

  PlannerScenario _currentExportScenario(PlannerState draft) {
    if (draft.summary == null || draft.inputs.isEmpty) {
      throw StateError('planner.export_requires_generated');
    }
    final stableObservedAt = '${draft.criteria['start']}T00:00:00.000Z';
    return PlannerScenario.fromCurrentUiDrafts(
      criteria: draft.criteria,
      positions: draft.inputs.values.map(
        (input) => input.toDraft(observedAt: stableObservedAt),
      ),
      savedAt: stableObservedAt,
      priceSourcePriority: draft.priceSourcePriority,
      fees: draft.fees,
      taxes: draft.taxes,
      fx: draft.fx,
      positionExits: draft.positionExits,
    );
  }

  Future<String?> _export(String extension) async {
    if (state.busy || state.locked) return null;
    final draft = state;
    emit(state.copyWith(busy: true, clearError: true));
    try {
      final scenario = _currentExportScenario(draft);
      final bonds = {
        for (final input in draft.inputs.values) input.bond.isin: input.bond,
      };
      final content = switch (extension) {
        'csv' => buildPlannerCsv(
            scenario: scenario,
            bonds: bonds,
            coverage: draft.expenseBalances,
          ),
        'ics' => buildPlannerIcs(
            scenario: scenario,
            bonds: bonds,
            coverage: draft.expenseBalances,
          ),
        _ => throw const FormatException('planner.export_format_unsupported'),
      };
      final fileName = '${plannerExportStem(scenario)}.$extension';
      final path = await repository.saveTextExport(fileName, content);
      if (!isClosed) emit(state.copyWith(busy: false, clearError: true));
      return path;
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(busy: false, error: AppError.from(e)));
      }
      return null;
    }
  }

  Future<String?> exportCsv() => _export('csv');

  Future<String?> exportIcs() => _export('ics');

  Future<bool> save() async {
    if (state.busy ||
        state.locked ||
        state.summary == null ||
        state.inputs.isEmpty) {
      return false;
    }
    if (state.criteria['name']!.trim().isEmpty) {
      emit(state.copyWith(error: const AppError('planner.name_required')));
      return false;
    }
    final draft = state;
    emit(state.copyWith(busy: true, clearError: true));
    try {
      final savedAt = clock().toUtc().toIso8601String();
      final scenario = PlannerScenario.fromCurrentUiDrafts(
        criteria: draft.criteria,
        positions: draft.inputs.values.map(
          (i) => i.toDraft(observedAt: savedAt),
        ),
        savedAt: savedAt,
        priceSourcePriority: draft.priceSourcePriority,
        fees: draft.fees,
        taxes: draft.taxes,
        fx: draft.fx,
        positionExits: draft.positionExits,
      );
      await repository.saveCollection(
        SavedSet(
          draft.criteria['name']!.trim(),
          PlannerGeneratedCopy.scenarioNote,
          savedAt,
          draft.inputs.values.map((i) => i.bond),
          scenario: scenario.toJson(),
        ),
      );
      if (!isClosed) emit(state.copyWith(busy: false, saved: true));
      return true;
    } catch (e) {
      if (!isClosed) emit(state.copyWith(busy: false, error: AppError.from(e)));
      return false;
    }
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
