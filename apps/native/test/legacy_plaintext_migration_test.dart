import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/portfolio/legacy_plaintext_migration.dart';
import 'package:ovdp_hub/features/portfolio/private_portfolio.dart';
import 'package:ovdp_hub/models.dart';
import 'package:ovdp_hub/security/vault_crypto.dart';
import 'package:ovdp_hub/security/vault_device_key_store.dart';
import 'package:ovdp_hub/security/vault_store.dart';
import 'package:ovdp_hub/workspace.dart';
import 'package:path/path.dart' as p;

class MemoryVaultDeviceKeyStore implements VaultDeviceKeyStore {
  final Map<String, Uint8List> keys = {};
  final Map<String, int> revisions = {};

  @override
  Future<void> storeDek({
    required String vaultId,
    required Uint8List dek,
  }) async {
    if (keys.containsKey(vaultId)) {
      throw StateError('vault.device_key_exists');
    }
    validateDekBytes(dek);
    keys[vaultId] = Uint8List.fromList(dek);
  }

  @override
  Future<Uint8List?> loadDek({required String vaultId}) async {
    final value = keys[vaultId];
    return value == null ? null : Uint8List.fromList(value);
  }

  @override
  Future<void> deleteDek({required String vaultId}) async {
    keys.remove(vaultId);
    revisions.remove(vaultId);
  }

  @override
  Future<int?> loadHighestAcceptedRevision({required String vaultId}) async =>
      revisions[vaultId];

  @override
  Future<void> storeHighestAcceptedRevision({
    required String vaultId,
    required int revision,
  }) async {
    validateRevision(revision);
    final previous = revisions[vaultId];
    if (previous != null && revision < previous) {
      throw StateError('vault.revision_regression');
    }
    revisions[vaultId] = revision;
  }
}

Bond legacyBond({
  String description = 'PUBLIC BOND SNAPSHOT — DO NOT COPY TO PRIVATE PAYLOAD',
}) =>
    Bond({
      'isin': 'UA4000221111',
      'currency': 'UAH',
      'nominal': '1000',
      'nominalRate': '16.5',
      'issueDate': '2025-01-01',
      'maturityDate': '2028-01-01',
      'description': description,
      'couponPeriodDays': 182,
      'payments': [
        {
          'date': '2026-01-15',
          'amount': '82.50',
          'kind': 'COUPON',
        },
      ],
    });

SavedSet legacySet({
  String note = 'Private legacy note',
  Bond? bond,
}) =>
    SavedSet(
      'Legacy planner set',
      note,
      '2026-09-24T12:00:00Z',
      [bond ?? legacyBond()],
      scenario: {
        'z': 2,
        'a': {
          'b': 2,
          'a': 1,
        },
        'budget': '50000',
      },
    );

