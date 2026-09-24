import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import 'vault_device_key_store_windows.dart';

// CRYPTPROTECT_UI_FORBIDDEN from the Windows DPAPI contract.
const int _cryptProtectUiForbidden = 0x1;

class Win32DpapiProtector implements DpapiProtector {
  void _ensureWindows() {
    if (!Platform.isWindows) {
      throw UnsupportedError('vault.dpapi_windows_only');
    }
  }

  @override
  Uint8List protect(Uint8List plainText) {
    _ensureWindows();
    return _transform(plainText, protect: true);
  }

  @override
  Uint8List unprotect(Uint8List cipherText) {
    _ensureWindows();
    return _transform(cipherText, protect: false);
  }

  Uint8List _transform(Uint8List input, {required bool protect}) =>
      using((arena) {
        if (input.isEmpty) {
          throw const FormatException('vault.dpapi_empty_input');
        }
        final inputBytes = arena<Uint8>(input.length);
        inputBytes.asTypedList(input.length).setAll(0, input);
        final inputBlob = arena<CRYPT_INTEGER_BLOB>();
        inputBlob.ref.cbData = input.length;
        inputBlob.ref.pbData = inputBytes;

        final outputBlob = arena<CRYPT_INTEGER_BLOB>();
        final result = protect
            ? CryptProtectData(
                inputBlob,
                null,
                null,
                null,
                _cryptProtectUiForbidden,
                outputBlob,
              )
            : CryptUnprotectData(
                inputBlob,
                null,
                null,
                null,
                _cryptProtectUiForbidden,
                outputBlob,
              );
        if (!result.value) {
          throw StateError(
            protect ? 'vault.dpapi_protect_failed' : 'vault.dpapi_unprotect_failed',
          );
        }

        final output = outputBlob.ref.pbData;
        if (output.address == 0 || outputBlob.ref.cbData <= 0) {
          throw StateError('vault.dpapi_empty_result');
        }
        try {
          return Uint8List.fromList(
            output.asTypedList(outputBlob.ref.cbData),
          );
        } finally {
          LocalFree(HLOCAL(output.cast()));
        }
      });
}
