import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../data/source_observation.dart';
import '../../models.dart';

@immutable
class MinfinAuctionRate {
  final String isin;
  final String termLabel;
  final String placementDate;
  final Decimal rate;

  const MinfinAuctionRate({
    required this.isin,
    required this.termLabel,
    required this.placementDate,
    required this.rate,
  });
}

enum MinfinAuctionEventKind { placement, switchAuction }

@immutable
class MinfinAuctionEvent {
  final String auctionDate;
  final MinfinAuctionEventKind kind;
  final String announcementUrl;
  final String? resultUrl;

  const MinfinAuctionEvent({
    required this.auctionDate,
    required this.kind,
    required this.announcementUrl,
    this.resultUrl,
  });
}

@immutable
class MinfinSnapshot {
  final SourceObservationMeta meta;
  final List<MinfinAuctionRate> rates;

  MinfinSnapshot(this.meta, Iterable<MinfinAuctionRate> rates)
      : rates = List.unmodifiable(rates);

  MinfinAuctionRate? forIsin(String isin) {
    for (final rate in rates) {
      if (rate.isin == isin) return rate;
    }
    return null;
  }
}

@immutable
class MinfinAuctionEventsSnapshot {
  final SourceObservationMeta meta;
  final List<MinfinAuctionEvent> events;

  MinfinAuctionEventsSnapshot(
    this.meta,
    Iterable<MinfinAuctionEvent> events,
  ) : events = List.unmodifiable(events);
}

String _plain(String html) => html
    .replaceAll(RegExp(r'<script\b[^>]*>.*?</script>', dotAll: true), ' ')
    .replaceAll(RegExp(r'<style\b[^>]*>.*?</style>', dotAll: true), ' ')
    .replaceAll(RegExp(r'<[^>]+>'), ' ')
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&#160;', ' ')
    .replaceAll('&amp;', '&')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

String _isoFromUaDate(String value) {
  final parts = value.split('.');
  if (parts.length != 3) {
    throw const FormatException('minfin.unknown_auction_date');
  }
  final result = '${parts[2]}-${parts[1]}-${parts[0]}';
  isoDate(result);
  return result;
}

const _uaMonths = <String, int>{
  'Січня': 1,
  'Лютого': 2,
  'Березня': 3,
  'Квітня': 4,
  'Травня': 5,
  'Червня': 6,
  'Липня': 7,
  'Серпня': 8,
  'Вересня': 9,
  'Жовтня': 10,
  'Листопада': 11,
  'Грудня': 12,
};

