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
    throw const FormatException('Невідома дата аукціону Мінфіну');
  }
  final result = '${parts[2]}-${parts[1]}-${parts[0]}';
  isoDate(result);
  return result;
}

MinfinSnapshot parseMinfinAuctionRates(String html, DateTime retrievedAt) {
  const startMarker = 'Ставки ОВДП за результатами останніх аукціонів';
  const endMarker = 'ОЗДП в обігу';
  final start = html.indexOf(startMarker);
  final end = html.indexOf(endMarker, start < 0 ? 0 : start);
  if (start < 0 || end <= start) {
    throw const FormatException(
      'Таблицю останніх ставок Мінфіну не знайдено. Формат сторінки міг змінитися.',
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
      throw const FormatException('Повторний ISIN у таблиці Мінфіну');
    }
    final placementDate = _isoFromUaDate(match.group(3)!);
    final rateText = match.group(4)!.replaceAll(',', '.');
    final rate = Decimal.parse(decimalText(rateText));
    if (rate <= Decimal.zero || rate >= Decimal.fromInt(100)) {
      throw const FormatException('Некоректна ставка аукціону Мінфіну');
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
    throw const FormatException('Мінфін не повернув розпізнаних ставок ОВДП');
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

class MinfinRepository {
  static const url = 'https://mof.gov.ua/uk/borgova-politika';

  final http.Client client;
  final DateTime Function() clock;

  MinfinRepository({http.Client? client, DateTime Function()? clock})
      : client = client ?? http.Client(),
        clock = clock ?? DateTime.now;

  Future<MinfinSnapshot> fetch() async {
    final response = await client
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 25));
    if (response.statusCode != 200) {
      throw StateError('Мінфін відповів HTTP ${response.statusCode}');
    }
    if (response.bodyBytes.length > 4 * 1024 * 1024) {
      throw const FormatException('Неочікуваний розмір сторінки Мінфіну');
    }
    return parseMinfinAuctionRates(
      utf8.decode(response.bodyBytes),
      clock(),
    );
  }

  void dispose() => client.close();
}
