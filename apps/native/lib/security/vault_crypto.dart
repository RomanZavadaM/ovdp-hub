import 'dart:convert';
import 'dart:typed_data';

import 'package:sodium/sodium_sumo.dart';

const String vaultMagic = 'OVDP-HUB-VAULT';
const int vaultEnvelopeVersion = 1;
const String vaultAeadAlgorithm = 'xchacha20poly1305-ietf';
const String vaultRecoveryKdfAlgorithm = 'argon2id13';
const int vaultRecoverySlotVersion = 1;

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
  final String? recoverySlotBinding;

  VaultEnvelopeV1({
    required this.vaultId,
    required this.revision,
    required Uint8List nonce,
    required Uint8List cipherText,
    this.recoverySlotBinding,
  }) : nonce = Uint8List.fromList(nonce),
       cipherText = Uint8List.fromList(cipherText) {
    validateVaultId(vaultId);
    if (revision < 1 || this.nonce.isEmpty || this.cipherText.isEmpty) {
      throw const FormatException('vault.invalid_envelope');
    }
  }

  Map<String, Object> headerJson() {
    final header = <String, Object>{
      'application': vaultMagic,
      'envelopeVersion': vaultEnvelopeVersion,
      'vaultId': vaultId,
      'revision': revision,
      'algorithm': vaultAeadAlgorithm,
    };
    final binding = recoverySlotBinding;
    if (binding != null) {
      header['recoverySlotBinding'] = binding;
    }
    return header;
  }

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
      recoverySlotBinding: json['recoverySlotBinding'] == null
          ? null
          : json['recoverySlotBinding'] is String
          ? json['recoverySlotBinding'] as String
          : throw const FormatException('vault.invalid_envelope'),
    );
  }
}

class VaultRecoverySlotV1 {
  final String vaultId;
  final VaultRecoveryKdfParameters kdf;
  final Uint8List salt;
  final Uint8List nonce;
  final Uint8List wrappedDek;

  VaultRecoverySlotV1({
    required this.vaultId,
    required this.kdf,
    required Uint8List salt,
    required Uint8List nonce,
    required Uint8List wrappedDek,
  }) : salt = Uint8List.fromList(salt),
       nonce = Uint8List.fromList(nonce),
       wrappedDek = Uint8List.fromList(wrappedDek) {
    validateVaultId(vaultId);
    if (this.salt.isEmpty || this.nonce.isEmpty || this.wrappedDek.isEmpty) {
      throw const FormatException('vault.invalid_recovery_slot');
    }
  }

  Map<String, Object> headerJson() => {
    'application': vaultMagic,
    'slotType': 'recovery',
    'slotVersion': vaultRecoverySlotVersion,
    'vaultId': vaultId,
    'algorithm': vaultAeadAlgorithm,
    'kdf': kdf.toJson(),
    'salt': _b64(salt),
    'nonce': _b64(nonce),
  };

  Uint8List authenticatedHeader() =>
      Uint8List.fromList(utf8.encode(jsonEncode(headerJson())));

  Map<String, Object> toJson() => {
    ...headerJson(),
    'wrappedDek': _b64(wrappedDek),
  };

  factory VaultRecoverySlotV1.fromJson(Map<String, dynamic> json) {
    if (json['application'] != vaultMagic ||
        json['slotType'] != 'recovery' ||
        json['slotVersion'] != vaultRecoverySlotVersion) {
      throw const FormatException('vault.unsupported_recovery_slot');
    }
    if (json['algorithm'] != vaultAeadAlgorithm) {
      throw const FormatException('vault.unsupported_algorithm');
    }
    final vaultId = json['vaultId'];
    final kdfJson = json['kdf'];
    if (vaultId is! String || kdfJson is! Map) {
      throw const FormatException('vault.invalid_recovery_slot');
    }
    return VaultRecoverySlotV1(
      vaultId: vaultId,
      kdf: VaultRecoveryKdfParameters.fromJson(
        Map<String, dynamic>.from(kdfJson),
      ),
      salt: _decodeB64(json['salt']),
      nonce: _decodeB64(json['nonce']),
      wrappedDek: _decodeB64(json['wrappedDek']),
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
    String? recoverySlotBinding,
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

  VaultRecoverySlotV1 wrapDekForRecovery({
    required String vaultId,
    required SecureKey dek,
    required String recoverySecret,
    required VaultRecoveryKdfParameters parameters,
  });

  SecureKey unwrapDekFromRecovery({
    required VaultRecoverySlotV1 slot,
    required String recoverySecret,
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
    String? recoverySlotBinding,
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
      recoverySlotBinding: recoverySlotBinding,
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
      recoverySlotBinding: recoverySlotBinding,
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

  @override
  VaultRecoverySlotV1 wrapDekForRecovery({
    required String vaultId,
    required SecureKey dek,
    required String recoverySecret,
    required VaultRecoveryKdfParameters parameters,
  }) {
    validateVaultId(vaultId);
    if (dek.length != _aead.keyBytes) {
      throw const FormatException('vault.invalid_device_key');
    }
    final salt = generateRecoverySalt();
    final nonce = sodium.randombytes.buf(_aead.nonceBytes);
    final kek = deriveRecoveryKey(
      recoverySecret: recoverySecret,
      salt: salt,
      parameters: parameters,
    );
    try {
      final template = VaultRecoverySlotV1(
        vaultId: vaultId,
        kdf: parameters,
        salt: salt,
        nonce: nonce,
        wrappedDek: Uint8List.fromList(const [1]),
      );
      final wrapped = dek.runUnlockedSync(
        (data) => _aead.encrypt(
          message: data,
          nonce: nonce,
          key: kek,
          additionalData: template.authenticatedHeader(),
        ),
      );
      return VaultRecoverySlotV1(
        vaultId: vaultId,
        kdf: parameters,
        salt: salt,
        nonce: nonce,
        wrappedDek: wrapped,
      );
    } finally {
      kek.dispose();
    }
  }

  @override
  SecureKey unwrapDekFromRecovery({
    required VaultRecoverySlotV1 slot,
    required String recoverySecret,
  }) {
    if (slot.nonce.length != _aead.nonceBytes ||
        slot.salt.length != _pwhash.saltBytes) {
      throw const FormatException('vault.invalid_recovery_slot');
    }
    final kek = deriveRecoveryKey(
      recoverySecret: recoverySecret,
      salt: slot.salt,
      parameters: slot.kdf,
    );
    Uint8List? rawDek;
    try {
      try {
        rawDek = _aead.decrypt(
          cipherText: slot.wrappedDek,
          nonce: slot.nonce,
          key: kek,
          additionalData: slot.authenticatedHeader(),
        );
      } on SodiumException {
        throw const FormatException('vault.recovery_authentication_failed');
      }
      if (rawDek.length != _aead.keyBytes) {
        throw const FormatException('vault.invalid_recovery_slot');
      }
      return sodium.secureCopy(rawDek);
    } finally {
      kek.dispose();
      rawDek?.fillRange(0, rawDek.length, 0);
    }
  }
}
