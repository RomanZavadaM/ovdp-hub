import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/data/source_observation.dart';
import 'package:ovdp_hub/features/market/market_isin.dart';
import 'package:ovdp_hub/features/market/minfin_repository.dart';
import 'package:ovdp_hub/features/sellers/seller_repository.dart';

import 'planner_test.dart' as fixture;

void main() {
  const html = '''
    <html><body>
    <h3>Ставки ОВДП за результатами останніх аукціонів</h3>
    <table>
      <tr><td>₴</td></tr>
      <tr><td>UA4000239115</td><td>1 рік</td><td>15.09.2026</td><td>15,17%</td></tr>
      <tr><td>UA4000239008</td><td>2 роки</td><td>25.08.2026</td><td>15,63%</td></tr>
    </table>
    <h3>ОЗДП в обігу</h3>
    </body></html>
  ''';

  test('MinFin latest auction table is parsed as primary-market observations', () {
    final snapshot = parseMinfinAuctionRates(
      html,
      DateTime.utc(2026, 9, 22, 12),
    );
    expect(snapshot.meta.kind, ObservationKind.primaryAuction);
    expect(snapshot.meta.sourceDate, '2026-09-15');
    expect(snapshot.rates.length, 2);
    expect(snapshot.rates.first.isin, 'UA4000239115');
    expect(snapshot.rates.first.rate, Decimal.parse('15.17'));
  });

  test('MinFin parser fails closed on duplicate ISIN or missing section', () {
    expect(
      () => parseMinfinAuctionRates(
        html.replaceFirst(
          '</table>',
          '<tr><td>UA4000239115</td><td>1 рік</td><td>15.09.2026</td><td>15,17%</td></tr></table>',
        ),
        DateTime.utc(2026, 9, 22),
      ),
      throwsFormatException,
    );
    expect(
      () => parseMinfinAuctionRates(
        '<html>no market table</html>',
        DateTime.utc(2026, 9, 22),
      ),
      throwsFormatException,
    );
  });

  test('ISIN join keeps NBU, primary and seller layers separate', () {
    final bond = fixture.bond('UA4000239115', '2027-09-15');
    final primary = parseMinfinAuctionRates(
      html,
      DateTime.utc(2026, 9, 22),
    );
    final seller = SellerSnapshot(
      SourceObservationMeta(
        sourceId: 'seller',
        sourceUrl: 'https://example.test',
        sourceDate: '2026-09-22',
        retrievedAt: '2026-09-22T12:00:00Z',
        kind: ObservationKind.secondaryQuote,
        confidence: ObservationConfidence.publicIndicative,
      ),
      const [
        SellerQuote(
          'UA4000239115',
          '2027-09-15',
          'UAH',
          'YTM',
          '14.50',
          '15.00',
        ),
      ],
    );

    final facts = MarketIsinFacts.join(
      bond,
      minfin: primary,
      seller: seller,
    );

    expect(facts.instrument.isin, bond.isin);
    expect(facts.primaryAuction!.rate, Decimal.parse('15.17'));
    expect(facts.secondaryQuote!.askYield, '15.00');
  });
}
