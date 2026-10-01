import 'dart:async';
import 'package:ovdp_hub/features/portfolio/legacy_plaintext_migration.dart';
import 'package:ovdp_hub/features/portfolio/portfolio_gateway.dart';
import 'package:ovdp_hub/features/portfolio/private_portfolio.dart';
import 'package:ovdp_hub/security/vault_store.dart';

class FakePortfolioGateway implements PortfolioGateway {
  @override
  final bool supported;
  @override
  final bool portableBackupSupported;
  PrivatePortfolioPayload? stored;
  bool locked = true;
  final _unlockChanges = StreamController<bool>.broadcast(sync: true);
  int migrationCalls = 0;
  int backupCalls = 0;
  int restoreCalls = 0;
  int rotateRecoveryCalls = 0;
  String? lastMigrationWorkspacePath;
  String? lastRecoverySecret;
  String recoverySecret = 'correct horse battery';
  bool recoverySecretRequired = false;
  int recoveryModeChanges = 0;
  int deleteCalls = 0;

  /// When set, the next unconfirmed restore reports an older backup.
  bool nextRestoreIsOlder = false;
  PrivatePortfolioPayload? backupPayload;
  String backupPath = 'local/OVDP-Hub-portfolio-backup.ovdp-vault.json';

  FakePortfolioGateway({
    this.supported = true,
    this.portableBackupSupported = true,
    this.stored,
  });

  @override
  bool get unlocked => !locked;

  @override
  Stream<bool> get unlockChanges => _unlockChanges.stream;

  @override
  Future<bool> exists() async => stored != null;

  @override
  Future<PrivatePortfolioPayload> create({
    required String recoverySecret,
  }) async {
    if (recoverySecret.length < 12) {
      throw const FormatException('portfolio.recovery_secret_too_short');
    }
    if (stored != null) throw StateError('vault.already_exists');
    this.recoverySecret = recoverySecret;
    recoverySecretRequired = false;
    stored = PrivatePortfolioPayload(portfolioId: 'primary');
    locked = false;
    _unlockChanges.add(true);
    return stored!;
  }

  @override
  Future<bool> requiresRecoverySecret() async =>
      stored != null && recoverySecretRequired;

  @override
  Future<void> setRecoverySecretRequired({
    required bool enabled,
    String? recoverySecret,
  }) async {
    if (locked) throw StateError('vault.session_locked');
    if (enabled && recoverySecret != this.recoverySecret) {
      throw const FormatException('vault.recovery_authentication_failed');
    }
    recoveryModeChanges++;
    recoverySecretRequired = enabled;
  }

  @override
  Future<PrivatePortfolioPayload> open({String? recoverySecret}) async {
    final value = stored;
    if (value == null) throw StateError('portfolio.open_failed');
    if (recoverySecretRequired) {
      if (recoverySecret == null) throw StateError('vault.device_key_missing');
      if (recoverySecret != this.recoverySecret) {
        throw const FormatException('vault.recovery_authentication_failed');
      }
    }
    locked = false;
    _unlockChanges.add(true);
    return value;
  }

  @override
  Future<void> save(PrivatePortfolioPayload payload) async {
    if (locked) throw StateError('vault.session_locked');
    stored = payload;
  }

  @override
  Future<String?> createPortableBackup() async {
    if (!portableBackupSupported) {
      throw UnsupportedError('portfolio.portable_backup_unsupported');
    }
    if (locked) throw StateError('vault.session_locked');
    backupCalls++;
    return backupPath;
  }

  @override
  Future<PrivatePortfolioPayload?> restorePortableBackup({
    required String recoverySecret,
    bool confirmRollback = false,
  }) async {
    if (!portableBackupSupported) {
      throw UnsupportedError('portfolio.portable_backup_unsupported');
    }
    restoreCalls++;
    lastRecoverySecret = recoverySecret;
    if (nextRestoreIsOlder && !confirmRollback) {
      throw const VaultRollbackException(
        vaultId: 'primary-portfolio',
        foundRevision: 2,
        highestAcceptedRevision: 5,
      );
    }
    nextRestoreIsOlder = false;
    if (backupPayload != null) stored = backupPayload;
    stored ??= PrivatePortfolioPayload(portfolioId: 'primary');
    locked = false;
    _unlockChanges.add(true);
    return stored;
  }

  @override
  Future<PrivatePortfolioPayload> rotateRecovery({
    required String recoverySecret,
  }) async {
    if (locked) throw StateError('vault.session_locked');
    if (recoverySecret.length < 12) {
      throw const FormatException('portfolio.recovery_secret_too_short');
    }
    rotateRecoveryCalls++;
    lastRecoverySecret = recoverySecret;
    return stored ?? (throw StateError('portfolio.open_failed'));
  }

  @override
  Future<PortfolioMigrationResult> migrateLegacy({
    required String workspacePath,
  }) async {
    if (locked) throw StateError('vault.session_locked');
    final value = stored;
    if (value == null) throw StateError('portfolio.open_failed');
    migrationCalls++;
    lastMigrationWorkspacePath = workspacePath;
    final report = LegacyPlaintextMigrationReport(
      vaultId: 'primary-portfolio',
      vaultRevisionBefore: 1,
      vaultRevisionAfter: 2,
      sourceFileCount: 2,
      plaintextFilesStillPresent: 2,
      migratedCount: 1,
      alreadyMigratedCount: 1,
      conflictCount: 0,
      invalidCount: 0,
      publicAssetSnapshotsOmitted: 2,
      portfolioFactsCreated: 0,
      encryptedCopyVerified: true,
      items: const [],
    );
    return PortfolioMigrationResult(report: report, payload: value);
  }

  @override
  Future<void> deleteLocalPortfolio() async {
    deleteCalls++;
    stored = null;
    recoverySecretRequired = false;
    locked = true;
    _unlockChanges.add(false);
  }

  @override
  Future<void> lock() async {
    locked = true;
    _unlockChanges.add(false);
  }

  @override
  void onBackground() {}

  @override
  Future<void> onForeground() async {}

  @override
  Future<void> dispose() => _unlockChanges.close();
}
