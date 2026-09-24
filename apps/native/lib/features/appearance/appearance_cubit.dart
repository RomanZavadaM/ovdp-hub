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
  AppearanceCubit() : super(const AppearanceState());

  void select(HubAppearance mode) => emit(state.copyWith(mode: mode));

  // Kept for compatibility with older callers: toggles between the two
  // original appearances. The new dashboard is selected explicitly.
  void toggle() => select(
        state.mode == HubAppearance.studio
            ? HubAppearance.classic
            : HubAppearance.studio,
      );
}
