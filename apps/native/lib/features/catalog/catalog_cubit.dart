import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../errors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/hub_repository.dart';
import '../../models.dart';

@immutable
class CatalogState {
  final Catalog? catalog;
  final String query, currency, horizon;
  final bool activeOnly, busy;
  final AppError? error;
  final List<Bond> visible;
  final Map<String, int> currencyCounts;
  final bool stale;
  CatalogState({
    this.catalog,
    this.query = '',
    this.currency = '',
    this.horizon = 'all',
    this.activeOnly = true,
    this.busy = false,
    this.error,
    Iterable<Bond> visible = const [],
    Map<String, int> currencyCounts = const {},
    this.stale = false,
  }) : visible = List.unmodifiable(visible),
       currencyCounts = Map.unmodifiable(currencyCounts);
  CatalogState copyWith({
    Catalog? catalog,
    String? query,
    String? currency,
    String? horizon,
    bool? activeOnly,
    bool? busy,
    AppError? error,
    bool clearError = false,
    Iterable<Bond>? visible,
    Map<String, int>? currencyCounts,
    bool? stale,
  }) => CatalogState(
    catalog: catalog ?? this.catalog,
    query: query ?? this.query,
    currency: currency ?? this.currency,
    horizon: horizon ?? this.horizon,
    activeOnly: activeOnly ?? this.activeOnly,
    busy: busy ?? this.busy,
    error: clearError ? null : error ?? this.error,
    visible: visible ?? this.visible,
    currencyCounts: currencyCounts ?? this.currencyCounts,
    stale: stale ?? this.stale,
  );
}

class CatalogCubit extends Cubit<CatalogState> {
  final HubRepository repository;
  final DateTime Function() clock;
  late final StreamSubscription<WorkspaceSnapshot> _subscription;
  CatalogCubit(this.repository, {DateTime Function()? clock})
    : clock = clock ?? DateTime.now,
      super(CatalogState()) {
    _subscription = repository.changes.listen(
      (s) => _filter(state.copyWith(catalog: s.catalog, clearError: true)),
    );
    if (repository.current != null) {
      _filter(state.copyWith(catalog: repository.current!.catalog));
    }
  }
  void filter({
    String? query,
    String? currency,
    String? horizon,
    bool? activeOnly,
  }) => _filter(
    state.copyWith(
      query: query,
      currency: currency,
      horizon: horizon,
      activeOnly: activeOnly,
    ),
  );
  void _filter(CatalogState next) {
    final date = clock();
    final today = DateTime.utc(date.year, date.month, date.day);
    final shortEnd = DateTime.utc(date.year + 1, date.month, date.day);
    final longStart = DateTime.utc(date.year + 2, date.month, date.day);
    final visible = (next.catalog?.bonds ?? <Bond>[]).where((b) {
      final maturity = isoDate(b.maturity);
      return b.isin.contains(next.query.trim().toUpperCase()) &&
          (next.currency.isEmpty || b.currency == next.currency) &&
          (!next.activeOnly || !maturity.isBefore(today)) &&
          (next.horizon == 'all' ||
              (next.horizon == 'short'
                  ? !maturity.isAfter(shortEnd) && !maturity.isBefore(today)
                  : !maturity.isBefore(longStart)));
    }).toList()..sort((a, b) => a.maturity.compareTo(b.maturity));
    emit(
      next.copyWith(
        visible: visible,
        currencyCounts: {
          for (final c in ['UAH', 'USD', 'EUR'])
            c: visible.where((b) => b.currency == c).length,
        },
        stale:
            next.catalog != null &&
            clock()
                    .toUtc()
                    .difference(
                      DateTime.parse(
                        next.catalog!.json['retrievedAt'] as String,
                      ),
                    )
                    .inHours >
                24,
      ),
    );
  }

  Future<void> refresh() async {
    if (state.busy) return;
    emit(state.copyWith(busy: true, clearError: true));
    try {
      await repository.refreshCatalog();
      if (!isClosed) emit(state.copyWith(busy: false));
    } catch (e) {
      if (!isClosed) emit(state.copyWith(busy: false, error: AppError.from(e)));
    }
  }

  void dismissError() => emit(state.copyWith(clearError: true));
  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
