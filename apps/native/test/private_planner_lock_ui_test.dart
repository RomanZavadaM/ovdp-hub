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
  for (final mode in ['manual', 'automatic', 'nestedDatePicker']) {
    testWidgets('private Planner is hidden after $mode session lock', (tester) async {
      tester.view.physicalSize = const Size(1400, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final catalog = comparisonCatalog();
      final set = comparisonSavedSet(
        catalog.bonds.first,
        name: 'Private plan',
        savedAt: '2026-09-23T12:00:00Z',
        budget: '654321',
      );
      final hub = FakeRepository(catalog);
      final gateway = FakePortfolioGateway(stored: PrivatePortfolioPayload(
        portfolioId: 'primary',
        privateScenarios: [PrivateScenarioRecord(id: 'private-1', set: set)],
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
      await tester.tap(find.text('Private plan'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(strings.text('openPlan')));
      await tester.tap(find.text(strings.text('openPlan')));
      await tester.pumpAndSettle();
      final planner = tester.element(find.byType(PlannerView)).read<PlannerCubit>();
      expect(planner.state.privateDraft, isTrue);
      expect(planner.state.criteria['budget'], '654321');

      if (mode == 'nestedDatePicker') {
        final editFx = find.text(strings.text('addFxComparison'));
        await tester.ensureVisible(editFx);
        await tester.tap(editFx);
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('planner-fx-asof-picker')));
        await tester.pumpAndSettle();
        expect(find.byType(DatePickerDialog), findsOneWidget);
      }
      if (mode == 'manual') {
        await navigate(Icons.account_balance_wallet_outlined);
        await tester.tap(find.byTooltip(strings.text('portfolioLock')));
        await tester.pumpAndSettle();
        await navigate(Icons.event_available_outlined);
      } else {
        // The gateway event is also used by inactivity/background timers.
        await gateway.lock();
        await tester.pumpAndSettle();
      }

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(DatePickerDialog), findsNothing);
      expect(planner.state.inputs, isEmpty);
      expect(planner.state.criteria['budget'], '100000');
      expect(planner.state.criteria['name'], isNot('Private plan'));
      final budget = find.byKey(ValueKey('budget-${planner.state.revision}'));
      expect(tester.widget<TextFormField>(budget).initialValue, '100000');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }
}
