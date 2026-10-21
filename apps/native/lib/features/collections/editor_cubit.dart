import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../errors.dart';
import '../../data/hub_repository.dart';
import '../../models.dart';
import '../portfolio/portfolio_cubit.dart';

@immutable
class EditorState {
  final Map<String, Bond> selected;
  final String name, note;
  final bool busy, locked, privateDraft;
  final String? recordId;
  final AppError? error;
  final int revision;
  EditorState({Map<String, Bond> selected = const {}, this.name = '',
    this.note = '', this.busy = false, this.locked = false,
    this.privateDraft = true, this.recordId, this.error, this.revision = 0,
  }) : selected = Map.unmodifiable(selected);
  bool get dirty => selected.isNotEmpty || name.isNotEmpty || note.isNotEmpty;
  EditorState copyWith({Map<String, Bond>? selected, String? name, String? note,
    bool? busy, bool? locked, AppError? error, bool clearError = false,
    int? revision,
  }) => EditorState(selected: selected ?? this.selected, name: name ?? this.name,
    note: note ?? this.note, busy: busy ?? this.busy, locked: locked ?? this.locked,
    privateDraft: privateDraft, recordId: recordId,
    error: clearError ? null : error ?? this.error, revision: revision ?? this.revision);
}

class CollectionEditorCubit extends Cubit<EditorState> {
  final HubRepository repository;
  final PortfolioCubit? portfolio;
  final DateTime Function() clock;
  StreamSubscription<bool>? _session;
  int _generation = 0;
  CollectionEditorCubit(this.repository, {this.portfolio, DateTime Function()? clock})
    : clock = clock ?? DateTime.now, super(EditorState()) {
    _session = portfolio?.gateway.unlockChanges.listen((open) {
      if (!open && !isClosed && state.privateDraft) {
        _generation++;
        emit(EditorState(locked: state.locked, revision: state.revision + 1));
      }
    });
  }
  bool get privateAvailable => portfolio?.state.unlocked == true &&
    portfolio?.gateway.unlocked == true;
  void selectPrivate(bool value) {
    if (state.busy || state.locked || state.privateDraft == value) return;
    _generation++;
    // Changing destination discards annotations; never convert them to plaintext.
    emit(EditorState(selected: state.selected, privateDraft: value,
      revision: state.revision + 1));
  }
  void toggle(Bond bond, bool checked) {
    if (state.busy || state.locked) return;
    final selected = {...state.selected};
    if (checked) { selected[bond.isin] = bond; } else { selected.remove(bond.isin); }
    emit(state.copyWith(selected: selected, clearError: true));
  }
  void edit({String? name, String? note}) {
    if (!state.busy && !state.locked && state.privateDraft && privateAvailable) {
      emit(state.copyWith(name: name, note: note, clearError: true));
    }
  }
  void lock(bool value) {
    if (!isClosed) emit(state.copyWith(locked: value));
  }
  void reset() {
    if (!state.busy) {
      _generation++;
      emit(EditorState(revision: state.revision + 1, locked: state.locked));
    }
  }
  void variant(SavedSet saved) {
    if (state.busy || state.locked || (saved.storedInVault && !privateAvailable)) return;
    if (saved.storedInVault && !portfolio!.privateCollectionSets.any((current) =>
        current.recordId == saved.recordId && savedSetContentEquals(current, saved))) {
      return;
    }
    _generation++;
    emit(EditorState(selected: {for (final b in saved.bonds) b.isin: b},
      name: privateAvailable ? saved.name : '', note: privateAvailable ? saved.note : '',
      recordId: saved.storedInVault ? saved.recordId : null,
      revision: state.revision + 1));
  }
  Future<bool> save() async {
    if (state.busy || state.locked) return false;
    if (state.privateDraft && !privateAvailable) {
      emit(state.copyWith(error: const AppError('vault.session_locked')));
      return false;
    }
    if (state.selected.isEmpty || (state.privateDraft && state.name.trim().isEmpty)) {
      emit(state.copyWith(error: const AppError('collection.name_and_issues_required')));
      return false;
    }
    final draft = state;
    final generation = _generation;
    final now = clock().toUtc().toIso8601String();
    emit(state.copyWith(busy: true, clearError: true));
    try {
      final set = SavedSet(draft.privateDraft ? draft.name.trim() : 'ISIN $now',
        draft.privateDraft ? draft.note.trim() : '', now, draft.selected.values);
      if (draft.privateDraft) {
        await portfolio!.savePrivateCollection(set, replaceId: draft.recordId);
      } else {
        await repository.saveCollection(set);
      }
      if (isClosed || generation != _generation) return false;
      emit(EditorState(privateDraft: draft.privateDraft, locked: state.locked,
        revision: draft.revision + 1));
      return true;
    } catch (e) {
      if (!isClosed && generation == _generation) {
        emit(state.copyWith(busy: false, error: AppError.from(e)));
      }
      return false;
    }
  }
  void dismissError() => emit(state.copyWith(clearError: true));
  @override
  Future<void> close() async {
    _generation++;
    await _session?.cancel();
    return super.close();
  }
}
