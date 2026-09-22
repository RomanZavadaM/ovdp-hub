import 'package:flutter/foundation.dart';
import '../../errors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../pricing.dart';

@immutable
class CalculatorState {
  final String quantity, price, fee;
  final BondResult? result;
  final AppError? error;
  const CalculatorState({
    this.quantity = '117',
    this.price = '850',
    this.fee = '100',
    this.result,
    this.error,
  });
  CalculatorState copyWith({
    String? quantity,
    String? price,
    String? fee,
    BondResult? result,
    AppError? error,
    bool clearResult = false,
    bool clearError = false,
  }) => CalculatorState(
    quantity: quantity ?? this.quantity,
    price: price ?? this.price,
    fee: fee ?? this.fee,
    result: clearResult ? null : result ?? this.result,
    error: clearError ? null : error ?? this.error,
  );
}

class CalculatorCubit extends Cubit<CalculatorState> {
  CalculatorCubit() : super(const CalculatorState());
  void edit({String? quantity, String? price, String? fee}) => emit(
    state.copyWith(
      quantity: quantity,
      price: price,
      fee: fee,
      clearResult: true,
      clearError: true,
    ),
  );
  void calculate() {
    try {
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
    } catch (e) {
      emit(state.copyWith(error: AppError.from(e), clearResult: true));
    }
  }
}
