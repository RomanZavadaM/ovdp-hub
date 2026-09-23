import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../errors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/hub_repository.dart';
import '../../models.dart';
import '../planner/planner_comparison.dart';

@immutable
class CollectionsState {
  final List<SavedSet> sets;
  final bool busy;
  final AppError? error;
  final List<String> selectedComparisonKeys;
  final ScenarioComparison? comparison;
  CollectionsState({
    Iterable<SavedSet> sets = const [],
    this.busy = false,
    this.error,
    Iterable<String> selectedComparisonKeys = const [],
    this.comparison,
  }) : sets = List.unmodifiable(sets),
       selectedComparisonKeys = List.unmodifiable(selectedComparisonKeys);
  CollectionsState copyWith({
    Iterable<SavedSet>? sets,
    bool? busy,
    AppError? error,
    bool clearError = false,
    Iterable<String>? selectedComparisonKeys,
    ScenarioComparison? comparison,
    bool clearComparison = false,
  }) => CollectionsState(
    sets: sets ?? this.sets,
    busy: busy ?? this.busy,
    error: clearError ? null : error ?? this.error,
    selectedComparisonKeys:
        selectedComparisonKeys ?? this.selectedComparisonKeys,
    comparison: clearComparison ? null : comparison ?? this.comparison,
  );
}

class CollectionsCubit extends Cubit<CollectionsState> {
  final HubRepository repository;
  final DateTime Function() clock;
  late final StreamSubscription<WorkspaceSnapshot> _subscription;

  CollectionsCubit(
    this.repository, {
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now,
       super(CollectionsState(sets: repository.current?.sets ?? [])) {
    _subscription = repository.changes.listen((snapshot) {
      final available = snapshot.sets.map(_comparisonKey).toSet();
      final selected = state.selectedComparisonKeys
          .where(available.contains)
          .toList(growable: false);
      _emitComparison(
        sets: snapshot.sets,
        selectedKeys: selected,
        clearError: true,
      );
    });
  }

  static String _comparisonKey(SavedSet set) => '${set.savedAt}|${set.name}';

  void _emitComparison({
    required Iterable<SavedSet> sets,
    required List<String> selectedKeys,
    bool clearError = false,
  }) {
    final materialized = sets.toList(growable: false);
    final byKey = {
      for (final set in materialized) _comparisonKey(set): set,
    };
    final selected = selectedKeys
        .map((key) => byKey[key])
        .whereType<SavedSet>()
        .toList(growable: false);
    if (selected.length < 2) {
      emit(
        state.copyWith(
          sets: materialized,
          selectedComparisonKeys: selectedKeys,
          clearComparison: true,
          clearError: clearError,
        ),
      );
      return;
    }
    try {
      final comparison = compareSavedScenarios(selected, now: clock());
      emit(
        state.copyWith(
          sets: materialized,
          selectedComparisonKeys: selectedKeys,
          comparison: comparison,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          sets: materialized,
          selectedComparisonKeys: selectedKeys,
          clearComparison: true,
          error: AppError.from(e),
        ),
      );
    }
  }

  void toggleComparison(SavedSet set) {
    if (state.busy || set.scenario == null) return;
    final key = _comparisonKey(set);
    final selected = [...state.selectedComparisonKeys];
    if (selected.contains(key)) {
      selected.remove(key);
    } else {
      if (selected.length >= 3) {
        emit(
          state.copyWith(
            error: const AppError('planner.comparison_max_three'),
          ),
        );
        return;
      }
      selected.add(key);
    }
    _emitComparison(sets: state.sets, selectedKeys: selected);
  }

  void clearComparison() {
    emit(
      state.copyWith(
        selectedComparisonKeys: const [],
        clearComparison: true,
        clearError: true,
      ),
    );
  }

  bool isSelectedForComparison(SavedSet set) =>
      state.selectedComparisonKeys.contains(_comparisonKey(set));
  Future<void> reload() async {
    if (state.busy) return;
    emit(state.copyWith(busy: true, clearError: true));
    try {
      await repository.reloadCollections();
      if (!isClosed) emit(state.copyWith(busy: false));
    } catch (e) {
      if (!isClosed) emit(state.copyWith(busy: false, error: AppError.from(e)));
    }
  }

  void dismissError() => emit(state.copyWith(clearError: true));
  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
