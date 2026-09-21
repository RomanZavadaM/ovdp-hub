import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/hub_repository.dart';
import '../../models.dart';
import '../../pricing.dart';
import 'planner_engine.dart';

@immutable
class PositionInput {
  final Bond bond;
  final String quantity, price;
  final bool nominalEstimate;
  const PositionInput(
    this.bond,
    this.quantity,
    this.price, {
    this.nominalEstimate = true,
  });
  PositionInput copyWith({
    String? quantity,
    String? price,
    bool? nominalEstimate,
  }) => PositionInput(
    bond,
    quantity ?? this.quantity,
    price ?? this.price,
    nominalEstimate: nominalEstimate ?? this.nominalEstimate,
  );
  PlanPosition parse() => PlanPosition(
    bond,
    int.parse(quantity),
    money(price),
    nominalEstimate: nominalEstimate,
  );
}

@immutable
class PlannerState {
  final Map<String, String> criteria;
  final Map<String, PositionInput> inputs;
  final List<Bond> candidates;
  final PlanSummary? summary;
  final String? error;
  final bool busy, locked, saved;
  final int revision;
  PlannerState({
    required Map<String, String> criteria,
    Map<String, PositionInput> inputs = const {},
    Iterable<Bond> candidates = const [],
    this.summary,
    this.error,
    this.busy = false,
    this.locked = false,
    this.saved = false,
    this.revision = 0,
  }) : criteria = Map.unmodifiable(criteria),
       inputs = Map.unmodifiable(inputs),
       candidates = List.unmodifiable(candidates);
  bool get dirty => inputs.isNotEmpty && !saved;
  PlannerState copyWith({
    Map<String, String>? criteria,
    Map<String, PositionInput>? inputs,
    Iterable<Bond>? candidates,
    PlanSummary? summary,
    String? error,
    bool clearSummary = false,
    bool clearError = false,
    bool? busy,
    bool? locked,
    bool? saved,
    int? revision,
  }) => PlannerState(
    criteria: criteria ?? this.criteria,
    inputs: inputs ?? this.inputs,
    candidates: candidates ?? this.candidates,
    summary: clearSummary ? null : summary ?? this.summary,
    error: clearError ? null : error ?? this.error,
    busy: busy ?? this.busy,
    locked: locked ?? this.locked,
    saved: saved ?? this.saved,
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
    };
  }

  PlannerCubit(this.repository, {DateTime Function()? clock})
    : clock = clock ?? DateTime.now,
      super(PlannerState(criteria: defaults((clock ?? DateTime.now)()))) {
    _subscription = repository.changes.listen((_) => _recalculate(state));
    _recalculate(state);
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
        throw const FormatException('Резерв перевищує бюджет');
      }
      final summary = summarizePlan(
        positions: next.inputs.values.map((i) => i.parse()).toList(),
        currency: c['currency']!,
        budget: budget,
        start: c['start']!,
        needDate: c['needDate']!,
        needAmount: money(c['needAmount']!),
      );
      if (summary.reserve < reserve) {
        throw const FormatException('Позиції витрачають запланований резерв');
      }
      emit(
        next.copyWith(
          candidates: candidates,
          summary: summary,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(next.copyWith(error: e.toString(), clearSummary: true));
    }
  }

  void generate() {
    if (state.busy || state.locked) return;
    try {
      final c = state.criteria, catalog = repository.current?.catalog;
      if (catalog == null) throw StateError('Спочатку відкрийте робочу папку');
      final candidates = eligibleBonds(
        catalog,
        c['currency']!,
        c['start']!,
        c['minDate']!,
        c['maxDate']!,
      );
      final positions = makeLadder(
        candidates,
        money(c['budget']!),
        money(c['reserve']!),
      );
      _recalculate(
        state.copyWith(
          inputs: {
            for (final p in positions)
              p.bond.isin: PositionInput(
                p.bond,
                p.quantity.toString(),
                p.unitCost.toString(),
              ),
          },
          saved: false,
          revision: state.revision + 1,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString(), clearSummary: true));
    }
  }

  void toggle(Bond bond, bool selected) {
    if (state.busy || state.locked) return;
    final inputs = {...state.inputs};
    if (selected) {
      inputs[bond.isin] = PositionInput(
        bond,
        '1',
        bond.json['nominal'].toString(),
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
      final plan = saved.scenario!;
      if (plan['schemaVersion'] != 1) {
        throw const FormatException('Невідома версія сценарію');
      }
      final criteria = Map<String, String>.from(plan['criteria'] as Map);
      final inputs = <String, PositionInput>{};
      for (final raw in plan['positions'] as List) {
        final bond = saved.bonds.firstWhere((b) => b.isin == raw['isin']);
        inputs[bond.isin] = PositionInput(
          bond,
          raw['quantity'].toString(),
          raw['unitCost'] as String,
          nominalEstimate: raw['nominalEstimate'] as bool,
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
          error: 'Не вдалося відкрити план: $e',
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
      emit(state.copyWith(error: 'Введіть назву плану'));
      return false;
    }
    final draft = state;
    emit(state.copyWith(busy: true, clearError: true));
    try {
      await repository.saveCollection(
        SavedSet(
          draft.criteria['name']!.trim(),
          'Сценарій у ${draft.criteria['currency']}. Ціни за номіналом або введені вручну; доступність не підтверджена.',
          clock().toUtc().toIso8601String(),
          draft.inputs.values.map((i) => i.bond),
          scenario: {
            'schemaVersion': 1,
            'criteria': draft.criteria,
            'positions': draft.inputs.values
                .map((i) => i.parse().toJson())
                .toList(),
          },
        ),
      );
      if (!isClosed) emit(state.copyWith(busy: false, saved: true));
      return true;
    } catch (e) {
      if (!isClosed) emit(state.copyWith(busy: false, error: e.toString()));
      return false;
    }
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
