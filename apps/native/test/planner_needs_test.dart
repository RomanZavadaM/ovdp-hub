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
}
