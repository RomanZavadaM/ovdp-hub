import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/market/minfin_calendar_pdf.dart';
import 'package:ovdp_hub/features/market/minfin_repository.dart';

void main() {
  const officialBase = 'https://mof.gov.ua/storage/files/';

  MinfinPdfTextRun run(
    String text,
    double left,
    double right,
    double bottom,
  ) {
    return MinfinPdfTextRun(
      page: 0,
      left: left,
      bottom: bottom,
      right: right,
      top: bottom + 14,
      text: text,
    );
  }

  test('monthly calendar keeps source-only currency and instrument facts', () {
    const document = MinfinCalendarDocument(
      publishedDate: '2026-03-27',
      kind: MinfinCalendarDocumentKind.monthlyPlacement,
      title: 'Графік розміщення ОВДП на квітень 2026 року',
      documentUrl: '${officialBase}monthly.pdf',
    );
    final runs = <MinfinPdfTextRun>[
      run('Графік проведення аукціонів на квітень 2026 року', 100, 600, 510),
      run('Квітень 07', 130, 210, 429),
      run('Квітень 14', 300, 380, 429),
      run('21/07/2027', 138, 208, 391),
      run('Первинне розміщення', 100, 245, 373),
      run('14/06/2028', 138, 208, 338),
      run('UA4000239008', 124, 222, 322),
      run('-', 170, 175, 280),
      run('EUR', 324, 354, 244),
      run('06/05/2027', 304, 374, 227),
      run('UA4000238364', 290, 387, 211),
      run('* - За результатами оцінки попиту', 30, 260, 127),
    ];

    final snapshot = parseMinfinCalendarScheduleRuns(
      document: document,
      runs: runs,
      retrievedAt: DateTime.utc(2026, 9, 22, 12),
    );

    expect(snapshot.meta.sourceDate, '2026-03-27');
    expect(snapshot.meta.sourceUrl, document.documentUrl);
    expect(snapshot.entries.length, 3);

    final first = snapshot.entries.first as MinfinMonthlyPlacementScheduleEntry;
    expect(first.auctionDate, '2026-04-07');
    expect(first.offerings.length, 2);
    expect(first.offerings.first.isPrimaryPlacement, isTrue);
    expect(first.offerings.first.isin, isNull);
    expect(first.offerings.first.explicitCurrencyCode, isNull);
    expect(first.offerings.last.isin, 'UA4000239008');
    expect(first.offerings.last.explicitCurrencyCode, isNull);

    final second = snapshot.entries.last as MinfinMonthlyPlacementScheduleEntry;
    expect(second.auctionDate, '2026-04-14');
    expect(second.offerings.single.maturityDate, '2027-05-06');
    expect(second.offerings.single.isin, 'UA4000238364');
    expect(second.offerings.single.explicitCurrencyCode, 'EUR');
  });

  test('quarterly calendar keeps tenor plans separate from instruments', () {
    const document = MinfinCalendarDocument(
      publishedDate: '2026-07-01',
      kind: MinfinCalendarDocumentKind.quarterlyPlacement,
      title: 'Графік розміщення ОВДП на III квартал 2026 року',
      documentUrl: '${officialBase}quarterly.pdf',
    );
    final runs = <MinfinPdfTextRun>[
      run('Графік проведення аукціонів на III квартал 2026 року', 80, 700, 500),
      run('07 липня', 100, 160, 439),
      run('14 липня', 260, 320, 439),
      run('21 липня', 420, 480, 439),
      run('28 липня', 525, 582, 439),
      run('-', 687, 692, 439),
      run('Гривня: 1 рік;', 60, 155, 416),
      run('2 роки; 3,5 року', 60, 155, 400),
      run('ЄВРО: 1,4 року', 60, 155, 384),
      run('Гривня: 1 рік;', 490, 579, 408),
      run('2 роки; 3 роки', 490, 575, 392),
      run('-', 687, 692, 400),
      run('04 серпня', 100, 160, 362),
      run('11 серпня', 260, 320, 362),
      run('18 серпня', 420, 480, 362),
      run('25 серпня', 523, 584, 362),
      run('-', 687, 692, 362),
      run('Гривня: 1 рік;', 220, 315, 331),
      run('2 роки; 3 роки', 220, 315, 315),
      run('* - За результатами оцінки попиту', 30, 260, 140),
    ];

    final snapshot = parseMinfinCalendarScheduleRuns(
      document: document,
      runs: runs,
      retrievedAt: DateTime.utc(2026, 9, 22, 12),
    );

    expect(snapshot.entries.length, 2);
    final july =
        snapshot.entries.first as MinfinQuarterlyPlacementScheduleEntry;
    expect(july.auctionDate, '2026-07-07');
    expect(july.plans.length, 2);
    expect(july.plans.first.currencyCode, 'UAH');
    expect(july.plans.first.sourceCurrencyLabel, 'Гривня');
    expect(july.plans.first.tenorLabels, ['1 рік', '2 роки', '3,5 року']);
    expect(july.plans.last.currencyCode, 'EUR');
    expect(july.plans.last.tenorLabels, ['1,4 року']);

    final july28 =
        snapshot.entries[1] as MinfinQuarterlyPlacementScheduleEntry;
    expect(july28.auctionDate, '2026-07-28');
    expect(july28.plans.single.currencyCode, 'UAH');

    final august =
        snapshot.entries.last as MinfinQuarterlyPlacementScheduleEntry;
    expect(august.auctionDate, '2026-08-11');
    expect(august.plans.single.tenorLabels, ['1 рік', '2 роки', '3 роки']);
  });

  test('switch calendar preserves offered and placed legs', () {
    const document = MinfinCalendarDocument(
      publishedDate: '2026-05-28',
      kind: MinfinCalendarDocumentKind.monthlySwitch,
      title: 'Графік розміщення ОВДП з обміну на червень 2026 року',
      documentUrl: '${officialBase}switch.pdf',
    );
    final runs = <MinfinPdfTextRun>[
      run('Графік проведення аукціонів з обміну на червень 2026 року', 80, 760, 513),
      run('24 Червня', 401, 478, 438),
      run('ОВДП, що пропонуються до обміну:', 320, 555, 406),
      run('22/07/2026', 402, 473, 390),
      run('UA4000228043', 389, 486, 374),
      run('ОВДП, що розміщуються:', 354, 521, 346),
      run('14/11/2029', 402, 473, 330),
      run('Первинне розміщення', 365, 510, 313),
      run('* - За результатами оцінки попиту', 30, 300, 29),
    ];

    final snapshot = parseMinfinCalendarScheduleRuns(
      document: document,
      runs: runs,
      retrievedAt: DateTime.utc(2026, 9, 22, 12),
    );

    expect(snapshot.entries.length, 1);
    final entry = snapshot.entries.single as MinfinSwitchScheduleEntry;
    expect(entry.auctionDate, '2026-06-24');
    expect(entry.offeredForExchange.maturityDate, '2026-07-22');
    expect(entry.offeredForExchange.isin, 'UA4000228043');
    expect(entry.offeredForExchange.isPrimaryPlacement, isFalse);
    expect(entry.placed.maturityDate, '2029-11-14');
    expect(entry.placed.isin, isNull);
    expect(entry.placed.isPrimaryPlacement, isTrue);
  });

  test('calendar PDF parser fails closed on unknown table content', () {
    const document = MinfinCalendarDocument(
      publishedDate: '2026-03-27',
      kind: MinfinCalendarDocumentKind.monthlyPlacement,
      title: 'Графік розміщення ОВДП на квітень 2026 року',
      documentUrl: '${officialBase}monthly.pdf',
    );
    final runs = <MinfinPdfTextRun>[
      run('Графік на квітень 2026 року', 100, 600, 510),
      run('Квітень 07', 130, 210, 429),
      run('Квітень 14', 300, 380, 429),
      run('21/07/2027', 138, 208, 391),
      run('Невідомий тип', 100, 210, 373),
      run('* - За результатами оцінки попиту', 30, 260, 127),
    ];

    expect(
      () => parseMinfinCalendarScheduleRuns(
        document: document,
        runs: runs,
        retrievedAt: DateTime.utc(2026, 9, 22),
      ),
      throwsFormatException,
    );
  });

  test('calendar PDF extractor rejects non-PDF bytes', () {
    expect(
      () => extractMinfinPdfTextRuns(Uint8List.fromList([1, 2, 3, 4, 5])),
      throwsFormatException,
    );
  });

  test('calendar schedule rejects non-MinFin evidence URL', () {
    const document = MinfinCalendarDocument(
      publishedDate: '2026-03-27',
      kind: MinfinCalendarDocumentKind.monthlyPlacement,
      title: 'Calendar',
      documentUrl: 'https://example.test/calendar.pdf',
    );
    expect(
      () => parseMinfinCalendarScheduleRuns(
        document: document,
        runs: const [],
        retrievedAt: DateTime.utc(2026, 9, 22),
      ),
      throwsFormatException,
    );
  });
}
