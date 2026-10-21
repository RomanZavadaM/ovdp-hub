import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../data/source_observation.dart';
import '../../models.dart';

/// A published indication, not an executable order or a verified all-in cost.
@immutable
class PublicBondOffer {
  final String provider, sourceUrl, isin, currency, maturity;
  final Decimal? purchasePrice, salePrice, listedYield, saleYield;
  final String? yieldMethod;
  final int? availableUnits;
  final SourceObservationMeta meta;
  const PublicBondOffer({required this.provider, required this.sourceUrl,
    required this.isin, required this.currency, required this.maturity,
    required this.purchasePrice, required this.meta, this.salePrice,
    this.listedYield, this.saleYield, this.yieldMethod, this.availableUnits});
}

@immutable
class PublicOfferSource {
  final String provider, url;
  final List<PublicBondOffer> offers;
  final int rejectedRows;
  final String? errorCode;
  PublicOfferSource(this.provider, this.url, {Iterable<PublicBondOffer> offers = const [],
    this.rejectedRows = 0, this.errorCode}) : offers = List.unmodifiable(offers);
}

String _text(String value) => value.replaceAll(RegExp(r'<[^>]*>'), ' ')
  .replaceAll('&nbsp;', ' ').replaceAll('&#160;', ' ').replaceAll('\u00a0', ' ')
  .replaceAll('&amp;', '&').replaceAll(RegExp(r'\s+'), ' ').trim();
Decimal _amount(String value) {
  final cleaned = value.replaceAll(RegExp(r'[\s\u00a0]'), '').replaceAll(',', '.');
  if (!RegExp(r'^\d+(?:\.\d{1,8})?$').hasMatch(cleaned)) {
    throw const FormatException('seller.unknown_quote_format');
  }
  return Decimal.parse(cleaned);
}
Decimal _percent(String value) {
  final result = _amount(value.replaceAll('%', ''));
  if (result > Decimal.fromInt(100)) throw const FormatException('seller.unknown_quote_format');
  return result;
}
SourceObservationMeta _meta(String id, String url, DateTime now) => SourceObservationMeta(
  sourceId: id, sourceUrl: url, retrievedAt: now.toUtc().toIso8601String(),
  // Neither page supplies an explicit quote timestamp. Page CMS update time
  // and HTTP retrieval time are deliberately not promoted to a quote date.
  sourceDate: null, kind: ObservationKind.secondaryQuote,
  confidence: ObservationConfidence.publicIndicative);

PublicOfferSource parseUniverPublicOffers(String html, DateTime now) {
  const url = PublicOffersRepository.univerUrl;
  final chunks = html.split(RegExp(r'''<div\s+class=["']writem["'][^>]*>''')).skip(1);
  final offers = <PublicBondOffer>[];
  var rejected = 0;
  for (final chunk in chunks) {
    final end = chunk.indexOf('</a>');
    final row = end < 0 ? chunk : chunk.substring(0, end + 4);
    final fields = RegExp(r'<p\b[^>]*>(.*?)</p>', dotAll: true)
      .allMatches(row).map((m) => _text(m.group(1)!)).take(7).toList();
    // Product pages also contain non-bond sections. Only explicit ISIN rows
    // participate; the UI joins them to the official NBU instrument catalog.
    if (!fields.any((s) => RegExp(r'^UA[A-Z0-9]{10}$').hasMatch(s))) continue;
    try {
      if (fields.length != 6 || !const ['UAH', 'USD', 'EUR'].contains(fields[1]) ||
          !RegExp(r'^UA[A-Z0-9]{10}$').hasMatch(fields[2])) {
        throw const FormatException('seller.structure_changed');
      }
      isoDate(fields[4]);
      offers.add(PublicBondOffer(provider: 'UNIVER', sourceUrl: url,
        isin: fields[2], currency: fields[1], maturity: fields[4],
        purchasePrice: _amount(fields[3]), listedYield: _percent(fields[5]),
        meta: _meta('univer-public-products', url, now)));
    } on FormatException { rejected++; }
  }
  if (offers.isEmpty || rejected > offers.length ~/ 4) {
    throw const FormatException('seller.structure_changed');
  }
  return PublicOfferSource('UNIVER', url, offers: offers, rejectedRows: rejected);
}

