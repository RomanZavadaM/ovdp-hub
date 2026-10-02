import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import '../../data/hub_repository.dart';
import '../../errors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models.dart';
import '../../pricing.dart';
import 'accrued_interest.dart';

@immutable
class CalculatorState {
  final String quantity, price, fee;

  /// Selected catalog bond; `null` keeps the labelled synthetic example.
  final String? isin;

  /// Settlement (payment) date for a catalog bond, `YYYY-MM-DD`.
  final String settlement;
  final BondResult? result;

  /// Accrued interest per bond used by the last catalog calculation.
  final Decimal? accruedPerBond;
  final AppError? error;
  const CalculatorState({
    this.quantity = '117',
    this.price = '850',
    this.fee = '100',
    this.isin,
    this.settlement = '',
    this.result,
    this.accruedPerBond,
    this.error,
  });
  CalculatorState copyWith({
    String? quantity,
    String? price,
    String? fee,
    String? isin,
    bool clearIsin = false,
    String? settlement,
    BondResult? result,
    Decimal? accruedPerBond,
    AppError? error,
    bool clearResult = false,
    bool clearError = false,
  }) => CalculatorState(
    quantity: quantity ?? this.quantity,
    price: price ?? this.price,
    fee: fee ?? this.fee,
    isin: clearIsin ? null : isin ?? this.isin,
    settlement: settlement ?? this.settlement,
    result: clearResult ? null : result ?? this.result,
    accruedPerBond: clearResult ? null : accruedPerBond ?? this.accruedPerBond,
    error: clearError ? null : error ?? this.error,
  );
}

class CalculatorCubit extends Cubit<CalculatorState> {
  final HubRepository? repository;
  final DateTime Function() clock;

  CalculatorCubit({this.repository, DateTime Function()? clock})
    : clock = clock ?? DateTime.now,
      super(const CalculatorState());

  void edit({String? quantity, String? price, String? fee, String? settlement}) =>
      emit(
        state.copyWith(
          quantity: quantity,
          price: price,
          fee: fee,
          settlement: settlement,
          clearResult: true,
          clearError: true,
        ),
      );

  /// Selects a catalog bond (or `null` for the synthetic example). The price
  /// starts at the nominal and the settlement date at today.
  void selectBond(String? isin) {
    if (isin == null) {
      emit(
        state.copyWith(
          clearIsin: true,
          price: const CalculatorState().price,
          clearResult: true,
          clearError: true,
        ),
      );
      return;
    }
    final bond = _bond(isin);
    final today = clock().toIso8601String().substring(0, 10);
    emit(
      state.copyWith(
        isin: isin,
        price: bond?.json['nominal']?.toString() ?? state.price,
        settlement: state.settlement.isEmpty ? today : state.settlement,
        clearResult: true,
        clearError: true,
      ),
    );
  }

  Bond? _bond(String isin) {
    for (final bond in repository?.current?.catalog.bonds ?? const <Bond>[]) {
      if (bond.isin == isin) return bond;
    }
    return null;
  }

  void calculate() {
    try {
      final isin = state.isin;
      if (isin == null) {
        final result = calculateBond(
          quantity: int.parse(state.quantity),
          cleanPrice: state.price,
          accruedInterest: '0',
          fee: state.fee,
          settlement: '2026-09-22',
          payments: [
            {'date': '2027-09-22', 'amount': '1000'},
          ],
        );
        emit(state.copyWith(result: result, clearError: true));
        return;
      }
      final bond = _bond(isin);
      if (bond == null) {
        throw const FormatException('calculator.bond_missing');
      }
      final accrued = accruedInterestPerBond(bond, state.settlement);
      final payments = futureBondPayments(bond, state.settlement);
      if (payments.isEmpty) {
        throw const FormatException('calculator.no_future_payments');
      }
      final result = calculateBond(
        quantity: int.parse(state.quantity),
        cleanPrice: state.price.trim(),
        accruedInterest: accrued.toString(),
        fee: state.fee.trim(),
        settlement: state.settlement,
        payments: payments,
      );
      emit(
        state.copyWith(
          result: result,
          accruedPerBond: accrued,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: AppError.from(e), clearResult: true));
    }
  }
}
