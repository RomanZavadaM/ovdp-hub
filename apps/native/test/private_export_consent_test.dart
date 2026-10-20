import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/planner/planner_cubit.dart';
import 'package:ovdp_hub/features/planner/planner_view.dart';
import 'package:ovdp_hub/features/portfolio/private_portfolio.dart';
import 'package:ovdp_hub/l10n/hub_locale.dart';
import 'package:ovdp_hub/main.dart';
import 'package:ovdp_hub/ui/studio_design.dart';

import 'support/fake_portfolio_gateway.dart';
import 'support/fake_repository.dart';
import 'support/planner_comparison_fixtures.dart';

void main() {
  final strings = HubStrings(AppLanguage.uk);
  for (final format in ['CSV', 'ICS']) {
    for (final action in ['cancel', 'confirm', 'public', 'lock', 'workspace', 'draft']) {
      testWidgets('$format private export: $action', (tester) async {
        tester.view.physicalSize = const Size(1400, 1200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final catalog = comparisonCatalog();
        final set = comparisonSavedSet(
          catalog.bonds.first,
          name: 'Private export plan',
          savedAt: '2026-09-23T12:00:00Z',
          budget: '654321',
        );
        final hub = FakeRepository(catalog);
        final gateway = FakePortfolioGateway(stored: PrivatePortfolioPayload(
          portfolioId: 'primary',
          privateScenarios: [PrivateScenarioRecord(id: 'private-export', set: set)],
        ));
        await tester.pumpWidget(OvdpApp(repository: hub, portfolioGateway: gateway));
        await tester.pumpAndSettle();

        Future<void> navigate(IconData icon) async {
          await tester.tap(find.descendant(
            of: find.byType(StudioSidebar), matching: find.byIcon(icon),
          ));
          await tester.pumpAndSettle();
        }

        await navigate(Icons.account_balance_wallet_outlined);
        await tester.tap(find.byKey(const ValueKey('portfolio-open')));
        await tester.pumpAndSettle();
        await navigate(Icons.bookmarks_outlined);
        await tester.tap(find.text('Private export plan'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(strings.text('openPlan')));
        await tester.tap(find.text(strings.text('openPlan')));
        await tester.pumpAndSettle();
        final planner = tester.element(find.byType(PlannerView)).read<PlannerCubit>();
        expect(planner.state.privateDraft, isTrue);
        if (action == 'public') {
          planner.load(set);
          await tester.pumpAndSettle();
          expect(planner.state.privateDraft, isFalse);
        }
        if (format == 'ICS' && action == 'confirm') {
          tester.view.physicalSize = const Size(390, 844);
          await tester.pumpAndSettle();
        }
        final export = find.text(strings.text(format == 'CSV' ? 'exportCsv' : 'exportIcs'));
        await tester.ensureVisible(export);
        await tester.tap(export);
        await tester.pumpAndSettle();
        final dialog = find.byKey(const ValueKey('private-export-confirmation'));
        if (action == 'public') {
          expect(dialog, findsNothing);
        } else {
          expect(dialog, findsOneWidget);
          expect(hub.exports, 0);
          expect(find.descendant(of: dialog, matching: find.textContaining('local')), findsOneWidget);
          expect(find.descendant(of: dialog, matching: find.textContaining(format)), findsOneWidget);
          if (action == 'lock') {
            await gateway.lock();
            await tester.pumpAndSettle();
            expect(dialog, findsNothing);
          } else {
            if (action == 'workspace') {
              hub.switchAccepted = true;
              await hub.chooseWorkspace();
              await tester.pumpAndSettle();
            }
            if (action == 'draft') {
              planner.edit('name', 'Changed after consent prompt');
              await tester.pumpAndSettle();
            }
            final key = action == 'cancel'
                ? 'private-export-cancel'
                : 'private-export-confirm';
            await tester.tap(find.byKey(ValueKey(key)));
            await tester.pumpAndSettle();
          }
        }
        if (action == 'confirm' || action == 'public') {
          expect(hub.exports, 1);
          expect(hub.exportedFiles.keys.single, endsWith('.${format.toLowerCase()}'));
          expect(hub.exportedFiles.values.single, isNotEmpty);
          if (format == 'ICS') {
            expect(hub.exportedFiles.values.single, contains('BEGIN:VCALENDAR'));
          }
        } else {
          expect(hub.exports, 0);
          expect(hub.exportedFiles, isEmpty);
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      });
    }
  }
}
