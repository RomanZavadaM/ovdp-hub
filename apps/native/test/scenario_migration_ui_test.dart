import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/portfolio/private_portfolio.dart';
import 'package:ovdp_hub/main.dart';
import 'package:ovdp_hub/models.dart';
import 'package:ovdp_hub/ui/studio_design.dart';

import 'support/fake_portfolio_gateway.dart';
import 'support/fake_repository.dart';

void main() {
  for (final conflict in [false, true]) {
    testWidgets('visible move control preserves source on conflict=$conflict',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final json = jsonDecode(
        File('assets/nbu-snapshot.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      json['assets'] = [(json['assets'] as List).last];
      final catalog = Catalog.parse(jsonEncode(json));
      SavedSet plan(String name) => SavedSet(
        name, 'Private', '2026-10-20T00:00:00Z', [catalog.bonds.single],
        scenario: {'schemaVersion': 99, 'budget': '250000'},
      );
      final hub = FakeRepository(catalog);
      await hub.saveCollection(plan('Original'));
      final id = hub.current!.sets.single.recordId!;
      final gateway = FakePortfolioGateway(
        stored: PrivatePortfolioPayload(
          portfolioId: 'primary',
          privateScenarios: conflict
              ? [PrivateScenarioRecord(id: 'workspace-$id', set: plan('Other'))]
              : [],
        ),
      );
      await tester.pumpWidget(
        OvdpApp(repository: hub, portfolioGateway: gateway),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(
        of: find.byType(StudioSidebar),
        matching: find.byIcon(Icons.account_balance_wallet_outlined),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('portfolio-open')));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(
        of: find.byType(StudioSidebar),
        matching: find.byIcon(Icons.bookmarks_outlined),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('collections-move-scenarios')));
      await tester.pumpAndSettle();

      if (conflict) {
        expect(hub.current!.sets.single.name, 'Original');
        expect(hub.deletedRecordIds, isEmpty);
        expect(find.byKey(const ValueKey('collections-move-error')), findsOneWidget);
        expect(find.text('Перенесено сценаріїв: 1. Відкриті файли видалено.'), findsNothing);
      } else {
        expect(hub.current!.sets, isEmpty);
        expect(gateway.stored!.privateScenarios.single.set.name, 'Original');
        expect(find.byKey(const ValueKey('collections-plaintext-warning')), findsNothing);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }
}
