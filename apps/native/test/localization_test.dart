import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/errors.dart';
import 'package:ovdp_hub/l10n/hub_locale.dart';
import 'package:ovdp_hub/main.dart';
import 'package:ovdp_hub/models.dart';
import 'package:ovdp_hub/ui/components.dart';

import 'support/fake_repository.dart';

void main() {
  testWidgets('Ukrainian is default and shell can switch to English', (
    tester,
  ) async {
    final data =
        jsonDecode(File('assets/nbu-snapshot.json').readAsStringSync())
            as Map<String, dynamic>;
    data['assets'] = [(data['assets'] as List).last];

    await tester.pumpWidget(
      OvdpApp(repository: FakeRepository(Catalog.parse(jsonEncode(data)))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Каталог'), findsWidgets);
    await tester.tap(find.byTooltip('Мова / Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Catalog'), findsWidgets);
    expect(find.text('Refresh directly from NBU'), findsOneWidget);
    expect(find.byTooltip('Language'), findsOneWidget);

    await tester.tap(find.text('Calculator').first);
    await tester.pumpAndSettle();
    expect(find.text('Educational calculator'), findsOneWidget);

    await tester.tap(find.text('Sellers').first);
    await tester.pumpAndSettle();
    expect(find.text('Sellers · public quotes'), findsOneWidget);

    await tester.tap(find.text('Storage').first);
    await tester.pumpAndSettle();
    expect(find.text('Workspace folder'), findsOneWidget);

    await tester.tap(find.text('Collections').first);
    await tester.pumpAndSettle();
    expect(find.text('Saved collections'), findsOneWidget);

    await tester.tap(find.text('Planning').first);
    await tester.pumpAndSettle();
    expect(find.text('Goals and income planner'), findsOneWidget);
    expect(find.text('Budget in selected currency'), findsOneWidget);
    expect(find.text('My plan'), findsOneWidget);
    expect(find.text('Primary need'), findsOneWidget);

    await tester.tap(find.byTooltip('Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Français'));
    await tester.pumpAndSettle();

    expect(find.text('Mon plan'), findsOneWidget);
    expect(find.text('Besoin principal'), findsWidgets);
    expect(find.text('My plan'), findsNothing);

    expect(tester.takeException(), isNull);
  });

  test('price source controls are localized in every supported language', () {
    const keys = [
      'addPriceSource',
      'priceSourceName',
      'priceSourceFullPrice',
      'priceSourcePriorityTitle',
      'priceSourcePriorityInfo',
      'moveSourceUp',
      'moveSourceDown',
      'selectedPriceSource',
      'useNominalEstimate',
    ];
    for (final language in AppLanguage.values) {
      final strings = HubStrings(language);
      for (final key in keys) {
        expect(
          strings.text(key),
          isNot(key),
          reason: '${language.code} must localize $key',
        );
      }
    }
  });

  test('purchase fee controls are localized in every supported language', () {
    const keys = [
      'feeAssumptionsTitle',
      'feeAssumptionsInfo',
      'feesUnknown',
      'feesKnown',
      'aggregatePurchaseFee',
      'advancedFeeRulesPreserved',
      'purchaseFeeApplied',
      'unknownFeesResultInfo',
      'expenseCoverageUnknownFeesInfo',
    ];
    for (final language in AppLanguage.values) {
      final strings = HubStrings(language);
      for (final key in keys) {
        expect(
          strings.text(key),
          isNot(key),
          reason: '${language.code} must localize $key',
        );
      }
    }
  });

  test('tax controls are localized in every supported language', () {
    const keys = [
      'taxAssumptionsTitle',
      'taxAssumptionsInfo',
      'taxesUnknown',
      'taxPresetUkraine2026',
      'taxVerifiedOn',
      'taxApplied',
      'unknownTaxesResultInfo',
      'expenseCoverageUnknownTaxesInfo',
    ];
    for (final language in AppLanguage.values) {
      final strings = HubStrings(language);
      for (final key in keys) {
        expect(
          strings.text(key),
          isNot(key),
          reason: '${language.code} must localize $key',
        );
      }
    }
  });

  test('A/B/C comparison is localized in every supported language', () {
    const keys = [
      'comparisonTitle',
      'comparisonSelectInfo',
      'comparisonSelected',
      'comparisonSelectOneMore',
      'comparisonSelectScenario',
      'comparisonVariant',
      'comparisonNoWinner',
      'comparisonSharedAssumptions',
      'comparisonMetric',
      'comparisonScenarioName',
      'comparisonStrategy',
      'comparisonComposition',
      'comparisonPurchaseFee',
      'comparisonTax',
      'comparisonProfit',
      'comparisonCoverageShortfall',
      'comparisonFx',
      'comparisonClear',
    ];
    for (final language in AppLanguage.values) {
      final strings = HubStrings(language);
      for (final key in keys) {
        expect(
          strings.text(key),
          isNot(key),
          reason: '${language.code} must localize $key',
        );
      }
      for (final code in [
        'planner.comparison_max_three',
        'planner.comparison_two_or_three',
        'planner.comparison_assumptions_mismatch',
        'planner.comparison_group_mismatch',
        'planner.comparison_need_model_unsupported',
      ]) {
        expect(
          strings.error(AppError(code)),
          isNot(code),
          reason: '${language.code} must localize $code',
        );
      }
    }
  });

  test('Planner needs block is localized in every supported language', () {
    const keys = [
      'futureExpenses',
      'futureExpensesIntro',
      'primaryNeedTitle',
      'primaryNeedName',
      'primaryNeedRecurring',
      'primaryNeedRecurringInfo',
      'repeatEveryMonths',
      'repeatOccurrences',
      'additionalNeedsTitle',
    ];
    for (final language in AppLanguage.values) {
      final strings = HubStrings(language);
      for (final key in keys) {
        expect(
          strings.text(key),
          isNot(key),
          reason: '${language.code} must localize $key',
        );
      }
      expect(
        strings.error(const AppError('planner.invalid_repeat')),
        isNot('planner.invalid_repeat'),
      );
    }
  });

  test('generated Planner copy is localized in every supported language', () {
    const keys = [
      'generatedPlanName',
      'generatedPrimaryNeedName',
      'generatedExpenseName',
      'generatedScenarioDescription',
      'generatedScenarioFeesUnknown',
      'generatedScenarioFeesKnown',
      'generatedScenarioTaxesUnknown',
      'generatedScenarioTaxesKnown',
      'generatedScenarioFxNone',
      'generatedScenarioFxKnown',
      'generatedScenarioExitHold',
      'generatedScenarioExitEarly',
    ];
    for (final language in AppLanguage.values) {
      final strings = HubStrings(language);
      for (final key in keys) {
        expect(
          strings.text(key),
          isNot(key),
          reason: '${language.code} must localize $key',
        );
      }
    }
  });

  test('FX controls are localized in every supported language', () {
    const keys = [
      'fxAssumptionsTitle',
      'fxAssumptionsInfo',
      'fxNotSet',
      'fxEditTitle',
      'fxTargetCurrency',
      'fxRate',
      'fxAsOf',
      'fxSourceUrl',
      'applyFxComparison',
      'addFxComparison',
      'changeFxComparison',
      'replaceFxComparison',
      'clearFxComparison',
      'advancedFxRulesPreserved',
      'fxComparisonResult',
      'fxBaseAuthoritative',
    ];
    for (final language in AppLanguage.values) {
      final strings = HubStrings(language);
      for (final key in keys) {
        expect(
          strings.text(key),
          isNot(key),
          reason: '${language.code} must localize $key',
        );
      }
    }
  });

  test('exit controls are localized in every supported language', () {
    const keys = [
      'exitEditTitle',
      'exitAssumptionsInfo',
      'exitDate',
      'exitFullPrice',
      'exitManualPrice',
      'exitBidPrice',
      'exitSourceUrlRequired',
      'exitSourceUrlOptional',
      'applyExit',
      'exitHoldToMaturity',
      'exitEarlySale',
      'exitSource',
      'addEarlySale',
      'changeEarlySale',
      'returnToMaturity',
      'exitResultInfo',
      'saleProceeds',
    ];
    for (final language in AppLanguage.values) {
      final strings = HubStrings(language);
      for (final key in keys) {
        expect(
          strings.text(key),
          isNot(key),
          reason: '${language.code} must localize $key',
        );
      }
    }
  });

  testWidgets('typed error follows the selected UI language', (tester) async {
    final locale = LocaleCubit()..select(AppLanguage.en);
    await tester.pumpWidget(
      BlocProvider.value(
        value: locale,
        child: MaterialApp(
          home: Scaffold(
            body: ErrorNotice(
              const AppError('planner.reserve_exceeds_budget'),
              () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('The reserve exceeds the budget.'), findsOneWidget);
    expect(
      HubStrings(AppLanguage.en).error(const AppError('model.invalid_date')),
      'The instrument data are invalid.',
    );
    expect(
      HubStrings(AppLanguage.en).error(
        const AppError('planner.fee_currency_mismatch'),
      ),
      'The fee currency does not match the scenario currency.',
    );
    expect(
      HubStrings(AppLanguage.en).error(
        const AppError('planner.unsupported_tax_base'),
      ),
      'A non-zero tax rule requires an explicit tax-base model; the calculation was stopped.',
    );
    expect(
      HubStrings(AppLanguage.en).error(
        const AppError('planner.fx_source_url_required'),
      ),
      'Enter a full http/https URL for the FX rate source.',
    );
    expect(
      HubStrings(AppLanguage.en).error(
        const AppError('planner.invalid_exit_timing'),
      ),
      'The sale date must be after the scenario start, before maturity, and not on a contractual payment date.',
    );
    await locale.close();
  });

}
