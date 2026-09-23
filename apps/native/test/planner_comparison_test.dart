import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/data/hub_repository.dart';
import 'package:ovdp_hub/features/collections/collections_cubit.dart';
import 'package:ovdp_hub/features/planner/planner_comparison.dart';
import 'package:ovdp_hub/features/planner/planner_scenario.dart';
import 'package:ovdp_hub/models.dart';

import 'support/fake_repository.dart';
import 'support/planner_comparison_fixtures.dart';

void main() {
  group('A/B/C comparison domain', () {
    test('compares two or three scenarios with neutral selection labels', () {
      final catalog = comparisonCatalog();
      final bond = catalog.bonds.first;
      final a = comparisonSavedSet(
        bond,
        name: 'План Альфа',
        savedAt: '2026-09-23T10:00:00Z',
        variantLabel: 'legacy-X',
        purchasePrice: '980',
      );
      final b = comparisonSavedSet(
        bond,
        name: 'План Бета',
        savedAt: '2026-09-23T10:01:00Z',
        variantLabel: 'legacy-Y',
        purchasePrice: '990',
      );
      final c = comparisonSavedSet(
        bond,
        name: 'План Гамма',
        savedAt: '2026-09-23T10:02:00Z',
        variantLabel: 'legacy-Z',
        purchasePrice: '995',
      );

      final result = compareSavedScenarios(
        [b, a, c],
        now: DateTime.utc(2026, 9, 23),
      );

      expect(result.variants.map((v) => v.label).toList(), ['A', 'B', 'C']);
      expect(
        result.variants.map((v) => v.name).toList(),
        ['План Бета', 'План Альфа', 'План Гамма'],
      );
      expect(result.currency, 'UAH');
      expect(result.variants.every((v) => v.positions.isNotEmpty), true);
    });

    test('baseline mismatch and explicit group mismatch fail closed', () {
      final bond = comparisonCatalog().bonds.first;
      final a = comparisonSavedSet(
        bond,
        name: 'A',
        savedAt: '2026-09-23T10:00:00Z',
      );
      final differentBudget = comparisonSavedSet(
        bond,
        name: 'B',
        savedAt: '2026-09-23T10:01:00Z',
        variantLabel: 'B',
        budget: '110000',
      );
      final differentGroup = comparisonSavedSet(
        bond,
        name: 'C',
        savedAt: '2026-09-23T10:02:00Z',
        groupId: 'other-group',
        variantLabel: 'C',
      );

      expect(
        () => compareSavedScenarios(
          [a, differentBudget],
          now: DateTime.utc(2026, 9, 23),
        ),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            'planner.comparison_assumptions_mismatch',
          ),
        ),
      );
      expect(
        () => compareSavedScenarios(
          [a, differentGroup],
          now: DateTime.utc(2026, 9, 23),
        ),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            'planner.comparison_group_mismatch',
          ),
        ),
      );
    });

    test('typed recurring needs compare when their schedule is identical', () {
      final bond = comparisonCatalog().bonds.first;
      final a = comparisonSavedSet(
        bond,
        name: 'A',
        savedAt: '2026-09-23T10:00:00Z',
        needType: PlannerNeedType.recurring,
      );
      final b = comparisonSavedSet(
        bond,
        name: 'B',
        savedAt: '2026-09-23T10:01:00Z',
        variantLabel: 'B',
        purchasePrice: '990',
        needType: PlannerNeedType.recurring,
      );

      final result = compareSavedScenarios(
        [a, b],
        now: DateTime.utc(2026, 9, 23),
      );

      expect(result.variants, hasLength(2));
      expect(result.variants.first.expenseBalances, hasLength(2));
      expect(
        result.variants.first.expenseBalances.map((e) => e.expense.date),
        ['2027-06-01', '2027-07-01'],
      );
    });

    test('reserve-floor needs remain explicit fail-closed comparison input', () {
      final bond = comparisonCatalog().bonds.first;
      final a = comparisonSavedSet(
        bond,
        name: 'A',
        savedAt: '2026-09-23T10:00:00Z',
        needType: PlannerNeedType.reserveFloor,
      );
      final b = comparisonSavedSet(
        bond,
        name: 'B',
        savedAt: '2026-09-23T10:01:00Z',
        variantLabel: 'B',
        purchasePrice: '990',
        needType: PlannerNeedType.reserveFloor,
      );

      expect(
        () => compareSavedScenarios(
          [a, b],
          now: DateTime.utc(2026, 9, 23),
        ),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            'planner.comparison_need_model_unsupported',
          ),
        ),
      );
    });

    test('comparison accepts exactly two or three scenarios', () {
      final bond = comparisonCatalog().bonds.first;
      final a = comparisonSavedSet(
        bond,
        name: 'A',
        savedAt: '2026-09-23T10:00:00Z',
      );

      expect(
        () => compareSavedScenarios([a], now: DateTime.utc(2026, 9, 23)),
        throwsFormatException,
      );
    });
  });

  group('CollectionsCubit A/B/C selection', () {
    test('preserves selection order, caps at three and clears stale errors', () async {
      final catalog = comparisonCatalog();
      final bond = catalog.bonds.first;
      final sets = [
        comparisonSavedSet(
          bond,
          name: 'A plan',
          savedAt: '2026-09-23T10:00:00Z',
        ),
        comparisonSavedSet(
          bond,
          name: 'B plan',
          savedAt: '2026-09-23T10:01:00Z',
          variantLabel: 'B',
          purchasePrice: '985',
        ),
        comparisonSavedSet(
          bond,
          name: 'C plan',
          savedAt: '2026-09-23T10:02:00Z',
          variantLabel: 'C',
          purchasePrice: '990',
        ),
        comparisonSavedSet(
          bond,
          name: 'D plan',
          savedAt: '2026-09-23T10:03:00Z',
          variantLabel: 'D',
          purchasePrice: '995',
        ),
      ];
      final repository = FakeRepository(catalog);
      repository.current = WorkspaceSnapshot('local', catalog, sets);
      final cubit = CollectionsCubit(
        repository,
        clock: () => DateTime.utc(2026, 9, 23),
      );

      cubit.toggleComparison(sets[1]);
      expect(cubit.comparisonLabelFor(sets[1]), 'A');
      expect(cubit.state.comparison, isNull);

      cubit.toggleComparison(sets[0]);
      expect(cubit.comparisonLabelFor(sets[1]), 'A');
      expect(cubit.comparisonLabelFor(sets[0]), 'B');
      expect(cubit.state.comparison!.variants.map((v) => v.name).toList(), [
        'B plan',
        'A plan',
      ]);

      cubit.toggleComparison(sets[2]);
      expect(cubit.comparisonLabelFor(sets[2]), 'C');

      cubit.toggleComparison(sets[3]);
      expect(cubit.state.error?.code, 'planner.comparison_max_three');
      expect(cubit.state.selectedComparisonKeys, hasLength(3));

      cubit.toggleComparison(sets[2]);
      expect(cubit.state.error, isNull);
      expect(cubit.state.comparison!.variants, hasLength(2));

      cubit.clearComparison();
      expect(cubit.state.selectedComparisonKeys, isEmpty);
      expect(cubit.state.comparison, isNull);
      expect(cubit.state.error, isNull);

      await cubit.close();
      await repository.dispose();
    });

    test('incompatible pair reports error and deselection recovers', () async {
      final catalog = comparisonCatalog();
      final bond = catalog.bonds.first;
      final a = comparisonSavedSet(
        bond,
        name: 'A',
        savedAt: '2026-09-23T10:00:00Z',
      );
      final b = comparisonSavedSet(
        bond,
        name: 'B',
        savedAt: '2026-09-23T10:01:00Z',
        variantLabel: 'B',
        budget: '150000',
      );
      final repository = FakeRepository(catalog);
      repository.current = WorkspaceSnapshot('local', catalog, [a, b]);
      final cubit = CollectionsCubit(
        repository,
        clock: () => DateTime.utc(2026, 9, 23),
      );

      cubit.toggleComparison(a);
      cubit.toggleComparison(b);
      expect(cubit.state.comparison, isNull);
      expect(
        cubit.state.error?.code,
        'planner.comparison_assumptions_mismatch',
      );

      cubit.toggleComparison(b);
      expect(cubit.state.selectedComparisonKeys, hasLength(1));
      expect(cubit.state.error, isNull);

      await cubit.close();
      await repository.dispose();
    });
  });
}
