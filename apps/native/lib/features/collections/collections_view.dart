import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/hub_locale.dart';
import '../../models.dart';
import '../../ui/components.dart';
import '../navigation/navigation_cubit.dart';
import '../planner/planner_comparison.dart';
import '../planner/planner_cubit.dart';
import '../planner/planner_scenario.dart';
import '../sellers/sellers_cubit.dart';
import '../workspace/workspace_cubit.dart';
import 'collections_cubit.dart';
import 'editor_cubit.dart';

class CollectionsView extends StatelessWidget {
  const CollectionsView({super.key});

  String _generatedCopy(HubStrings strings, String value) {
    if (value == PlannerGeneratedCopy.planName) {
      return strings.text('generatedPlanName');
    }
    if (value == PlannerGeneratedCopy.primaryNeedName) {
      return strings.text('generatedPrimaryNeedName');
    }
    final ordinal = PlannerGeneratedCopy.expenseOrdinal(value);
    if (ordinal != null) {
      return strings
          .text('generatedExpenseName')
          .replaceAll('{n}', ordinal.toString());
    }
    return value;
  }

  String _scenarioNote(HubStrings strings, SavedSet set) {
    if (set.note != PlannerGeneratedCopy.scenarioNote) {
      return set.note.isEmpty ? strings.text('noNotes') : set.note;
    }
    final scenario = set.scenario;
    if (scenario == null) return strings.text('noNotes');

    final fees = scenario['fees'];
    final taxes = scenario['taxes'];
    final fx = scenario['fx'];
    final positionExits = scenario['positionExits'];
    var exitCount = positionExits is List ? positionExits.length : 0;
    if (exitCount == 0) {
      final legacyExit = scenario['exit'];
      if (legacyExit is Map && legacyExit['mode'] == 'earlySale') {
        exitCount = 1;
      }
    }

    final feeText = fees is Map && fees['status'] == 'unknown'
        ? strings.text('generatedScenarioFeesUnknown')
        : strings.text('generatedScenarioFeesKnown');
    final taxText = taxes is Map && taxes['status'] == 'unknown'
        ? strings.text('generatedScenarioTaxesUnknown')
        : strings.text('generatedScenarioTaxesKnown');
    final fxText = fx is List && fx.isNotEmpty
        ? strings.text('generatedScenarioFxKnown')
        : strings.text('generatedScenarioFxNone');
    final exitText = exitCount == 0
        ? strings.text('generatedScenarioExitHold')
        : strings
              .text('generatedScenarioExitEarly')
              .replaceAll('{count}', exitCount.toString());

    return strings
        .text('generatedScenarioDescription')
        .replaceAll('{currency}', scenario['currency']?.toString() ?? '')
        .replaceAll('{fee}', feeText)
        .replaceAll('{tax}', taxText)
        .replaceAll('{fx}', fxText)
        .replaceAll('{exit}', exitText);
  }

  String _strategy(HubStrings strings, ComparisonVariant variant) =>
      switch (variant.strategy) {
        PlannerStrategy.ladder => strings.text('comparisonStrategyLadder'),
        PlannerStrategy.profit => strings.text('comparisonStrategyProfit'),
        PlannerStrategy.expenses => strings.text('comparisonStrategyExpenses'),
      };

  String _profit(
    HubStrings strings,
    ComparisonVariant variant,
    String currency,
  ) {
    final basis = switch (variant.profitBasis) {
      ComparisonProfitBasis.grossBeforeFees =>
        strings.text('comparisonProfitGross'),
      ComparisonProfitBasis.afterFeesBeforeTax =>
        strings.text('comparisonProfitBeforeTax'),
      ComparisonProfitBasis.verifiedAfterTax =>
        strings.text('comparisonProfitVerifiedAfterTax'),
    };
    return '${variant.displayedProfit.toStringAsFixed(2)} $currency · $basis';
  }

  String _fee(
    HubStrings strings,
    ComparisonVariant variant,
    String currency,
  ) => variant.feeImpact.known
      ? '${variant.feeImpact.purchaseFee!.toStringAsFixed(2)} $currency'
      : strings.text('comparisonUnknown');

  String _tax(
    HubStrings strings,
    ComparisonVariant variant,
    String currency,
  ) => variant.taxImpact.known
      ? '${variant.taxImpact.taxAmount!.toStringAsFixed(2)} $currency'
      : strings.text('comparisonUnknown');

  String _fx(HubStrings strings, ComparisonVariant variant) {
    final impact = variant.fxImpact;
    if (impact.deferred) return strings.text('comparisonFxDeferred');
    if (!impact.active) return strings.text('comparisonFxNone');
    return '1 ${impact.assumption!.fromCurrency} = '
        '${impact.assumption!.rate} ${impact.assumption!.toCurrency}';
  }

