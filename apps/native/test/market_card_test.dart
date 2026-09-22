import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/data/source_observation.dart';
import 'package:ovdp_hub/features/market/minfin_repository.dart';
import 'package:ovdp_hub/features/sellers/seller_repository.dart';
import 'package:ovdp_hub/l10n/hub_locale.dart';
import 'package:ovdp_hub/ui/components.dart';

import 'planner_test.dart' as fixture;

void main() {
  testWidgets('ISIN card keeps NBU primary and secondary layers separate', (
    tester,
  ) async {
    final bond = fixture.bond('UA4000239115', '2027-09-15');
    final primary = MinfinSnapshot(
      const SourceObservationMeta(
        sourceId: 'minfin-test',
        sourceUrl: 'https://mof.gov.ua/test',
        sourceDate: '2026-09-15',
        retrievedAt: '2026-09-22T12:00:00Z',
        kind: ObservationKind.primaryAuction,
        confidence: ObservationConfidence.officialPublished,
      ),
      [
        MinfinAuctionRate(
          isin: bond.isin,
          termLabel: '1 year',
          placementDate: '2026-09-15',
          rate: Decimal.parse('15.17'),
        ),
      ],
    );
    final seller = SellerSnapshot(
      const SourceObservationMeta(
        sourceId: 'seller-test',
        sourceUrl: 'https://seller.example/test',
        sourceDate: '2026-09-22',
        retrievedAt: '2026-09-22T12:05:00Z',
        kind: ObservationKind.secondaryQuote,
        confidence: ObservationConfidence.publicIndicative,
      ),
      [
        SellerQuote(
          bond.isin,
          bond.maturity,
          bond.currency,
          'YTM',
          '14.50',
          '15.00',
        ),
      ],
    );

    await tester.pumpWidget(
      BlocProvider(
        create: (_) => LocaleCubit()..select(AppLanguage.en),
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showBondDetails(
                  context,
                  bond,
                  seller: seller,
                  primaryFuture: Future.value(primary),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('NBU · issue terms'), findsOneWidget);
    expect(
      find.text('Ministry of Finance · primary market'),
      findsOneWidget,
    );
    expect(find.text('Seller · secondary market'), findsOneWidget);
    expect(find.textContaining('15.17%'), findsOneWidget);
    expect(find.textContaining('15.00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
