import 'package:flutter/foundation.dart';

import '../../models.dart';
import '../sellers/seller_repository.dart';
import 'minfin_repository.dart';

@immutable
class MarketIsinFacts {
  final Bond instrument;
  final MinfinAuctionRate? primaryAuction;
  final SellerQuote? secondaryQuote;

  const MarketIsinFacts({
    required this.instrument,
    this.primaryAuction,
    this.secondaryQuote,
  });

  factory MarketIsinFacts.join(
    Bond instrument, {
    MinfinSnapshot? minfin,
    SellerSnapshot? seller,
  }) {
    SellerQuote? quote;
    if (seller != null) {
      for (final item in seller.quotes) {
        if (item.isin == instrument.isin) {
          quote = item;
          break;
        }
      }
    }
    return MarketIsinFacts(
      instrument: instrument,
      primaryAuction: minfin?.forIsin(instrument.isin),
      secondaryQuote: quote,
    );
  }
}
