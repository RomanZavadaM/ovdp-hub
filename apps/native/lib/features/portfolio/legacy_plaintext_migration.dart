import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

import '../../models.dart';
import '../../workspace.dart';
import '../../security/vault_store.dart';
import 'private_portfolio.dart';

enum LegacyMigrationItemStatus {
  migrated,
  alreadyMigrated,
  conflict,
  invalid,
}

class LegacyMigrationItemResult {
  final String sourceId;
  final String sourcePath;
  final LegacyMigrationItemStatus status;
  final int selectedIsinCount;
  final int publicAssetSnapshotsOmitted;
  final bool hadScenario;
  final String? errorCode;

  const LegacyMigrationItemResult({
    required this.sourceId,
    required this.sourcePath,
    required this.status,
    required this.selectedIsinCount,
    required this.publicAssetSnapshotsOmitted,
    required this.hadScenario,
    this.errorCode,
  });
}

class LegacyPlaintextMigrationReport {
  final String vaultId;
  final int vaultRevisionBefore;
  final int vaultRevisionAfter;
  final int sourceFileCount;
  final int plaintextFilesStillPresent;
  final int migratedCount;
  final int alreadyMigratedCount;
  final int conflictCount;
  final int invalidCount;
  final int publicAssetSnapshotsOmitted;
  final int portfolioFactsCreated;
  final bool encryptedCopyVerified;
  final List<LegacyMigrationItemResult> items;

  LegacyPlaintextMigrationReport({
    required this.vaultId,
    required this.vaultRevisionBefore,
    required this.vaultRevisionAfter,
    required this.sourceFileCount,
    required this.plaintextFilesStillPresent,
    required this.migratedCount,
    required this.alreadyMigratedCount,
    required this.conflictCount,
    required this.invalidCount,
    required this.publicAssetSnapshotsOmitted,
    required this.portfolioFactsCreated,
    required this.encryptedCopyVerified,
    required Iterable<LegacyMigrationItemResult> items,
  }) : items = List.unmodifiable(items);

  bool get changed => migratedCount > 0;

  bool get complete =>
      encryptedCopyVerified && conflictCount == 0 && invalidCount == 0;

  bool get requiresExplicitPlaintextCleanup => plaintextFilesStillPresent > 0;
}

class LegacyPlaintextMigrator {
  final Workspace workspace;
  final VaultContentStore vaultStore;

  const LegacyPlaintextMigrator({
    required this.workspace,
    required this.vaultStore,
  });

