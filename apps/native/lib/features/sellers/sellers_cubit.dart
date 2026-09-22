import 'package:flutter/foundation.dart';
import '../../errors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_repository.dart';
import '../../data/source_observation.dart';

@immutable
class SellersState {
  final SellerSnapshot? snapshot;
  final bool busy, askOnly;
  final String currency;
  final AppError? error;
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
    AppError? error,
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
                q.maturity.compareTo(repository.clock().toIso8601String().substring(0, 10)) > 0 &&
                (!state.askOnly || q.askYield != null),
          )
          .toList() ??
      [];

  DataFreshness? get freshness =>
      state.snapshot?.meta.freshness(repository.clock());

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
        emit(state.copyWith(busy: false, error: AppError.from(e)));
      }
    }
  }

  @override
  Future<void> close() {
    repository.dispose();
    return super.close();
  }
}
