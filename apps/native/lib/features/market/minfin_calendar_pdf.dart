import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pdf_document/pdf_document.dart';
import 'package:pdf_graphics/pdf_graphics.dart';

import '../../data/source_observation.dart';
import 'minfin_repository.dart';

@immutable
class MinfinPdfTextRun {
  final int page;
  final double left;
  final double bottom;
  final double right;
  final double top;
  final String text;

  const MinfinPdfTextRun({
    required this.page,
    required this.left,
    required this.bottom,
    required this.right,
    required this.top,
    required this.text,
  });

  double get centerX => (left + right) / 2;
}

sealed class MinfinCalendarScheduleEntry {
  final String auctionDate;

  const MinfinCalendarScheduleEntry(this.auctionDate);
}

@immutable
class MinfinMonthlyPlacementOffering {
  final String maturityDate;
  final String? isin;
  final bool isPrimaryPlacement;
  final String? explicitCurrencyCode;

  const MinfinMonthlyPlacementOffering({
    required this.maturityDate,
    required this.isin,
    required this.isPrimaryPlacement,
    required this.explicitCurrencyCode,
  });
}

@immutable
class MinfinMonthlyPlacementScheduleEntry
    extends MinfinCalendarScheduleEntry {
  final List<MinfinMonthlyPlacementOffering> offerings;

  MinfinMonthlyPlacementScheduleEntry(
    super.auctionDate,
    Iterable<MinfinMonthlyPlacementOffering> offerings,
  ) : offerings = List.unmodifiable(offerings);
}

@immutable
class MinfinQuarterlyTenorPlan {
  final String currencyCode;
  final String sourceCurrencyLabel;
  final List<String> tenorLabels;

  MinfinQuarterlyTenorPlan({
    required this.currencyCode,
    required this.sourceCurrencyLabel,
    required Iterable<String> tenorLabels,
  }) : tenorLabels = List.unmodifiable(tenorLabels);
}

@immutable
class MinfinQuarterlyPlacementScheduleEntry
    extends MinfinCalendarScheduleEntry {
  final List<MinfinQuarterlyTenorPlan> plans;

  MinfinQuarterlyPlacementScheduleEntry(
    super.auctionDate,
    Iterable<MinfinQuarterlyTenorPlan> plans,
  ) : plans = List.unmodifiable(plans);
}

@immutable
class MinfinSwitchLeg {
  final String maturityDate;
  final String? isin;
  final bool isPrimaryPlacement;

  const MinfinSwitchLeg({
    required this.maturityDate,
    required this.isin,
    required this.isPrimaryPlacement,
  });
}

@immutable
class MinfinSwitchScheduleEntry extends MinfinCalendarScheduleEntry {
  final MinfinSwitchLeg offeredForExchange;
  final MinfinSwitchLeg placed;

  const MinfinSwitchScheduleEntry(
    super.auctionDate, {
    required this.offeredForExchange,
    required this.placed,
  });
}

@immutable
class MinfinCalendarScheduleSnapshot {
  final SourceObservationMeta meta;
  final MinfinCalendarDocumentKind documentKind;
  final List<MinfinCalendarScheduleEntry> entries;

  MinfinCalendarScheduleSnapshot({
    required this.meta,
    required this.documentKind,
    required Iterable<MinfinCalendarScheduleEntry> entries,
  }) : entries = List.unmodifiable(entries);
}

List<MinfinPdfTextRun> extractMinfinPdfTextRuns(Uint8List bytes) {
  if (bytes.length < 5 ||
      String.fromCharCodes(bytes.take(5).toList()) != '%PDF-') {
    throw const FormatException('minfin.calendar_pdf_invalid');
  }

  try {
    final document = PdfDocument.open(bytes);
    final runs = <MinfinPdfTextRun>[];
    for (var page = 0; page < document.pageCount; page++) {
      final extracted = PdfTextExtractor.extract(document, page);
      for (final run in extracted.runs) {
        if (run.text.trim().isEmpty) continue;
        final bounds = run.bounds;
        runs.add(
          MinfinPdfTextRun(
            page: page,
            left: bounds.left,
            bottom: bounds.bottom,
            right: bounds.right,
            top: bounds.top,
            text: run.text,
          ),
        );
      }
    }
    if (runs.isEmpty) {
      throw const FormatException('minfin.calendar_pdf_layout_changed');
    }
    return List.unmodifiable(runs);
  } on FormatException {
    rethrow;
  } catch (_) {
    throw const FormatException('minfin.calendar_pdf_invalid');
  }
}