  Future<LegacyPlaintextMigrationReport> migrate({
    required String vaultId,
  }) async {
    final opened = await vaultStore.open(vaultId: vaultId);
    late final PrivatePortfolioPayload before;
    try {
      before = PrivatePortfolioPayloadCodec.decode(opened.plainText);
    } finally {
      opened.plainText.fillRange(0, opened.plainText.length, 0);
    }

    final files = await workspace.records('sets');
    files.sort((a, b) => a.path.compareTo(b.path));
    final existingBySourceId = {
      for (final record in before.legacyCollections) record.sourceId: record,
    };
    final pendingBySourceId = <String, PrivateLegacyCollectionRecord>{};
    final preliminary = <LegacyMigrationItemResult>[];
    var publicSnapshotsOmitted = 0;

    for (final file in files) {
      final sourceId = p.basenameWithoutExtension(file.path);
      try {
        final content = await Workspace.readLimited(file);
        _validateLegacyEnvelope(content);
        final savedSet = SavedSet.parse(content);
        final record = _mapLegacySet(sourceId, savedSet);
        publicSnapshotsOmitted += savedSet.bonds.length;
        final existing = existingBySourceId[sourceId];
        if (existing != null) {
          if (existing.canonicalJson == record.canonicalJson) {
            preliminary.add(
              _result(
                file,
                record,
                LegacyMigrationItemStatus.alreadyMigrated,
                publicAssetSnapshotsOmitted: savedSet.bonds.length,
              ),
            );
          } else {
            preliminary.add(
              _result(
                file,
                record,
                LegacyMigrationItemStatus.conflict,
                publicAssetSnapshotsOmitted: savedSet.bonds.length,
                errorCode: 'migration.source_changed_after_migration',
              ),
            );
          }
          continue;
        }

        final duplicatePending = pendingBySourceId[sourceId];
        if (duplicatePending != null) {
          preliminary.add(
            _result(
              file,
              record,
              LegacyMigrationItemStatus.conflict,
              publicAssetSnapshotsOmitted: savedSet.bonds.length,
              errorCode: 'migration.duplicate_source_id',
            ),
          );
          continue;
        }

        pendingBySourceId[sourceId] = record;
        preliminary.add(
          _result(
            file,
            record,
            LegacyMigrationItemStatus.migrated,
            publicAssetSnapshotsOmitted: savedSet.bonds.length,
          ),
        );
      } catch (error) {
        preliminary.add(
          LegacyMigrationItemResult(
            sourceId: sourceId,
            sourcePath: file.path,
            status: LegacyMigrationItemStatus.invalid,
            selectedIsinCount: 0,
            publicAssetSnapshotsOmitted: 0,
            hadScenario: false,
            errorCode: _migrationErrorCode(error),
          ),
        );
      }
    }

    var revisionAfter = opened.revision;
    const encryptedCopyVerified = true;

    if (pendingBySourceId.isNotEmpty) {
      final expected = PrivatePortfolioPayload(
        portfolioId: before.portfolioId,
        acquisitionLots: before.acquisitionLots,
        cashEvents: before.cashEvents,
        disposals: before.disposals,
        legacyCollections: [
          ...before.legacyCollections,
          ...pendingBySourceId.values,
        ],
      );
      final expectedBytes = PrivatePortfolioPayloadCodec.encode(expected);

      final saved = await vaultStore.save(
        vaultId: vaultId,
        plainText: expectedBytes,
      );
      revisionAfter = saved.revision;
      saved.plainText.fillRange(0, saved.plainText.length, 0);
      expectedBytes.fillRange(0, expectedBytes.length, 0);

      final verifiedOpen = await vaultStore.open(vaultId: vaultId);
      try {
        final verified = PrivatePortfolioPayloadCodec.decode(
          verifiedOpen.plainText,
        );
        _verifyMigration(
          expected: expected,
          verified: verified,
          migratedSourceIds: pendingBySourceId.keys.toSet(),
        );
      } finally {
        verifiedOpen.plainText.fillRange(
          0,
          verifiedOpen.plainText.length,
          0,
        );
      }
    } else {
      _verifyExistingRecords(
        before,
        preliminary.where(
          (item) => item.status == LegacyMigrationItemStatus.alreadyMigrated,
        ),
      );
    }

    var plaintextFilesStillPresent = 0;
    for (final file in files) {
      if (await file.exists()) plaintextFilesStillPresent++;
    }

    final migratedCount = preliminary
        .where((item) => item.status == LegacyMigrationItemStatus.migrated)
        .length;
    final alreadyMigratedCount = preliminary
        .where(
          (item) => item.status == LegacyMigrationItemStatus.alreadyMigrated,
        )
        .length;
    final conflictCount = preliminary
        .where((item) => item.status == LegacyMigrationItemStatus.conflict)
        .length;
    final invalidCount = preliminary
        .where((item) => item.status == LegacyMigrationItemStatus.invalid)
        .length;

    // Portfolio facts are intentionally never synthesized from SavedSet data.
    const portfolioFactsCreated = 0;

    return LegacyPlaintextMigrationReport(
      vaultId: vaultId,
      vaultRevisionBefore: opened.revision,
      vaultRevisionAfter: revisionAfter,
      sourceFileCount: files.length,
      plaintextFilesStillPresent: plaintextFilesStillPresent,
      migratedCount: migratedCount,
      alreadyMigratedCount: alreadyMigratedCount,
      conflictCount: conflictCount,
      invalidCount: invalidCount,
      publicAssetSnapshotsOmitted: publicSnapshotsOmitted,
      portfolioFactsCreated: portfolioFactsCreated,
      encryptedCopyVerified: encryptedCopyVerified,
      items: preliminary,
    );
  }

