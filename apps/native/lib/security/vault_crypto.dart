import 'dart:convert';
import 'dart:typed_data';

import 'package:sodium/sodium_sumo.dart';

const String vaultMagic = 'OVDP-HUB-VAULT';
const int vaultEnvelopeVersion = 1;
const String vaultAeadAlgorithm = 'xchacha20poly1305-ietf';
const String vaultRecoveryKdfAlgorithm = 'argon2id13';

final RegExp _vaultIdPattern = RegExp(r'^[A-Za-z0-9._-]{1,96}$');

void validateVaultId(String vaultId) {
  if (!_vaultIdPattern.hasMatch(vaultId)) {
    throw const FormatException('vault.invalid_id');
  }
}

String _b64(Uint8List value) => base64UrlEncode(value);

Uint8List _decodeB64(Object? value) {
  if (value is! String || value.isEmpty) {
    throw const FormatException('vault.invalid_envelope');
  }
  try {
    return Uint8List.fromList(base64Url.decode(value));
  } on FormatException {
    throw const FormatException('vault.invalid_envelope');
  }
}

class VaultRecoveryKdfParameters {
  final int opsLimit;
  final int memLimit;

  const VaultRecoveryKdfParameters({
    required this.opsLimit,
    required this.memLimit,
  });

  static const interactive = VaultRecoveryKdfParameters(
    opsLimit: 2,
    memLimit: 64 * 1024 * 1024,
  );

  static const moderate = VaultRecoveryKdfParameters(
    opsLimit: 3,
    memLimit: 256 * 1024 * 1024,
  );

  Map<String, Object> toJson() => {
    'algorithm': vaultRecoveryKdfAlgorithm,
    'opslimit': opsLimit,
    'memlimit': memLimit,
  };

  factory VaultRecoveryKdfParameters.fromJson(Map<String, dynamic> json) {
    if (json['algorithm'] != vaultRecoveryKdfAlgorithm) {
      throw const FormatException('vault.unsupported_kdf');
    }
    final opsLimit = json['opslimit'];
    final memLimit = json['memlimit'];
    if (opsLimit is! int || memLimit is! int) {
      throw const FormatException('vault.invalid_kdf');
    }
    final result = VaultRecoveryKdfParameters(
      opsLimit: opsLimit,
      memLimit: memLimit,
    );
    if (result != interactive && result != moderate) {
      throw const FormatException('vault.unapproved_kdf_parameters');
    }
    return result;
  }

  @override
  bool operator ==(Object other) =>
      other is VaultRecoveryKdfParameters &&
      other.opsLimit == opsLimit &&
      other.memLimit == memLimit;

  @override
  int get hashCode => Object.hash(opsLimit, memLimit);
}

class VaultEnvelopeV1 {
  final String vaultId;
  final int revision;
  final Uint8List nonce;
  final Uint8List cipherText;

  VaultEnvelopeV1({
    required this.vaultId,
    required this.revision,
    required Uint8List nonce,
    required Uint8List cipherText,
  }) : nonce = Uint8List.fromList(nonce),
       cipherText = Uint8List.fromList(cipherText) {
    validateVaultId(vaultId);
    if (revision < 1 || this.nonce.isEmpty || this.cipherText.isEmpty) {
      throw const FormatException('vault.invalid_envelope');
    }
  }

  Map<String, Object> headerJson() => {
    'application': vaultMagic,
    'envelopeVersion': vaultEnvelopeVersion,
    'vaultId': vaultId,
    'revision': revision,
    'algorithm': vaultAeadAlgorithm,
  };

  Uint8List authenticatedHeader() =>
      Uint8List.fromList(utf8.encode(jsonEncode(headerJson())));

  Map<String, Object> toJson() => {
    ...headerJson(),
    'nonce': _b64(nonce),
    'ciphertext': _b64(cipherText),
  };

