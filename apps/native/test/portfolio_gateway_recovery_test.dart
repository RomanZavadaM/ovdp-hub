import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/portfolio/portfolio_gateway.dart';
import 'package:ovdp_hub/features/portfolio/private_portfolio.dart';
import 'package:ovdp_hub/security/vault_crypto.dart';
import 'package:ovdp_hub/security/vault_session.dart';
import 'package:ovdp_hub/security/vault_store.dart';
import 'package:sodium/sodium_sumo.dart';

import 'vault_store_test.dart' show MemoryVaultDeviceKeyStore;

/// Pause a real recovery result before the store can cache its DEK.
class PausedRecoveryCrypto extends SodiumVaultCrypto {
  Completer<void>? entered;
  Completer<void>? resume;

  PausedRecoveryCrypto(super.sodium);

  void pause() {
    entered = Completer<void>();
    resume = Completer<void>();
  }

  @override
  Future<SecureKey> unwrapDekFromRecoveryAsync({
    required VaultRecoverySlotV1 slot,
    required String recoverySecret,
  }) async {
    final key = await super.unwrapDekFromRecoveryAsync(
      slot: slot,
      recoverySecret: recoverySecret,
    );
    final gate = resume;
    if (gate != null) {
      entered!.complete();
      await gate.future;
      resume = null;
    }
    return key;
  }
}

void main() {
  const secret = 'synthetic recovery secret';
  const vaultId = LocalEncryptedPortfolioGateway.vaultId;
  late Directory root;
  late PausedRecoveryCrypto crypto;
  late LocalVaultStore store;
  late VaultSessionController session;
  late LocalEncryptedPortfolioGateway gateway;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('ovdp-gateway-recovery-');
    crypto = PausedRecoveryCrypto((await SodiumVaultCrypto.create()).sodium);
    store = LocalVaultStore(
      directory: root,
      crypto: crypto,
      deviceKeyStore: MemoryVaultDeviceKeyStore(),
    );
    final payload = PrivatePortfolioPayload(
      portfolioId: LocalEncryptedPortfolioGateway.portfolioId,
    );
    final bytes = PrivatePortfolioPayloadCodec.encode(payload);
    try {
      final created = await store.create(
        vaultId: vaultId,
        plainText: bytes,
        recoverySecret: secret,
        recoveryParameters: VaultRecoveryKdfParameters.interactive,
      );
      created.plainText.fillRange(0, created.plainText.length, 0);
    } finally {
      bytes.fillRange(0, bytes.length, 0);
    }
    await store.requireRecoverySecretOnOpen(
      vaultId: vaultId,
      recoverySecret: secret,
    );
    store.forgetUnlockedKey(vaultId: vaultId);
    session = VaultSessionController(
      store: store,
      policy: VaultSessionPolicy(
        inactivityTimeout: const Duration(minutes: 15),
        backgroundGrace: const Duration(seconds: 15),
      ),
    );
    gateway = LocalEncryptedPortfolioGateway.forTesting(
      store: store,
      session: session,
    );
  });

  tearDown(() async {
    await gateway.dispose();
    await root.delete(recursive: true);
  });

  test('lock during recovery cannot reopen or retain the recovered DEK', () async {
    crypto.pause();
    final opening = gateway.open(recoverySecret: secret);
    // Install the error handler before allowing asynchronous completion.
    final rejected = expectLater(opening, throwsStateError);
    await crypto.entered!.future;
    await gateway.lock();
    crypto.resume!.complete();
    await rejected;
    expect(gateway.unlocked, isFalse);
    expect(session.state.isUnlocked, isFalse);
    expect(store.hasUnlockedKey(vaultId: vaultId), isFalse);
    await expectLater(gateway.open(), throwsStateError);
    expect(gateway.unlocked, isFalse);
    expect(store.hasUnlockedKey(vaultId: vaultId), isFalse);
    // Explicitly retrying with the secret must still work.
    await gateway.open(recoverySecret: secret);
    expect(gateway.unlocked, isTrue);
  });
}
