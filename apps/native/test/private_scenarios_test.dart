import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/collections/collections_cubit.dart';
import 'package:ovdp_hub/features/portfolio/portfolio_cubit.dart';
import 'package:ovdp_hub/features/portfolio/private_portfolio.dart';
import 'package:ovdp_hub/models.dart';
import 'package:ovdp_hub/workspace.dart';
import 'package:path/path.dart' as p;

import 'support/fake_portfolio_gateway.dart';
import 'support/fake_repository.dart';

void main() {
  late Catalog catalog;

  setUpAll(() {
    final json =
        jsonDecode(File('assets/nbu-snapshot.json').readAsStringSync())
            as Map<String, dynamic>;
    json['assets'] = [(json['assets'] as List).last];
    catalog = Catalog.parse(jsonEncode(json));
  });

  SavedSet scenarioSet(String name, {String savedAt = '2026-09-24T12:00:00Z'}) =>
      SavedSet(
        name,
        'Private note',
        savedAt,
        [catalog.bonds.single],
        scenario: {
          'schemaVersion': 99,
          'budget': '250000',
        },
      );

  SavedSet publicSet(String name) => SavedSet(
    name,
    'Public list',
    '2026-09-23T12:00:00Z',
    [catalog.bonds.single],
  );

  group('payload schema', () {
    test('private scenario records round-trip with their bond snapshot', () {
      final payload = PrivatePortfolioPayload(
        portfolioId: 'primary',
        privateScenarios: [
          PrivateScenarioRecord(id: 'scenario-1', set: scenarioSet('Plan A')),
        ],
      );
      final decoded = PrivatePortfolioPayloadCodec.decode(
        PrivatePortfolioPayloadCodec.encode(payload),
      );
      final record = decoded.privateScenarios.single;
      expect(record.id, 'scenario-1');
      expect(record.set.name, 'Plan A');
      expect(record.set.bonds.single.isin, catalog.bonds.single.isin);
      expect(record.set.scenario!['budget'], '250000');
    });

    test('schema v3 payload decodes with no private scenarios', () {
      final v3 = Uint8List.fromList(
        utf8.encode(
          '{"schemaVersion":3,"portfolioId":"v3","acquisitionLots":[],'
          '"cashEvents":[],"disposals":[],"legacyCollections":[]}',
        ),
      );
      final decoded = PrivatePortfolioPayloadCodec.decode(v3);
      expect(decoded.privateScenarios, isEmpty);
      expect(
        utf8.decode(PrivatePortfolioPayloadCodec.encode(decoded)),
        contains('"privateScenarios":[]'),
      );
    });

    test('records without a scenario or with duplicate ids are rejected', () {
      expect(
        () => PrivateScenarioRecord(id: 'scenario-1', set: publicSet('List')),
        throwsFormatException,
      );
      expect(
        () => PrivatePortfolioPayload(
          portfolioId: 'primary',
          privateScenarios: [
            PrivateScenarioRecord(id: 'same', set: scenarioSet('A')),
            PrivateScenarioRecord(id: 'same', set: scenarioSet('B')),
          ],
        ),
        throwsFormatException,
      );
    });
  });

  group('portfolio cubit', () {
    test('saving a scenario needs an unlocked portfolio', () async {
      final hub = FakeRepository(catalog);
      final missing = PortfolioCubit(hub, FakePortfolioGateway());
      await missing.initialize();
      await expectLater(
        missing.savePrivateScenario(scenarioSet('Plan')),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'planner.private_scenario_no_portfolio',
          ),
        ),
      );

      final locked = PortfolioCubit(
        hub,
        FakePortfolioGateway(
          stored: PrivatePortfolioPayload(portfolioId: 'primary'),
        ),
      );
      await locked.initialize();
      await expectLater(
        locked.savePrivateScenario(scenarioSet('Plan')),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'planner.private_scenario_locked',
          ),
        ),
      );
      expect(hub.saves, 0);

      await missing.close();
      await locked.close();
      await hub.dispose();
    });

    test('saved private scenarios stay out of the workspace', () async {
      final hub = FakeRepository(catalog);
      final gateway = FakePortfolioGateway(
        stored: PrivatePortfolioPayload(portfolioId: 'primary'),
      );
      final cubit = PortfolioCubit(hub, gateway);
      await cubit.initialize();
      await cubit.open();

      await cubit.savePrivateScenario(scenarioSet('Plan'));

      expect(hub.saves, 0);
      expect(gateway.stored!.privateScenarios.single.set.name, 'Plan');
      final listed = cubit.privateScenarioSets.single;
      expect(listed.storedInVault, isTrue);
      expect(listed.recordId, gateway.stored!.privateScenarios.single.id);

      await cubit.close();
      await hub.dispose();
    });

    test('plaintext scenarios move into the vault and their files are deleted', () async {
      final hub = FakeRepository(catalog);
      await hub.saveCollection(publicSet('Bond list'));
      await hub.saveCollection(scenarioSet('Old plan'));
      final scenarioRecordId = hub.current!.sets
          .firstWhere((set) => set.scenario != null)
          .recordId!;
      final publicRecordId = hub.current!.sets
          .firstWhere((set) => set.scenario == null)
          .recordId!;

      final gateway = FakePortfolioGateway(
        stored: PrivatePortfolioPayload(portfolioId: 'primary'),
      );
      final cubit = PortfolioCubit(hub, gateway);
      await cubit.initialize();
      await cubit.open();

      await cubit.movePlaintextScenariosToVault();

      expect(cubit.state.errorCode, isNull);
      expect(cubit.state.movedScenarioCount, 1);
      expect(hub.deletedRecordIds, [scenarioRecordId]);
      expect(hub.current!.sets.single.recordId, publicRecordId);
      final moved = gateway.stored!.privateScenarios.single;
      expect(moved.id, 'workspace-$scenarioRecordId');
      expect(moved.set.name, 'Old plan');
      expect(moved.set.scenario!['budget'], '250000');

      // Running again is a no-op and never duplicates records.
      await cubit.movePlaintextScenariosToVault();
      expect(cubit.state.movedScenarioCount, 0);
      expect(gateway.stored!.privateScenarios, hasLength(1));

      await cubit.close();
      await hub.dispose();
    });

    test('moving is refused while the portfolio is locked', () async {
      final hub = FakeRepository(catalog);
      await hub.saveCollection(scenarioSet('Old plan'));
      final gateway = FakePortfolioGateway(
        stored: PrivatePortfolioPayload(portfolioId: 'primary'),
      );
      final cubit = PortfolioCubit(hub, gateway);
      await cubit.initialize();

      await cubit.movePlaintextScenariosToVault();
      expect(cubit.state.errorCode, 'vault.session_locked');
      expect(hub.deletedRecordIds, isEmpty);
      expect(hub.current!.sets, hasLength(1));

      await cubit.close();
      await hub.dispose();
    });
  });

  test('collections list vault scenarios while the portfolio is unlocked', () async {
    final hub = FakeRepository(catalog);
    await hub.saveCollection(scenarioSet('Plaintext plan'));
    final gateway = FakePortfolioGateway(
      stored: PrivatePortfolioPayload(
        portfolioId: 'primary',
        privateScenarios: [
          PrivateScenarioRecord(
            id: 'scenario-1',
            set: scenarioSet('Vault plan'),
          ),
        ],
      ),
    );
    final portfolio = PortfolioCubit(hub, gateway);
    await portfolio.initialize();
    final collections = CollectionsCubit(hub, portfolio: portfolio);

    expect(collections.state.sets.map((s) => s.name), ['Plaintext plan']);
    expect(collections.plaintextScenarioCount, 1);

    await portfolio.open();
    await Future<void>.delayed(Duration.zero);
    expect(
      collections.state.sets.map((s) => s.name),
      ['Vault plan', 'Plaintext plan'],
    );
    expect(collections.state.sets.first.storedInVault, isTrue);
    expect(collections.plaintextScenarioCount, 1);

    await portfolio.lock();
    await Future<void>.delayed(Duration.zero);
    expect(collections.state.sets.map((s) => s.name), ['Plaintext plan']);

    await collections.close();
    await portfolio.close();
    await hub.dispose();
  });

  test('workspace exposes record ids and deletes only saved-set records', () async {
    final root = await Directory.systemTemp.createTemp('ovdp-sets-');
    addTearDown(() => root.delete(recursive: true));
    final workspace = await Workspace.open(
      Directory(p.join(root.path, 'ws')),
      create: true,
    );
    await workspace.saveSet(scenarioSet('Plan'));
    final saved = (await workspace.sets()).single;
    expect(saved.recordId, isNotNull);
    expect(saved.storedInVault, isFalse);

    await expectLater(
      workspace.deleteSet('../ovdp-workspace'),
      throwsFormatException,
    );
    await workspace.deleteSet(saved.recordId!);
    expect(await workspace.sets(), isEmpty);
    expect(
      await File(p.join(workspace.directory.path, Workspace.marker)).exists(),
      isTrue,
    );
  });
}
