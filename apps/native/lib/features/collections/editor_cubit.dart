import 'package:flutter/foundation.dart';
import '../../errors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/hub_repository.dart';
import '../../models.dart';

@immutable
class EditorState {
  final Map<String, Bond> selected;
  final String name, note;
  final bool busy, locked;
  final AppError? error;
  final int revision;
  EditorState({
    Map<String, Bond> selected = const {},
    this.name = '',
    this.note = '',
    this.busy = false,
    this.locked = false,
    this.error,
    this.revision = 0,
  }) : selected = Map.unmodifiable(selected);
  bool get dirty => selected.isNotEmpty || name.isNotEmpty || note.isNotEmpty;
  EditorState copyWith({
    Map<String, Bond>? selected,
    String? name,
    String? note,
    bool? busy,
    bool? locked,
    AppError? error,
    bool clearError = false,
    int? revision,
  }) => EditorState(
    selected: selected ?? this.selected,
    name: name ?? this.name,
    note: note ?? this.note,
    busy: busy ?? this.busy,
    locked: locked ?? this.locked,
    error: clearError ? null : error ?? this.error,
    revision: revision ?? this.revision,
  );
}

class CollectionEditorCubit extends Cubit<EditorState> {
  final HubRepository repository;
  final DateTime Function() clock;
  CollectionEditorCubit(this.repository, {DateTime Function()? clock})
    : clock = clock ?? DateTime.now,
      super(EditorState());
  void toggle(Bond bond, bool checked) {
    if (state.busy || state.locked) return;
    final selected = {...state.selected};
    if (checked) {
      selected[bond.isin] = bond;
    } else {
      selected.remove(bond.isin);
    }
    emit(state.copyWith(selected: selected, clearError: true));
  }

  void edit({String? name, String? note}) {
    if (!state.busy && !state.locked) {
      emit(state.copyWith(name: name, note: note, clearError: true));
    }
  }

  void lock(bool value) {
    if (!isClosed) emit(state.copyWith(locked: value));
  }

  void reset() {
    if (!state.busy) {
      emit(EditorState(revision: state.revision + 1, locked: state.locked));
    }
  }

  void variant(SavedSet saved) {
    if (state.busy || state.locked) return;
    emit(
      EditorState(
        selected: {for (final b in saved.bonds) b.isin: b},
        name: '${saved.name} — варіант',
        note: saved.note,
        revision: state.revision + 1,
      ),
    );
  }

  Future<bool> save() async {
    if (state.busy || state.locked) return false;
    if (state.selected.isEmpty || state.name.trim().isEmpty) {
      emit(state.copyWith(error: const AppError('collection.name_and_issues_required')));
      return false;
    }
    final draft = state;
    emit(state.copyWith(busy: true, clearError: true));
    try {
      await repository.saveCollection(
        SavedSet(
          draft.name.trim(),
          draft.note.trim(),
          clock().toUtc().toIso8601String(),
          draft.selected.values.toList(),
        ),
      );
      if (!isClosed) emit(EditorState(revision: draft.revision + 1));
      return true;
    } catch (e) {
      if (!isClosed) emit(state.copyWith(busy: false, error: AppError.from(e)));
      return false;
    }
  }

  void dismissError() => emit(state.copyWith(clearError: true));
}
