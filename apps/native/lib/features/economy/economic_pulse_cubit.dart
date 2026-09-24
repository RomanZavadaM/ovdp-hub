import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/hub_repository.dart';
import 'economic_pulse_model.dart';

@immutable
class EconomicPulseState {
  final EconomicPulseSnapshot? snapshot;
  final bool busy;

  const EconomicPulseState({
    this.snapshot,
    this.busy = false,
  });

  EconomicPulseState copyWith({
    EconomicPulseSnapshot? snapshot,
    bool? busy,
  }) => EconomicPulseState(
    snapshot: snapshot ?? this.snapshot,
    busy: busy ?? this.busy,
  );
}

class EconomicPulseCubit extends Cubit<EconomicPulseState> {
  final HubRepository repository;

  EconomicPulseCubit(this.repository) : super(const EconomicPulseState());

  Future<void> load() => refresh();

  Future<void> refresh() async {
    if (state.busy) return;
    emit(state.copyWith(busy: true));
    try {
      final snapshot = await repository.loadEconomicPulse();
      if (!isClosed) {
        emit(EconomicPulseState(snapshot: snapshot));
      }
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(busy: false));
      }
    }
  }
}
