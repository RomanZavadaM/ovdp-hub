import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../l10n/hub_locale.dart';
import '../../ui/components.dart';
import '../catalog/catalog_cubit.dart';
import 'public_offer_strings.dart';
import 'sellers_cubit.dart';

class PublicOffersView extends StatelessWidget {
  const PublicOffersView({super.key});
  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<SellersCubit>();
    final state = cubit.state;
    final catalog = context.watch<CatalogCubit>().state.catalog;
    final strings = HubStrings(context.watch<LocaleCubit>().state.language);
    final matched = cubit.publicOffers.where((offer) =>
      catalog?.bonds.any((b) => b.isin == offer.isin && b.currency == offer.currency && b.maturity == offer.maturity) ?? false).toList();
    final unmatched = cubit.publicOffers.length - matched.length;
    final offers = matched.where((offer) => offer.currency == state.currency);
    final isins = offers.map((offer) => offer.isin).toSet().toList()..sort();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeading(strings.offerText('title')),
      Text(strings.offerText('notice')),
      FilledButton.icon(key: const ValueKey('refresh-all-public-offers'),
        onPressed: state.busy || state.sourcesBusy ? null : cubit.refreshAllPublicSources,
        icon: const Icon(Icons.refresh), label: Text(strings.offerText('load'))),
      if (state.sourcesBusy) const LinearProgressIndicator(),
      for (final source in state.publicSources) Card(child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(source.provider, style: Theme.of(context).textTheme.titleMedium),
          SelectableText(source.url),
          if (source.errorCode != null) Text(strings.offerText('unavailable'),
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
          if (source.offers.isNotEmpty)
            Text('${strings.text('loadedAt')}: ${source.offers.first.meta.retrievedAt}'),
          Text(strings.offerText('timestamp')),
          if (source.rejectedRows > 0)
            Text('${strings.offerText('rejected')}: ${source.rejectedRows}'),
        ]),
      )),
      if (isins.isEmpty) Text(strings.offerText('empty')),
      if (unmatched > 0) Text('${strings.offerText('unmatched')}: $unmatched'),
      for (final isin in isins) Card(child: ExpansionTile(
        key: ValueKey('public-offers-$isin'), title: Text(isin),
        subtitle: Text(state.currency),
        children: [for (final offer in offers.where((o) => o.isin == isin))
          Padding(padding: const EdgeInsets.all(12), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(offer.provider, style: Theme.of(context).textTheme.titleMedium),
              Text('${strings.text('maturity')}: ${offer.maturity}'),
              Text('${strings.offerText('purchase')}: ${offer.purchasePrice ?? '—'} ${offer.currency}'),
              if (offer.salePrice != null)
                Text('${strings.offerText('sale')}: ${offer.salePrice} ${offer.currency}'),
              Text('${strings.offerText('yield')}: ${offer.listedYield ?? '—'}% ${offer.yieldMethod ?? '—'}'),
              Text('${strings.offerText('quantity')}: ${offer.availableUnits ?? '—'}'),
              SelectableText(offer.sourceUrl),
            ])),
        ],
      )),
      const SizedBox(height: 16),
    ]);
  }
}
