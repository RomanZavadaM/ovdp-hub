import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/planner/planner_cubit.dart';
import 'package:ovdp_hub/features/planner/planner_goals.dart';
import 'package:ovdp_hub/features/planner/planner_scenario.dart';
import 'package:ovdp_hub/models.dart';

import 'support/fake_repository.dart';

Catalog needsCatalog() => Catalog.parse(
      jsonEncode({
        'schemaVersion': 1,
        'retrievedAt': '2026-09-21T00:00:00Z',
        'assets': [
          {
            'isin': 'UA4000239115',
            'currency': 'UAH',
            'nominal': '1000',
            'nominalRate': '15',
            'issueDate': '2026-01-01',
            'maturityDate': '2027-09-21',
            'payments': [
              {
                'date': '2027-09-21',
                'kind': 'REDEMPTION',
                'amount': '1000',
              },
            ],
          },
        ],
      }),
    );

void main() {
  test('recurring need expands with month-end clamping and one-off extras', () {
    final criteria = <String, String>{
      'start': '2026-01-01',
      'needName': 'Оренда',
      'needDate': '2026-01-31',
      'needAmount': '1000',
      'needRecurring': 'true',
      'needEveryMonths': '1',
      'needOccurrences': '3',
      'expenseCount': '1',
      'expenseName0': 'Страхування',
      'expenseDate0': '2026-03-15',
      'expenseAmount0': '2500',
    };

    final needs = plannerNeedsFromCriteria(criteria);
    expect(needs, hasLength(2));
    expect(needs.first.type, PlannerNeedType.recurring);
    expect(needs.first.everyMonths, 1);
    expect(needs.first.occurrences, 3);

    final expenses = readExpenses(criteria);
    expect(expenses, hasLength(4));
    expect(
      expenses.map((e) => e.date).toList(),
      ['2026-01-31', '2026-02-28', '2026-03-15', '2026-03-31'],
    );
    expect(expenses[0].amount, Decimal.parse('1000'));
    expect(expenses[2].name, 'Страхування');
  });

  test('invalid recurring interval or count fails closed', () {
    Map<String, String> criteria(String interval, String count) => {
      'start': '2026-01-01',
      'needName': 'Оренда',
      'needDate': '2026-01-31',
      'needAmount': '1000',
      'needRecurring': 'true',
      'needEveryMonths': interval,
      'needOccurrences': count,
      'expenseCount': '0',
    };

    expect(
      () => plannerNeedsFromCriteria(criteria('0', '6')),
      throwsFormatException,
    );
    expect(
      () => plannerNeedsFromCriteria(criteria('1', '1')),
      throwsFormatException,
    );
    expect(
      () => plannerNeedsFromCriteria(criteria('bad', '6')),
      throwsFormatException,
    );
  });

  test('recurring primary need survives planner save and reload', () async {
    final repository = FakeRepository(needsCatalog());
    final cubit = PlannerCubit(
      repository,
      clock: () => DateTime.utc(2026, 9, 21),
    );

    cubit.edit('needName', 'Щомісячна потреба');
    cubit.edit('needDate', '2026-10-31');
    cubit.edit('needAmount', '1000');
    cubit.edit('needRecurring', 'true');
    cubit.edit('needEveryMonths', '1');
    cubit.edit('needOccurrences', '3');

    expect(cubit.state.error, isNull);
    expect(cubit.state.expenseBalances, hasLength(3));
    expect(
      cubit.state.expenseBalances.map((e) => e.expense.date).toList(),
      ['2026-10-31', '2026-11-30', '2026-12-31'],
    );

    cubit.generate();
    expect(cubit.state.error, isNull);
    expect(await cubit.save(), true);

    final saved = repository.current!.sets.single;
    final rawNeeds = saved.scenario!['needs'] as List;
    final primary = Map<String, dynamic>.from(rawNeeds.first as Map);
    expect(primary['type'], 'recurring');
    expect(primary['everyMonths'], 1);
    expect(primary['occurrences'], 3);

    cubit.reset();
    expect(cubit.state.criteria['needRecurring'], 'false');

    cubit.load(saved);
    expect(cubit.state.error, isNull);
    expect(cubit.state.criteria['needName'], 'Щомісячна потреба');
    expect(cubit.state.criteria['needRecurring'], 'true');
    expect(cubit.state.criteria['needEveryMonths'], '1');
    expect(cubit.state.criteria['needOccurrences'], '3');
    expect(cubit.state.expenseBalances, hasLength(3));

    await cubit.close();
    await repository.dispose();
  });

  test('reserve floor is a minimum balance constraint, not a cash expense', () {
    final needs = [
      PlannerNeed(
        id: 'floor',
        name: 'Мінімальний залишок',
        type: PlannerNeedType.reserveFloor,
        date: '2026-02-01',
        amount: Decimal.parse('5000'),
      ),
      PlannerNeed(
        id: 'expense',
        name: 'Страхування',
        type: PlannerNeedType.oneOff,
        date: '2026-03-01',
        amount: Decimal.parse('1000'),
      ),
    ];

    final requirements = expandPlannerNeeds(needs, start: '2026-01-01');
    final funded = expenseCalendar(
      const [],
      Decimal.parse('6000'),
      '2026-01-01',
      requirements,
      0,
    );
    expect(funded, hasLength(2));
    expect(funded.first.expense.type, PlannerNeedType.reserveFloor);
    expect(funded.first.available, Decimal.parse('6000'));
    expect(funded.first.remaining, Decimal.parse('6000'));
    expect(funded.first.shortfall, Decimal.zero);
    expect(funded.last.remaining, Decimal.parse('5000'));
    expect(funded.last.shortfall, Decimal.zero);

    final underfunded = expenseCalendar(
      const [],
      Decimal.parse('5500'),
      '2026-01-01',
      requirements,
      0,
    );
    expect(underfunded.first.shortfall, Decimal.zero);
    expect(underfunded.last.remaining, Decimal.parse('4500'));
    expect(underfunded.last.shortfall, Decimal.parse('500'));
  });

  test('reserve floor survives Planner save and reload in schema 3', () async {
    final repository = FakeRepository(needsCatalog());
    final cubit = PlannerCubit(
      repository,
      clock: () => DateTime.utc(2026, 9, 21),
    );

    cubit.edit('reserveFloorEnabled', 'true');
    cubit.edit('reserveFloorName', 'Мій мінімальний залишок');
    cubit.edit('reserveFloorDate', '2026-12-01');
    cubit.edit('reserveFloorAmount', '15000');

    cubit.generate();
    expect(cubit.state.error, isNull);
    expect(await cubit.save(), true);

    final saved = repository.current!.sets.single;
    final rawNeeds = saved.scenario!['needs'] as List;
    final floor = rawNeeds
        .map((item) => Map<String, dynamic>.from(item as Map))
        .singleWhere((item) => item['type'] == 'reserveFloor');
    expect(floor['name'], 'Мій мінімальний залишок');
    expect(floor['date'], '2026-12-01');
    expect(floor['amount'], '15000');

    cubit.reset();
    expect(cubit.state.criteria['reserveFloorEnabled'], 'false');

    cubit.load(saved);
    expect(cubit.state.error, isNull);
    expect(cubit.state.criteria['reserveFloorEnabled'], 'true');
    expect(
      cubit.state.criteria['reserveFloorName'],
      'Мій мінімальний залишок',
    );
    expect(cubit.state.criteria['reserveFloorDate'], '2026-12-01');
    expect(cubit.state.criteria['reserveFloorAmount'], '15000');
    expect(
      cubit.state.expenseBalances.any(
        (row) => row.expense.type == PlannerNeedType.reserveFloor,
      ),
      true,
    );

    await cubit.close();
    await repository.dispose();
  });


  test('Planner export writes CSV and ICS without saving or mutating scenario', () async {
    final repository = FakeRepository(needsCatalog());
    final cubit = PlannerCubit(
      repository,
      clock: () => DateTime(2026, 9, 21, 14, 5, 6),
    );

    cubit.edit('reserveFloorEnabled', 'true');
    cubit.edit('reserveFloorDate', '2027-01-01');
    cubit.edit('reserveFloorAmount', '5000');
    cubit.generate();
    expect(cubit.state.error, isNull);
    expect(repository.saves, 0);

    String displayLabel(String value) {
      if (value == PlannerGeneratedCopy.planName) return 'Мій план';
      if (value == PlannerGeneratedCopy.primaryNeedName) {
        return 'Основна потреба';
      }
      if (value == PlannerGeneratedCopy.reserveFloorName) {
        return 'Мінімальний залишок';
      }
      final ordinal = PlannerGeneratedCopy.expenseOrdinal(value);
      return ordinal == null ? value : 'Витрата $ordinal';
    }

    expect(
      await cubit.exportCsvIcs(displayLabel: displayLabel),
      true,
    );
    expect(repository.saves, 0);
    expect(repository.exports, 1);
    expect(repository.exportBundles, hasLength(1));

    final entry = repository.exportBundles.entries.single;
    expect(
      entry.key,
      'OVDP-Hub-Мій план-2026-09-21_140506',
    );
    expect(entry.value.keys.toSet(), {'planner.csv', 'planner.ics'});
    expect(entry.value['planner.csv'], contains('Мій план'));
    expect(entry.value['planner.csv'], contains('Мінімальний залишок'));
    expect(entry.value['planner.ics'], contains('Мінімальний залишок'));
    expect(
      cubit.state.lastExportPath,
      'local/exports/OVDP-Hub-Мій план-2026-09-21_140506',
    );
    expect(cubit.state.saved, false);

    await cubit.close();
    await repository.dispose();
  });

}
