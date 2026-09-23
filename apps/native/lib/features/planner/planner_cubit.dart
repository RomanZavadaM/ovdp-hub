import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../errors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/hub_repository.dart';
import '../../models.dart';
import '../../pricing.dart';
import 'planner_engine.dart';
import 'planner_goals.dart';
import 'planner_scenario.dart';

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
       candidates = List.unmodifiable(candidates);
  bool get dirty => (changed || inputs.isNotEmpty) && !saved;
  PlannerState copyWith({
    Map<String, String>? criteria,
    Map<String, PositionInput>? inputs,
    PriceSourcePriority? priceSourcePriority,
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
      'needDate': date(DateTime(now.year, now.month + 6, now.day)),
      'needAmount': '10000',
      'name': 'Мій план',
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
      final summary = summarizePlan(
        positions: next.inputs.values.map((i) => i.parse()).toList(),
        currency: c['currency']!,
        budget: budget,
        start: c['start']!,
        needDate: c['needDate']!,
        needAmount: money(c['needAmount']!),
      );
      if (summary.reserve < reserve) {
        throw const FormatException('planner.reserve_spent');
      }
      emit(
        next.copyWith(
          candidates: candidates,
          summary: summary,
          expenseBalances: expenseCalendar(
            positions,
            budget,
            c['start']!,
            expenses,
            delay,
          ),
          profit: totalProfit(positions, c['start']!).toStringAsFixed(2),
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
          ? makeLadder(candidates, money(c['budget']!), money(c['reserve']!))
          : suggestProfitablePlan(
              offers: offers,
              budget: money(c['budget']!),
              reserve: money(c['reserve']!),
              start: c['start']!,
              expenses: strategy == 'expenses' ? readExpenses(c) : [],
              delay: int.parse(c['delay'] ?? '2'),
            );
      _recalculate(
        state.copyWith(
          inputs: {
            for (final p in positions)
              p.bond.isin: PositionInput(
                p.bond,
                p.quantity.toString(),
                p.unitCost.toString(),
                nominalEstimate: p.nominalEstimate,
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
          'expenseName$n': 'Витрата ${n + 2}',
          'expenseDate$n': state.criteria['needDate']!,
          'expenseAmount$n': '0',
        },
        saved: false,
      ),
    );
  }

  void repeatMonthly() {
    if (state.busy || state.locked) return;
    try {
      final c = {...state.criteria};
      final base = isoDate(c['needDate']!);
      money(c['needAmount']!);
      final n = int.parse(c['expenseCount'] ?? '0');
      if (n > 45) throw const FormatException('planner.too_many_expenses');
      for (var j = 1; j <= 5; j++) {
        final month = DateTime.utc(base.year, base.month + j);
        final lastDay = DateTime.utc(month.year, month.month + 1, 0).day;
        final date = DateTime.utc(
          month.year,
          month.month,
          base.day > lastDay ? lastDay : base.day,
        );
        final i = n + j - 1;
        c['expenseName$i'] = 'Щомісячна потреба ${j + 1}';
        c['expenseDate$i'] = date.toIso8601String().substring(0, 10);
        c['expenseAmount$i'] = c['needAmount']!;
      }
      c['expenseCount'] = '${n + 5}';
      _recalculate(state.copyWith(criteria: c, saved: false));
    } catch (e) {
      emit(state.copyWith(error: AppError.from(e)));
    }
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
    _recalculate(
      state.copyWith(
        criteria: price == null
            ? null
            : {...state.criteria, 'unitPrice:$isin': price},
        inputs: {
          ...state.inputs,
          isin: old.copyWith(
            quantity: quantity,
            price: price,
            nominalEstimate: price == null ? null : false,
          ),
        },
        saved: false,
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
        final nominal =
            position.price.kind == PriceValueKind.nominalEstimate;
        inputs[bond.isin] = PositionInput(
          bond,
          position.quantity.toString(),
          position.unitCost.toString(),
          nominalEstimate: nominal,
        );
      }
      _recalculate(
        state.copyWith(
          criteria: criteria,
          inputs: inputs,
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
      final scenario = PlannerScenario.fromCurrentUi(
        criteria: draft.criteria,
        positions: draft.inputs.values.map((i) => i.parse()),
        savedAt: savedAt,
      );
      await repository.saveCollection(
        SavedSet(
          draft.criteria['name']!.trim(),
          'Сценарій у ${draft.criteria['currency']}. Невідомі комісії, податки або FX не підміняються нулем.',
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
