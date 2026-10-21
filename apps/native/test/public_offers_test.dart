import 'dart:io';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ovdp_hub/data/source_observation.dart';
import 'package:ovdp_hub/features/sellers/public_offers.dart';
import 'package:ovdp_hub/features/sellers/public_offer_strings.dart';
import 'package:ovdp_hub/features/sellers/sellers_cubit.dart';
import 'package:ovdp_hub/features/sellers/seller_repository.dart';
import 'package:ovdp_hub/l10n/hub_locale.dart';

void main() {
  final now = DateTime.utc(2026, 10, 21, 12);
  String univerRow({String price = '1014.12', String currency = 'UAH'}) => '''
    <div class="writem"><div>image</div><p>207518</p><p>$currency</p>
    <p>UA4000207518</p><p>$price</p><p>2027-05-26</p><p>14.9</p><a href="/app">Open</a></div>''';
  const inzhurRow = '''<div><span>UA4000239016</span>
    <span data-testid="bond-units-yield-value">15,50%</span><span>YTM</span>
    <button data-testid="bond-units-maturity-value">21.07.2027</button>
    <span>1&nbsp;038,91 ₴</span><span>1&nbsp;038,91 ₴</span>
    <span>12</span><a href="/dashboard" data-testid="bond-units-invest-button">Open</a></div>''';
  test('UNIVER preserves price and yield separately, timestamp and quantity unknown', () {
    final source = parseUniverPublicOffers(univerRow(), now);
    final offer = source.offers.single;
    expect(offer.purchasePrice, Decimal.parse('1014.12'));
    expect(offer.listedYield, Decimal.parse('14.9'));
    expect(offer.availableUnits, isNull);
    expect(offer.yieldMethod, isNull);
    expect(offer.meta.sourceDate, isNull);
    expect(offer.meta.freshness(now), DataFreshness.unknown);
    expect(offer.meta.confidence, ObservationConfidence.publicIndicative);
  });
  test('Inzhur preserves published sides and quantity without executing scripts', () {
    final source = parseInzhurPublicOffers(inzhurRow.replaceAll('&nbsp;', '\u00a0'), now);
    final offer = source.offers.single;
    expect(offer.purchasePrice, Decimal.parse('1038.91'));
    expect(offer.salePrice, Decimal.parse('1038.91'));
    expect(offer.listedYield, Decimal.parse('15.5'));
    expect(offer.availableUnits, 12);
    expect(offer.yieldMethod, 'YTM');
    expect(offer.maturity, '2027-07-21');
    expect(offer.meta.sourceDate, isNull);
    expect(() => parseInzhurPublicOffers('<script>$inzhurRow</script>', now), throwsFormatException);
  });
  test('public parsers reject changed or mostly invalid structures', () {
    expect(() => parseUniverPublicOffers(univerRow(price: '-2'), now), throwsFormatException);
    expect(() => parseUniverPublicOffers(univerRow(currency: '???'), now), throwsFormatException);
    expect(() => parseInzhurPublicOffers(inzhurRow.replaceAll('21.07.2027', '31.02.2027'), now), throwsFormatException);
    expect(() => parseInzhurPublicOffers('<html>sign in</html>', now), throwsFormatException);
  });
  test('one unavailable provider does not suppress a working provider', () async {
    final repo = PublicOffersRepository(clock: () => now, client: MockClient((request) async {
      if (request.url.host == 'www.univer.ua') return http.Response(univerRow(), 200);
      return http.Response('unavailable', 503);
    }));
    final result = await repo.fetch();
    expect(result.where((s) => s.errorCode != null), hasLength(1));
    expect(result.expand((s) => s.offers), hasLength(1));
    repo.dispose();
  });
  test('failed refresh retains last public observations with an error marker', () async {
    var fail = false;
    final repo = PublicOffersRepository(clock: () => now, client: MockClient((request) async {
      if (!fail && request.url.host == 'www.univer.ua') return http.Response(univerRow(), 200);
      return http.Response('unavailable', 503);
    }));
    final cubit = SellersCubit(SellerRepository(client: MockClient((_) async => http.Response('', 503))),
      publicRepository: repo);
    await cubit.refreshPublicSources();
    expect(cubit.publicOffers, hasLength(1));
    fail = true;
    await cubit.refreshPublicSources();
    expect(cubit.publicOffers, hasLength(1));
    expect(cubit.state.publicSources.last.errorCode, isNotNull);
    expect(cubit.publicOffers.single.meta.retrievedAt, now.toIso8601String());
    await cubit.close();
  });
  test('all source UI copy exists in all seven languages', () {
    for (final language in AppLanguage.values) {
      final strings = HubStrings(language);
      for (final key in ['title','load','notice','unavailable','purchase','sale','yield','quantity','timestamp','empty']) {
        expect(strings.offerText(key), isNot(key));
        expect(strings.offerText(key), isNotEmpty);
      }
    }
  });
  test('captured public provider rows retain the verified HTML contract', () {
    final inzhur = File('test/fixtures/inzhur-public-row.html').readAsStringSync();
    final univer = File('test/fixtures/univer-public-row.html').readAsStringSync();
    expect(parseInzhurPublicOffers(inzhur, now).offers, isNotEmpty);
    expect(parseUniverPublicOffers(univer, now).offers, isNotEmpty);
  });
}
