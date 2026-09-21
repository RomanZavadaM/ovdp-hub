import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/hub_repository.dart';
import '../collections/editor_cubit.dart';
import '../planner/planner_cubit.dart';

@immutable
class WorkspaceState {
  final String? path, error;
  final bool busy, externalFolders;
  const WorkspaceState({
    this.path,
    this.error,
    this.busy = false,
    this.externalFolders = false,
  });
  WorkspaceState copyWith({
    String? path,
    String? error,
    bool clearError = false,
    bool? busy,
    bool? externalFolders,
  }) => WorkspaceState(
    path: path ?? this.path,
    error: clearError ? null : error ?? this.error,
    busy: busy ?? this.busy,
    externalFolders: externalFolders ?? this.externalFolders,
  );
}

class WorkspaceCubit extends Cubit<WorkspaceState> {
  final HubRepository repository;
  final CollectionEditorCubit editor;
  final PlannerCubit? planner;
  WorkspaceCubit(this.repository, this.editor, {this.planner})
    : super(
        WorkspaceState(
          path: repository.current?.path,
          externalFolders: repository.supportsExternalFolders,
        ),
      );
  bool get needsDraftDecision =>
      editor.state.dirty || (planner?.state.dirty ?? false);
  Future<void> initialize() => _run(() async {
    await repository.initialize();
  });
  Future<void> choose({bool copy = false, bool discardDraft = false}) async {
    if (state.busy || editor.state.busy || (planner?.state.busy ?? false)) {
      return;
    }
    if (needsDraftDecision && !discardDraft) {
      emit(
        state.copyWith(
          error: 'Збережіть добірку або підтвердьте відкидання чернетки',
        ),
      );
      return;
    }
    await _run(() async {
      if (await repository.chooseWorkspace(copy: copy)) {
        editor.reset();
        planner?.reset();
      }
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    if (state.busy || editor.state.busy || (planner?.state.busy ?? false)) {
      return;
    }
    emit(state.copyWith(busy: true, clearError: true));
    editor.lock(true);
    planner?.lock(true);
    try {
      await action();
      if (!isClosed) {
        emit(state.copyWith(path: repository.current?.path, busy: false));
      }
    } catch (e) {
      if (!isClosed) emit(state.copyWith(busy: false, error: e.toString()));
    } finally {
      editor.lock(false);
      planner?.lock(false);
    }
  }

  void dismissError() => emit(state.copyWith(clearError: true));
}