MinfinCalendarScheduleSnapshot parseMinfinCalendarScheduleRuns({
  required MinfinCalendarDocument document,
  required List<MinfinPdfTextRun> runs,
  required DateTime retrievedAt,
}) {
  if (!_isOfficialCalendarPdfUrl(document.documentUrl)) {
    throw const FormatException('minfin.invalid_source_url');
  }
  if (runs.isEmpty || runs.any((run) => run.page != 0)) {
    throw const FormatException('minfin.calendar_pdf_layout_changed');
  }

  final lines = _groupLines(runs);
  if (lines.isEmpty) {
    throw const FormatException('minfin.calendar_pdf_layout_changed');
  }
  final year = _documentYear(lines);

  final entries = switch (document.kind) {
    MinfinCalendarDocumentKind.monthlyPlacement =>
      _parseMonthlyPlacement(lines, year),
    MinfinCalendarDocumentKind.quarterlyPlacement =>
      _parseQuarterlyPlacement(lines, year),
    MinfinCalendarDocumentKind.monthlySwitch =>
      _parseSwitch(lines, year),
  };

  if (entries.isEmpty) {
    throw const FormatException('minfin.calendar_pdf_layout_changed');
  }

  return MinfinCalendarScheduleSnapshot(
    meta: SourceObservationMeta(
      sourceId: 'minfin-auction-calendar-pdf',
      sourceUrl: document.documentUrl,
      sourceDate: document.publishedDate,
      retrievedAt: retrievedAt.toUtc().toIso8601String(),
      kind: ObservationKind.primaryAuction,
      confidence: ObservationConfidence.officialPublished,
    ),
    documentKind: document.kind,
    entries: entries,
  );
}

MinfinCalendarScheduleSnapshot parseMinfinCalendarSchedulePdf({
  required MinfinCalendarDocument document,
  required Uint8List bytes,
  required DateTime retrievedAt,
}) {
  return parseMinfinCalendarScheduleRuns(
    document: document,
    runs: extractMinfinPdfTextRuns(bytes),
    retrievedAt: retrievedAt,
  );
}

class MinfinCalendarPdfRepository {
  static const maxPdfBytes = 8 * 1024 * 1024;

  final http.Client client;
  final DateTime Function() clock;

  MinfinCalendarPdfRepository({
    http.Client? client,
    DateTime Function()? clock,
  }) : client = client ?? http.Client(),
       clock = clock ?? DateTime.now;

  Future<MinfinCalendarScheduleSnapshot> fetch(
    MinfinCalendarDocument document,
  ) async {
    if (!_isOfficialCalendarPdfUrl(document.documentUrl)) {
      throw const FormatException('minfin.invalid_source_url');
    }

    final response = await client
        .get(Uri.parse(document.documentUrl))
        .timeout(const Duration(seconds: 25));
    if (response.statusCode != 200) {
      throw FormatException('minfin.calendar_pdf_http_status', {
        'status': response.statusCode,
      });
    }
    if (response.bodyBytes.length > maxPdfBytes) {
      throw const FormatException('minfin.calendar_pdf_too_large');
    }

    return parseMinfinCalendarSchedulePdf(
      document: document,
      bytes: Uint8List.fromList(response.bodyBytes),
      retrievedAt: clock(),
    );
  }

  void dispose() => client.close();
}

bool _isOfficialCalendarPdfUrl(String value) {
  final uri = Uri.tryParse(value);
  return uri != null &&
      uri.scheme == 'https' &&
      uri.host == 'mof.gov.ua' &&
      uri.path.startsWith('/storage/files/') &&
      uri.path.toLowerCase().endsWith('.pdf');
}

class _Line {
  final double y;
  final List<MinfinPdfTextRun> runs;

  const _Line(this.y, this.runs);

  String get compact => _compact(runs.map((run) => run.text).join());
}

class _Cluster {
  final double left;
  final double right;
  final String text;

  const _Cluster({
    required this.left,
    required this.right,
    required this.text,
  });

  double get center => (left + right) / 2;
}

List<_Line> _groupLines(List<MinfinPdfTextRun> runs) {
  final sorted = [...runs]..sort((a, b) {
    final y = b.bottom.compareTo(a.bottom);
    return y != 0 ? y : a.left.compareTo(b.left);
  });
  final lines = <_Line>[];

  for (final run in sorted) {
    final index = lines.indexWhere((line) => (line.y - run.bottom).abs() <= 0.35);
    if (index < 0) {
      lines.add(_Line(run.bottom, [run]));
    } else {
      lines[index].runs.add(run);
    }
  }

  for (final line in lines) {
    line.runs.sort((a, b) => a.left.compareTo(b.left));
  }
  lines.sort((a, b) => b.y.compareTo(a.y));
  return lines;
}

