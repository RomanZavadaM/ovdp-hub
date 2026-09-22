import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_repository.dart';
import '../../data/source_observation.dart';

@immutable
class SellersState {
  final SellerSnapshot? snapshot;
  final bool busy, askOnly;
  final String currency;
  final String? error;
  const SellersState({
    this.snapshot,
    this.busy = false,
    this.askOnly = true,
    this.currency = 'UAH',
    this.error,
  });
  SellersState copyWith({
    SellerSnapshot? snapshot,
    bool? busy,
    bool? askOnly,
    String? currency,
    String? error,
    bool clearError = false,
  }) => SellersState(
    snapshot: snapshot ?? this.snapshot,
    busy: busy ?? this.busy,
    askOnly: askOnly ?? this.askOnly,
    currency: currency ?? this.currency,
    error: clearError ? null : error ?? this.error,
  );
}

class SellersCubit extends Cubit<SellersState> {
  final SellerRepository repository;
  SellersCubit(this.repository) : super(const SellersState());
  List<SellerQuote> get visible =>
      state.snapshot?.quotes
          .where(
            (q) =>
                q.currency == state.currency &&
                q.maturity.compareTo(
                      repository.clock().toIso8601String().substring(0, 10),
                    ) >
                    0 &&
                (!state.askOnly || q.askYield != null),
          )
          .toList() ??
      [];
  DataFreshness? get freshness => state.snapshot?.meta.freshness(repository.clock());

  String? get dateWarning {
    final meta = state.snapshot?.meta;
    if (meta == null) return null;
    return switch (meta.freshness(repository.clock())) {
      DataFreshness.futureDated =>
        'Дата джерела в майбутньому. Актуальність не підтверджена.',
      DataFreshness.stale =>
        'Котирування не за сьогодні. Уточніть умови у продавця.',
      DataFreshness.unknown =>
        'Джерело не має надійної дати даних. Перевірте умови у продавця.',
      DataFreshness.current => null,
    };
  }

  void currency(String value) => emit(state.copyWith(currency: value));
  void askOnly(bool value) => emit(state.copyWith(askOnly: value));
  Future<void> refresh() async {
    if (state.busy) return;
    emit(state.copyWith(busy: true, clearError: true));
    try {
      final snapshot = await repository.fetch();
      if (!isClosed) {
        emit(state.copyWith(snapshot: snapshot, busy: false, clearError: true));
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            busy: false,
            error:
                'Не вдалося оновити. Показано попереднє завантаження, якщо воно є. $e',
          ),
        );
      }
    }
  }

  @override
  Future<void> close() {
    repository.dispose();
    return super.close();
  }
}
