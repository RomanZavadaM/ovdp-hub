import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ovdp_hub/features/catalog/catalog_cubit.dart';
import 'package:ovdp_hub/features/sellers/public_offers.dart';
import 'package:ovdp_hub/features/sellers/public_offers_view.dart';
import 'package:ovdp_hub/features/sellers/public_offer_strings.dart';
import 'package:ovdp_hub/features/sellers/sellers_cubit.dart';
import 'package:ovdp_hub/features/sellers/seller_repository.dart';
import 'package:ovdp_hub/l10n/hub_locale.dart';
import 'package:ovdp_hub/models.dart';
import 'support/fake_repository.dart';

void main() {
  for (final width in [430.0, 1280.0]) {
    testWidgets('public offers controls tolerate one failed source at $width', (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final catalog = Catalog.parse(File('assets/nbu-snapshot.json').readAsStringSync());
      final bond = catalog.bonds.first;
      final hub = FakeRepository(catalog);
      final catalogCubit = CatalogCubit(hub);
      final locale = LocaleCubit();
      final strings = HubStrings(AppLanguage.uk);
      final offers = PublicOffersRepository(client: MockClient((request) async {
        if (request.url.host != 'www.univer.ua') return http.Response('unavailable', 503);
        return http.Response('<div class="writem"><p>Test</p><p>${bond.currency}</p>'
          '<p>${bond.isin}</p><p>1014.12</p><p>${bond.maturity}</p><p>14.9</p><a>Open</a></div>', 200);
      }));
      final sellers = SellersCubit(SellerRepository(client: MockClient((_) async => http.Response('', 503))),
        publicRepository: offers)..currency(bond.currency);
      await tester.pumpWidget(MultiBlocProvider(providers: [
        BlocProvider.value(value: sellers), BlocProvider.value(value: catalogCubit),
        BlocProvider.value(value: locale),
      ], child: const MaterialApp(home: Scaffold(body: SingleChildScrollView(child: PublicOffersView())))));
      await tester.tap(find.byKey(const ValueKey('refresh-all-public-offers')));
      await tester.pumpAndSettle();
      expect(find.text(strings.offerText('unavailable')), findsOneWidget);
      final row = find.byKey(ValueKey('public-offers-${bond.isin}'));
      await tester.ensureVisible(row); await tester.tap(row); await tester.pumpAndSettle();
      expect(find.text('${strings.offerText('purchase')}: 1014.12 ${bond.currency}'), findsOneWidget);
      expect(find.text('${strings.offerText('quantity')}: —'), findsOneWidget);
      expect(sellers.publicOffers.single.meta.sourceDate, isNull);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(() async {
        await sellers.close(); await catalogCubit.close(); await locale.close(); await hub.dispose();
      });
    });
  }
}
