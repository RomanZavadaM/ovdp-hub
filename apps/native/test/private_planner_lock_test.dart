import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/planner/planner_cubit.dart';
import 'package:ovdp_hub/features/portfolio/portfolio_cubit.dart';
import 'package:ovdp_hub/features/portfolio/private_portfolio.dart';
import 'package:ovdp_hub/models.dart';

import 'support/fake_portfolio_gateway.dart';
import 'support/fake_repository.dart';
import 'support/planner_comparison_fixtures.dart';

class PausedExportRepository extends FakeRepository {
  final started = Completer<void>();
  final resume = Completer<void>();
  PausedExportRepository(super.catalog);

  @override
  Future<String> saveTextExport(String fileName, String content) async {
    started.complete();
    await resume.future;
    return super.saveTextExport(fileName, content);
  }
}

void main() {
  final catalog = comparisonCatalog();
  SavedSet privatePlan() => comparisonSavedSet(
    catalog.bonds.first,
    name: 'Private plan',
    savedAt: '2026-09-23T12:00:00Z',
    budget: '654321',
  ).withStorage(recordId: 'private-plan', storedInVault: true);

  late FakeRepository hub;
  late FakePortfolioGateway gateway;
  late PortfolioCubit portfolio;
  late PlannerCubit planner;

  setUp(() async {
    hub = FakeRepository(catalog);
    gateway = FakePortfolioGateway(
      stored: PrivatePortfolioPayload(portfolioId: 'primary'),
    );
    portfolio = PortfolioCubit(hub, gateway);
    await portfolio.open();
    planner = PlannerCubit(
      hub,
      portfolio: portfolio,
      clock: () => DateTime.utc(2026, 9, 23),
    );
  });

  tearDown(() async {
    await planner.close();
    await portfolio.close();
    await hub.dispose();
  });

  test('manual lock clears edited private input, calculations and exports', () async {
    planner.load(privatePlan());
    expect(planner.state.privateDraft, isTrue);
    expect(planner.state.summary, isNotNull);
    planner.edit('budget', '765432');
    await portfolio.lock();

    expect(planner.state.privateDraft, isFalse);
    expect(planner.state.criteria['budget'], '100000');
    expect(planner.state.criteria['name'], isNot('Private plan'));
    expect(planner.state.inputs, isEmpty);
    expect(planner.state.summary, isNull);
    expect(planner.state.expenseBalances, isEmpty);
    expect(planner.state.fx, isEmpty);
    expect(planner.state.positionExits, isEmpty);
    expect(await planner.exportCsv(), isNull);
    expect(await planner.exportIcs(), isNull);
    expect(hub.exports, 0);

    await portfolio.open();
    expect(planner.state.inputs, isEmpty);
    expect(planner.state.criteria['budget'], '100000');
  });

  test('automatic session lock clears private state even while workspace is locked', () async {
    planner.load(privatePlan());
    planner.lock(true);
    await gateway.lock();
    expect(planner.state.locked, isTrue);
    expect(planner.state.inputs, isEmpty);
    expect(planner.state.privacyRevision, 1);
  });

  test('new and public drafts survive portfolio lock', () async {
    planner.edit('budget', '345678');
    await gateway.lock();
    expect(planner.state.criteria['budget'], '345678');
    expect(planner.state.privacyRevision, 0);
    await portfolio.open();
    planner.load(privatePlan().withStorage());
    await gateway.lock();
    expect(planner.state.criteria['budget'], '654321');
    expect(planner.state.inputs, isNotEmpty);
    expect(planner.state.privacyRevision, 0);
  });

  test('stale vault references cannot reload a private scenario after lock', () async {
    final reference = privatePlan();
    await portfolio.lock();
    planner.load(reference);
    expect(planner.state.inputs, isEmpty);
    expect(planner.state.error?.code, 'planner.private_scenario_locked');
  });

  test('late save completion does not mark a purged draft as saved', () async {
    await planner.close();
    final started = Completer<void>();
    final resume = Completer<void>();
    planner = PlannerCubit(
      hub,
      portfolio: portfolio,
      clock: () => DateTime.utc(2026, 9, 23),
      saveScenario: (_) async {
        started.complete();
        await resume.future;
      },
    );
    planner.load(privatePlan());
    final saving = planner.save();
    await started.future;
    expect(planner.state.busy, isTrue);
    await gateway.lock();
    expect(planner.state.inputs, isEmpty);
    expect(planner.state.busy, isFalse);
    resume.complete();
    expect(await saving, isFalse);
    expect(planner.state.saved, isFalse);
    expect(planner.state.inputs, isEmpty);
  });

  test('failed save to an already locked vault preserves a new public draft', () async {
    await planner.close();
    planner = PlannerCubit(
      hub,
      portfolio: portfolio,
      clock: () => DateTime.utc(2026, 9, 23),
      saveScenario: portfolio.savePrivateScenario,
    );
    planner.load(privatePlan().withStorage());
    await gateway.lock();
    expect(await planner.save(), isFalse);
    expect(planner.state.privateDraft, isFalse);
    expect(planner.state.criteria['budget'], '654321');
    expect(planner.state.inputs, isNotEmpty);
  });

  test('late export result is suppressed after private data is cleared', () async {
    await planner.close();
    final exportingHub = PausedExportRepository(catalog);
    planner = PlannerCubit(exportingHub, portfolio: portfolio);
    planner.load(privatePlan());
    final exporting = planner.exportCsv();
    await exportingHub.started.future;
    await gateway.lock();
    exportingHub.resume.complete();
    expect(await exporting, isNull);
    expect(planner.state.inputs, isEmpty);
    expect(planner.state.error, isNull);
    await exportingHub.dispose();
  });
}
