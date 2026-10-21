import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/portfolio/private_portfolio.dart';
import 'package:ovdp_hub/l10n/hub_locale.dart';
import 'package:ovdp_hub/main.dart';
import 'package:ovdp_hub/models.dart';
import 'package:ovdp_hub/ui/studio_design.dart';
import 'support/fake_portfolio_gateway.dart';
import 'support/fake_repository.dart';

void main() {
  for (final conflict in [false, true]) {
    testWidgets('collection move confirmation, conflict and edit controls: $conflict', (tester) async {
      tester.view.physicalSize = const Size(1400, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final data = jsonDecode(File('assets/nbu-snapshot.json').readAsStringSync()) as Map<String, dynamic>;
      data['assets'] = [(data['assets'] as List).last];
      final catalog = Catalog.parse(jsonEncode(data));
      SavedSet set(String name) => SavedSet(name, 'Private note', '2026-10-21T12:00:00Z', [catalog.bonds.single]);
      final hub = FakeRepository(catalog);
      await hub.saveCollection(set('Original'));
      final id = hub.current!.sets.single.recordId!;
      final gateway = FakePortfolioGateway(stored: PrivatePortfolioPayload(portfolioId: 'primary',
        privateCollections: conflict ? [PrivateCollectionRecord(id: 'workspace-$id', set: set('Other'))] : []));
      final strings = HubStrings(AppLanguage.uk);
      await tester.pumpWidget(OvdpApp(repository: hub, portfolioGateway: gateway));
      await tester.pumpAndSettle();
      Future<void> navigate(IconData icon) async {
        await tester.tap(find.descendant(of: find.byType(StudioSidebar), matching: find.byIcon(icon)));
        await tester.pumpAndSettle();
      }
      await navigate(Icons.account_balance_wallet_outlined);
      await tester.tap(find.byKey(const ValueKey('portfolio-open')));
      await tester.pumpAndSettle();
      await navigate(Icons.bookmarks_outlined);
      await tester.tap(find.text('Original'));
      await tester.pumpAndSettle();
      final move = find.byKey(ValueKey('move-collection-$id'));
      await tester.ensureVisible(move); await tester.tap(move);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, strings.text('cancel')));
      await tester.pumpAndSettle();
      expect(hub.deletedRecordIds, isEmpty);
      await tester.ensureVisible(move); await tester.tap(move);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, strings.text('moveCollectionTitle')));
      await tester.pumpAndSettle();
      if (conflict) {
        expect(hub.current!.sets.single.name, 'Original');
        expect(hub.deletedRecordIds, isEmpty);
        expect(find.byKey(const ValueKey('collections-move-error')), findsOneWidget);
      } else {
        expect(hub.current!.sets, isEmpty);
        expect(gateway.stored!.privateCollections.single.set.note, 'Private note');
        // The private collection has replaced the workspace row; expand it if needed.
        final edit = find.text(strings.text('editPrivateCollection'));
        if (edit.evaluate().isEmpty) {
          await tester.tap(find.text('Original')); await tester.pumpAndSettle();
        }
        await tester.ensureVisible(edit); await tester.tap(edit); await tester.pumpAndSettle();
        final name = find.widgetWithText(TextFormField, strings.text('collectionName'));
        await tester.ensureVisible(name); await tester.enterText(name, 'Edited privately');
        final save = find.text(strings.text('savePrivateCollection'));
        await tester.ensureVisible(save); await tester.tap(save); await tester.pumpAndSettle();
        expect(gateway.stored!.privateCollections.single.id, 'workspace-$id');
        expect(gateway.stored!.privateCollections.single.set.name, 'Edited privately');
        expect(hub.current!.sets, isEmpty);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink()); await tester.pumpAndSettle();
    });
  }
}