PublicOfferSource parseInzhurPublicOffers(String html, DateTime now) {
  const url = PublicOffersRepository.inzhurUrl;
  // Read only the rendered public rows. Never evaluate embedded scripts or
  // fetch authenticated cabinet endpoints discovered in third-party code.
  final visible = html.replaceAll(RegExp(r'<script\b[^>]*>.*?</script>',
    dotAll: true, caseSensitive: false), '');
  final rows = RegExp(r'>\s*(UA[A-Z0-9]{10})\s*</span>(.*?)data-testid="bond-units-invest-button"',
    dotAll: true).allMatches(visible);
  final offers = <PublicBondOffer>[];
  final seen = <String>{};
  var rejected = 0;
  for (final row in rows) {
    try {
      final isin = row.group(1)!;
      final body = row.group(2)!;
      if (RegExp(r'UA[A-Z0-9]{10}').hasMatch(body)) {
        throw const FormatException('seller.structure_changed');
      }
      final maturity = RegExp(r'data-testid="bond-units-maturity-value"[^>]*>([^<]+)<').firstMatch(body);
      final yieldValue = RegExp(r'data-testid="bond-units-yield-value"[^>]*>([^<]+)<').firstMatch(body);
      final prices = RegExp(r'>([\d\s\u00a0]+,\d{2})\s*([₴$€])</span>')
        .allMatches(body).toList();
      if (maturity == null || prices.length != 2 || prices[0].group(2) != prices[1].group(2)) {
        throw const FormatException('seller.structure_changed');
      }
      final parts = _text(maturity.group(1)!).split('.');
      if (parts.length != 3) throw const FormatException('seller.structure_changed');
      final date = '${parts[2]}-${parts[1]}-${parts[0]}';
      isoDate(date);
      final quantity = RegExp(r'<span[^>]*>\s*([\d\s\u00a0]+)\s*</span>').allMatches(body).lastOrNull;
      final currency = switch (prices.first.group(2)) { '₴' => 'UAH', r'$' => 'USD', _ => 'EUR' };
      final buy = _amount(prices[0].group(1)!);
      final sell = _amount(prices[1].group(1)!);
      final key = '$isin|$currency|$buy|$sell';
      if (!seen.add(key)) continue;
      offers.add(PublicBondOffer(provider: 'Inzhur', sourceUrl: url, isin: isin,
        currency: currency, maturity: date, purchasePrice: buy, salePrice: sell,
        listedYield: yieldValue == null ? null : _percent(_text(yieldValue.group(1)!)),
        yieldMethod: body.contains('>YTM<') ? 'YTM' : null,
        availableUnits: quantity == null ? null : int.tryParse(quantity.group(1)!.replaceAll(RegExp(r'\s|\u00a0'), '')),
        meta: _meta('inzhur-public-ovdp', url, now)));
    } on FormatException { rejected++; }
  }
  if (offers.isEmpty || rejected > offers.length ~/ 4) {
    throw const FormatException('seller.structure_changed');
  }
  return PublicOfferSource('Inzhur', url, offers: offers, rejectedRows: rejected);
}

class PublicOffersRepository {
  static const inzhurUrl = 'https://www.inzhur.reit/offer/ovdp';
  static const univerUrl = 'https://www.univer.ua/products';
  final http.Client client;
  final DateTime Function() clock;
  PublicOffersRepository({http.Client? client, DateTime Function()? clock})
    : client = client ?? http.Client(), clock = clock ?? DateTime.now;
  Future<PublicOfferSource> _fetch(String provider, String url,
    PublicOfferSource Function(String, DateTime) parse) async {
    try {
      final response = await client.get(Uri.parse(url)).timeout(const Duration(seconds: 25));
      if (response.statusCode != 200 || response.bodyBytes.length > 4000000) {
        throw const FormatException('seller.structure_changed');
      }
      return parse(utf8.decode(response.bodyBytes), clock());
    } catch (_) {
      return PublicOfferSource(provider, url, errorCode: 'seller.structure_changed');
    }
  }
  Future<List<PublicOfferSource>> fetch() async => List.unmodifiable(await Future.wait([
    _fetch('Inzhur', inzhurUrl, parseInzhurPublicOffers),
    _fetch('UNIVER', univerUrl, parseUniverPublicOffers),
  ]));
  void dispose() => client.close();
}
