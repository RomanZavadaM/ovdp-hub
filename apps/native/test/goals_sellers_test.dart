import 'dart:convert';
import 'dart:io';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ovdp_hub/features/planner/planner_engine.dart';
import 'package:ovdp_hub/features/planner/planner_goals.dart';
import 'package:ovdp_hub/features/planner/planner_cubit.dart';
import 'package:ovdp_hub/features/sellers/seller_repository.dart';
import 'package:ovdp_hub/features/sellers/sellers_cubit.dart';
import 'package:ovdp_hub/data/source_observation.dart';
import 'package:ovdp_hub/models.dart';
import 'planner_test.dart' as fixture;
import 'support/fake_repository.dart';

Decimal d(String s) => Decimal.parse(s);
void main() {
  final bond = fixture.bond(
    'UA4000187348',
    '2027-01-01',
    payments: [
      {'date': '2026-10-01', 'kind': 'COUPON', 'amount': '100'},
      {'date': '2027-01-01', 'kind': 'REDEMPTION', 'amount': '1000'},
    ],
  );
  test('expenses consume cash once, preserve deficits and wait for buffer', () {
    final rows = expenseCalendar(
      [PlanPosition(bond, 1, d('1000'))],
      d('1500'),
      '2026-09-21',
      [
        CashExpense('one', '2026-10-01', d('550')),
        CashExpense('two', '2026-10-03', d('100')),
        CashExpense('three', '2027-01-03', d('100')),
      ],
      2,
    );
    expect(rows.map((r) => r.remaining), [d('-50'), d('-50'), d('850')]);
  });
  test('profit uses full price rather than coupon ranking', () {
    final cheapBond = fixture.bond('UA4000236541', '2027-01-01');
    final result = suggestProfitablePlan(
      offers: [
        PlanPosition(bond, 1, d('1150')),
        PlanPosition(cheapBond, 1, d('900'), nominalEstimate: false),
      ],
      budget: d('10000'),
      reserve: d('1000'),
      start: '2026-09-21',
      expenses: [],
      delay: 2,
    );
    expect(result.single.bond.isin, cheapBond.isin);
    expect(result.single.quantity, 10);
    expect(totalProfit(result, '2026-09-21'), d('1000'));
  });
  test('expense strategy preserves reserve after every expense', () {
    final expenses = [
      CashExpense('rent', '2026-09-25', d('2000')),
      CashExpense('trip', '2026-10-03', d('1500')),
    ];
    final result = suggestProfitablePlan(
      offers: [PlanPosition(bond, 1, d('1000'))],
      budget: d('10000'),
      reserve: d('1000'),
      start: '2026-09-21',
      expenses: expenses,
      delay: 2,
    );
    expect(result.single.quantity, 6);
    expect(
      expenseCalendar(
        result,
        d('10000'),
        '2026-09-21',
        expenses,
        2,
      ).every((e) => e.remaining >= d('1000')),
      true,
    );
  });
  test('unfunded expenses cannot silently pass', () {
    expect(
      () => suggestProfitablePlan(
        offers: [PlanPosition(bond, 1, d('1000'))],
        budget: d('1000'),
        reserve: d('100'),
        start: '2026-09-21',
        expenses: [CashExpense('rent', '2026-09-22', d('1100'))],
        delay: 2,
      ),
      throwsFormatException,
    );
  });
  test('multiple expenses and manual prices restore', () async {
    final repo = FakeRepository(fixture.catalog([bond]));
    final cubit = PlannerCubit(repo, clock: () => DateTime(2026, 9, 21));
    cubit.toggle(bond, true);
    cubit.position(bond.isin, price: '950');
    cubit.edit('strategy', 'expenses');
    cubit.addExpense();
    cubit.edit('expenseDate0', '2026-12-01');
    cubit.edit('expenseAmount0', '1200');
    cubit.edit('expenseName0', 'Навчання');
    expect(await cubit.save(), true);
    final saved = SavedSet.parse(
      jsonEncode(repo.current!.sets.single.toJson()),
    );
    cubit.reset();
    cubit.load(saved);
    expect(cubit.state.criteria['expenseName0'], 'Навчання');
    expect(cubit.state.expenseBalances.length, 2);
    expect(cubit.state.inputs[bond.isin]!.nominalEstimate, false);
    cubit.removeExpense(0);
    expect(cubit.state.expenseBalances.length, 1);
    await cubit.close();
    await repo.dispose();
  });
  test(
    'monthly repeats clamp month ends and protect expense-only draft',
    () async {
      final repo = FakeRepository(fixture.catalog([bond]));
      final cubit = PlannerCubit(repo, clock: () => DateTime(2026, 9, 21));
      cubit.edit('needDate', '2027-01-31');
      cubit.repeatMonthly();
      expect(cubit.state.criteria['expenseDate0'], '2027-02-28');
      expect(cubit.state.criteria['expenseDate1'], '2027-03-31');
      expect(cubit.state.criteria['expenseCount'], '5');
      expect(cubit.state.dirty, true);
      await cubit.close();
      await repo.dispose();
    },
  );
  test(
    'repeated optimization retains prices of previously rejected candidates',
    () async {
      final other = fixture.bond('UA4000236541', '2027-01-01');
      final repo = FakeRepository(fixture.catalog([bond, other]));
      final cubit = PlannerCubit(repo, clock: () => DateTime(2026, 9, 21));
      cubit.edit('strategy', 'profit');
      cubit.toggle(bond, true);
      cubit.position(bond.isin, price: '1150');
      cubit.toggle(other, true);
      cubit.position(other.isin, price: '900');
      cubit.generate();
      expect(cubit.state.inputs.containsKey(bond.isin), false);
      cubit.generate();
      expect(cubit.state.inputs.containsKey(bond.isin), false);
      cubit.toggle(bond, true);
      expect(cubit.state.inputs[bond.isin]!.price, '1150');
      await cubit.close();
      await repo.dispose();
    },
  );
  final html = File('test/fixtures/privat-quotes.html').readAsStringSync();
  test(
    'seller adapter preserves currencies and missing ASK from observed HTML',
    () {
      final snap = parsePrivatQuotes(html, DateTime(2026, 9, 21));
      expect(snap.sourceDate, '2026-09-22');
      expect(snap.quotes.first.currency, 'USD');
      expect(snap.quotes.first.askYield, '1.7500');
      expect(snap.quotes[1].askYield, isNull);
      expect(snap.quotes.map((q) => q.currency).toSet(), {'UAH', 'USD', 'EUR'});
    },
  );
  test('seller adapter rejects changed headings and impossible date', () {
    expect(
      () => parsePrivatQuotes(
        html.replaceAll('ASK Yield', 'Changed'),
        DateTime(2026, 9, 21),
      ),
      throwsFormatException,
    );
    expect(
      () => parsePrivatQuotes(
        html.replaceAll('22.09.2026', '31.02.2026'),
        DateTime(2026, 9, 21),
      ),
      throwsFormatException,
    );
  });
  test('failed refresh retains snapshot and warns on future date', () async {
    var fail = false;
    final repo = SellerRepository(
      client: MockClient(
        (_) async => http.Response(
          fail ? 'error' : html,
          fail ? 503 : 200,
          headers: {'content-type': 'text/html; charset=utf-8'},
        ),
      ),
      clock: () => DateTime(2026, 9, 21),
    );
    final cubit = SellersCubit(repo);
    await cubit.refresh();
    expect(cubit.state.error, isNull);
    expect(cubit.freshness, DataFreshness.futureDated);
    cubit.currency('USD');
    expect(cubit.visible.every((q) => q.askYield != null), true);
    final before = cubit.state.snapshot;
    fail = true;
    await cubit.refresh();
    expect(cubit.state.snapshot, same(before));
    expect(cubit.state.error?.code, 'seller.http_status');
    expect(cubit.state.error?.parameters['status'], 503);
    await cubit.close();
  });
}
