import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/planner/planner_engine.dart';
import 'package:ovdp_hub/features/planner/planner_export.dart';
import 'package:ovdp_hub/features/planner/planner_goals.dart';
import 'package:ovdp_hub/features/planner/planner_scenario.dart';

import 'support/planner_comparison_fixtures.dart';

void main() {
  test('CSV and ICS export is deterministic and preserves Planner semantics', () {
    final catalog = comparisonCatalog();
    final bond = catalog.bonds.first;
    final scenario = comparisonScenario(
      bond,
      name: 'План, "А"',
      budget: '100000',
      reserve: '10000',
      purchasePrice: '980',
      needType: PlannerNeedType.recurring,
      needAmount: '1000',
      reserveFloorAmount: '95000',
      reserveFloorDate: '2027-01-01',
    );
    final position = PlanPosition(
      bond,
      1,
      Decimal.parse('980'),
      nominalEstimate: false,
    );
    final requirements = expandPlannerNeeds(
      scenario.needs,
      start: scenario.startDate,
    );
    final balances = expenseCalendar(
      [position],
      scenario.budget,
      scenario.startDate,
      requirements,
      scenario.settlementDelayDays,
    );

    String ukrainianLabel(String value) =>
        value == PlannerGeneratedCopy.reserveFloorName
            ? 'Мінімальний залишок'
            : value;
    String englishLabel(String value) =>
        value == PlannerGeneratedCopy.reserveFloorName
            ? 'Minimum balance'
            : value;

    final first = buildPlannerExportBundle(
      scenario: scenario,
      bonds: catalog.bonds,
      expenseBalances: balances,
      displayLabel: ukrainianLabel,
    );
    final second = buildPlannerExportBundle(
      scenario: scenario,
      bonds: catalog.bonds,
      expenseBalances: balances,
      displayLabel: ukrainianLabel,
    );

    expect(first.csv, second.csv);
    expect(first.ics, second.ics);
    expect(first.csv.startsWith('\ufeffscenario_name,currency,'), true);
    expect(first.csv, contains('"План, ""А"""'));
    expect(first.csv, contains(',POSITION,'));
    expect(first.csv, contains(',NEED_RECURRING,'));
    expect(first.csv, contains(',RESERVE_FLOOR,'));
    expect(first.csv, contains('Мінімальний залишок'));
    expect(first.csv, isNot(contains(PlannerGeneratedCopy.reserveFloorName)));
    expect(first.csv, contains(',COUPON,'));
    expect(first.csv, contains(',REDEMPTION,'));

    final floorLine = first.csv
        .split('\n')
        .firstWhere((line) => line.contains(',RESERVE_FLOOR,'));
    final floorColumns = floorLine.split(',');
    // available and remaining are the final 3rd/2nd fields and are equal:
    // reserve floor is not spent. The scenario name itself contains a comma
    // and therefore intentionally exercises CSV quoting.
    expect(
      floorColumns[floorColumns.length - 3],
      floorColumns[floorColumns.length - 2],
    );

    expect(first.ics, startsWith('BEGIN:VCALENDAR\r\n'));
    expect(first.ics, endsWith('END:VCALENDAR\r\n'));
    expect(first.ics, contains('DTSTART;VALUE=DATE:20270101'));
    // Coupon date 2027-03-01 plus the scenario's 2-day settlement delay.
    expect(first.ics, contains('DTSTART;VALUE=DATE:20270303'));
    expect(first.ics, contains('RESERVE_FLOOR'));
    expect(first.ics, contains('Мінімальний залишок'));
    expect(first.ics, isNot(contains('POSITION')));

    final english = buildPlannerExportBundle(
      scenario: scenario,
      bonds: catalog.bonds,
      expenseBalances: balances,
      displayLabel: englishLabel,
    );
    List<String> uids(String ics) => ics
        .split('\r\n')
        .where((line) => line.startsWith('UID:'))
        .toList(growable: false);
    expect(uids(english.ics), uids(first.ics));
    expect(english.ics, contains('Minimum balance'));
  });

  test('early sale replaces later contractual receipts in export calendar', () {
    final catalog = comparisonCatalog();
    final bond = catalog.bonds.first;
    final exit = comparisonExit(
      bond,
      date: '2027-05-01',
      price: '990',
    );
    final scenario = comparisonScenario(
      bond,
      purchasePrice: '980',
      positionExits: [exit],
    );
    final position = PlanPosition(
      bond,
      1,
      Decimal.parse('980'),
      nominalEstimate: false,
    );
    final balances = expenseCalendar(
      [position],
      scenario.budget,
      scenario.startDate,
      expandPlannerNeeds(scenario.needs, start: scenario.startDate),
      scenario.settlementDelayDays,
      exits: {
        bond.isin: PlanExitOverride(
          bond.isin,
          exit.date,
          exit.price.effectiveUnitCost!,
        ),
      },
    );

    final bundle = buildPlannerExportBundle(
      scenario: scenario,
      bonds: catalog.bonds,
      expenseBalances: balances,
    );

    expect(bundle.csv, contains(',SALE,'));
    expect(bundle.ics, contains('DTSTART;VALUE=DATE:20270503'));
    // Redemption after the explicit sale must not be exported.
    expect(bundle.csv, isNot(contains(',REDEMPTION,')));
  });

  test('export folder name stays human-readable and removes unsafe characters', () {
    final name = plannerExportFolderName(
      '  Мій: план / тест*?  ',
      DateTime(2026, 9, 24, 15, 7, 9),
    );

    expect(name, 'OVDP-Hub-Мій_ план _ тест__-2026-09-24_150709');
    expect(name, isNot(contains('/')));
    expect(name, isNot(contains(':')));
  });
}
