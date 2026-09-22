import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../data/source_observation.dart';
import 'minfin_repository.dart';

@immutable
class MinfinPlacementAuctionLot {
  final int placementNumber;
  final String isin;
  final String sourceSecurityLabel;
  final Decimal nominalValue;
  final int offeredQuantity;
  final String placementDate;
  final String paymentDate;
  final List<String> couponDates;
  final Decimal couponPayment;
  final Decimal nominalYield;
  final int termDays;
  final String maturityDate;
  final Decimal submittedNominalValue;
  final Decimal acceptedNominalValue;
  final Decimal totalIssueNominalValue;
  final int submittedBidCount;
  final int acceptedBidCount;
  final Decimal maximumYield;
  final Decimal minimumYield;
  final Decimal cutoffYield;
  final Decimal weightedAverageYield;
  final Decimal proceedsAmount;

  MinfinPlacementAuctionLot({
    required this.placementNumber,
    required this.isin,
    required this.sourceSecurityLabel,
    required this.nominalValue,
    required this.offeredQuantity,
    required this.placementDate,
    required this.paymentDate,
    required Iterable<String> couponDates,
    required this.couponPayment,
    required this.nominalYield,
    required this.termDays,
    required this.maturityDate,
    required this.submittedNominalValue,
    required this.acceptedNominalValue,
    required this.totalIssueNominalValue,
    required this.submittedBidCount,
    required this.acceptedBidCount,
    required this.maximumYield,
    required this.minimumYield,
    required this.cutoffYield,
    required this.weightedAverageYield,
    required this.proceedsAmount,
  }) : couponDates = List.unmodifiable(couponDates);
}

@immutable
class MinfinSwitchAuctionDetails {
  final int auctionNumber;
  final String placedIsin;
  final Decimal nominalValue;
  final int placementLimit;
  final String exchangeDate;
  final String settlementDate;
  final List<String> couponDates;
  final Decimal couponPayment;
  final Decimal nominalYield;
  final int termDays;
  final String placedMaturityDate;
  final Decimal submittedNominalValue;
  final Decimal acceptedNominalValue;
  final Decimal totalIssueNominalValue;
  final int submittedBidCount;
  final int acceptedBidCount;
  final Decimal minimumYield;
  final Decimal maximumYield;
  final Decimal cutoffYield;
  final Decimal weightedAverageYield;
  final Decimal placedValueUah;
  final String returnedIsin;
  final String returnedMaturityDate;
  final int returnedQuantity;
  final Decimal returnedValueUah;
  final Decimal cashDifferenceToIssuerUah;

  MinfinSwitchAuctionDetails({
    required this.auctionNumber,
    required this.placedIsin,
    required this.nominalValue,
    required this.placementLimit,
    required this.exchangeDate,
    required this.settlementDate,
    required Iterable<String> couponDates,
    required this.couponPayment,
    required this.nominalYield,
    required this.termDays,
    required this.placedMaturityDate,
    required this.submittedNominalValue,
    required this.acceptedNominalValue,
    required this.totalIssueNominalValue,
    required this.submittedBidCount,
    required this.acceptedBidCount,
    required this.minimumYield,
    required this.maximumYield,
    required this.cutoffYield,
    required this.weightedAverageYield,
    required this.placedValueUah,
    required this.returnedIsin,
    required this.returnedMaturityDate,
    required this.returnedQuantity,
    required this.returnedValueUah,
    required this.cashDifferenceToIssuerUah,
  }) : couponDates = List.unmodifiable(couponDates);
}

sealed class MinfinDetailedAuctionResult {
  final SourceObservationMeta meta;
  final String auctionDate;

  const MinfinDetailedAuctionResult({
    required this.meta,
    required this.auctionDate,
  });
}

@immutable
class MinfinPlacementAuctionResult extends MinfinDetailedAuctionResult {
  final List<MinfinPlacementAuctionLot> lots;

  MinfinPlacementAuctionResult({
    required super.meta,
    required super.auctionDate,
    required Iterable<MinfinPlacementAuctionLot> lots,
  }) : lots = List.unmodifiable(lots);
}

@immutable
class MinfinSwitchAuctionResult extends MinfinDetailedAuctionResult {
  final MinfinSwitchAuctionDetails details;

  const MinfinSwitchAuctionResult({
    required super.meta,
    required super.auctionDate,
    required this.details,
  });
}