List<_Cluster> _clusters(_Line line, {double minGap = 25}) {
  if (line.runs.isEmpty) return const [];
  final clusters = <_Cluster>[];
  var current = <MinfinPdfTextRun>[line.runs.first];

  void flush() {
    final text = _compact(current.map((run) => run.text).join());
    if (text.isNotEmpty) {
      clusters.add(
        _Cluster(
          left: current.first.left,
          right: current.last.right,
          text: text,
        ),
      );
    }
  }

  for (final run in line.runs.skip(1)) {
    if (run.left - current.last.right > minGap) {
      flush();
      current = [run];
    } else {
      current.add(run);
    }
  }
  flush();
  return clusters;
}

String _compact(String value) => value.replaceAll(RegExp(r'\s+'), '').trim();

int _documentYear(List<_Line> lines) {
  final top = lines.take(12).map((line) => line.compact).join();
  final match = RegExp(r'20\d{2}').firstMatch(top);
  if (match == null) {
    throw const FormatException('minfin.calendar_pdf_layout_changed');
  }
  return int.parse(match.group(0)!);
}

final _months = <String, int>{
  'січень': 1,
  'січня': 1,
  'лютий': 2,
  'лютого': 2,
  'березень': 3,
  'березня': 3,
  'квітень': 4,
  'квітня': 4,
  'травень': 5,
  'травня': 5,
  'червень': 6,
  'червня': 6,
  'липень': 7,
  'липня': 7,
  'серпень': 8,
  'серпня': 8,
  'вересень': 9,
  'вересня': 9,
  'жовтень': 10,
  'жовтня': 10,
  'листопад': 11,
  'листопада': 11,
  'грудень': 12,
  'грудня': 12,
};

String? _headerDate(String compact, int year) {
  final normalized = compact.toLowerCase();
  final dayFirst = RegExp(
    r'^(\d{1,2})([а-яіїєґ]+)$',
  ).firstMatch(normalized);
  final monthFirst = RegExp(
    r'^([а-яіїєґ]+)(\d{1,2})$',
  ).firstMatch(normalized);

  int? day;
  int? month;
  if (dayFirst != null) {
    day = int.tryParse(dayFirst.group(1)!);
    month = _months[dayFirst.group(2)!];
  } else if (monthFirst != null) {
    month = _months[monthFirst.group(1)!];
    day = int.tryParse(monthFirst.group(2)!);
  }
  if (day == null || month == null) return null;

  final date = DateTime.utc(year, month, day);
  if (date.year != year || date.month != month || date.day != day) {
    throw const FormatException('minfin.calendar_pdf_layout_changed');
  }
  return _iso(date);
}

