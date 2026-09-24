import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../security/vault_crypto.dart';
import '../../security/vault_device_key_store.dart';
import '../../security/vault_device_key_store_secure.dart';
import '../../security/vault_device_key_store_windows.dart';
import '../../security/vault_dpapi_protector_win32.dart';
import '../../security/vault_session.dart';
import '../../security/vault_store.dart';
import 'private_portfolio.dart';

abstract interface class PortfolioGateway {
  bool get supported;
  Future<bool> exists();
  Future<PrivatePortfolioPayload> create({required String recoverySecret});
  Future<PrivatePortfolioPayload> open();
  Future<void> save(PrivatePortfolioPayload payload);
  Future<void> lock();
  void dispose();
}

class LocalEncryptedPortfolioGateway implements PortfolioGateway {
  static const vaultId = 'primary-portfolio';
  static const portfolioId = 'primary';

  LocalVaultStore? _store;
  VaultSessionController? _session;

  @override
  bool get supported =>
      Platform.isWindows || Platform.isAndroid || Platform.isIOS;

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
    _session = VaultSessionController(
      store: store,
      policy: VaultSessionPolicy(
        inactivityTimeout: const Duration(minutes: 15),
        backgroundGrace: const Duration(seconds: 15),
      ),
    );
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
  Future<void> lock() async {
    final session = _session;
    if (session != null) await session.lock();
  }

  @override
  void dispose() {
    _session?.dispose();
    _session = null;
    _store = null;
  }
}