  factory VaultEnvelopeV1.fromJson(Map<String, dynamic> json) {
    if (json['application'] != vaultMagic ||
        json['envelopeVersion'] != vaultEnvelopeVersion) {
      throw const FormatException('vault.unsupported_envelope');
    }
    if (json['algorithm'] != vaultAeadAlgorithm) {
      throw const FormatException('vault.unsupported_algorithm');
    }
    final vaultId = json['vaultId'];
    final revision = json['revision'];
    if (vaultId is! String || revision is! int) {
      throw const FormatException('vault.invalid_envelope');
    }
    return VaultEnvelopeV1(
      vaultId: vaultId,
      revision: revision,
      nonce: _decodeB64(json['nonce']),
      cipherText: _decodeB64(json['ciphertext']),
    );
  }
}

abstract interface class VaultCrypto {
  int get dekBytes;
  int get nonceBytes;
  int get recoverySaltBytes;

  SecureKey generateDek();
  Uint8List generateRecoverySalt();

  VaultEnvelopeV1 encrypt({
    required String vaultId,
    required int revision,
    required Uint8List plainText,
    required SecureKey dek,
  });

  Uint8List decrypt({
    required VaultEnvelopeV1 envelope,
    required SecureKey dek,
  });

  SecureKey deriveRecoveryKey({
    required String recoverySecret,
    required Uint8List salt,
    required VaultRecoveryKdfParameters parameters,
  });
}

class SodiumVaultCrypto implements VaultCrypto {
  final SodiumSumo sodium;

  SodiumVaultCrypto(this.sodium);

  static Future<SodiumVaultCrypto> create() async =>
      SodiumVaultCrypto(await SodiumSumoInit.init());

  Aead get _aead => sodium.crypto.aeadXChaCha20Poly1305IETF;
  Pwhash get _pwhash => sodium.crypto.pwhash;

  @override
  int get dekBytes => _aead.keyBytes;

  @override
  int get nonceBytes => _aead.nonceBytes;

  @override
  int get recoverySaltBytes => _pwhash.saltBytes;

  @override
  SecureKey generateDek() => _aead.keygen();

  @override
  Uint8List generateRecoverySalt() =>
      sodium.randombytes.buf(_pwhash.saltBytes);

  @override
  VaultEnvelopeV1 encrypt({
    required String vaultId,
    required int revision,
    required Uint8List plainText,
    required SecureKey dek,
  }) {
    validateVaultId(vaultId);
    if (revision < 1 || dek.length != _aead.keyBytes) {
      throw const FormatException('vault.invalid_crypto_input');
    }
    final nonce = sodium.randombytes.buf(_aead.nonceBytes);
    final template = VaultEnvelopeV1(
      vaultId: vaultId,
      revision: revision,
      nonce: nonce,
      cipherText: Uint8List.fromList(const [1]),
    );
    final cipherText = _aead.encrypt(
      message: plainText,
      nonce: nonce,
      key: dek,
      additionalData: template.authenticatedHeader(),
    );
    return VaultEnvelopeV1(
      vaultId: vaultId,
      revision: revision,
      nonce: nonce,
      cipherText: cipherText,
    );
  }

  @override
  Uint8List decrypt({
    required VaultEnvelopeV1 envelope,
    required SecureKey dek,
  }) {
    if (envelope.nonce.length != _aead.nonceBytes ||
        dek.length != _aead.keyBytes) {
      throw const FormatException('vault.invalid_crypto_input');
    }
    try {
      return _aead.decrypt(
        cipherText: envelope.cipherText,
        nonce: envelope.nonce,
        key: dek,
        additionalData: envelope.authenticatedHeader(),
      );
    } on SodiumException {
      throw const FormatException('vault.authentication_failed');
    }
  }

  @override
  SecureKey deriveRecoveryKey({
    required String recoverySecret,
    required Uint8List salt,
    required VaultRecoveryKdfParameters parameters,
  }) {
    if (recoverySecret.isEmpty ||
        salt.length != _pwhash.saltBytes ||
        !const [
          VaultRecoveryKdfParameters.interactive,
          VaultRecoveryKdfParameters.moderate,
        ].contains(parameters)) {
      throw const FormatException('vault.invalid_kdf');
    }
    return _pwhash.callStr(
      outLen: _aead.keyBytes,
      password: recoverySecret,
      salt: salt,
      opsLimit: parameters.opsLimit,
      memLimit: parameters.memLimit,
      alg: CryptoPwhashAlgorithm.argon2id13,
    );
  }
}
