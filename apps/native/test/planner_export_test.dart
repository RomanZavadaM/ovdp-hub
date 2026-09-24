import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/planner/planner_export.dart';
import 'package:ovdp_hub/features/planner/planner_goals.dart';
import 'package:ovdp_hub/features/planner/planner_engine.dart';
import 'package:ovdp_hub/features/planner/planner_scenario.dart';

import 'support/planner_comparison_fixtures.dart';

void main() {
  test('CSV and ICS exports are deterministic and include floor plus receipts', () {
    final catalog = comparisonCatalog();
    final bond = catalog.bonds.first;
    final scenario = comparisonScenario(
      bond,
      name: 'План, тест; X',
      purchasePrice: '980',
      reserveFloorAmount: '5000',
      reserveFloorDate: '2027-01-01',
      positionExits: [
        comparisonExit(
          bond,
          date: '2027-05-01',
          price: '990',
        ),
      ],
    );

    final position = PlanPosition(
      bond,
      1,
      Decimal.parse('980'),
      nominalEstimate: false,
    );
    final coverage = expenseCalendar(
      [position],
      scenario.budget,
      scenario.startDate,
      expandPlannerNeeds(
        scenario.needs,
        start: scenario.startDate,
      ),
      scenario.settlementDelayDays,
      exits: {
        bond.isin: PlanExitOverride(
          bond.isin,
          '2027-05-01',
          Decimal.parse('990'),
        ),
      },
    );

    final csvA = buildPlannerCsv(
      scenario: scenario,
      bonds: {bond.isin: bond},
      coverage: coverage,
    );
    final csvB = buildPlannerCsv(
      scenario: scenario,
      bonds: {bond.isin: bond},
      coverage: coverage,
    );
    expect(csvB, csvA);
    expect(csvA.startsWith('\uFEFFrecord_type,id,date'), true);
    expect(csvA, contains('need_rule,reserve-floor,2027-01-01'));
    expect(csvA, contains(',reserveFloor,UAH,5000,'));
    expect(csvA, contains('receipt,receipt:${bond.isin}:COUPON:2027-03-01,2027-03-03,2027-03-01'));
    expect(csvA, contains('receipt,receipt:${bond.isin}:sale:2027-05-01,2027-05-03,2027-05-01'));
    expect(csvA, isNot(contains('2027-09-23,2027-09-23')));

    final icsA = buildPlannerIcs(
      scenario: scenario,
      bonds: {bond.isin: bond},
      coverage: coverage,
    );
    final icsB = buildPlannerIcs(
      scenario: scenario,
      bonds: {bond.isin: bond},
      coverage: coverage,
    );
    expect(icsB, icsA);
    expect(icsA, startsWith('BEGIN:VCALENDAR\r\nVERSION:2.0\r\n'));
    expect(icsA, contains('DTSTAMP:20260923T000000Z'));
    expect(icsA, contains('DTSTART;VALUE=DATE:20270101'));
    expect(icsA, contains('DTSTART;VALUE=DATE:20270303'));
    expect(icsA, contains('DTSTART;VALUE=DATE:20270503'));
    expect(icsA, contains('X-WR-CALNAME:План\\, тест\\; X'));
    expect(icsA, isNot(contains('DTSTART;VALUE=DATE:20270925')));

    expect(plannerExportStem(scenario), plannerExportStem(scenario));
    expect(
      plannerExportStem(scenario),
      matches(RegExp(r'^ovdp-planner-20260923-[0-9a-f]{8}$')),
    );
  });

  test('generated names are rendered without persisted marker syntax', () {
    expect(
      plannerExportDisplayName(PlannerGeneratedCopy.planName),
      'Plan',
    );
    expect(
      plannerExportDisplayName(PlannerGeneratedCopy.primaryNeedName),
      'Primary need',
    );
    expect(
      plannerExportDisplayName(PlannerGeneratedCopy.reserveFloorName),
      'Minimum balance',
    );
    expect(
      plannerExportDisplayName(PlannerGeneratedCopy.expenseName(3)),
      'Expense 3',
    );
    expect(plannerExportDisplayName('Моя подія'), 'Моя подія');
  });
}
