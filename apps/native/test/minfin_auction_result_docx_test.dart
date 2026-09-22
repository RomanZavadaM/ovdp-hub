import 'package:archive/archive.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/market/minfin_auction_result_docx.dart';
import 'package:ovdp_hub/features/market/minfin_repository.dart';

String _escape(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');

String _xml(List<List<String>> rows) {
  final body = rows.map((row) {
    final cells = row.map((cell) {
      return '<w:tc><w:p><w:r><w:t>' +
          _escape(cell) +
          '</w:t></w:r></w:p></w:tc>';
    }).join();
    return '<w:tr>' + cells + '</w:tr>';
  }).join();
  return '<w:document><w:body><w:tbl>' + body + '</w:tbl></w:body></w:document>';
}

List<List<String>> _placementRows() => [
  ['Номер розміщення', '106', '107'],
  [
    'Код облігації',
    'Дорозміщення UA4000239115 Військові облігації',
    'Дорозміщення UA4000239107',
  ],
  ['Номінальна вартість', '1 000', '1 000'],
  ['Кількість виставлених облігацій (шт.)', '2 000 000', '1 000 000'],
  ['Дата розміщення', '22.09.2026', '22.09.2026'],
  ['Дата оплати за придбані облігації', '23.09.2026', '23.09.2026'],
  [
    'Дати сплати відсотків',
    '17.03.2027 15.09.2027',
    '10.02.2027 11.08.2027 09.02.2028 09.08.2028 07.02.2029',
  ],
  ['Розмір купонного платежу на одну облігацію', '75,90', '80,35'],
  ['Номінальний рівень дохідності (%)', '15,18%', '16,07%'],
  ['Термін обігу ( дн .)', '357', '868'],
  ['Дата погашення', '15.09.2027', '07.02.2029'],
  [
    'Обсяг поданих заявок (за номінальною вартістю)',
    '5 018 612 000',
    '1 320 045 000',
  ],
  [
    'Обсяг задоволених заявок (за номінальною вартістю)',
    '2 000 000 000',
    '283 454 000',
  ],
  [
    'Загальний обсяг випуску (за номінальною вартістю)',
    '5 000 000 000',
    '3 944 944 000',
  ],
  ['Кількість виставлених заявок (шт.)', '69', '14'],
  ['Кількість задоволених заявок (шт.)', '62', '12'],
  ['Максимальний рівень дохідності (%)', '15,48%', '16,30%'],
  ['Мінімальний рівень дохідності (%)', '14,50%', '16,00%'],
  ['Встановлений рівень дохідності (%)', '15,18%', '16,10%'],
  ['Середньозважений рівень дохідності (%)', '15,16%', '16,08%'],
  [
    'Залучено коштів до Державного бюджету від продажу облігацій',
    '2 006 002 055,84',
    '288 520 421,04',
  ],
];

List<List<String>> _switchRows() => [
  ['Номер аукціону з обміну облігацій', '8'],
  [
    'Міжнародний iдентифiкацiйний номер цінного папера розміщених облігацій',
    'UA4000239099',
  ],
  ['Номінальна вартість', '1000'],
  ['Обмеження на обсяг розміщення облігацій (шт.)', '1 5 000 000'],
  ['Дата обміну облігацій', '26. 0 8.202 6'],
  ['Дата розрахунків за аукціоном', '28. 0 8.202 6'],
  [
    'Дата сплати відсотків за розміщеним и облігаціями',
    '17.02.2027 18.08.2027 16.02.2028 16.08.2028 14.02.2029 15.08.2029',
  ],
  ['Розмір купонного платежу на одну облігацію', '6 2 , 95'],
  ['Номінальний рівень дохідності (%)', '1 2 , 59'],
  ['Термін обігу ( дн .)', '1 083'],
  ['Дата погашення розміщених облігацій', '15.08.2029'],
  ['Обсяг поданих заявок (за номінальною вартістю)', '18 694 969 000'],
  ['Обсяг задоволених заявок (за номінальною вартістю)', '1 5 000 000 000'],
  ['Загальний обсяг випуску (за номінальною вартістю)', '2 0 000 000 000'],
  ['Кількість виставлених заявок (шт.)', '28'],
  ['Кількість задоволених заявок (шт.)', '28'],
  [
    'Мінімальний рівень дохiдностi розміщених облігацій (%)',
    '12 , 39',
  ],
  [
    'Максимальний рівень дохiдностi розміщених облігацій (%)',
    '1 2 , 70',
  ],
  [
    'Граничний рівень дохiдностi розміщених облігацій (%)',
    '12 , 70',
  ],
  [
    'Середньозважений рівень дохiдностi розміщених облігацій (%)',
    '1 2 , 61',
  ],
  ['Вартість розміщених облігацій (грн.)', '15 039 591 503,27'],
  [
    'Міжнародний ідентифікаційний номер цінного папера облігацій, що зараховуються емітенту',
    'UA40002 28811',
  ],
  [
    'Термін погашення облігацій, що зараховуються емітенту',
    '30. 0 9.202 6',
  ],
  ['Кількість облігацій, що зараховуються емітенту (шт.)', '13 891 321'],
  ['Вартість облігацій, що зараховуються емітенту (грн.)', '15 039 577 593,86'],
  ['Різниця вартостей, яка виплачується емітенту (грн.)', '13 909,41'],
];

MinfinAuctionEvent _placementEvent() => const MinfinAuctionEvent(
  auctionDate: '2026-09-22',
  kind: MinfinAuctionEventKind.placement,
  announcementUrl: 'https://mof.gov.ua/storage/files/announcement.docx',
  resultUrl: 'https://mof.gov.ua/storage/files/file_doc/result.docx',
);

MinfinAuctionEvent _switchEvent() => const MinfinAuctionEvent(
  auctionDate: '2026-08-26',
  kind: MinfinAuctionEventKind.switchAuction,
  announcementUrl: 'https://mof.gov.ua/storage/files/switch-announcement.docx',
  resultUrl: 'https://mof.gov.ua/storage/files/switch-result.docx',
);

void main() {
  test('placement DOCX rows parse all observed fields and provenance', () {
    final parsed = parseMinfinAuctionResultDocumentXml(
      event: _placementEvent(),
      documentXml: _xml(_placementRows()),
      retrievedAt: DateTime.utc(2026, 9, 22, 19),
    );

    expect(parsed, isA<MinfinPlacementAuctionResult>());
    final result = parsed as MinfinPlacementAuctionResult;
    expect(result.meta.sourceDate, '2026-09-22');
    expect(result.meta.sourceUrl, _placementEvent().resultUrl);
    expect(result.lots.length, 2);

    final first = result.lots.first;
    expect(first.placementNumber, 106);
    expect(first.isin, 'UA4000239115');
    expect(first.nominalValue, Decimal.parse('1000'));
    expect(first.offeredQuantity, 2000000);
    expect(first.placementDate, '2026-09-22');
    expect(first.paymentDate, '2026-09-23');
    expect(first.couponDates, ['2027-03-17', '2027-09-15']);
    expect(first.couponPayment, Decimal.parse('75.90'));
    expect(first.nominalYield, Decimal.parse('15.18'));
    expect(first.maximumYield, Decimal.parse('15.48'));
    expect(first.minimumYield, Decimal.parse('14.50'));
    expect(first.cutoffYield, Decimal.parse('15.18'));
    expect(first.weightedAverageYield, Decimal.parse('15.16'));
    expect(first.proceedsAmount, Decimal.parse('2006002055.84'));
  });

  test('switch DOCX normalizes fragmented Word runs without guessing fields', () {
    final parsed = parseMinfinAuctionResultDocumentXml(
      event: _switchEvent(),
      documentXml: _xml(_switchRows()),
      retrievedAt: DateTime.utc(2026, 9, 22, 19),
    );

    expect(parsed, isA<MinfinSwitchAuctionResult>());
    final result = parsed as MinfinSwitchAuctionResult;
    final details = result.details;

    expect(details.auctionNumber, 8);
    expect(details.placedIsin, 'UA4000239099');
    expect(details.placementLimit, 15000000);
    expect(details.exchangeDate, '2026-08-26');
    expect(details.settlementDate, '2026-08-28');
    expect(details.couponPayment, Decimal.parse('62.95'));
    expect(details.nominalYield, Decimal.parse('12.59'));
    expect(details.minimumYield, Decimal.parse('12.39'));
    expect(details.maximumYield, Decimal.parse('12.70'));
    expect(details.cutoffYield, Decimal.parse('12.70'));
    expect(details.weightedAverageYield, Decimal.parse('12.61'));
    expect(details.returnedIsin, 'UA4000228811');
    expect(details.returnedMaturityDate, '2026-09-30');
    expect(details.returnedQuantity, 13891321);
    expect(details.cashDifferenceToIssuerUah, Decimal.parse('13909.41'));
  });

  test('DOCX container extraction uses word/document.xml deterministically', () {
    final archive = Archive()
      ..add(ArchiveFile.string('word/document.xml', _xml(_placementRows())));
    final bytes = ZipEncoder().encodeBytes(archive);

    final parsed = parseMinfinAuctionResultDocx(
      event: _placementEvent(),
      bytes: bytes,
      retrievedAt: DateTime.utc(2026, 9, 22, 19),
    );

    expect(parsed, isA<MinfinPlacementAuctionResult>());
  });

  test('result parser fails closed when a required field disappears', () {
    final rows = _placementRows()..removeAt(20);
    expect(
      () => parseMinfinAuctionResultDocumentXml(
        event: _placementEvent(),
        documentXml: _xml(rows),
        retrievedAt: DateTime.utc(2026, 9, 22),
      ),
      throwsFormatException,
    );
  });

  test('result parser fails closed when document date disagrees with event', () {
    final rows = _placementRows();
    rows[4][1] = '21.09.2026';

    expect(
      () => parseMinfinAuctionResultDocumentXml(
        event: _placementEvent(),
        documentXml: _xml(rows),
        retrievedAt: DateTime.utc(2026, 9, 22),
      ),
      throwsFormatException,
    );
  });

  test('result parser rejects non-MinFin URL and invalid DOCX bytes', () {
    const badEvent = MinfinAuctionEvent(
      auctionDate: '2026-09-22',
      kind: MinfinAuctionEventKind.placement,
      announcementUrl: 'https://mof.gov.ua/storage/files/a.docx',
      resultUrl: 'https://example.test/result.docx',
    );

    expect(
      () => parseMinfinAuctionResultDocumentXml(
        event: badEvent,
        documentXml: _xml(_placementRows()),
        retrievedAt: DateTime.utc(2026, 9, 22),
      ),
      throwsFormatException,
    );
    expect(
      () => extractMinfinAuctionResultDocumentXml(
        Uint8List.fromList([1, 2, 3, 4]),
      ),
      throwsFormatException,
    );
  });
}
