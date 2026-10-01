import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/hub_locale.dart';
import '../../models.dart';
import '../../ui/components.dart';
import '../../ui/date_field.dart';
import '../catalog/catalog_cubit.dart';
import 'accrued_interest.dart';
import 'calculator_cubit.dart';

class CalculatorView extends StatelessWidget {
  const CalculatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CalculatorCubit>().state;
    final strings = HubStrings(context.watch<LocaleCubit>().state.language);
    final cubit = context.read<CalculatorCubit>();
    final catalog = context.watch<CatalogCubit>().state.catalog;
    final result = state.result;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final bonds = [
      for (final bond in catalog?.bonds ?? const <Bond>[])
        if (bond.maturity.compareTo(today) > 0) bond,
    ]..sort((a, b) => a.maturity.compareTo(b.maturity));
    Bond? selected;
    for (final bond in bonds) {
      if (bond.isin == state.isin) selected = bond;
    }
    final currency = selected?.currency ?? 'UAH';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(
          strings.text(selected == null ? 'calcTitle' : 'calcBondTitle'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            strings.text(selected == null ? 'calcExample' : 'calcCatalogInfo'),
          ),
        ),
        DropdownButtonFormField<String?>(
          key: const ValueKey('calculator-bond'),
          initialValue: selected?.isin,
          isExpanded: true,
          decoration: InputDecoration(labelText: strings.text('calcBondLabel')),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(strings.text('calcSynthetic')),
            ),
            for (final bond in bonds)
              DropdownMenuItem<String?>(
                value: bond.isin,
                child: Text(
                  '${bond.isin} · ${bond.currency} · ${bond.rate}% · '
                  '${bond.maturity}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: cubit.selectBond,
        ),
        const SizedBox(height: 12),
        if (selected != null) ...[
          HubDateField(
            key: ValueKey('calculator-settlement-${selected.isin}'),
            controlKey: 'calculator-settlement',
            canonicalValue: state.settlement,
            label: strings.text('calcSettlement'),
            invalidDateText: strings.text('plannerCriteriaInvalidDate'),
            onCommit: (value) async {
              cubit.edit(settlement: value);
              return true;
            },
          ),
          const SizedBox(height: 12),
        ],
        TextFormField(
          initialValue: state.quantity,
          decoration: InputDecoration(labelText: strings.text('quantity')),
          onChanged: (v) => cubit.edit(quantity: v),
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: ValueKey('calculator-price-${selected?.isin ?? 'synthetic'}'),
          initialValue: state.price,
          decoration: InputDecoration(
            labelText: selected == null
                ? strings.text('cleanPrice')
                : strings
                      .text('calcCleanPricePerBond')
                      .replaceAll('{currency}', currency),
          ),
          onChanged: (v) => cubit.edit(price: v),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: state.fee,
          decoration: InputDecoration(
            labelText: selected == null
                ? strings.text('oneTimeFee')
                : strings
                      .text('calcFeeCurrency')
                      .replaceAll('{currency}', currency),
          ),
          onChanged: (v) => cubit.edit(fee: v),
        ),
        const SizedBox(height: 12),
        FilledButton(
          key: const ValueKey('calculator-run'),
          onPressed: cubit.calculate,
          child: Text(strings.text('calculateLocal')),
        ),
        if (state.error != null) Text(strings.error(state.error!)),
        if (result != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: SelectableText(
              [
                if (selected != null) ...[
                  '${strings.text('calcMaturity')}: ${selected.maturity}',
                  '${strings.text('calcAccrued')}: '
                      '${state.accruedPerBond?.toStringAsFixed(2) ?? '0.00'} '
                      '$currency',
                ],
                '${strings.text('costs')}: ${result.cost.toStringAsFixed(2)} '
                    '$currency',
                '${strings.text('receipts')}: '
                    '${result.receipts.toStringAsFixed(2)} $currency',
                '${strings.text('result')}: '
                    '${result.profit.toStringAsFixed(2)} $currency',
                '${strings.text(selected == null ? 'approxXirr' : 'calcYtm')}: '
                    '${(result.yield * 100).toStringAsFixed(selected == null ? 4 : 2)}%',
                if (selected != null && bondHasConditionalRedemption(selected))
                  strings.text('calcConditionalRedemption'),
              ].join('\n'),
            ),
          ),
      ],
    );
  }
}
