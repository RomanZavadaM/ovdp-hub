import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../calendar.dart';
import '../../l10n/hub_locale.dart';
import '../../ui/components.dart';
import '../../ui/studio_design.dart';
import '../appearance/appearance_cubit.dart';
import '../collections/editor_cubit.dart';
import '../collections/editor_view.dart';
import '../navigation/navigation_cubit.dart';
import '../workspace/workspace_cubit.dart';
import 'catalog_cubit.dart';

class CatalogView extends StatelessWidget {
  const CatalogView({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<CatalogCubit>().state;
    final strings = HubStrings.of(context);
    final studio = context.watch<AppearanceCubit>().state.studio;
    final cubit = context.read<CatalogCubit>();
    final editor = context.watch<CollectionEditorCubit>().state;
    final busy =
        state.busy || editor.busy || context.watch<WorkspaceCubit>().state.busy;
    if (state.catalog == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(strings.text('openWorkspace')),
          const Text(
            'Каталог і збережені набори будуть доступні без інтернету.',
          ),
          FilledButton(
            onPressed: () => context.read<NavigationCubit>().select(3),
            child: Text(strings.text('setupWorkspace')),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (studio)
          StudioHero(
            plan: () => context.read<NavigationCubit>().select(4),
            sellers: () => context.read<NavigationCubit>().select(5),
          )
        else
          SectionHeading(strings.text('catalogClassicTitle')),
        if (studio) const SizedBox(height: 12),
        ErrorNotice(state.error, cubit.dismissError),
        if (state.busy) const LinearProgressIndicator(),
        Text(strings.text('catalogIntro')),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (studio)
              MetricTile(strings.text('issuesInSelection'), state.visible.length.toString())
            else
              Chip(label: Text('${state.visible.length} випусків у вибірці')),
            for (final c in state.currencyCounts.entries)
              if (studio)
                MetricTile(strings.fmt('issuesInCurrency', {'currency': c.key}), c.value.toString())
              else
                Chip(label: Text('${c.key}: ${c.value}')),
          ],
        ),
        Text(
          'Завантажено: ${state.catalog!.json['retrievedAt']}${state.stale ? ' · Знімок старший за 24 години' : ''}',
        ),
        const Text(
          'Номінальна ставка не є дохідністю купівлі. Цін брокерів у каталозі немає.',
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: busy ? null : cubit.refresh,
          icon: const Icon(Icons.refresh),
          label: Text(strings.text('refreshNbu')),
        ),
        const SizedBox(height: 20),
        TextFormField(
          initialValue: state.query,
          decoration: const InputDecoration(
            labelText: 'Пошук за ISIN',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (v) => cubit.filter(query: v),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final c in ['', 'UAH', 'USD', 'EUR'])
              ChoiceChip(
                label: Text(c.isEmpty ? strings.text('allCurrencies') : c),
                selected: state.currency == c,
                onSelected: (_) => cubit.filter(currency: c),
              ),
            FilterChip(
              label: Text(strings.text('activeOnly')),
              selected: state.activeOnly,
              onSelected: (v) => cubit.filter(activeOnly: v),
            ),
          ],
        ),
        Wrap(
          spacing: 10,
          children: [
            for (final h in {
              'all': 'Усі строки',
              'short': 'До 12 місяців',
              'long': 'Від 24 місяців',
            }.entries)
              ChoiceChip(
                label: Text(h.value),
                selected: state.horizon == h.key,
                onSelected: (_) => cubit.filter(horizon: h.key),
              ),
          ],
        ),
        if (editor.dirty) const CollectionEditorView(),
        const SizedBox(height: 16),
        if (state.visible.isEmpty)
          Text(strings.text('noIssues')),
        ...state.visible.map(
          (b) => Card(
            child: ListTile(
              isThreeLine: true,
              leading: Checkbox(
                value: editor.selected.containsKey(b.isin),
                onChanged: busy
                    ? null
                    : (checked) => context.read<CollectionEditorCubit>().toggle(
                        b,
                        checked == true,
                      ),
              ),
              title: Text(b.isin),
              subtitle: Text(
                '${b.currency} · ${b.rate}% номінальна ставка\nПогашення ${b.maturity}',
              ),
              trailing: IconButton(
                tooltip: strings.text('issueDetails'),
                icon: const Icon(Icons.chevron_right),
                onPressed: () => showBondDetails(context, b),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const AuctionCalendar(),
      ],
    );
  }
}
