import 'package:flutter/foundation.dart';

@immutable
class EconomicFxQuote {
  final String currency;
  final String rate;
  final String sourceDate;
  final String sourceUrl;

  const EconomicFxQuote({
    required this.currency,
    required this.rate,
    required this.sourceDate,
    required this.sourceUrl,
  });
}

@immutable
class EconomicAuctionYield {
  final String minRate;
  final String maxRate;
  final String sourceDate;
  final String sourceUrl;

  const EconomicAuctionYield({
    required this.minRate,
    required this.maxRate,
    required this.sourceDate,
    required this.sourceUrl,
  });

  bool get isRange => minRate != maxRate;
}

@immutable
class EconomicNextAuction {
  final String date;
  final String sourceUrl;

  const EconomicNextAuction({
    required this.date,
    required this.sourceUrl,
  });
}

@immutable
class EconomicPulseSnapshot {
  final EconomicFxQuote? usd;
  final EconomicFxQuote? eur;
  final EconomicAuctionYield? uahAuctionYield;
  final EconomicNextAuction? nextAuction;
  final String retrievedAt;

  const EconomicPulseSnapshot({
    this.usd,
    this.eur,
    this.uahAuctionYield,
    this.nextAuction,
    required this.retrievedAt,
  });

  bool get hasAnyData =>
      usd != null ||
      eur != null ||
      uahAuctionYield != null ||
      nextAuction != null;
}
