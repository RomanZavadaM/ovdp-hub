import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/security/vault_crypto.dart';

void main() {
  late SodiumVaultCrypto crypto;

  setUpAll(() async {
    crypto = await SodiumVaultCrypto.create();
  });

  test('XChaCha20 envelope round-trips and authenticates header', () {
    final dek = crypto.generateDek();
    addTearDown(dek.dispose);
    final plain = Uint8List.fromList(utf8.encode('private planner state'));

    final envelope = crypto.encrypt(
      vaultId: 'vault-test-1',
      revision: 1,
      plainText: plain,
      dek: dek,
    );

    expect(crypto.dekBytes, 32);
    expect(crypto.nonceBytes, 24);
    expect(envelope.nonce, hasLength(24));
    expect(crypto.decrypt(envelope: envelope, dek: dek), plain);

    final tamperedHeader = VaultEnvelopeV1(
      vaultId: envelope.vaultId,
      revision: 2,
      nonce: envelope.nonce,
      cipherText: envelope.cipherText,
    );
    expect(
      () => crypto.decrypt(envelope: tamperedHeader, dek: dek),
      throwsFormatException,
    );
  });

  test('wrong key and corrupt ciphertext fail closed', () {
    final first = crypto.generateDek();
    final second = crypto.generateDek();
    addTearDown(first.dispose);
    addTearDown(second.dispose);

    final envelope = crypto.encrypt(
      vaultId: 'vault-test-2',
      revision: 1,
      plainText: Uint8List.fromList([1, 2, 3, 4]),
      dek: first,
    );

    expect(
      () => crypto.decrypt(envelope: envelope, dek: second),
      throwsFormatException,
    );

    final corrupt = Uint8List.fromList(envelope.cipherText);
    corrupt[corrupt.length - 1] ^= 1;
    final corruptedEnvelope = VaultEnvelopeV1(
      vaultId: envelope.vaultId,
      revision: envelope.revision,
      nonce: envelope.nonce,
      cipherText: corrupt,
    );
    expect(
      () => crypto.decrypt(envelope: corruptedEnvelope, dek: first),
      throwsFormatException,
    );
  });

  test('envelope json is versioned and rejects unknown crypto ids', () {
    final dek = crypto.generateDek();
    addTearDown(dek.dispose);
    final envelope = crypto.encrypt(
      vaultId: 'vault-json',
      revision: 9,
      plainText: Uint8List.fromList([9, 8, 7]),
      dek: dek,
    );

    final decoded = VaultEnvelopeV1.fromJson(
      Map<String, dynamic>.from(
        jsonDecode(jsonEncode(envelope.toJson())) as Map,
      ),
    );
    expect(decoded.vaultId, 'vault-json');
    expect(decoded.revision, 9);
    expect(crypto.decrypt(envelope: decoded, dek: dek), [9, 8, 7]);

    final wrongAlgorithm = Map<String, dynamic>.from(envelope.toJson())
      ..['algorithm'] = 'aes-cbc';
    expect(
      () => VaultEnvelopeV1.fromJson(wrongAlgorithm),
      throwsFormatException,
    );
  });

  test('Argon2id recovery derivation is explicit and deterministic', () {
    final salt = crypto.generateRecoverySalt();
    expect(salt, hasLength(crypto.recoverySaltBytes));

    final first = crypto.deriveRecoveryKey(
      recoverySecret: 'correct horse battery staple',
      salt: salt,
      parameters: VaultRecoveryKdfParameters.interactive,
    );
    final second = crypto.deriveRecoveryKey(
      recoverySecret: 'correct horse battery staple',
      salt: salt,
      parameters: VaultRecoveryKdfParameters.interactive,
    );
    addTearDown(first.dispose);
    addTearDown(second.dispose);

    expect(first.length, 32);
    expect(first, second);
    expect(
      VaultRecoveryKdfParameters.fromJson(
        VaultRecoveryKdfParameters.interactive.toJson(),
      ),
      VaultRecoveryKdfParameters.interactive,
    );
    expect(
      () => VaultRecoveryKdfParameters.fromJson({
        'algorithm': vaultRecoveryKdfAlgorithm,
        'opslimit': 1,
        'memlimit': 8192,
      }),
      throwsFormatException,
    );
  });
}
