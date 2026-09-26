import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum HubAppearance {
  classic,
  studio,
  dashboard,
}

String appearanceTranslationKey(HubAppearance appearance) => switch (appearance) {
  HubAppearance.classic => 'classicDesign',
  HubAppearance.studio => 'studioDesign',
  HubAppearance.dashboard => 'dashboardDesign',
};

@immutable
class AppearanceState {
  final HubAppearance mode;
  const AppearanceState({this.mode = HubAppearance.studio});

  bool get studio => mode == HubAppearance.studio;
  bool get dashboard => mode == HubAppearance.dashboard;

  AppearanceState copyWith({HubAppearance? mode}) =>
      AppearanceState(mode: mode ?? this.mode);
}

class AppearanceCubit extends Cubit<AppearanceState> {
  final ValueChanged<HubAppearance>? onSelected;

  AppearanceCubit({
    HubAppearance initialMode = HubAppearance.studio,
    this.onSelected,
  }) : super(AppearanceState(mode: initialMode));

  void select(HubAppearance mode) {
    if (state.mode == mode) return;
    emit(state.copyWith(mode: mode));
    onSelected?.call(mode);
  }

  // Kept for compatibility with older callers: toggles between the two
  // original appearances. The new dashboard is selected explicitly.
  void toggle() => select(
        state.mode == HubAppearance.studio
            ? HubAppearance.classic
            : HubAppearance.studio,
      );
}