String _iso(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

String _isoSlashDate(String compact) {
  final match = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(compact);
  if (match == null) {
    throw const FormatException('minfin.calendar_pdf_layout_changed');
  }
  final day = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final year = int.parse(match.group(3)!);
  final date = DateTime.utc(year, month, day);
  if (date.year != year || date.month != month || date.day != day) {
    throw const FormatException('minfin.calendar_pdf_layout_changed');
  }
  return _iso(date);
}

List<_Cluster> _dateClusters(_Line line, int year) {
  return _clusters(line)
      .where((cluster) => _headerDate(cluster.text, year) != null)
      .toList();
}

double _footnoteY(List<_Line> lines) {
  final footnote = lines.where(
    (line) => line.compact.toLowerCase().contains('зарезультатамиоцінкипопиту'),
  );
  return footnote.isEmpty ? 0 : footnote.first.y;
}

List<String> _cellLines({
  required List<_Line> lines,
  required double topY,
  required double bottomY,
  required double left,
  required double right,
}) {
  final values = <String>[];
  for (final line in lines) {
    if (line.y >= topY || line.y <= bottomY) continue;
    final selected = line.runs
        .where((run) => run.centerX >= left && run.centerX < right)
        .toList()
      ..sort((a, b) => a.left.compareTo(b.left));
    if (selected.isEmpty) continue;
    final text = _compact(selected.map((run) => run.text).join());
    if (text.isNotEmpty) values.add(text);
  }
  return values;
}

List<MinfinCalendarScheduleEntry> _parseMonthlyPlacement(
  List<_Line> lines,
  int year,
) {
  final headerCandidates = lines
      .where((line) => _dateClusters(line, year).length >= 2)
      .toList();
  if (headerCandidates.length != 1) {
    throw const FormatException('minfin.calendar_pdf_layout_changed');
  }
  final header = headerCandidates.single;
  final dateClusters = _dateClusters(header, year);
  final footnoteY = _footnoteY(lines);
  if (footnoteY >= header.y) {
    throw const FormatException('minfin.calendar_pdf_layout_changed');
  }

  final entries = <MinfinCalendarScheduleEntry>[];
  for (var index = 0; index < dateClusters.length; index++) {
    final cluster = dateClusters[index];
    final left = index == 0
        ? double.negativeInfinity
        : (dateClusters[index - 1].center + cluster.center) / 2;
    final right = index == dateClusters.length - 1
        ? double.infinity
        : (cluster.center + dateClusters[index + 1].center) / 2;
    final texts = _cellLines(
      lines: lines,
      topY: header.y,
      bottomY: footnoteY,
      left: left,
      right: right,
    );

    final offerings = _parseMonthlyOfferings(texts);
    if (offerings.isNotEmpty) {
      entries.add(
        MinfinMonthlyPlacementScheduleEntry(
          _headerDate(cluster.text, year)!,
          offerings,
        ),
      );
    }
  }
  return entries;
}

List<MinfinMonthlyPlacementOffering> _parseMonthlyOfferings(
  List<String> texts,
) {
  final offerings = <MinfinMonthlyPlacementOffering>[];
  String? currency;
  String? maturity;

  for (final text in texts) {
    final compact = _compact(text);
    if (compact == '-') {
      if (maturity != null || currency != null) {
        throw const FormatException('minfin.calendar_pdf_layout_changed');
      }
      continue;
    }
    if (compact == 'EUR' || compact == 'USD') {
      if (maturity != null || currency != null) {
        throw const FormatException('minfin.calendar_pdf_layout_changed');
      }
      currency = compact;
      continue;
    }
    if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(compact)) {
      if (maturity != null) {
        throw const FormatException('minfin.calendar_pdf_layout_changed');
      }
      maturity = _isoSlashDate(compact);
      continue;
    }

    final isIsin = RegExp(r'^UA\d{10}$').hasMatch(compact);
    final isPrimary = compact.toLowerCase() == 'первиннерозміщення';
    if (!isIsin && !isPrimary) {
      throw const FormatException('minfin.calendar_pdf_layout_changed');
    }
    if (maturity == null) {
      throw const FormatException('minfin.calendar_pdf_layout_changed');
    }

    offerings.add(
      MinfinMonthlyPlacementOffering(
        maturityDate: maturity,
        isin: isIsin ? compact : null,
        isPrimaryPlacement: isPrimary,
        explicitCurrencyCode: currency,
      ),
    );
    maturity = null;
    currency = null;
  }

  if (maturity != null || currency != null) {
    throw const FormatException('minfin.calendar_pdf_layout_changed');
  }
  return offerings;
}

List<MinfinCalendarScheduleEntry> _parseQuarterlyPlacement(
  List<_Line> lines,
  int year,
) {
  final headers = lines
      .where((line) => _dateClusters(line, year).length >= 3)
      .toList()
    ..sort((a, b) => b.y.compareTo(a.y));
  if (headers.length < 2) {
    throw const FormatException('minfin.calendar_pdf_layout_changed');
  }

  final footnoteY = _footnoteY(lines);
  final entries = <MinfinCalendarScheduleEntry>[];
  for (var row = 0; row < headers.length; row++) {
    final header = headers[row];
    final slots = _clusters(header);
    final bottomY = row + 1 < headers.length ? headers[row + 1].y : footnoteY;

    for (var slotIndex = 0; slotIndex < slots.length; slotIndex++) {
      final cluster = slots[slotIndex];
      final auctionDate = _headerDate(cluster.text, year);
      if (auctionDate == null) continue;

      final left = slotIndex == 0
          ? double.negativeInfinity
          : (slots[slotIndex - 1].center + cluster.center) / 2;
      final right = slotIndex == slots.length - 1
          ? double.infinity
          : (cluster.center + slots[slotIndex + 1].center) / 2;
      final texts = _cellLines(
        lines: lines,
        topY: header.y,
        bottomY: bottomY,
        left: left,
        right: right,
      );
      final plans = _parseQuarterlyPlans(texts);
      if (plans.isNotEmpty) {
        entries.add(
          MinfinQuarterlyPlacementScheduleEntry(
            auctionDate,
            plans,
          ),
        );
      }
    }
  }
  return entries;
}

