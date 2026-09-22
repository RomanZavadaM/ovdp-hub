import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/source_observation.dart';
import '../../l10n/hub_locale.dart';
import '../../ui/components.dart';
import 'seller_repository.dart';
import 'sellers_cubit.dart';

class SellersView extends StatelessWidget {
  const SellersView({super.key});

  String? _freshnessWarning(HubStrings strings, DataFreshness? freshness) => switch (freshness) {
    DataFreshness.futureDated => strings.text('futureData'),
    DataFreshness.stale => strings.text('staleData'),
    DataFreshness.unknown => strings.text('unknownDate'),
    DataFreshness.current || null => null,
  };
  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<SellersCubit>();
    final state = cubit.state;
    final strings = HubStrings(context.watch<LocaleCubit>().state.language);
    final warning = _freshnessWarning(strings, cubit.freshness);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(strings.text('sellerHeading')),
        Text(strings.text('sellerIntro')),
        const SizedBox(height: 12),
        const Text(
          'ПриватБанк',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SelectableText(SellerRepository.url),
        FilledButton.icon(
          onPressed: state.busy ? null : cubit.refresh,
          icon: const Icon(Icons.refresh),
          label: Text(strings.text('loadPrivat')),
        ),
        if (state.busy) const LinearProgressIndicator(),
        if (state.error != null)
          Text(
            '${strings.text('refreshFailed')} ${state.error}',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        if (state.snapshot != null)
          Text(
            '${strings.text('sourceDate')}: ${state.snapshot!.sourceDate} · ${strings.text('loadedAt')}: ${state.snapshot!.retrievedAt}',
          ),
        if (warning != null)
          Text(
            warning,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        Text(strings.text('sellerNote')),
        Wrap(
          spacing: 8,
          children: [
            for (final c in ['UAH', 'USD', 'EUR'])
              ChoiceChip(
                label: Text(c),
                selected: state.currency == c,
                onSelected: (_) => cubit.currency(c),
              ),
          ],
        ),
        SwitchListTile(
          title: Text(strings.text('askOnly')),
          value: state.askOnly,
          onChanged: cubit.askOnly,
        ),
        if (state.snapshot == null)
          Text(strings.text('sellerLoadPrompt')),
        if (state.snapshot != null && cubit.visible.isEmpty)
          Text(strings.text('noSellerIssues')),
        for (final q in cubit.visible)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    '${q.isin} · ${q.currency} · ${strings.text('maturity')} ${q.maturity}',
                  ),
                  Text(
                    'ASK: ${q.askYield ?? '—'}${q.askYield == null ? '' : '%'} · BID: ${q.bidYield ?? '—'}${q.bidYield == null ? '' : '%'} · ${q.method}',
                  ),
                  Text(strings.text('availabilityUnknown')),
                ],
              ),
            ),
          ),
        SectionHeading(strings.text('otherSellers')),
        Text(strings.text('icuNote')),
        const SelectableText('https://icu.ua/investments'),
        Text(strings.text('senseNote')),
        const SelectableText(
          'https://help.sensebank.com.ua/uk_UA/4879522845714',
        ),
        const SizedBox(height: 12),
        Text(strings.text('sellerScenarioHint')),
      ],
    );
  }
}