const _maxDocxBytes = 4 * 1024 * 1024;
const _maxDocumentXmlBytes = 4 * 1024 * 1024;

bool _isOfficialResultUrl(String value) {
  final uri = Uri.tryParse(value);
  return uri != null &&
      uri.scheme == 'https' &&
      uri.host == 'mof.gov.ua' &&
      uri.path.startsWith('/storage/files/') &&
      uri.path.toLowerCase().endsWith('.docx');
}

String extractMinfinAuctionResultDocumentXml(Uint8List bytes) {
  if (bytes.length < 4 || bytes[0] != 0x50 || bytes[1] != 0x4b) {
    throw const FormatException('minfin.result_docx_invalid');
  }

  try {
    final archive = ZipDecoder().decodeBytes(bytes, verify: true);
    final document = archive.findFile('word/document.xml');
    if (document == null ||
        !document.isFile ||
        document.size <= 0 ||
        document.size > _maxDocumentXmlBytes) {
      throw const FormatException('minfin.result_docx_invalid');
    }
    final content = document.readBytes();
    if (content == null || content.isEmpty) {
      throw const FormatException('minfin.result_docx_invalid');
    }
    final xml = utf8.decode(content);
    if (!xml.contains('<w:document') || !xml.contains('<w:tbl')) {
      throw const FormatException('minfin.result_docx_layout_changed');
    }
    return xml;
  } on FormatException {
    rethrow;
  } catch (_) {
    throw const FormatException('minfin.result_docx_invalid');
  }
}

MinfinDetailedAuctionResult parseMinfinAuctionResultDocx({
  required MinfinAuctionEvent event,
  required Uint8List bytes,
  required DateTime retrievedAt,
}) {
  return parseMinfinAuctionResultDocumentXml(
    event: event,
    documentXml: extractMinfinAuctionResultDocumentXml(bytes),
    retrievedAt: retrievedAt,
  );
}

MinfinDetailedAuctionResult parseMinfinAuctionResultDocumentXml({
  required MinfinAuctionEvent event,
  required String documentXml,
  required DateTime retrievedAt,
}) {
  final resultUrl = event.resultUrl;
  if (resultUrl == null || resultUrl.trim().isEmpty) {
    throw const FormatException('minfin.result_missing_url');
  }
  if (!_isOfficialResultUrl(resultUrl)) {
    throw const FormatException('minfin.invalid_source_url');
  }

  final rows = _extractRows(documentXml);
  if (rows.isEmpty) {
    throw const FormatException('minfin.result_docx_layout_changed');
  }

  final meta = SourceObservationMeta(
    sourceId: event.kind == MinfinAuctionEventKind.placement
        ? 'minfin-placement-result-docx'
        : 'minfin-switch-result-docx',
    sourceUrl: resultUrl,
    sourceDate: event.auctionDate,
    retrievedAt: retrievedAt.toUtc().toIso8601String(),
    kind: ObservationKind.primaryAuction,
    confidence: ObservationConfidence.publicIndicative,
  );

  return switch (event.kind) {
    MinfinAuctionEventKind.placement => MinfinPlacementAuctionResult(
        meta: meta,
        auctionDate: event.auctionDate,
        lots: _parsePlacementRows(rows, event.auctionDate),
      ),
    MinfinAuctionEventKind.switchAuction => MinfinSwitchAuctionResult(
        meta: meta,
        auctionDate: event.auctionDate,
        details: _parseSwitchRows(rows, event.auctionDate),
      ),
  };
}

class MinfinAuctionResultDocxRepository {
  final http.Client client;
  final DateTime Function() clock;

  MinfinAuctionResultDocxRepository({
    http.Client? client,
    DateTime Function()? clock,
  }) : client = client ?? http.Client(),
       clock = clock ?? DateTime.now;

  Future<MinfinDetailedAuctionResult> fetch(MinfinAuctionEvent event) async {
    final resultUrl = event.resultUrl;
    if (resultUrl == null || resultUrl.trim().isEmpty) {
      throw const FormatException('minfin.result_missing_url');
    }
    if (!_isOfficialResultUrl(resultUrl)) {
      throw const FormatException('minfin.invalid_source_url');
    }

    final response = await client
        .get(Uri.parse(resultUrl))
        .timeout(const Duration(seconds: 25));
    if (response.statusCode != 200) {
      throw FormatException(
        'minfin.result_docx_http_status',
        {'status': response.statusCode},
      );
    }
    if (response.bodyBytes.length > _maxDocxBytes) {
      throw const FormatException('minfin.result_docx_too_large');
    }

    return parseMinfinAuctionResultDocx(
      event: event,
      bytes: Uint8List.fromList(response.bodyBytes),
      retrievedAt: clock(),
    );
  }

