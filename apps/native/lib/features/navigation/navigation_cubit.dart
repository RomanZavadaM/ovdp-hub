import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@immutable
class NavigationState {
  final int index;
  const NavigationState({this.index = 0});
  NavigationState copyWith({int? index}) =>
      NavigationState(index: index ?? this.index);
}

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState());
  void select(int index) {
    if (index >= 0 && index < 5) emit(state.copyWith(index: index));
  }
}
