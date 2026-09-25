import 'dart:async';
import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../security/vault_crypto.dart';
import '../../security/vault_device_key_store.dart';
import '../../security/vault_device_key_store_secure.dart';
import '../../security/vault_device_key_store_windows.dart';
import '../../security/vault_dpapi_protector_win32.dart';
import '../../security/vault_session.dart';
import '../../security/vault_store.dart';
import '../../workspace.dart';
import 'legacy_plaintext_migration.dart';
import 'private_portfolio.dart';

class PortfolioMigrationResult {
  final LegacyPlaintextMigrationReport report;
  final PrivatePortfolioPayload payload;

  const PortfolioMigrationResult({
    required this.report,
    required this.payload,
  });
}

abstract interface class PortfolioGateway {
  bool get supported;
  bool get portableBackupSupported;
  bool get unlocked;
  Stream<bool> get unlockChanges;
  Future<bool> exists();
  Future<PrivatePortfolioPayload> create({required String recoverySecret});
  Future<PrivatePortfolioPayload> open();
  Future<void> save(PrivatePortfolioPayload payload);
  Future<String?> createPortableBackup();
  Future<PrivatePortfolioPayload?> restorePortableBackup({
    required String recoverySecret,
  });
  Future<PrivatePortfolioPayload> rotateRecovery({
    required String recoverySecret,
  });
  Future<PortfolioMigrationResult> migrateLegacy({
    required String workspacePath,
  });
  Future<void> lock();
  void onBackground();
  Future<void> onForeground();
  Future<void> dispose();
}

class LocalEncryptedPortfolioGateway implements PortfolioGateway {
  static const vaultId = 'primary-portfolio';
  static const portfolioId = 'primary';

  LocalVaultStore? _store;
  VaultSessionController? _session;
  final _unlockChanges = StreamController<bool>.broadcast(sync: true);

  @override
  bool get supported =>
      Platform.isWindows || Platform.isAndroid || Platform.isIOS;

  @override
  bool get portableBackupSupported => supported && Platform.isWindows;

  @override
  bool get unlocked => _session?.state.isUnlocked ?? false;

  @override
  Stream<bool> get unlockChanges => _unlockChanges.stream;

  Future<void> _ensureReady() async {
    if (!supported) {
      throw UnsupportedError('portfolio.platform_not_ready');
    }
    if (_store != null && _session != null) return;

    final root = Directory(
      p.join((await getApplicationSupportDirectory()).path, 'OVDP Hub'),
    );
    final crypto = await SodiumVaultCrypto.create();
    final VaultDeviceKeyStore keyStore = Platform.isWindows
        ? WindowsVaultDeviceKeyStore(
            directory: Directory(p.join(root.path, 'private-device-state')),
            protector: Win32DpapiProtector(),
          )
        : const FlutterSecureStorageVaultDeviceKeyStore();

    final store = LocalVaultStore(
      directory: Directory(p.join(root.path, 'private-vault')),
      crypto: crypto,
      deviceKeyStore: keyStore,
    );
    _store = store;
    final session = VaultSessionController(
      store: store,
      policy: VaultSessionPolicy(
        inactivityTimeout: const Duration(minutes: 15),
        backgroundGrace: const Duration(seconds: 15),
      ),
    );
    session.addListener(_publishLockState);
    _session = session;
  }

  void _publishLockState() {
    if (!_unlockChanges.isClosed) {
      _unlockChanges.add(unlocked);
    }
  }

  @override
  Future<bool> exists() async {
    await _ensureReady();
    return _store!.fileFor(vaultId).exists();
  }

  @override
  Future<PrivatePortfolioPayload> create({
    required String recoverySecret,
  }) async {
    await _ensureReady();
    if (recoverySecret.length < 12) {
      throw const FormatException('portfolio.recovery_secret_too_short');
    }
    final payload = PrivatePortfolioPayload(portfolioId: portfolioId);
    final bytes = PrivatePortfolioPayloadCodec.encode(payload);
    try {
      final created = await _store!.create(
        vaultId: vaultId,
        plainText: bytes,
        recoverySecret: recoverySecret,
      );
      created.plainText.fillRange(0, created.plainText.length, 0);
    } finally {
      bytes.fillRange(0, bytes.length, 0);
    }
    return open();
  }

