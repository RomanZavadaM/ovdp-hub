import 'dart:io';

import 'package:flutter/services.dart';

/// Opaque user-granted external folder capability.
///
/// The native side owns the actual Android SAF URI / iOS bookmark. Dart only
/// persists this stable grant id and a human-readable label, so platform
/// capability details never masquerade as a normal filesystem path.
class ExternalFolderGrant {
  final String id;
  final String label;

  const ExternalFolderGrant({required this.id, required this.label});

  factory ExternalFolderGrant.fromMap(Map<Object?, Object?> map) {
    final id = map['id'];
    final label = map['label'];
    if (id is! String || id.isEmpty || label is! String || label.isEmpty) {
      throw const FormatException('workspace.external_grant_invalid');
    }
    return ExternalFolderGrant(id: id, label: label);
  }
}

abstract interface class MobileExternalStorage {
  bool get supported;

  Future<String?> exportEncryptedBackup({
    required String suggestedName,
    required Uint8List bytes,
  });

  Future<Uint8List?> importEncryptedBackup({required int maxBytes});

  Future<ExternalFolderGrant?> chooseWorkspaceFolder();
  Future<bool> workspaceFolderAvailable(String grantId);
  Future<String?> readWorkspaceText({
    required String grantId,
    required String relativePath,
    required int maxBytes,
  });
  Future<void> writeWorkspaceText({
    required String grantId,
    required String relativePath,
    required String content,
    required bool replace,
  });
  Future<List<String>> listWorkspaceFiles({
    required String grantId,
    required String relativeDirectory,
  });
  Future<void> deleteWorkspaceFile({
    required String grantId,
    required String relativePath,
  });
}

class MethodChannelMobileExternalStorage implements MobileExternalStorage {
  static const channelName = 'ua.ovdphub/mobile_external_storage';
  static const _channel = MethodChannel(channelName);

  final bool? _supportedOverride;

  const MethodChannelMobileExternalStorage({bool? supportedOverride})
      : _supportedOverride = supportedOverride;

  @override
  bool get supported =>
      _supportedOverride ?? Platform.isAndroid || Platform.isIOS;

  @override
  Future<String?> exportEncryptedBackup({
    required String suggestedName,
    required Uint8List bytes,
  }) async {
    _requireSupported();
    if (bytes.isEmpty) {
      throw const FormatException('vault.invalid_file');
    }
    try {
      return await _channel.invokeMethod<String>('exportEncryptedBackup', {
        'suggestedName': suggestedName,
        'bytes': bytes,
      });
    } on PlatformException catch (error) {
      throw StateError(_platformCode(error, 'portfolio.backup_export_failed'));
    }
  }

  @override
  Future<Uint8List?> importEncryptedBackup({required int maxBytes}) async {
    _requireSupported();
    if (maxBytes <= 0) {
      throw ArgumentError.value(maxBytes, 'maxBytes');
    }
    try {
      final value = await _channel.invokeMethod<Uint8List>(
        'importEncryptedBackup',
        {'maxBytes': maxBytes},
      );
      if (value != null && value.length > maxBytes) {
        throw const FormatException('vault.file_too_large');
      }
      return value;
    } on PlatformException catch (error) {
      throw StateError(_platformCode(error, 'portfolio.backup_import_failed'));
    }
  }

  @override
  Future<ExternalFolderGrant?> chooseWorkspaceFolder() async {
    _requireSupported();
    try {
      final value = await _channel.invokeMethod<Map<Object?, Object?>>(
        'chooseWorkspaceFolder',
      );
      return value == null ? null : ExternalFolderGrant.fromMap(value);
    } on PlatformException catch (error) {
      throw StateError(_platformCode(error, 'workspace.external_pick_failed'));
    }
  }

  @override
  Future<bool> workspaceFolderAvailable(String grantId) async {
    _requireSupported();
    _validateGrantId(grantId);
    try {
      return await _channel.invokeMethod<bool>('workspaceFolderAvailable', {
            'grantId': grantId,
          }) ??
          false;
    } on PlatformException catch (error) {
      throw StateError(
        _platformCode(error, 'workspace.external_permission_lost'),
      );
    }
  }

  @override
  Future<String?> readWorkspaceText({
    required String grantId,
    required String relativePath,
    required int maxBytes,
  }) async {
    _requireSupported();
    _validateGrantId(grantId);
    _validateRelativePath(relativePath);
    if (maxBytes <= 0) throw ArgumentError.value(maxBytes, 'maxBytes');
    try {
      return await _channel.invokeMethod<String>('readWorkspaceText', {
        'grantId': grantId,
        'relativePath': relativePath,
        'maxBytes': maxBytes,
      });
    } on PlatformException catch (error) {
      throw StateError(_platformCode(error, 'workspace.external_read_failed'));
    }
  }

  @override
  Future<void> writeWorkspaceText({
    required String grantId,
    required String relativePath,
    required String content,
    required bool replace,
  }) async {
    _requireSupported();
    _validateGrantId(grantId);
    _validateRelativePath(relativePath);
    try {
      await _channel.invokeMethod<void>('writeWorkspaceText', {
        'grantId': grantId,
        'relativePath': relativePath,
        'content': content,
        'replace': replace,
      });
    } on PlatformException catch (error) {
      throw StateError(_platformCode(error, 'workspace.external_write_failed'));
    }
  }

  @override
  Future<List<String>> listWorkspaceFiles({
    required String grantId,
    required String relativeDirectory,
  }) async {
    _requireSupported();
    _validateGrantId(grantId);
    if (relativeDirectory.isNotEmpty) {
      _validateRelativePath(relativeDirectory);
    }
    try {
      final values = await _channel.invokeListMethod<String>(
            'listWorkspaceFiles',
            {
              'grantId': grantId,
              'relativeDirectory': relativeDirectory,
            },
          ) ??
          const <String>[];
      return List.unmodifiable(values);
    } on PlatformException catch (error) {
      throw StateError(_platformCode(error, 'workspace.external_list_failed'));
    }
  }

  @override
  Future<void> deleteWorkspaceFile({
    required String grantId,
    required String relativePath,
  }) async {
    _requireSupported();
    _validateGrantId(grantId);
    _validateRelativePath(relativePath);
    try {
      await _channel.invokeMethod<void>('deleteWorkspaceFile', {
        'grantId': grantId,
        'relativePath': relativePath,
      });
    } on PlatformException catch (error) {
      throw StateError(_platformCode(error, 'workspace.external_delete_failed'));
    }
  }

  void _requireSupported() {
    if (!supported) {
      throw UnsupportedError('workspace.external_unsupported');
    }
  }

  static void _validateGrantId(String grantId) {
    if (!RegExp(r'^[A-Za-z0-9-]{8,80}$').hasMatch(grantId)) {
      throw const FormatException('workspace.external_grant_invalid');
    }
  }

  static void _validateRelativePath(String value) {
    if (value.isEmpty ||
        value.length > 512 ||
        value.startsWith('/') ||
        value.startsWith('\\') ||
        value.contains('\\') ||
        value.split('/').any((part) => part.isEmpty || part == '.' || part == '..')) {
      throw const FormatException('workspace.invalid_relative_path');
    }
  }

  static String _platformCode(PlatformException error, String fallback) {
    final code = error.code.trim();
    return code.isEmpty ? fallback : code;
  }
}