void main() {
  late Directory root;
  late Workspace workspace;
  late SodiumVaultCrypto crypto;
  late MemoryVaultDeviceKeyStore device;
  late LocalVaultStore store;

  setUpAll(() async {
    crypto = await SodiumVaultCrypto.create();
  });

  setUp(() async {
    root = await Directory.systemTemp.createTemp('ovdp-legacy-migration-');
    workspace = await Workspace.open(
      Directory(p.join(root.path, 'workspace')),
      create: true,
    );
    device = MemoryVaultDeviceKeyStore();
    store = LocalVaultStore(
      directory: Directory(p.join(root.path, 'vault')),
      crypto: crypto,
      deviceKeyStore: device,
    );
    await store.create(
      vaultId: 'vault-migration',
      plainText: PrivatePortfolioPayloadCodec.encode(
        PrivatePortfolioPayload(portfolioId: 'portfolio-main'),
      ),
    );
  });

  tearDown(() async {
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
  });

  test(
    'migrates only private-capable legacy collection data and keeps plaintext source',
    () async {
      await workspace.saveSet(legacySet());
      final source = (await workspace.records('sets')).single;
      final sourceBefore = await source.readAsString();
      expect(sourceBefore, contains('Private legacy note'));
      expect(sourceBefore, contains('PUBLIC BOND SNAPSHOT'));

      final report = await LegacyPlaintextMigrator(
        workspace: workspace,
        vaultStore: store,
      ).migrate(vaultId: 'vault-migration');

      expect(report.sourceFileCount, 1);
      expect(report.migratedCount, 1);
      expect(report.alreadyMigratedCount, 0);
      expect(report.conflictCount, 0);
      expect(report.invalidCount, 0);
      expect(report.publicAssetSnapshotsOmitted, 1);
      expect(report.portfolioFactsCreated, 0);
      expect(report.encryptedCopyVerified, true);
      expect(report.complete, true);
      expect(report.plaintextFilesStillPresent, 1);
      expect(report.requiresExplicitPlaintextCleanup, true);
      expect(report.vaultRevisionAfter, report.vaultRevisionBefore + 1);

      expect(await source.exists(), true);
      expect(await source.readAsString(), sourceBefore);

      final opened = await store.open(vaultId: 'vault-migration');
      late final PrivatePortfolioPayload payload;
      try {
        payload = PrivatePortfolioPayloadCodec.decode(opened.plainText);
      } finally {
        opened.plainText.fillRange(0, opened.plainText.length, 0);
      }

      expect(payload.acquisitionLots, isEmpty);
      expect(payload.cashEvents, isEmpty);
      expect(payload.disposals, isEmpty);
      expect(payload.holdings, isEmpty);
      expect(payload.legacyCollections, hasLength(1));

      final migrated = payload.legacyCollections.single;
      expect(migrated.sourceId, p.basenameWithoutExtension(source.path));
      expect(migrated.name, 'Legacy planner set');
      expect(migrated.note, 'Private legacy note');
      expect(migrated.savedAt, '2026-09-24T12:00:00Z');
      expect(migrated.selectedIsins, ['UA4000221111']);
      expect(migrated.scenario!.keys.toList(), ['a', 'budget', 'z']);
      expect((migrated.scenario!['a'] as Map).keys.toList(), ['a', 'b']);

      final privateJson = String.fromCharCodes(
        PrivatePortfolioPayloadCodec.encode(payload),
      );
      expect(privateJson, isNot(contains('PUBLIC BOND SNAPSHOT')));
      expect(privateJson, contains('Private legacy note'));

      final physical = await store.fileFor('vault-migration').readAsString();
      expect(physical, isNot(contains('Private legacy note')));
      expect(physical, isNot(contains('UA4000221111')));
      expect(physical, isNot(contains('50000')));
    },
  );

  test('rerun is idempotent and does not bump vault revision', () async {
    await workspace.saveSet(legacySet());
    final migrator = LegacyPlaintextMigrator(
      workspace: workspace,
      vaultStore: store,
    );

    final first = await migrator.migrate(vaultId: 'vault-migration');
    final second = await migrator.migrate(vaultId: 'vault-migration');

    expect(first.migratedCount, 1);
    expect(second.migratedCount, 0);
    expect(second.alreadyMigratedCount, 1);
    expect(second.conflictCount, 0);
    expect(second.invalidCount, 0);
    expect(second.vaultRevisionAfter, second.vaultRevisionBefore);
    expect(second.vaultRevisionBefore, first.vaultRevisionAfter);

    final opened = await store.open(vaultId: 'vault-migration');
    try {
      final payload = PrivatePortfolioPayloadCodec.decode(opened.plainText);
      expect(payload.legacyCollections, hasLength(1));
    } finally {
      opened.plainText.fillRange(0, opened.plainText.length, 0);
    }
  });

  test('same source id with changed private content reports conflict without overwrite', () async {
    await workspace.saveSet(legacySet(note: 'Original private note'));
    final source = (await workspace.records('sets')).single;
    final migrator = LegacyPlaintextMigrator(
      workspace: workspace,
      vaultStore: store,
    );

    final first = await migrator.migrate(vaultId: 'vault-migration');
    expect(first.migratedCount, 1);

    await source.writeAsString(
      jsonEncode(legacySet(note: 'Changed after migration').toJson()),
      flush: true,
    );

    final second = await migrator.migrate(vaultId: 'vault-migration');
    expect(second.migratedCount, 0);
    expect(second.conflictCount, 1);
    expect(second.complete, false);
    expect(second.vaultRevisionAfter, second.vaultRevisionBefore);
    expect(
      second.items.single.errorCode,
      'migration.source_changed_after_migration',
    );

    final opened = await store.open(vaultId: 'vault-migration');
    try {
      final payload = PrivatePortfolioPayloadCodec.decode(opened.plainText);
      expect(payload.legacyCollections.single.note, 'Original private note');
    } finally {
      opened.plainText.fillRange(0, opened.plainText.length, 0);
    }
  });

  test('public snapshot-only changes do not create a migration conflict', () async {
    await workspace.saveSet(legacySet());
    final source = (await workspace.records('sets')).single;
    final migrator = LegacyPlaintextMigrator(
      workspace: workspace,
      vaultStore: store,
    );

    await migrator.migrate(vaultId: 'vault-migration');

    await source.writeAsString(
      jsonEncode(
        legacySet(
          bond: legacyBond(description: 'NEW PUBLIC DESCRIPTION ONLY'),
        ).toJson(),
      ),
      flush: true,
    );

    final rerun = await migrator.migrate(vaultId: 'vault-migration');
    expect(rerun.migratedCount, 0);
    expect(rerun.alreadyMigratedCount, 1);
    expect(rerun.conflictCount, 0);
    expect(rerun.vaultRevisionAfter, rerun.vaultRevisionBefore);
  });

  test('unknown legacy top-level fields fail closed instead of being dropped', () async {
    await workspace.saveSet(legacySet());
    final source = (await workspace.records('sets')).single;
    final raw = Map<String, dynamic>.from(
      jsonDecode(await source.readAsString()) as Map,
    )..['futurePrivateField'] = {
        'mustNotDisappear': true,
      };
    await source.writeAsString(jsonEncode(raw), flush: true);

    final before = await store.open(vaultId: 'vault-migration');
    final beforeRevision = before.revision;
    before.plainText.fillRange(0, before.plainText.length, 0);

    final report = await LegacyPlaintextMigrator(
      workspace: workspace,
      vaultStore: store,
    ).migrate(vaultId: 'vault-migration');

    expect(report.migratedCount, 0);
    expect(report.invalidCount, 1);
    expect(report.complete, false);
    expect(report.vaultRevisionBefore, beforeRevision);
    expect(report.vaultRevisionAfter, beforeRevision);
    expect(
      report.items.single.errorCode,
      'migration.unsupported_legacy_fields',
    );
    expect(await source.exists(), true);

    final opened = await store.open(vaultId: 'vault-migration');
    try {
      final payload = PrivatePortfolioPayloadCodec.decode(opened.plainText);
      expect(payload.legacyCollections, isEmpty);
    } finally {
      opened.plainText.fillRange(0, opened.plainText.length, 0);
    }
  });

  test('valid files migrate even when another legacy json is corrupt', () async {
    await workspace.saveSet(legacySet());
    final setsDirectory = Directory(p.join(workspace.directory.path, 'sets'));
    final broken = File(p.join(setsDirectory.path, 'broken.json'));
    await broken.writeAsString('{"schemaVersion":2,"broken":true}', flush: true);

    final report = await LegacyPlaintextMigrator(
      workspace: workspace,
      vaultStore: store,
    ).migrate(vaultId: 'vault-migration');

    expect(report.sourceFileCount, 2);
    expect(report.migratedCount, 1);
    expect(report.invalidCount, 1);
    expect(report.conflictCount, 0);
    expect(report.complete, false);
    expect(report.plaintextFilesStillPresent, 2);
    expect(
      report.items
          .singleWhere((item) => item.sourceId == 'broken')
          .status,
      LegacyMigrationItemStatus.invalid,
    );

    final opened = await store.open(vaultId: 'vault-migration');
    try {
      final payload = PrivatePortfolioPayloadCodec.decode(opened.plainText);
      expect(payload.legacyCollections, hasLength(1));
      expect(payload.acquisitionLots, isEmpty);
    } finally {
      opened.plainText.fillRange(0, opened.plainText.length, 0);
    }
    expect(await broken.exists(), true);
  });
}
