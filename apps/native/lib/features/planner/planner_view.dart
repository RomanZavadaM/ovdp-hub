import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../l10n/hub_locale.dart';
import '../../ui/components.dart';
import '../navigation/navigation_cubit.dart';
import 'planner_cubit.dart';
import 'planner_scenario.dart';

class PlannerView extends StatelessWidget {
  const PlannerView({super.key});

  String _sourceLabel(HubStrings strings, String sourceId) {
    if (sourceId == 'manual-price') return strings.text('manualPrice');
    if (sourceId.startsWith('user:')) return sourceId.substring(5);
    return sourceId;
  }

  Future<void> _addPriceSource(
    BuildContext context,
    PlannerCubit cubit,
    PositionInput input,
    HubStrings strings,
  ) async {
    var source = '';
    var price = '';
    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.text('addPriceSource')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) => source = value,
              decoration: InputDecoration(
                labelText: strings.text('priceSourceName'),
              ),
            ),
            TextField(
              onChanged: (value) => price = value,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: strings.text('priceSourceFullPrice'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(strings.text('close')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(strings.text('addPriceSource')),
          ),
        ],
      ),
    );
    if (submitted == true && context.mounted) {
      cubit.addManualPriceSource(
        input.bond.isin,
        source,
        price,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlannerCubit>(),
        state = context.watch<PlannerCubit>().state;
    final strings = HubStrings(context.watch<LocaleCubit>().state.language);
    final c = state.criteria,
        summary = state.summary,
        feeImpact = state.feeImpact,
        disabled = state.busy || state.locked;
    final currency = c['currency'];
    final feesKnown = state.fees.status == FeeAssumptionStatus.known;
    final simpleFeeRules = state.fees.rules.isEmpty ||
        (state.fees.rules.length == 1 &&
            state.fees.rules.single.id == 'ui-purchase-fee');
    final aggregatePurchaseFee = state.fees.rules.isEmpty
        ? '0'
        : simpleFeeRules
            ? state.fees.rules.single.value.toString()
            : '';
    final maximum =
        summary?.months.fold<double>(
          0,
          (m, v) => v.total.toDouble() > m ? v.total.toDouble() : m,
        ) ??
        0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(strings.text('plannerTitle')),
        Text(strings.text('plannerIntro')),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            for (final cur in ['UAH', 'USD', 'EUR'])
              ChoiceChip(
                label: Text(cur),
                selected: currency == cur,
                onSelected: disabled
                    ? null
                    : (_) => cubit.edit('currency', cur),
              ),
          ],
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final field in {
              'budget': strings.text('budgetField'),
              'reserve': strings.text('reserveField'),
              'start': strings.text('startField'),
              'minDate': strings.text('minDateField'),
              'maxDate': strings.text('maxDateField'),
              'needDate': strings.text('needDateField'),
              'needAmount': strings.text('needAmountField'),
            }.entries)
              SizedBox(
                width: 280,
                child: TextFormField(
                  key: ValueKey('${field.key}-${state.revision}'),
                  initialValue: c[field.key],
                  enabled: !disabled,
                  decoration: InputDecoration(labelText: field.value),
                  onChanged: (v) => cubit.edit(field.key, v),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SectionHeading(strings.text('priorityTitle')),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final strategy in {
              'ladder': strings.text('strategyLadder'),
              'profit': strings.text('strategyProfit'),
              'expenses': strings.text('strategyExpenses'),
            }.entries)
              ChoiceChip(
                label: Text(strategy.value),
                selected: (c['strategy'] ?? 'ladder') == strategy.key,
                onSelected: disabled
                    ? null
                    : (_) => cubit.edit('strategy', strategy.key),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(strings.text('strategyExplanation')),
        if (c['strategy'] != 'ladder')
          SwitchListTile(
            title: Text(strings.text('pricedOnlyTitle')),
            subtitle: Text(strings.text('pricedOnlySubtitle')),
            value: c['pricedOnly'] == 'true',
            onChanged: disabled ? null : (v) => cubit.edit('pricedOnly', '$v'),
          ),
        SectionHeading(strings.text('futureExpenses')),
        Text(strings.text('futureExpensesIntro')),
        for (var i = 0; i < int.parse(c['expenseCount'] ?? '0'); i++)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final field in {
                    'expenseName$i': strings.text('expenseName'),
                    'expenseDate$i': strings.text('dateYmd'),
                    'expenseAmount$i': '${strings.text('amount')}, $currency',
                  }.entries)
                    SizedBox(
                      width: 220,
                      child: TextFormField(
                        key: ValueKey('${field.key}-${state.revision}'),
                        initialValue: c[field.key],
                        enabled: !disabled,
                        decoration: InputDecoration(labelText: field.value),
                        onChanged: (v) => cubit.edit(field.key, v),
                      ),
                    ),
                  IconButton(
                    tooltip: strings.text('deleteExpense'),
                    onPressed: disabled ? null : () => cubit.removeExpense(i),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          ),
        TextButton.icon(
          onPressed: disabled ? null : cubit.addExpense,
          icon: const Icon(Icons.add),
          label: Text(strings.text('addExpense')),
        ),
        TextButton.icon(
          onPressed: disabled ? null : cubit.repeatMonthly,
          icon: const Icon(Icons.repeat),
          label: Text(strings.text('repeatNeed')),
        ),
        SizedBox(
          width: 300,
          child: TextFormField(
            key: ValueKey('delay-${state.revision}'),
            initialValue: c['delay'] ?? '2',
            enabled: !disabled,
            decoration: InputDecoration(
              labelText: strings.text('settlementDelay'),
            ),
            onChanged: (v) => cubit.edit('delay', v),
          ),
        ),
        const SizedBox(height: 12),
        SectionHeading(strings.text('feeAssumptionsTitle')),
        Text(strings.text('feeAssumptionsInfo')),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text(strings.text('feesUnknown')),
              selected: !feesKnown,
              onSelected: disabled ? null : (_) => cubit.setFeesUnknown(),
            ),
            ChoiceChip(
              label: Text(strings.text('feesKnown')),
              selected: feesKnown,
              onSelected: disabled
                  ? null
                  : (_) {
                      if (!feesKnown) cubit.confirmZeroPurchaseFees();
                    },
            ),
          ],
        ),
        if (feesKnown && simpleFeeRules)
          SizedBox(
            width: 300,
            child: TextFormField(
              key: ValueKey('aggregate-purchase-fee-${state.revision}'),
              initialValue: aggregatePurchaseFee,
              enabled: !disabled,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText:
                    '${strings.text('aggregatePurchaseFee')}, $currency',
              ),
              onChanged: cubit.setAggregatePurchaseFee,
            ),
          ),
        if (feesKnown && !simpleFeeRules)
          Text(strings.text('advancedFeeRulesPreserved')),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: disabled ? null : cubit.generate,
          icon: const Icon(Icons.auto_awesome_outlined),
          label: Text(
            c['strategy'] == 'ladder'
                ? strings.text('generateLadder')
                : strings.text('generateVariant'),
          ),
        ),
        Text(strings.text('generationDisclaimer')),
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              strings.error(state.error!),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (state.inputs.isNotEmpty) ...[
          SectionHeading(strings.text('scenarioComposition')),
          Text(strings.text('priceDefaultInfo')),
          if (state.priceSourcePriority.sourceIds.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.text('priceSourcePriorityTitle'),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(strings.text('priceSourcePriorityInfo')),
                    for (var sourceIndex = 0;
                        sourceIndex < state.priceSourcePriority.sourceIds.length;
                        sourceIndex++)
                      Row(
                        children: [
                          SizedBox(
                            width: 28,
                            child: Text('${sourceIndex + 1}.'),
                          ),
                          Expanded(
                            child: Text(
                              _sourceLabel(
                                strings,
                                state.priceSourcePriority.sourceIds[sourceIndex],
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: strings.text('moveSourceUp'),
                            onPressed: disabled || sourceIndex == 0
                                ? null
                                : () => cubit.movePriceSource(
                                    state.priceSourcePriority.sourceIds[sourceIndex],
                                    -1,
                                  ),
                            icon: const Icon(Icons.arrow_upward),
                          ),
                          IconButton(
                            tooltip: strings.text('moveSourceDown'),
                            onPressed: disabled ||
                                    sourceIndex ==
                                        state.priceSourcePriority.sourceIds.length - 1
                                ? null
                                : () => cubit.movePriceSource(
                                    state.priceSourcePriority.sourceIds[sourceIndex],
                                    1,
                                  ),
                            icon: const Icon(Icons.arrow_downward),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ...state.inputs.values.map(
            (i) => Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('${i.bond.isin} · ${i.bond.maturity}'),
                        ),
                        IconButton(
                          tooltip: strings.text('removePosition'),
                          onPressed: disabled
                              ? null
                              : () => cubit.toggle(i.bond, false),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    Text(
                      i.nominalEstimate
                          ? strings.text('nominalEstimate')
                          : '${strings.text('selectedPriceSource')}: '
                              '${_sourceLabel(strings, i.selectedSourceId ?? 'manual-price')}',
                    ),
                    if (i.observations.any((o) => o.isExplicitPurchasePrice))
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final observation
                                in i.observations.where(
                                  (o) => o.isExplicitPurchasePrice,
                                ))
                              ChoiceChip(
                                label: Text(
                                  '${_sourceLabel(strings, observation.meta.sourceId)} · '
                                  '${observation.effectiveUnitCost} $currency',
                                ),
                                selected: !i.nominalEstimate &&
                                    i.selectedSourceId ==
                                        observation.meta.sourceId,
                                onSelected: disabled
                                    ? null
                                    : (_) => cubit.selectPriceSource(
                                        i.bond.isin,
                                        observation.meta.sourceId,
                                      ),
                              ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: disabled
                                ? null
                                : () => cubit.useNominalEstimate(i.bond.isin),
                            icon: const Icon(Icons.account_balance_outlined),
                            label: Text(strings.text('useNominalEstimate')),
                          ),
                          OutlinedButton.icon(
                            onPressed: disabled
                                ? null
                                : () => _addPriceSource(
                                    context,
                                    cubit,
                                    i,
                                    strings,
                                  ),
                            icon: const Icon(Icons.add_chart_outlined),
                            label: Text(strings.text('addPriceSource')),
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        SizedBox(
                          width: 160,
                          child: TextFormField(
                            key: ValueKey('q-${i.bond.isin}-${state.revision}'),
                            initialValue: i.quantity,
                            enabled: !disabled,
                            decoration: InputDecoration(
                              labelText: strings.text('quantityUnits'),
                            ),
                            onChanged: (v) =>
                                cubit.position(i.bond.isin, quantity: v),
                          ),
                        ),
                        SizedBox(
                          width: 230,
                          child: TextFormField(
                            key: ValueKey('p-${i.bond.isin}-${state.revision}'),
                            initialValue: i.price,
                            enabled: !disabled,
                            decoration: InputDecoration(
                              labelText: '${strings.text('fullPrice')}, $currency',
                            ),
                            onChanged: (v) =>
                                cubit.position(i.bond.isin, price: v),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        ExpansionTile(
          title: Text('${strings.text('manualIssues')} · ${state.candidates.length}'),
          children: [
            ...state.candidates.map(
              (b) => CheckboxListTile(
                value: state.inputs.containsKey(b.isin),
                onChanged: disabled ? null : (v) => cubit.toggle(b, v == true),
                title: Text(b.isin),
                subtitle: Text('${b.maturity} · ${b.rate}% ${strings.text('nominalRate')}'),
              ),
            ),
          ],
        ),
        if (summary != null) ...[
          SectionHeading(strings.text('scenarioResult')),
          if (feeImpact?.known == true) ...[
            Text(
              '${strings.text('invested')}: '
              '${feeImpact!.totalInitialCost!.toStringAsFixed(2)} $currency · '
              '${strings.text('free')}: '
              '${feeImpact.reserveAfterPurchaseFee!.toStringAsFixed(2)} $currency',
            ),
            Text(
              '${strings.text('purchaseFeeApplied')}: '
              '${feeImpact.purchaseFee!.toStringAsFixed(2)} $currency',
            ),
            Text(
              '${strings.text('expectedProfit')}: '
              '${feeImpact.profitAfterPurchaseFee!.toStringAsFixed(2)} $currency',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ] else ...[
            Text(
              '${strings.text('invested')}: ${summary.cost.toStringAsFixed(2)} $currency · '
              '${strings.text('free')}: ${summary.reserve.toStringAsFixed(2)} $currency',
            ),
            Text(
              '${strings.text('expectedProfit')}: ${state.profit} $currency',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(strings.text('unknownFeesResultInfo')),
          ],
          if (feeImpact?.hasDeferredRules == true)
            Text(strings.text('advancedFeeRulesPreserved')),
          Text(strings.text('resultCaveat')),
          SectionHeading(strings.text('expenseCoverage')),
          if (feeImpact?.known != true)
            Text(strings.text('expenseCoverageUnknownFeesInfo')),
          for (final row in state.expenseBalances)
            Card(
              child: ListTile(
                leading: Icon(
                  row.shortfall.toDouble() > 0
                      ? Icons.warning_amber
                      : Icons.check_circle_outline,
                ),
                title: Text(
                  '${row.expense.date} · ${row.expense.name} · ${row.expense.amount.toStringAsFixed(2)} $currency',
                ),
                subtitle: Text(
                  '${strings.text('beforeExpense')}: ${row.available.toStringAsFixed(2)} · '
                  '${strings.text('afterExpense')}: ${row.remaining.toStringAsFixed(2)} · '
                  '${strings.text('shortfall')}: ${row.shortfall.toStringAsFixed(2)} $currency',
                ),
              ),
            ),
          Text(strings.text('expenseCalendarInfo')),
          if (summary.containsEstimates)
            Text(strings.text('containsEstimates')),
          if (summary.hasConditionalPayments)
            Text(strings.text('conditionalPayments')),
          SectionHeading(strings.text('monthlyReceipts')),
          Text(strings.text('monthlyIntro')),
          ...summary.months.map(
            (m) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${m.month} · ${strings.text('coupons')} ${m.coupons.toStringAsFixed(2)} · '
                    '${strings.text('principal')} ${m.principal.toStringAsFixed(2)} $currency',
                  ),
                  LinearProgressIndicator(
                    value: maximum == 0 ? 0 : m.total.toDouble() / maximum,
                    minHeight: 7,
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        TextFormField(
          key: ValueKey('plan-name-${state.revision}'),
          initialValue: c['name'],
          enabled: !disabled,
          decoration: InputDecoration(labelText: strings.text('scenarioName')),
          onChanged: (v) => cubit.edit('name', v),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: disabled || summary == null || state.inputs.isEmpty
              ? null
              : () async {
                  final navigation = context.read<NavigationCubit>();
                  if (await cubit.save() && context.mounted) {
                    navigation.select(1);
                  }
                },
          icon: const Icon(Icons.save_outlined),
          label: Text(
            state.saved
                ? strings.text('saveNewVariant')
                : strings.text('saveScenario'),
          ),
        ),
      ],
    );
  }
}
