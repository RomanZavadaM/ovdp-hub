import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../ui/components.dart';
import 'calculator_cubit.dart';

class CalculatorView extends StatelessWidget {
  const CalculatorView({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<CalculatorCubit>().state;
    final cubit = context.read<CalculatorCubit>();
    final result = state.result;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading('Навчальний калькулятор'),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'СИНТЕТИЧНИЙ ПРИКЛАД · Купівля 22.09.2026, єдина виплата 1000 грн 22.09.2027 на облігацію. НКД, податки й регулярні витрати — 0. Це не ринкова пропозиція.',
          ),
        ),
        TextFormField(
          initialValue: state.quantity,
          decoration: const InputDecoration(labelText: 'Кількість облігацій'),
          onChanged: (v) => cubit.edit(quantity: v),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: state.price,
          decoration: const InputDecoration(labelText: 'Чиста ціна, грн'),
          onChanged: (v) => cubit.edit(price: v),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: state.fee,
          decoration: const InputDecoration(labelText: 'Разова комісія, грн'),
          onChanged: (v) => cubit.edit(fee: v),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: cubit.calculate,
          child: const Text('Розрахувати локально'),
        ),
        if (state.error != null) Text(state.error!),
        if (result != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: SelectableText(
              'Витрати: ${result.cost.toStringAsFixed(2)} грн\nНадходження: ${result.receipts.toStringAsFixed(2)} грн\nРезультат: ${result.profit.toStringAsFixed(2)} грн\nОрієнтовна XIRR ACT/365F: ${(result.yield * 100).toStringAsFixed(4)}%',
            ),
          ),
      ],
    );
  }
}