  @override
  Future<PrivatePortfolioPayload> open() async {
    await _ensureReady();
    final session = _session!;
    await session.unlock(vaultId: vaultId);
    if (!session.state.isUnlocked) {
      throw StateError(session.state.errorCode ?? 'portfolio.open_failed');
    }
    final bytes = session.readPlainTextCopy();
    try {
      return PrivatePortfolioPayloadCodec.decode(bytes);
    } finally {
      bytes.fillRange(0, bytes.length, 0);
    }
  }

  @override
  Future<void> save(PrivatePortfolioPayload payload) async {
    await _ensureReady();
    final session = _session!;
    if (!session.state.isUnlocked) {
      throw StateError('vault.session_locked');
    }
    final bytes = PrivatePortfolioPayloadCodec.encode(payload);
    try {
      await session.save(bytes);
      if (!session.state.isUnlocked) {
        throw StateError(session.state.errorCode ?? 'portfolio.save_failed');
      }
    } finally {
      bytes.fillRange(0, bytes.length, 0);
    }
  }

  @override
  Future<String?> createPortableBackup() async {
    if (!portableBackupSupported) {
      throw UnsupportedError('portfolio.portable_backup_unsupported');
    }
    await _ensureReady();
    if (!unlocked) {
      throw StateError('vault.session_locked');
    }
    final now = DateTime.now().toUtc();
    final stamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final location = await getSaveLocation(
      suggestedName: 'OVDP-Hub-portfolio-backup-$stamp.ovdp-vault.json',
    );
    if (location == null) return null;
    final file = await _store!.createEncryptedBackup(
      vaultId: vaultId,
      destination: File(location.path),
    );
    return file.path;
  }

  @override
  Future<PrivatePortfolioPayload?> restorePortableBackup({
    required String recoverySecret,
  }) async {
    if (!portableBackupSupported) {
      throw UnsupportedError('portfolio.portable_backup_unsupported');
    }
    await _ensureReady();
    final selected = await openFile();
    if (selected == null) return null;

    final session = _session!;
    if (session.state.isUnlocked) {
      await session.lock();
    }
    final restored = await _store!.restoreEncryptedBackup(
      vaultId: vaultId,
      source: File(selected.path),
      recoverySecret: recoverySecret,
    );
    restored.plainText.fillRange(0, restored.plainText.length, 0);
    return open();
  }

  @override
  Future<PrivatePortfolioPayload> rotateRecovery({
    required String recoverySecret,
  }) async {
    await _ensureReady();
    final session = _session!;
    if (!session.state.isUnlocked) {
      throw StateError('vault.session_locked');
    }
    await session.lock();
    await _store!.rotateRecovery(
      vaultId: vaultId,
      recoverySecret: recoverySecret,
    );
    return open();
  }

  @override
  Future<PortfolioMigrationResult> migrateLegacy({
    required String workspacePath,
  }) async {
    await _ensureReady();
    final session = _session!;
    if (!session.state.isUnlocked) {
      throw StateError('vault.session_locked');
    }

    final workspace = await Workspace.open(Directory(workspacePath));
    late final LegacyPlaintextMigrationReport report;
    try {
      report = await LegacyPlaintextMigrator(
        workspace: workspace,
        vaultStore: _store!,
      ).migrate(vaultId: vaultId);
    } finally {
      // The migrator writes through the durable store. Always discard the
      // session plaintext, even when verification fails after a write, so a
      // stale unlocked session can never overwrite migrated vault contents.
      await session.lock();
    }

    final payload = await open();
    return PortfolioMigrationResult(report: report, payload: payload);
  }

  @override
  Future<void> lock() async {
    final session = _session;
    if (session != null) await session.lock();
  }

  @override
  void onBackground() {
    _session?.onBackground();
  }

  @override
  Future<void> onForeground() async {
    await _session?.onForeground();
  }

  @override
  Future<void> dispose() async {
    final session = _session;
    if (session != null) {
      session.removeListener(_publishLockState);
      session.dispose();
    }
    _session = null;
    _store = null;
    await _unlockChanges.close();
  }
}