String _isoFromUaLongDate(String value) {
  final match = RegExp(
    r'^(\d{1,2})\s+([А-ЯІЇЄҐа-яіїєґ]+)\s+(\d{4})$',
  ).firstMatch(value.trim());
  if (match == null) {
    throw const FormatException('minfin.unknown_auction_date');
  }
  final month = _uaMonths[match.group(2)!];
  if (month == null) {
    throw const FormatException('minfin.unknown_auction_date');
  }
  final day = int.parse(match.group(1)!);
  final year = int.parse(match.group(3)!);
  final date = DateTime.utc(year, month, day);
  if (date.day != day || date.month != month || date.year != year) {
    throw const FormatException('minfin.unknown_auction_date');
  }
  return '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}

String _absoluteMinfinUrl(String href) {
  final uri = Uri.tryParse(href);
  if (uri == null) {
    throw const FormatException('minfin.invalid_source_url');
  }
  final absolute = Uri.parse(MinfinRepository.auctionEventsUrl).resolveUri(uri);
  if (absolute.scheme != 'https' || absolute.host != 'mof.gov.ua') {
    throw const FormatException('minfin.invalid_source_url');
  }
  return absolute.toString();
}

MinfinSnapshot parseMinfinAuctionRates(String html, DateTime retrievedAt) {
  const startMarker = 'Ставки ОВДП за результатами останніх аукціонів';
  const endMarker = 'ОЗДП в обігу';
  final start = html.indexOf(startMarker);
  final end = html.indexOf(endMarker, start < 0 ? 0 : start);
  if (start < 0 || end <= start) {
    throw const FormatException(
      'minfin.section_missing',
    );
  }

  final text = _plain(html.substring(start, end));
  final pattern = RegExp(
    r'(UA\d{10})\s+(.{1,40}?)\s+(\d{2}\.\d{2}\.\d{4})\s+(\d{1,3}(?:[\.,]\d{1,6})?)%',
  );
  final rows = <MinfinAuctionRate>[];
  final seen = <String>{};

  for (final match in pattern.allMatches(text)) {
    final isin = match.group(1)!;
    if (!seen.add(isin)) {
      throw const FormatException('minfin.duplicate_isin');
    }
    final placementDate = _isoFromUaDate(match.group(3)!);
    final rateText = match.group(4)!.replaceAll(',', '.');
    final rate = Decimal.parse(decimalText(rateText));
    if (rate <= Decimal.zero || rate >= Decimal.fromInt(100)) {
      throw const FormatException('minfin.invalid_rate');
    }
    rows.add(
      MinfinAuctionRate(
        isin: isin,
        termLabel: match.group(2)!.trim(),
        placementDate: placementDate,
        rate: rate,
      ),
    );
  }

  if (rows.isEmpty) {
    throw const FormatException('minfin.empty');
  }

  final latest = rows
      .map((e) => e.placementDate)
      .reduce((a, b) => a.compareTo(b) >= 0 ? a : b);

  return MinfinSnapshot(
    SourceObservationMeta(
      sourceId: 'minfin-debt-policy-auction-rates',
      sourceUrl: MinfinRepository.url,
      sourceDate: latest,
      retrievedAt: retrievedAt.toUtc().toIso8601String(),
      kind: ObservationKind.primaryAuction,
      confidence: ObservationConfidence.publicIndicative,
    ),
    rows,
  );
}

MinfinAuctionEventsSnapshot parseMinfinAuctionEvents(
  String html,
  DateTime retrievedAt,
) {
  if (!html.contains('Оголошення та результати аукціонів')) {
    throw const FormatException('minfin.events_section_missing');
  }

  final rowPattern = RegExp(r'<tr\b[^>]*>(.*?)</tr>', dotAll: true);
  final anchorPattern = RegExp(
    r'''<a\b[^>]*href=["']([^"']+)["'][^>]*>(.*?)</a>''',
    dotAll: true,
  );
  final datePattern = RegExp(
    r'\b\d{1,2}\s+[А-ЯІЇЄҐа-яіїєґ]+\s+\d{4}\b',
  );

  final events = <MinfinAuctionEvent>[];
  final seen = <String>{};

  for (final rowMatch in rowPattern.allMatches(html)) {
    final rowHtml = rowMatch.group(1)!;
    final rowText = _plain(rowHtml);
    final dateMatch = datePattern.firstMatch(rowText);
    if (dateMatch == null) continue;

    String? announcementUrl;
    String? resultUrl;
    String? announcementLabel;

    for (final anchor in anchorPattern.allMatches(rowHtml)) {
      final href = anchor.group(1)!;
      final label = _plain(anchor.group(2)!);
      if (label.startsWith('Оголошення про проведення')) {
        if (announcementUrl != null) {
          throw const FormatException('minfin.duplicate_announcement_link');
        }
        announcementUrl = _absoluteMinfinUrl(href);
        announcementLabel = label;
      } else if (label.startsWith('Результати проведення')) {
        if (resultUrl != null) {
          throw const FormatException('minfin.duplicate_result_link');
        }
        resultUrl = _absoluteMinfinUrl(href);
      }
    }

    if (announcementUrl == null || announcementLabel == null) continue;

    final kind = announcementLabel.contains('обміну державних облігацій')
        ? MinfinAuctionEventKind.switchAuction
        : announcementLabel.contains(
            'розміщення облігацій внутрішньої державної позики',
          )
        ? MinfinAuctionEventKind.placement
        : null;

    if (kind == null) {
      throw const FormatException('minfin.unknown_event_type');
    }

    final auctionDate = _isoFromUaLongDate(dateMatch.group(0)!);
    final key = '$auctionDate|${kind.name}|$announcementUrl';
    if (!seen.add(key)) {
      throw const FormatException('minfin.duplicate_event');
    }

    events.add(
      MinfinAuctionEvent(
        auctionDate: auctionDate,
        kind: kind,
        announcementUrl: announcementUrl,
        resultUrl: resultUrl,
      ),
    );
  }

  if (events.isEmpty) {
    throw const FormatException('minfin.events_empty');
  }

  events.sort((a, b) => b.auctionDate.compareTo(a.auctionDate));
  final latest = events.first.auctionDate;

  return MinfinAuctionEventsSnapshot(
    SourceObservationMeta(
      sourceId: 'minfin-auction-events',
      sourceUrl: MinfinRepository.auctionEventsUrl,
      sourceDate: latest,
      retrievedAt: retrievedAt.toUtc().toIso8601String(),
      kind: ObservationKind.primaryAuction,
      confidence: ObservationConfidence.publicIndicative,
    ),
    events,
  );
}

class MinfinRepository {
  static const url = 'https://mof.gov.ua/uk/borgova-politika';
  static const auctionEventsUrl =
      'https://mof.gov.ua/uk/ogoloshennja-ta-rezultati-aukcioniv';

  final http.Client client;
  final DateTime Function() clock;

  MinfinRepository({http.Client? client, DateTime Function()? clock})
      : client = client ?? http.Client(),
        clock = clock ?? DateTime.now;

  Future<String> _fetchPage(String sourceUrl) async {
    final response = await client
        .get(Uri.parse(sourceUrl))
        .timeout(const Duration(seconds: 25));
    if (response.statusCode != 200) {
      throw FormatException('minfin.http_status', {'status': response.statusCode});
    }
    if (response.bodyBytes.length > 4 * 1024 * 1024) {
      throw const FormatException('minfin.page_too_large');
    }
    return utf8.decode(response.bodyBytes);
  }

  Future<MinfinSnapshot> fetch() async {
    return parseMinfinAuctionRates(
      await _fetchPage(url),
      clock(),
    );
  }

  Future<MinfinAuctionEventsSnapshot> fetchAuctionEvents() async {
    return parseMinfinAuctionEvents(
      await _fetchPage(auctionEventsUrl),
      clock(),
    );
  }

  void dispose() => client.close();
}