  void dispose() => client.close();
}

List<List<String>> _extractRows(String xml) {
  if (!xml.contains('<w:document') || !xml.contains('<w:tbl')) {
    throw const FormatException('minfin.result_docx_layout_changed');
  }

  final rowPattern = RegExp(r'<w:tr\b[^>]*>(.*?)</w:tr>', dotAll: true);
  final cellPattern = RegExp(r'<w:tc\b[^>]*>(.*?)</w:tc>', dotAll: true);
  final textPattern = RegExp(r'<w:t(?:\s[^>]*)?>(.*?)</w:t>', dotAll: true);
  final rows = <List<String>>[];

  for (final rowMatch in rowPattern.allMatches(xml)) {
    final cells = <String>[];
    for (final cellMatch in cellPattern.allMatches(rowMatch.group(1)!)) {
      final fragments = textPattern
          .allMatches(cellMatch.group(1)!)
          .map((match) => _decodeXml(match.group(1)!))
          .toList();
      cells.add(_cleanText(fragments.join(' ')));
    }
    if (cells.any((cell) => cell.isNotEmpty)) {
      rows.add(List.unmodifiable(cells));
    }
  }

  return List.unmodifiable(rows);
}

String _decodeXml(String value) {
  var result = value
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'");
  result = result.replaceAllMapped(
    RegExp(r'&#x([0-9A-Fa-f]+);'),
    (match) => String.fromCharCode(int.parse(match.group(1)!, radix: 16)),
  );
  result = result.replaceAllMapped(
    RegExp(r'&#(\d+);'),
    (match) => String.fromCharCode(int.parse(match.group(1)!)),
  );
  return result;
}

