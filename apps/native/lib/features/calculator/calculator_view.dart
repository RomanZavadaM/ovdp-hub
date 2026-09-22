import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/hub_locale.dart';
import '../../ui/components.dart';
import 'calculator_cubit.dart';

class CalculatorView extends StatelessWidget {
  const CalculatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CalculatorCubit>().state;
    final strings = HubStrings(context.watch<LocaleCubit>().state.language);
    final cubit = context.read<CalculatorCubit>();
    final result = state.result;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(strings.text('calcTitle')),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(strings.text('calcExample')),
        ),
        TextFormField(
          initialValue: state.quantity,
          decoration: InputDecoration(labelText: strings.text('quantity')),
          onChanged: (v) => cubit.edit(quantity: v),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: state.price,
          decoration: InputDecoration(labelText: strings.text('cleanPrice')),
          onChanged: (v) => cubit.edit(price: v),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: state.fee,
          decoration: InputDecoration(labelText: strings.text('oneTimeFee')),
          onChanged: (v) => cubit.edit(fee: v),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: cubit.calculate,
          child: Text(strings.text('calculateLocal')),
        ),
        if (state.error != null) Text(state.error!),
        if (result != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: SelectableText(
              '${strings.text('costs')}: ${result.cost.toStringAsFixed(2)} грн\n'
              '${strings.text('receipts')}: ${result.receipts.toStringAsFixed(2)} грн\n'
              '${strings.text('result')}: ${result.profit.toStringAsFixed(2)} грн\n'
              '${strings.text('approxXirr')}: ${(result.yield * 100).toStringAsFixed(4)}%',
            ),
          ),
      ],
    );
  }
}