  Widget _comparisonTable(
    BuildContext context,
    HubStrings strings,
    ScenarioComparison comparison,
    CollectionsCubit cubit,
  ) {
    final variants = comparison.variants;
    DataRow row(String label, String Function(ComparisonVariant) value) =>
        DataRow(
          cells: [
            DataCell(Text(label)),
            for (final variant in variants) DataCell(Text(value(variant))),
          ],
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeading(strings.text('comparisonTitle')),
            Text(strings.text('comparisonNoWinner')),
            const SizedBox(height: 8),
            Text(
              '${strings.text('comparisonSharedAssumptions')}: '
              '${comparison.currency} · '
              '${strings.text('budget')} ${comparison.budget} · '
              '${strings.text('reserve')} ${comparison.reserve} · '
              '${comparison.startDate} → ${comparison.maxMaturity} · '
              '${strings.text('settlementDelay')} '
              '${comparison.settlementDelayDays}',
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text(strings.text('comparisonMetric'))),
                  for (final variant in variants)
                    DataColumn(label: Text(variant.label)),
                ],
                rows: [
                  row(
                    strings.text('comparisonScenarioName'),
                    (v) => _generatedCopy(strings, v.name),
                  ),
                  row(strings.text('comparisonStrategy'), (v) => _strategy(strings, v)),
                  row(
                    strings.text('comparisonComposition'),
                    (v) => v.composition,
                  ),
                  row(
                    strings.text('comparisonPositionCost'),
                    (v) =>
                        '${v.feeImpact.grossPositionCost.toStringAsFixed(2)} '
                        '${comparison.currency}',
                  ),
                  row(
                    strings.text('comparisonPurchaseFee'),
                    (v) => _fee(strings, v, comparison.currency),
                  ),
                  row(
                    strings.text('comparisonTax'),
                    (v) => _tax(strings, v, comparison.currency),
                  ),
                  row(
                    strings.text('comparisonReserve'),
                    (v) =>
                        '${v.reserveAfterKnownPurchaseFee.toStringAsFixed(2)} '
                        '${comparison.currency}',
                  ),
                  row(
                    strings.text('comparisonProfit'),
                    (v) => _profit(strings, v, comparison.currency),
                  ),
                  row(
                    strings.text('comparisonCoverageShortfall'),
                    (v) =>
                        '${v.totalShortfall.toStringAsFixed(2)} '
                        '${comparison.currency}',
                  ),
                  row(
                    strings.text('comparisonExitCount'),
                    (v) => '${v.exits.length}',
                  ),
                  row(strings.text('comparisonFx'), (v) => _fx(strings, v)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: cubit.clearComparison,
              icon: const Icon(Icons.clear_all),
              label: Text(strings.text('comparisonClear')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CollectionsCubit>().state;
    final strings = HubStrings(context.watch<LocaleCubit>().state.language);
    final cubit = context.read<CollectionsCubit>();
    final editor = context.watch<CollectionEditorCubit>();
    final workspace = context.watch<WorkspaceCubit>().state;
    final busy = state.busy || editor.state.busy || workspace.busy;
    final seller = context.watch<SellersCubit>().state.snapshot;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(strings.text('collectionsTitle')),
        ErrorNotice(state.error, cubit.dismissError),
        Text(strings.text('collectionImmutableInfo')),
        OutlinedButton(
          onPressed: busy || workspace.path == null ? null : cubit.reload,
          child: Text(strings.text('reloadFolder')),
        ),
        if (state.sets.where((s) => s.scenario != null).length >= 2) ...[
          const SizedBox(height: 12),
          SectionHeading(strings.text('comparisonTitle')),
          Text(strings.text('comparisonSelectInfo')),
          Text(
            '${strings.text('comparisonSelected')}: '
            '${state.selectedComparisonKeys.length}/3',
          ),
          if (state.selectedComparisonKeys.length == 1)
            Text(strings.text('comparisonSelectOneMore')),
          if (state.comparison != null) ...[
            const SizedBox(height: 8),
            _comparisonTable(
              context,
              strings,
              state.comparison!,
              cubit,
            ),
          ],
        ],
        if (state.sets.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(strings.text('noCollections')),
          ),
        ...state.sets.map(
          (s) => Card(
            child: ExpansionTile(
              title: Text(_generatedCopy(strings, s.name)),
              subtitle: Text(
                '${s.bonds.length} ${strings.text('issuesWord')} · ${s.savedAt}',
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _scenarioNote(strings, s),
                  ),
                ),
                ...s.bonds.map(
                  (b) => ListTile(
                    title: Text(b.isin),
                    subtitle: Text(
                      '${b.currency} · ${b.rate}% · ${b.maturity}',
                    ),
                    onTap: () => showBondDetails(
                      context,
                      b,
                      seller: seller,
                    ),
                  ),
                ),
                if (s.scenario != null)
                  CheckboxListTile(
                    value: cubit.isSelectedForComparison(s),
                    onChanged: busy
                        ? null
                        : (_) => cubit.toggleComparison(s),
                    title: Text(strings.text('comparisonSelectScenario')),
                    subtitle: cubit.comparisonLabelFor(s) == null
                        ? null
                        : Text(
                            '${strings.text('comparisonVariant')} '
                            '${cubit.comparisonLabelFor(s)}',
                          ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                if (s.scenario != null)
                  TextButton(
                    onPressed: busy
                        ? null
                        : () async {
                            final planner = context.read<PlannerCubit>();
                            final navigation = context.read<NavigationCubit>();
                            if (planner.state.dirty &&
                                !await confirmDiscard(context)) {
                              return;
                            }
                            if (!context.mounted) return;
                            planner.load(s);
                            navigation.select(4);
                          },
                    child: Text(strings.text('openPlan')),
                  ),
                if (s.scenario == null)
                  TextButton(
                    onPressed: busy
                        ? null
                        : () async {
                            final navigation = context.read<NavigationCubit>();
                            if (editor.state.dirty &&
                                !await confirmDiscard(context)) {
                              return;
                            }
                            if (!context.mounted) return;
                            editor.variant(s);
                            navigation.select(0);
                          },
                    child: Text(strings.text('newVariant')),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