List<MinfinQuarterlyTenorPlan> _parseQuarterlyPlans(List<String> texts) {
  final compact = texts.map(_compact).join();
  if (compact.isEmpty || compact == '-') return const [];

  final marker = RegExp(r'(Гривня|ЄВРО):');
  final matches = marker.allMatches(compact).toList();
  if (matches.isEmpty) {
    throw const FormatException('minfin.calendar_pdf_layout_changed');
  }

  final plans = <MinfinQuarterlyTenorPlan>[];
  for (var index = 0; index < matches.length; index++) {
    final match = matches[index];
    final label = match.group(1)!;
    final start = match.end;
    final end = index + 1 < matches.length ? matches[index + 1].start : compact.length;
    final source = compact.substring(start, end);
    final tenorMatches = RegExp(
      r'(\d+(?:,\d+)?)(рік|роки|року)',
    ).allMatches(source).toList();
    if (tenorMatches.isEmpty) {
      throw const FormatException('minfin.calendar_pdf_layout_changed');
    }
    final remainder = source
        .replaceAll(RegExp(r'\d+(?:,\d+)?(?:рік|роки|року)'), '')
        .replaceAll(';', '');
    if (remainder.isNotEmpty) {
      throw const FormatException('minfin.calendar_pdf_layout_changed');
    }

    plans.add(
      MinfinQuarterlyTenorPlan(
        currencyCode: label == 'Гривня' ? 'UAH' : 'EUR',
        sourceCurrencyLabel: label,
        tenorLabels: tenorMatches
            .map((tenor) => '${tenor.group(1)} ${tenor.group(2)}')
            .toList(),
      ),
    );
  }
  return plans;
}

List<MinfinCalendarScheduleEntry> _parseSwitch(
  List<_Line> lines,
  int year,
) {
  final offeredIndex = lines.indexWhere(
    (line) => line.compact.toLowerCase().contains('пропонуютьсядообміну'),
  );
  final placedIndex = lines.indexWhere(
    (line) => line.compact.toLowerCase().contains('розміщуються'),
  );
  if (offeredIndex < 0 || placedIndex < 0 || offeredIndex >= placedIndex) {
    throw const FormatException('minfin.calendar_pdf_layout_changed');
  }

  final headerCandidates = lines
      .take(offeredIndex)
      .where((line) => _dateClusters(line, year).length == 1)
      .toList();
  if (headerCandidates.length != 1) {
    throw const FormatException('minfin.calendar_pdf_layout_changed');
  }
  final dateCluster = _dateClusters(headerCandidates.single, year).single;

  final offeredTexts = lines
      .sublist(offeredIndex + 1, placedIndex)
      .map((line) => line.compact)
      .where((text) => text.isNotEmpty)
      .toList();
  final footnoteIndex = lines.indexWhere(
    (line) => line.compact.toLowerCase().contains('зарезультатамиоцінкипопиту'),
  );
  final placedEnd = footnoteIndex > placedIndex ? footnoteIndex : lines.length;
  final placedTexts = lines
      .sublist(placedIndex + 1, placedEnd)
      .map((line) => line.compact)
      .where((text) => text.isNotEmpty)
      .toList();

  return [
    MinfinSwitchScheduleEntry(
      _headerDate(dateCluster.text, year)!,
      offeredForExchange: _parseSwitchLeg(
        offeredTexts,
        allowPrimaryPlacement: false,
      ),
      placed: _parseSwitchLeg(
        placedTexts,
        allowPrimaryPlacement: true,
      ),
    ),
  ];
}

MinfinSwitchLeg _parseSwitchLeg(
  List<String> texts, {
  required bool allowPrimaryPlacement,
}) {
  String? maturity;
  String? isin;
  var primary = false;

  for (final text in texts) {
    final compact = _compact(text);
    if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(compact)) {
      if (maturity != null) {
        throw const FormatException('minfin.calendar_pdf_layout_changed');
      }
      maturity = _isoSlashDate(compact);
    } else if (RegExp(r'^UA\d{10}$').hasMatch(compact)) {
      if (isin != null || primary) {
        throw const FormatException('minfin.calendar_pdf_layout_changed');
      }
      isin = compact;
    } else if (compact.toLowerCase() == 'первиннерозміщення') {
      if (!allowPrimaryPlacement || isin != null || primary) {
        throw const FormatException('minfin.calendar_pdf_layout_changed');
      }
      primary = true;
    } else {
      throw const FormatException('minfin.calendar_pdf_layout_changed');
    }
  }

  if (maturity == null || (isin == null && !primary)) {
    throw const FormatException('minfin.calendar_pdf_layout_changed');
  }
  return MinfinSwitchLeg(
    maturityDate: maturity,
    isin: isin,
    isPrimaryPlacement: primary,
  );
}
