import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/hub_repository.dart';
import '../../models.dart';

@immutable
class CollectionsState {
  final List<SavedSet> sets;
  final bool busy;
  final String? error;
  CollectionsState({
    Iterable<SavedSet> sets = const [],
    this.busy = false,
    this.error,
  }) : sets = List.unmodifiable(sets);
  CollectionsState copyWith({
    Iterable<SavedSet>? sets,
    bool? busy,
    String? error,
    bool clearError = false,
  }) => CollectionsState(
    sets: sets ?? this.sets,
    busy: busy ?? this.busy,
    error: clearError ? null : error ?? this.error,
  );
}

class CollectionsCubit extends Cubit<CollectionsState> {
  final HubRepository repository;
  late final StreamSubscription<WorkspaceSnapshot> _subscription;
  CollectionsCubit(this.repository)
    : super(CollectionsState(sets: repository.current?.sets ?? [])) {
    _subscription = repository.changes.listen(
      (s) => emit(state.copyWith(sets: s.sets, clearError: true)),
    );
  }
  Future<void> reload() async {
    if (state.busy) return;
    emit(state.copyWith(busy: true, clearError: true));
    try {
      await repository.reloadCollections();
      if (!isClosed) emit(state.copyWith(busy: false));
    } catch (e) {
      if (!isClosed) emit(state.copyWith(busy: false, error: e.toString()));
    }
  }

  void dismissError() => emit(state.copyWith(clearError: true));
  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
