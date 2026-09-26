import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/planner/planner_cubit.dart';
import 'package:ovdp_hub/features/planner/planner_view.dart';
import 'package:ovdp_hub/features/portfolio/private_portfolio.dart';
import 'package:ovdp_hub/main.dart';
import 'package:ovdp_hub/models.dart';
import 'package:ovdp_hub/ui/studio_design.dart';

import 'support/fake_portfolio_gateway.dart';
import 'support/fake_repository.dart';

void main() {
  late Catalog catalog;

  setUpAll(() {
    final data =
        jsonDecode(File('assets/nbu-snapshot.json').readAsStringSync())
            as Map<String, dynamic>;
    data['assets'] = [(data['assets'] as List).last];
    catalog = Catalog.parse(jsonEncode(data));
  });

  testWidgets(
    'Planner exposes picker and invalid keyboard draft does not change canonical date',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(OvdpApp(repository: FakeRepository(catalog)));
      await tester.pumpAndSettle();

      final plannerNavigation = find.descendant(
        of: find.byType(StudioSidebar),
        matching: find.byIcon(Icons.event_available_outlined),
      );
      await tester.tap(plannerNavigation);
      await tester.pumpAndSettle();

      expect(find.byType(PlannerView), findsOneWidget);
      expect(
        find.byKey(const ValueKey('planner-start-picker')),
        findsOneWidget,
      );

      final plannerContext = tester.element(find.byType(PlannerView));
      final cubit = plannerContext.read<PlannerCubit>();
      final originalStart = cubit.state.criteria['start'];
      final startInput = find.byKey(const ValueKey('planner-start-input'));

      await tester.enterText(startInput, 'not-a-date');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(cubit.state.criteria['start'], originalStart);
      final startDecorator = find.descendant(
        of: startInput,
        matching: find.byType(InputDecorator),
      );
      expect(startDecorator, findsOneWidget);
      expect(
        tester.widget<InputDecorator>(startDecorator).decoration.errorText,
        isNotNull,
      );

      await tester.enterText(startInput, originalStart!);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('planner-start-picker')));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      Navigator.of(tester.element(find.byType(DatePickerDialog))).pop();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'phone Portfolio purchase date picker is reachable without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final bond = catalog.bonds.single;
      final payload = PrivatePortfolioPayload(
        portfolioId: 'primary',
        acquisitionLots: [
          PrivateAcquisitionLot(
            id: 'lot-phone-date',
            isin: bond.isin,
            units: 1,
            acquiredOn: '2026-09-24',
            currency: bond.currency,
            tradeAmount: Decimal.parse('980'),
            feeStatus: AcquisitionFeeStatus.known,
            feeTotal: Decimal.zero,
          ),
        ],
      );
      final gateway = FakePortfolioGateway(stored: payload);

      await tester.pumpWidget(
        OvdpApp(
          repository: FakeRepository(catalog),
          portfolioGateway: gateway,
        ),
      );
      await tester.pumpAndSettle();

      final portfolioNavigation = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.byIcon(Icons.account_balance_wallet_outlined),
      );
      await tester.tap(portfolioNavigation);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Відкрити портфель'));
      await tester.pumpAndSettle();

      final addPurchase =
          find.byKey(const ValueKey('portfolio-add-purchase'));
      await tester.ensureVisible(addPurchase);
      await tester.tap(addPurchase);
      await tester.pumpAndSettle();

      final purchaseDatePicker =
          find.byKey(const ValueKey('portfolio-purchase-date-picker'));
      await tester.ensureVisible(purchaseDatePicker);
      expect(purchaseDatePicker, findsOneWidget);

      await tester.tap(purchaseDatePicker);
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      expect(tester.takeException(), isNull);

      Navigator.of(tester.element(find.byType(DatePickerDialog))).pop();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
