import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../ui/components.dart';
import '../../l10n/hub_locale.dart';
import '../../data/source_observation.dart';
import 'seller_repository.dart';
import 'sellers_cubit.dart';

class SellersView extends StatelessWidget {
  const SellersView({super.key});
  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<SellersCubit>();
    final strings = HubStrings.of(context);
    final state = cubit.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(strings.text('sellersTitle')),
        Text(strings.text('sellersIntro')),
        const SizedBox(height: 12),
        Text(
          strings.text('privatbank'),
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
            state.error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        if (state.snapshot != null)
          Text(strings.fmt('sourceDate', {'date': state.snapshot!.sourceDate}) + ' · ' + strings.fmt('loadedAt', {'date': state.snapshot!.retrievedAt})),
        if (cubit.freshness != null && cubit.freshness != DataFreshness.current)
          Text(
            strings.text(switch (cubit.freshness!) {
              DataFreshness.futureDated => 'futureWarning',
              DataFreshness.stale => 'staleWarning',
              DataFreshness.unknown => 'unknownWarning',
              DataFreshness.current => 'staleWarning',
            }),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        Text(strings.text('sellerExplanation')),
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
          Text(strings.text('pressLoad')),
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
                    '${q.isin} · ${q.currency} · погашення ${q.maturity}',
                  ),
                  Text(
                    'ASK: ${q.askYield ?? 'немає'}${q.askYield == null ? '' : '%'} · BID: ${q.bidYield ?? 'немає'}${q.bidYield == null ? '' : '%'} · ${q.method}',
                  ),
                  Text(strings.text('notConfirmed')),
                ],
              ),
            ),
          ),
        SectionHeading(strings.text('otherSellers')),
        Text(strings.text('icuText')),
        const SelectableText('https://icu.ua/investments'),
        Text(strings.text('senseText')),
        const SelectableText(
          'https://help.sensebank.com.ua/uk_UA/4879522845714',
        ),
        const SizedBox(height: 12),
        Text(strings.text('sellerPlanHint')),
      ],
    );
  }
}
