import 'package:flutter/foundation.dart';
import '../../errors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_repository.dart';
import 'public_offers.dart';
import 'package:decimal/decimal.dart';
import '../../data/source_observation.dart';

@immutable
class SellersState {
  final SellerSnapshot? snapshot;
  final bool busy, askOnly;
  final String currency;
  final AppError? error;
  final List<PublicOfferSource> publicSources;
  final bool sourcesBusy;
  SellersState({
    this.snapshot,
    this.busy = false,
    this.askOnly = true,
    this.currency = 'UAH',
    this.error,
    Iterable<PublicOfferSource> publicSources = const [],
    this.sourcesBusy = false,
  }) : publicSources = List.unmodifiable(publicSources);
  SellersState copyWith({
    SellerSnapshot? snapshot,
    bool? busy,
    bool? askOnly,
    String? currency,
    AppError? error,
    bool clearError = false,
    Iterable<PublicOfferSource>? publicSources,
    bool? sourcesBusy,
  }) => SellersState(
    snapshot: snapshot ?? this.snapshot,
    busy: busy ?? this.busy,
    askOnly: askOnly ?? this.askOnly,
    currency: currency ?? this.currency,
    error: clearError ? null : error ?? this.error,
    publicSources: publicSources ?? this.publicSources,
    sourcesBusy: sourcesBusy ?? this.sourcesBusy,
  );
}

class SellersCubit extends Cubit<SellersState> {
  final SellerRepository repository;
  final PublicOffersRepository publicRepository;
  SellersCubit(this.repository, {PublicOffersRepository? publicRepository})
    : publicRepository = publicRepository ?? PublicOffersRepository(),
      super(SellersState());

  List<PublicBondOffer> get publicOffers => List.unmodifiable([
    for (final source in state.publicSources) ...source.offers,
    for (final quote in state.snapshot?.quotes ?? <SellerQuote>[])
      PublicBondOffer(provider: 'PrivatBank', sourceUrl: SellerRepository.url,
        isin: quote.isin, currency: quote.currency, maturity: quote.maturity,
        purchasePrice: null, listedYield: quote.askYield == null ? null : Decimal.parse(quote.askYield!),
        saleYield: quote.bidYield == null ? null : Decimal.parse(quote.bidYield!),
        yieldMethod: quote.method, meta: state.snapshot!.meta),
  ]);

  Future<void> refreshPublicSources() async {
    if (state.sourcesBusy) return;
    emit(state.copyWith(sourcesBusy: true));
    final previous = state.publicSources;
    final sources = await publicRepository.fetch();
    if (isClosed) return;
    emit(state.copyWith(sourcesBusy: false, publicSources: [
      for (final source in sources)
        if (source.errorCode != null)
          PublicOfferSource(source.provider, source.url, errorCode: source.errorCode,
            offers: previous.where((s) => s.provider == source.provider).expand((s) => s.offers))
        else source,
    ]));
  }

  Future<void> refreshAllPublicSources() async {
    await Future.wait([refresh(), refreshPublicSources()]);
  }

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
    publicRepository.dispose();
    return super.close();
  }
}
