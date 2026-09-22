import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@immutable
class AppearanceState {
  final bool studio;
  const AppearanceState({this.studio = true});
  AppearanceState copyWith({bool? studio}) =>
      AppearanceState(studio: studio ?? this.studio);
}

class AppearanceCubit extends Cubit<AppearanceState> {
  AppearanceCubit() : super(const AppearanceState());
  void toggle() => emit(state.copyWith(studio: !state.studio));
}