String _cleanText(String value) => value
    .replaceAll('\u00a0', ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

String _compact(String value) =>
    _cleanText(value).replaceAll(RegExp(r'\s+'), '');

String _labelKey(String value) => _cleanText(value)
    .toLowerCase()
    .replaceAll('i', 'і')
    .replaceAll(RegExp(r'[^a-zа-яіїєґ0-9]+'), '');

Map<String, List<String>> _rowMap(List<List<String>> rows) {
  final result = <String, List<String>>{};
  for (final row in rows) {
    if (row.length < 2 || row.first.isEmpty) {
      throw const FormatException('minfin.result_docx_layout_changed');
    }
    final key = _labelKey(row.first);
    if (key.isEmpty || result.containsKey(key)) {
      throw const FormatException('minfin.result_docx_layout_changed');
    }
    result[key] = List.unmodifiable(row.skip(1));
  }
  return result;
}

List<String> _requiredRow(
  Map<String, List<String>> rows,
  String label,
  int columnCount,
) {
  final values = rows[_labelKey(label)];
  if (values == null || values.length != columnCount) {
    throw const FormatException('minfin.result_docx_layout_changed');
  }
  return values;
}

void _requireExactLabels(
  Map<String, List<String>> rows,
  Iterable<String> labels,
) {
  final expected = labels.map(_labelKey).toSet();
  if (rows.length != expected.length ||
      expected.any((label) => !rows.containsKey(label))) {
    throw const FormatException('minfin.result_docx_layout_changed');
  }
}

String _isoDate(String value) {
  final compact = _compact(value);
  final match = RegExp(r'^(\d{1,2})\.(\d{1,2})\.(\d{4})$')
      .firstMatch(compact);
  if (match == null) {
    throw const FormatException('minfin.result_docx_layout_changed');
  }
  final day = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final year = int.parse(match.group(3)!);
  final date = DateTime.utc(year, month, day);
  if (date.day != day || date.month != month || date.year != year) {
    throw const FormatException('minfin.result_docx_layout_changed');
  }
  return year.toString().padLeft(4, '0') +
      '-' +
      month.toString().padLeft(2, '0') +
      '-' +
      day.toString().padLeft(2, '0');
}

List<String> _couponDates(String value) {
  final compact = _compact(value);
  final pattern = RegExp(r'\d{1,2}\.\d{1,2}\.\d{4}');
  final matches = pattern.allMatches(compact).toList();
  if (matches.isEmpty || compact.replaceAll(pattern, '').isNotEmpty) {
    throw const FormatException('minfin.result_docx_layout_changed');
  }
  return List.unmodifiable(matches.map((match) => _isoDate(match.group(0)!)));
}

Decimal _decimal(String value, {bool allowNegative = false}) {
  final compact = _compact(value)
      .replaceAll('%', '')
      .replaceAll(',', '.');
  final pattern = allowNegative
      ? RegExp(r'^-?\d+(?:\.\d+)?$')
      : RegExp(r'^\d+(?:\.\d+)?$');
  if (!pattern.hasMatch(compact)) {
    throw const FormatException('minfin.result_docx_layout_changed');
  }
  return Decimal.parse(compact);
}

Decimal _positiveDecimal(String value) {
  final parsed = _decimal(value);
  if (parsed <= Decimal.zero) {
    throw const FormatException('minfin.result_docx_layout_changed');
  }
  return parsed;
}

Decimal _nonNegativeDecimal(String value) {
  final parsed = _decimal(value, allowNegative: true);
  if (parsed < Decimal.zero) {
    throw const FormatException('minfin.result_docx_layout_changed');
  }
  return parsed;
}

Decimal _yield(String value) {
  final parsed = _decimal(value);
  if (parsed <= Decimal.zero || parsed >= Decimal.fromInt(100)) {
    throw const FormatException('minfin.result_docx_layout_changed');
  }
  return parsed;
}

int _positiveInt(String value) {
  final compact = _compact(value);
  if (!RegExp(r'^\d+$').hasMatch(compact)) {
    throw const FormatException('minfin.result_docx_layout_changed');
  }
  final parsed = int.parse(compact);
  if (parsed <= 0) {
    throw const FormatException('minfin.result_docx_layout_changed');
  }
  return parsed;
}

String _isin(String value) {
  final compact = _compact(value);
  final match = RegExp(r'UA\d{10}').firstMatch(compact);
  if (match == null) {
    throw const FormatException('minfin.result_docx_layout_changed');
  }
  return match.group(0)!;
}

const _placementLabels = <String>[
  'Номер розміщення',
  'Код облігації',
  'Номінальна вартість',
  'Кількість виставлених облігацій (шт.)',
  'Дата розміщення',
  'Дата оплати за придбані облігації',
  'Дати сплати відсотків',
  'Розмір купонного платежу на одну облігацію',
  'Номінальний рівень дохідності (%)',
  'Термін обігу (дн.)',
  'Дата погашення',
  'Обсяг поданих заявок (за номінальною вартістю)',
  'Обсяг задоволених заявок (за номінальною вартістю)',
  'Загальний обсяг випуску (за номінальною вартістю)',
  'Кількість виставлених заявок (шт.)',
  'Кількість задоволених заявок (шт.)',
  'Максимальний рівень дохідності (%)',
  'Мінімальний рівень дохідності (%)',
  'Встановлений рівень дохідності (%)',
  'Середньозважений рівень дохідності (%)',
  'Залучено коштів до Державного бюджету від продажу облігацій',
];

List<MinfinPlacementAuctionLot> _parsePlacementRows(
  List<List<String>> sourceRows,
  String auctionDate,
) {
  final rows = _rowMap(sourceRows);
  _requireExactLabels(rows, _placementLabels);

  final placementNumbers = rows[_labelKey('Номер розміщення')]!;
  final columnCount = placementNumbers.length;
  if (columnCount < 1) {
    throw const FormatException('minfin.result_docx_layout_changed');
  }
  for (final label in _placementLabels) {
    _requiredRow(rows, label, columnCount);
  }

  final codes = _requiredRow(rows, 'Код облігації', columnCount);
  final nominalValues = _requiredRow(rows, 'Номінальна вартість', columnCount);
  final offeredQuantities = _requiredRow(
    rows,
    'Кількість виставлених облігацій (шт.)',
    columnCount,
  );
  final placementDates =
      _requiredRow(rows, 'Дата розміщення', columnCount);
  final paymentDates = _requiredRow(
    rows,
    'Дата оплати за придбані облігації',
    columnCount,
  );
  final couponDates =
      _requiredRow(rows, 'Дати сплати відсотків', columnCount);
  final couponPayments = _requiredRow(
    rows,
    'Розмір купонного платежу на одну облігацію',
    columnCount,
  );
  final nominalYields = _requiredRow(
    rows,
    'Номінальний рівень дохідності (%)',
    columnCount,
  );
  final termDays = _requiredRow(rows, 'Термін обігу (дн.)', columnCount);
  final maturityDates = _requiredRow(rows, 'Дата погашення', columnCount);
  final submittedNominal = _requiredRow(
    rows,
    'Обсяг поданих заявок (за номінальною вартістю)',
    columnCount,
  );
  final acceptedNominal = _requiredRow(
    rows,
    'Обсяг задоволених заявок (за номінальною вартістю)',
    columnCount,
  );
  final totalIssueNominal = _requiredRow(
    rows,
    'Загальний обсяг випуску (за номінальною вартістю)',
    columnCount,
  );
  final submittedBids = _requiredRow(
    rows,
    'Кількість виставлених заявок (шт.)',
    columnCount,
  );
  final acceptedBids = _requiredRow(
    rows,
    'Кількість задоволених заявок (шт.)',
    columnCount,
  );
  final maximumYields = _requiredRow(
    rows,
    'Максимальний рівень дохідності (%)',
    columnCount,
  );
  final minimumYields = _requiredRow(
    rows,
    'Мінімальний рівень дохідності (%)',
    columnCount,
  );
  final cutoffYields = _requiredRow(
    rows,
    'Встановлений рівень дохідності (%)',
    columnCount,
  );
  final weightedYields = _requiredRow(
    rows,
    'Середньозважений рівень дохідності (%)',
    columnCount,
  );
  final proceeds = _requiredRow(
    rows,
    'Залучено коштів до Державного бюджету від продажу облігацій',
    columnCount,
  );

  final result = <MinfinPlacementAuctionLot>[];
  final seenNumbers = <int>{};
  final seenIsins = <String>{};

  for (var index = 0; index < columnCount; index++) {
    final placementNumber = _positiveInt(placementNumbers[index]);
    final isin = _isin(codes[index]);
    final placementDate = _isoDate(placementDates[index]);
    if (placementDate != auctionDate ||
        !seenNumbers.add(placementNumber) ||
        !seenIsins.add(isin)) {
      throw const FormatException('minfin.result_docx_layout_changed');
    }

    result.add(
      MinfinPlacementAuctionLot(
        placementNumber: placementNumber,
        isin: isin,
        sourceSecurityLabel: _cleanText(codes[index]),
        nominalValue: _positiveDecimal(nominalValues[index]),
        offeredQuantity: _positiveInt(offeredQuantities[index]),
        placementDate: placementDate,
        paymentDate: _isoDate(paymentDates[index]),
        couponDates: _couponDates(couponDates[index]),
        couponPayment: _positiveDecimal(couponPayments[index]),
        nominalYield: _yield(nominalYields[index]),
        termDays: _positiveInt(termDays[index]),
        maturityDate: _isoDate(maturityDates[index]),
        submittedNominalValue: _positiveDecimal(submittedNominal[index]),
        acceptedNominalValue: _positiveDecimal(acceptedNominal[index]),
        totalIssueNominalValue: _positiveDecimal(totalIssueNominal[index]),
        submittedBidCount: _positiveInt(submittedBids[index]),
        acceptedBidCount: _positiveInt(acceptedBids[index]),
        maximumYield: _yield(maximumYields[index]),
        minimumYield: _yield(minimumYields[index]),
        cutoffYield: _yield(cutoffYields[index]),
        weightedAverageYield: _yield(weightedYields[index]),
        proceedsAmount: _positiveDecimal(proceeds[index]),
      ),
    );
  }

  return List.unmodifiable(result);
}

const _switchLabels = <String>[
  'Номер аукціону з обміну облігацій',
  'Міжнародний ідентифікаційний номер цінного папера розміщених облігацій',
  'Номінальна вартість',
  'Обмеження на обсяг розміщення облігацій (шт.)',
  'Дата обміну облігацій',
  'Дата розрахунків за аукціоном',
  'Дата сплати відсотків за розміщеними облігаціями',
  'Розмір купонного платежу на одну облігацію',
  'Номінальний рівень дохідності (%)',
  'Термін обігу (дн.)',
  'Дата погашення розміщених облігацій',
  'Обсяг поданих заявок (за номінальною вартістю)',
  'Обсяг задоволених заявок (за номінальною вартістю)',
  'Загальний обсяг випуску (за номінальною вартістю)',
  'Кількість виставлених заявок (шт.)',
  'Кількість задоволених заявок (шт.)',
  'Мінімальний рівень дохідності розміщених облігацій (%)',
  'Максимальний рівень дохідності розміщених облігацій (%)',
  'Граничний рівень дохідності розміщених облігацій (%)',
  'Середньозважений рівень дохідності розміщених облігацій (%)',
  'Вартість розміщених облігацій (грн.)',
  'Міжнародний ідентифікаційний номер цінного папера облігацій, що зараховуються емітенту',
  'Термін погашення облігацій, що зараховуються емітенту',
  'Кількість облігацій, що зараховуються емітенту (шт.)',
  'Вартість облігацій, що зараховуються емітенту (грн.)',
  'Різниця вартостей, яка виплачується емітенту (грн.)',
];

MinfinSwitchAuctionDetails _parseSwitchRows(
  List<List<String>> sourceRows,
  String auctionDate,
) {
  final rows = _rowMap(sourceRows);
  _requireExactLabels(rows, _switchLabels);
  for (final label in _switchLabels) {
    _requiredRow(rows, label, 1);
  }

  String one(String label) => _requiredRow(rows, label, 1).single;

  final exchangeDate = _isoDate(one('Дата обміну облігацій'));
  if (exchangeDate != auctionDate) {
    throw const FormatException('minfin.result_docx_layout_changed');
  }

  return MinfinSwitchAuctionDetails(
    auctionNumber: _positiveInt(one('Номер аукціону з обміну облігацій')),
    placedIsin: _isin(
      one(
        'Міжнародний ідентифікаційний номер цінного папера розміщених облігацій',
      ),
    ),
    nominalValue: _positiveDecimal(one('Номінальна вартість')),
    placementLimit: _positiveInt(
      one('Обмеження на обсяг розміщення облігацій (шт.)'),
    ),
    exchangeDate: exchangeDate,
    settlementDate: _isoDate(one('Дата розрахунків за аукціоном')),
    couponDates: _couponDates(
      one('Дата сплати відсотків за розміщеними облігаціями'),
    ),
    couponPayment: _positiveDecimal(
      one('Розмір купонного платежу на одну облігацію'),
    ),
    nominalYield: _yield(one('Номінальний рівень дохідності (%)')),
    termDays: _positiveInt(one('Термін обігу (дн.)')),
    placedMaturityDate: _isoDate(
      one('Дата погашення розміщених облігацій'),
    ),
    submittedNominalValue: _positiveDecimal(
      one('Обсяг поданих заявок (за номінальною вартістю)'),
    ),
    acceptedNominalValue: _positiveDecimal(
      one('Обсяг задоволених заявок (за номінальною вартістю)'),
    ),
    totalIssueNominalValue: _positiveDecimal(
      one('Загальний обсяг випуску (за номінальною вартістю)'),
    ),
    submittedBidCount: _positiveInt(
      one('Кількість виставлених заявок (шт.)'),
    ),
    acceptedBidCount: _positiveInt(
      one('Кількість задоволених заявок (шт.)'),
    ),
    minimumYield: _yield(
      one('Мінімальний рівень дохідності розміщених облігацій (%)'),
    ),
    maximumYield: _yield(
      one('Максимальний рівень дохідності розміщених облігацій (%)'),
    ),
    cutoffYield: _yield(
      one('Граничний рівень дохідності розміщених облігацій (%)'),
    ),
    weightedAverageYield: _yield(
      one('Середньозважений рівень дохідності розміщених облігацій (%)'),
    ),
    placedValueUah: _positiveDecimal(
      one('Вартість розміщених облігацій (грн.)'),
    ),
    returnedIsin: _isin(
      one(
        'Міжнародний ідентифікаційний номер цінного папера облігацій, що зараховуються емітенту',
      ),
    ),
    returnedMaturityDate: _isoDate(
      one('Термін погашення облігацій, що зараховуються емітенту'),
    ),
    returnedQuantity: _positiveInt(
      one('Кількість облігацій, що зараховуються емітенту (шт.)'),
    ),
    returnedValueUah: _positiveDecimal(
      one('Вартість облігацій, що зараховуються емітенту (грн.)'),
    ),
    cashDifferenceToIssuerUah: _nonNegativeDecimal(
      one('Різниця вартостей, яка виплачується емітенту (грн.)'),
    ),
  );
}