  void _validateLegacyEnvelope(String content) {
    final decoded = jsonDecode(content);
    if (decoded is! Map) {
      throw const FormatException('migration.invalid_legacy_record');
    }
    final json = Map<String, dynamic>.from(decoded);
    final version = json['schemaVersion'];
    final allowed = switch (version) {
      1 => const {'schemaVersion', 'name', 'note', 'savedAt', 'assets'},
      2 => const {
          'schemaVersion',
          'name',
          'note',
          'savedAt',
          'assets',
          'scenario',
        },
      _ => throw const FormatException('collection.invalid'),
    };
    if (json.keys.any((key) => !allowed.contains(key))) {
      throw const FormatException('migration.unsupported_legacy_fields');
    }
    if (version == 1 && json.containsKey('scenario')) {
      throw const FormatException('migration.unsupported_legacy_fields');
    }
  }

  PrivateLegacyCollectionRecord _mapLegacySet(
    String sourceId,
    SavedSet set,
  ) {
    final selectedIsins = set.bonds.map((bond) => bond.isin).toSet().toList()
      ..sort();
    return PrivateLegacyCollectionRecord(
      sourceId: sourceId,
      name: set.name,
      note: set.note,
      savedAt: set.savedAt,
      selectedIsins: selectedIsins,
      scenario: set.scenario,
    );
  }

  LegacyMigrationItemResult _result(
    File file,
    PrivateLegacyCollectionRecord record,
    LegacyMigrationItemStatus status, {
    required int publicAssetSnapshotsOmitted,
    String? errorCode,
  }) =>
      LegacyMigrationItemResult(
        sourceId: record.sourceId,
        sourcePath: file.path,
        status: status,
        selectedIsinCount: record.selectedIsins.length,
        publicAssetSnapshotsOmitted: publicAssetSnapshotsOmitted,
        hadScenario: record.scenario != null,
        errorCode: errorCode,
      );

  void _verifyMigration({
    required PrivatePortfolioPayload expected,
    required PrivatePortfolioPayload verified,
    required Set<String> migratedSourceIds,
  }) {
    final expectedBytes = PrivatePortfolioPayloadCodec.encode(expected);
    final verifiedBytes = PrivatePortfolioPayloadCodec.encode(verified);
    try {
      if (expectedBytes.length != verifiedBytes.length) {
        throw StateError('migration.verification_failed');
      }
      for (var i = 0; i < expectedBytes.length; i++) {
        if (expectedBytes[i] != verifiedBytes[i]) {
          throw StateError('migration.verification_failed');
        }
      }

      final verifiedSourceIds = verified.legacyCollections
          .map((record) => record.sourceId)
          .toSet();
      if (!migratedSourceIds.every(verifiedSourceIds.contains)) {
        throw StateError('migration.verification_failed');
      }
    } finally {
      expectedBytes.fillRange(0, expectedBytes.length, 0);
      verifiedBytes.fillRange(0, verifiedBytes.length, 0);
    }
  }

  void _verifyExistingRecords(
    PrivatePortfolioPayload payload,
    Iterable<LegacyMigrationItemResult> alreadyMigrated,
  ) {
    final ids = payload.legacyCollections.map((record) => record.sourceId).toSet();
    for (final item in alreadyMigrated) {
      if (!ids.contains(item.sourceId)) {
        throw StateError('migration.verification_failed');
      }
    }
  }

  String _migrationErrorCode(Object error) {
    if (error is FormatException) {
      final message = error.message.toString();
      if (message.isNotEmpty) return message;
      return 'migration.invalid_legacy_record';
    }
    if (error is FileSystemException) {
      return 'migration.source_unavailable';
    }
    return 'migration.invalid_legacy_record';
  }
}
