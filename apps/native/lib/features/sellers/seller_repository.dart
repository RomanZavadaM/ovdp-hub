import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../pricing.dart';
import '../../models.dart';
import '../../data/source_observation.dart';

@immutable
class SellerQuote {
  final String isin, maturity, currency, method;
  final String? bidYield, askYield;
  const SellerQuote(
    this.isin,
    this.maturity,
    this.currency,
    this.method,
    this.bidYield,
    this.askYield,
  );
}

@immutable
class SellerSnapshot {
  final SourceObservationMeta meta;
  final List<SellerQuote> quotes;
  SellerSnapshot(this.meta, Iterable<SellerQuote> quotes)
    : quotes = List.unmodifiable(quotes);

  String get sourceDate => meta.sourceDate!;
  String get retrievedAt => meta.retrievedAt;
}

String _plain(String s) => s
    .replaceAll(RegExp(r'<[^>]*>'), '')
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&#160;', ' ')
    .trim();
String _date(String s) {
  final parts = s.split('.');
  if (parts.length != 3) throw const FormatException('Невідома дата джерела');
  final date = '${parts[2]}-${parts[1]}-${parts[0]}';
  isoDate(date);
  return date;
}

String? _yield(String s) {
  if (s == '-' || s.isEmpty) return null;
  final v = s.replaceAll(',', '.');
  money(v);
  if (double.parse(v) > 100) {
    throw const FormatException('Невідомий формат котирування');
  }
  return v;
}

SellerSnapshot parsePrivatQuotes(String html, DateTime now) {
  final dateMatch = RegExp(
    r'''id=["']actual-date["'][^>]*>([^<]+)<''',
  ).firstMatch(html);
  if (dateMatch == null) {
    throw const FormatException(
      'Дату котирувань не знайдено. Формат сайту міг змінитися.',
    );
  }
  final sourceDate = _date(dateMatch.group(1)!.trim());
  final end = html.indexOf('</article>', dateMatch.end);
  if (end < 0) throw const FormatException('Неповна таблиця продавця');
  final section = html.substring(dateMatch.end, end);
  final currencies = RegExp(
    r'''class=["']tab-table[^"']*["'][^>]*>\s*<span>(USD|EUR|UAH)</span>''',
  ).allMatches(section).map((m) => m.group(1)!).toList();
  final tables = RegExp(
    r'<table\b[^>]*>(.*?)</table>',
    dotAll: true,
  ).allMatches(section).toList();
  if (currencies.length != 3 ||
      tables.length != 3 ||
      currencies.toSet().length != 3) {
    throw const FormatException(
      'Структура валют або таблиць змінилася; дані не завантажено',
    );
  }
  final quotes = <SellerQuote>[];
  final seen = <String>{};
  for (var i = 0; i < tables.length; i++) {
    final table = tables[i].group(1)!;
    final headers = RegExp(
      r'<th\b[^>]*>(.*?)</th>',
      dotAll: true,
    ).allMatches(table).map((m) => _plain(m.group(1)!)).toList();
    if (headers.length != 5 ||
        !headers[0].contains('ISIN') ||
        !headers[1].contains('Maturity') ||
        !headers[2].contains('BID Yield') ||
        !headers[3].contains('ASK Yield') ||
        headers[4] != 'Yield') {
      throw const FormatException(
        'Колонки продавця змінилися; потрібне оновлення адаптера',
      );
    }
    for (final row in RegExp(
      r'<tr\b[^>]*>(.*?)</tr>',
      dotAll: true,
    ).allMatches(table)) {
      final cells = RegExp(
        r'<td\b[^>]*>(.*?)</td>',
        dotAll: true,
      ).allMatches(row.group(1)!).map((m) => _plain(m.group(1)!)).toList();
      if (cells.isEmpty) continue;
      if (cells.length != 5 ||
          !RegExp(r'^UA\d{10}$').hasMatch(cells[0]) ||
          !['SIM', 'YTM'].contains(cells[4]) ||
          !seen.add(cells[0])) {
        throw const FormatException('Невідомий або повторний рядок котирувань');
      }
      quotes.add(
        SellerQuote(
          cells[0],
          _date(cells[1]),
          currencies[i],
          cells[4],
          _yield(cells[2]),
          _yield(cells[3]),
        ),
      );
    }
  }
  if (quotes.isEmpty) {
    throw const FormatException('Продавець не повернув котирувань');
  }
  return SellerSnapshot(
    SourceObservationMeta(
      sourceId: 'privatbank-public-ovdp',
      sourceUrl: SellerRepository.url,
      sourceDate: sourceDate,
      retrievedAt: now.toUtc().toIso8601String(),
      kind: ObservationKind.secondaryQuote,
      confidence: ObservationConfidence.publicIndicative,
    ),
    quotes,
  );
}

class SellerRepository {
  static const url = 'https://privatbank.ua/ovdp';
  final http.Client client;
  final DateTime Function() clock;
  SellerRepository({http.Client? client, DateTime Function()? clock})
    : client = client ?? http.Client(),
      clock = clock ?? DateTime.now;
  Future<SellerSnapshot> fetch() async {
    final response = await client
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 25));
    if (response.statusCode != 200) {
      throw StateError('Продавець відповів HTTP ${response.statusCode}');
    }
    if (response.bodyBytes.length > 4000000) {
      throw const FormatException('Неочікуваний розмір сторінки');
    }
    return parsePrivatQuotes(utf8.decode(response.bodyBytes), clock());
  }

  void dispose() => client.close();
}
