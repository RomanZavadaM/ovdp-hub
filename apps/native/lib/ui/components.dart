import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/market/market_isin.dart';
import '../features/market/minfin_repository.dart';
import '../features/sellers/seller_repository.dart';
import '../l10n/hub_locale.dart';
import '../models.dart';

class SectionHeading extends StatelessWidget {
  final String text;
  const SectionHeading(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(text, style: Theme.of(context).textTheme.headlineSmall),
  );
}

class ErrorNotice extends StatelessWidget {
  final String? message;
  final VoidCallback onDismiss;
  const ErrorNotice(this.message, this.onDismiss, {super.key});

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    final strings = HubStrings(context.watch<LocaleCubit>().state.language);
    return MaterialBanner(
      content: Text(message!),
      actions: [
        TextButton(onPressed: onDismiss, child: Text(strings.text('close'))),
      ],
    );
  }
}

Future<bool> confirmDiscard(BuildContext context) async {
  final strings = HubStrings(context.read<LocaleCubit>().state.language);
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(strings.text('unsavedTitle')),
          content: Text(strings.text('unsavedBody')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(strings.text('back')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(strings.text('discardDraft')),
            ),
          ],
        ),
      ) ??
      false;
}

void showBondDetails(
  BuildContext context,
  Bond bond, {
  SellerSnapshot? seller,
  Future<MinfinSnapshot>? primaryFuture,
}) {
  final minfinRepository = primaryFuture == null ? MinfinRepository() : null;
  final minfinFuture = primaryFuture ?? minfinRepository!.fetch();

  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final strings = HubStrings(
        dialogContext.watch<LocaleCubit>().state.language,
      );
      final sellerFacts = MarketIsinFacts.join(
        bond,
        seller: seller,
      );
      final quote = sellerFacts.secondaryQuote;

      String paymentLabel(Object? kind) => switch (kind) {
        'COUPON' => strings.text('coupon'),
        'REDEMPTION' => strings.text('redemption'),
        'EARLY_REDEMPTION' => strings.text('earlyRedemption'),
        _ => kind?.toString() ?? '',
      };

      return AlertDialog(
        title: Text(bond.isin),
        content: SizedBox(
          width: 620,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeading(strings.text('instrumentLayer')),
                Text(
                  '${bond.json['description']}\n'
                  '${bond.currency} · ${strings.text('nominal')} ${bond.json['nominal']}\n'
                  '${strings.text('rate')} ${bond.rate}% · '
                  '${strings.text('maturityColumn')} ${bond.maturity}',
                ),
                const SizedBox(height: 12),
                Text(
                  strings.text('paymentSchedule'),
                  style: Theme.of(dialogContext).textTheme.titleMedium,
                ),
                ...bond.payments.map(
                  (v) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${v['date']} · ${v['amount']} ${bond.currency}',
                    ),
                    subtitle: Text(paymentLabel(v['kind'])),
                  ),
                ),
                const Divider(height: 32),
                SectionHeading(strings.text('primaryLayer')),
                FutureBuilder<MinfinSnapshot>(
                  future: minfinFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LinearProgressIndicator();
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Text(strings.text('primaryUnavailable'));
                    }
                    final facts = MarketIsinFacts.join(
                      bond,
                      minfin: snapshot.data,
                    );
                    final auction = facts.primaryAuction;
                    if (auction == null) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(strings.text('noAuctionForIsin')),
                          const SizedBox(height: 8),
                          SelectableText(snapshot.data!.meta.sourceUrl),
                          Text(
                            '${strings.text('sourceAsOf')}: '
                            '${snapshot.data!.meta.sourceDate ?? strings.text('notAvailable')}',
                          ),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.text('latestAuction'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${strings.text('placementDate')}: '
                          '${auction.placementDate}',
                        ),
                        Text(
                          '${strings.text('auctionRate')}: '
                          '${auction.rate.toString()}%',
                        ),
                        Text(auction.termLabel),
                        const SizedBox(height: 8),
                        SelectableText(snapshot.data!.meta.sourceUrl),
                        Text(
                          '${strings.text('sourceAsOf')}: '
                          '${snapshot.data!.meta.sourceDate ?? strings.text('notAvailable')}',
                        ),
                        Text(
                          '${strings.text('retrievedAt')}: '
                          '${snapshot.data!.meta.retrievedAt}',
                        ),
                      ],
                    );
                  },
                ),
                const Divider(height: 32),
                SectionHeading(strings.text('secondaryLayer')),
                if (quote == null)
                  Text(strings.text('noSellerForIsin'))
                else ...[
                  Text(
                    strings.text('sellerQuote'),
                    style: Theme.of(dialogContext).textTheme.titleMedium,
                  ),
                  Text(
                    '${strings.text('bidYield')}: '
                    '${quote.bidYield ?? strings.text('notAvailable')}',
                  ),
                  Text(
                    '${strings.text('askYield')}: '
                    '${quote.askYield ?? strings.text('notAvailable')}',
                  ),
                  if (seller != null) ...[
                    const SizedBox(height: 8),
                    SelectableText(seller.meta.sourceUrl),
                    Text(
                      '${strings.text('sourceAsOf')}: '
                      '${seller.meta.sourceDate ?? strings.text('notAvailable')}',
                    ),
                    Text(
                      '${strings.text('retrievedAt')}: '
                      '${seller.meta.retrievedAt}',
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(strings.text('close')),
          ),
        ],
      );
    },
  ).whenComplete(() => minfinRepository?.dispose());
}
