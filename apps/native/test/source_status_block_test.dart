import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/data/source_observation.dart';
import 'package:ovdp_hub/l10n/hub_locale.dart';
import 'package:ovdp_hub/ui/source_status_block.dart';

void main() {
  testWidgets('official source status is explicit and includes provenance', (
    tester,
  ) async {
    const meta = SourceObservationMeta(
      sourceId: 'nbu-test',
      sourceUrl: 'https://bank.gov.ua/ua/markets/ovdp',
      sourceDate: '2026-09-22',
      retrievedAt: '2026-09-22T12:00:00Z',
      kind: ObservationKind.instrument,
      confidence: ObservationConfidence.officialPublished,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SourceStatusBlock(
            meta: meta,
            strings: HubStrings(AppLanguage.uk),
            sourceName: 'НБУ',
            now: DateTime.utc(2026, 9, 22, 18),
          ),
        ),
      ),
    );

    expect(find.text('Джерело: НБУ'), findsOneWidget);
    expect(find.text('Дата джерела: 2026-09-22'), findsOneWidget);
    expect(find.text('Отримано: 2026-09-22T12:00:00Z'), findsOneWidget);
    expect(
      find.text('Актуальність: Дата джерела — сьогодні'),
      findsOneWidget,
    );
    expect(
      find.text('Статус даних: Офіційно опубліковані дані'),
      findsOneWidget,
    );
    expect(find.text('https://bank.gov.ua/ua/markets/ovdp'), findsOneWidget);
  });

  testWidgets('indicative seller quote shows stale state in text', (
    tester,
  ) async {
    const meta = SourceObservationMeta(
      sourceId: 'seller-test',
      sourceUrl: 'https://seller.example/quotes',
      sourceDate: '2026-09-21',
      retrievedAt: '2026-09-22T12:00:00Z',
      kind: ObservationKind.secondaryQuote,
      confidence: ObservationConfidence.publicIndicative,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SourceStatusBlock(
            meta: meta,
            strings: HubStrings(AppLanguage.en),
            sourceName: 'Seller',
            now: DateTime.utc(2026, 9, 22, 18),
          ),
        ),
      ),
    );

    expect(
      find.text('Freshness: Source date is earlier than today'),
      findsOneWidget,
    );
    expect(
      find.text('Data status: Public indicative data'),
      findsOneWidget,
    );
  });
}
