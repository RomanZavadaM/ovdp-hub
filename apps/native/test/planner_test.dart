import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/models.dart';
import 'package:ovdp_hub/features/planner/planner_engine.dart';
import 'package:ovdp_hub/features/planner/planner_cubit.dart';
import 'package:ovdp_hub/features/collections/editor_cubit.dart';
import 'package:ovdp_hub/features/workspace/workspace_cubit.dart';
import 'support/fake_repository.dart';

Bond bond(
  String isin,
  String maturity, {
  String currency = 'UAH',
  List<Map<String, String>>? payments,
}) => Bond({
  'isin': isin,
  'currency': currency,
  'nominal': '1000',
  'nominalRate': '10',
  'issueDate': '2025-01-01',
  'maturityDate': maturity,
  'payments':
      payments ??
      [
        {'date': maturity, 'kind': 'REDEMPTION', 'amount': '1000'},
      ],
});
Catalog catalog(List<Bond> bonds) => Catalog.parse(
  jsonEncode({
    'schemaVersion': 1,
    'retrievedAt': '2026-09-21T00:00:00Z',
    'assets': bonds.map((b) => b.json).toList(),
  }),
);
void main() {
  final one = bond(
    'UA4000187348',
    '2027-09-21',
    payments: [
      {'date': '2026-09-21', 'kind': 'COUPON', 'amount': '50'},
      {'date': '2026-10-21', 'kind': 'COUPON', 'amount': '50'},
      {'date': '2027-09-21', 'kind': 'COUPON', 'amount': '50'},
      {'date': '2027-09-21', 'kind': 'REDEMPTION', 'amount': '1000'},
      {'date': '2027-01-21', 'kind': 'EARLY_REDEMPTION', 'amount': '1000'},
    ],
  );
  final two = bond('UA4000236541', '2028-09-21');
  final data = catalog([one, two]);
  test(
    'criteria exclude matured and other currencies; range endpoints included',
    () {
      final c = catalog([
        one,
        two,
        bond('UA4000237432', '2026-09-21'),
        bond('UA4000237994', '2027-09-21', currency: 'USD'),
      ]);
      expect(
        eligibleBonds(
          c,
          'UAH',
          '2026-09-21',
          '2027-09-21',
          '2028-09-21',
        ).map((b) => b.isin),
        [one.isin, two.isin],
      );
      expect(
        () => eligibleBonds(c, 'UAH', '2026-09-21', '2029-01-01', '2028-01-01'),
        throwsFormatException,
      );
    },
  );
  test('ladder respects integer lots, reserve and budget', () {
    final positions = makeLadder(
      [one, two],
      Decimal.parse('10500'),
      Decimal.parse('1000'),
    );
    final cost = positions.fold(Decimal.zero, (s, p) => s + p.cost);
    expect(cost.toString(), '8000');
    expect(positions.map((p) => p.quantity), [4, 4]);
    expect(
      () => makeLadder([one], Decimal.parse('999'), Decimal.zero),
      throwsFormatException,
    );
  });
  test(
    'cash needs split coupons and returned principal; conditional redemption excluded',
    () {
      final summary = summarizePlan(
        positions: [
          PlanPosition(one, 2, Decimal.parse('1010'), nominalEstimate: false),
        ],
        currency: 'UAH',
        budget: Decimal.parse('2500'),
        start: '2026-09-21',
        needDate: '2027-02-01',
        needAmount: Decimal.parse('1000'),
      );
      expect(summary.cost.toString(), '2020');
      expect(summary.reserve.toString(), '480');
      expect(summary.couponsByNeed.toString(), '100');
      expect(summary.principalByNeed, Decimal.zero);
      expect(summary.availableByNeed.toString(), '580');
      expect(summary.shortfall.toString(), '420');
      expect(summary.hasConditionalPayments, true);
      expect(summary.containsEstimates, false);
      expect(summary.months.first.total, Decimal.zero);
      expect(
        summary.months.firstWhere((m) => m.month == '2026-11').total,
        Decimal.zero,
      );
      expect(summary.months.last.principal.toString(), '2000');
    },
  );
  test('overspend, mixed currencies and fractional quantities rejected', () {
    expect(
      () => summarizePlan(
        positions: [PlanPosition(one, 3, Decimal.parse('1000'))],
        currency: 'UAH',
        budget: Decimal.parse('2500'),
        start: '2026-09-21',
        needDate: '2027-02-01',
        needAmount: Decimal.zero,
      ),
      throwsFormatException,
    );
    expect(
      () => summarizePlan(
        positions: [PlanPosition(one, 1, Decimal.parse('1000'))],
        currency: 'USD',
        budget: Decimal.parse('2500'),
        start: '2026-09-21',
        needDate: '2027-02-01',
        needAmount: Decimal.zero,
      ),
      throwsFormatException,
    );
    expect(
      () => PositionInput(one, '1.5', '1000').parse(),
      throwsFormatException,
    );
  });
  test(
    'scenario persists quantities prices and need date and reloads identically',
    () async {
      final repository = FakeRepository(data);
      final cubit = PlannerCubit(
        repository,
        clock: () => DateTime.utc(2026, 9, 21),
      );
      cubit.generate();
      cubit.position(one.isin, quantity: '3', price: '1050.25');
      expect(cubit.state.inputs[one.isin]!.quantity, '3');
      expect(cubit.state.error, isNull);
      final before = cubit.state.summary!.availableByNeed;
      expect(await cubit.save(), true);
      final saved = SavedSet.parse(
        jsonEncode(repository.current!.sets.single.toJson()),
      );
      cubit.reset();
      cubit.load(saved);
      expect(cubit.state.inputs[one.isin]!.quantity, '3');
      expect(cubit.state.inputs[one.isin]!.price, '1050.25');
      expect(cubit.state.inputs[one.isin]!.nominalEstimate, false);
      expect(cubit.state.summary!.availableByNeed, before);
      cubit.position(one.isin, quantity: '999999');
      expect(cubit.state.summary, isNull);
      expect(await cubit.save(), false);
      await cubit.close();
      await repository.dispose();
    },
  );
  test('price sources add select reorder persist and return to nominal', () async {
    final repository = FakeRepository(data);
    final cubit = PlannerCubit(
      repository,
      clock: () => DateTime.utc(2026, 9, 21),
    );
    cubit.generate();

    cubit.addManualPriceSource(one.isin, 'Seller A', '990');
    expect(cubit.state.inputs[one.isin]!.selectedSourceId, 'user:Seller A');
    expect(cubit.state.inputs[one.isin]!.price, '990');

    cubit.addManualPriceSource(one.isin, 'Seller B', '995');
    cubit.selectPriceSource(one.isin, 'user:Seller B');
    expect(cubit.state.inputs[one.isin]!.selectedSourceId, 'user:Seller B');
    expect(cubit.state.inputs[one.isin]!.price, '995');

    cubit.movePriceSource('user:Seller B', 1);
    expect(
      cubit.state.priceSourcePriority.sourceIds.take(2),
      ['user:Seller A', 'user:Seller B'],
    );
    expect(cubit.state.inputs[one.isin]!.selectedSourceId, 'user:Seller A');
    expect(cubit.state.inputs[one.isin]!.price, '990');

    expect(await cubit.save(), true);
    final saved = repository.current!.sets.single;
    cubit.reset();
    cubit.load(saved);

    expect(
      cubit.state.priceSourcePriority.sourceIds.take(2),
      ['user:Seller A', 'user:Seller B'],
    );
    expect(cubit.state.inputs[one.isin]!.selectedSourceId, 'user:Seller A');
    expect(cubit.state.inputs[one.isin]!.observations.length, greaterThanOrEqualTo(3));

    cubit.useNominalEstimate(one.isin);
    expect(cubit.state.inputs[one.isin]!.nominalEstimate, true);
    expect(cubit.state.inputs[one.isin]!.selectedSourceId, isNull);
    expect(cubit.state.inputs[one.isin]!.price, '1000');
    expect(cubit.state.summary, isNotNull);

    await cubit.close();
    await repository.dispose();
  });

  test('workspace change protects planner draft on cancellation', () async {
    final repository = FakeRepository(data);
    final planner = PlannerCubit(
      repository,
      clock: () => DateTime.utc(2026, 9, 21),
    )..generate();
    final editor = CollectionEditorCubit(repository);
    final workspace = WorkspaceCubit(repository, editor, planner: planner);
    await workspace.choose();
    expect(repository.switches, 0);
    await workspace.choose(discardDraft: true);
    expect(planner.state.dirty, true);
    repository.switchAccepted = true;
    await workspace.choose(discardDraft: true);
    expect(planner.state.inputs, isEmpty);
    await workspace.close();
    await editor.close();
    await planner.close();
    await repository.dispose();
  });
  test('old saved collection without scenario remains readable', () {
    final old = SavedSet('old', '', '2026-09-21T00:00:00Z', [one]);
    expect(SavedSet.parse(jsonEncode(old.toJson())).scenario, isNull);
  });
}
