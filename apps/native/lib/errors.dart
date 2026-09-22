import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

@immutable
class AppError {
  final String code;
  final Map<String, Object?> parameters;

  const AppError(this.code, [this.parameters = const {}]);

  static final RegExp _codePattern = RegExp(r'^[a-z][a-z0-9_.-]+$');

  factory AppError.from(Object error) {
    if (error is AppError) return error;
    if (error is FormatException) {
      return _fromParts(error.message.toString(), error.source);
    }
    if (error is StateError) {
      return _fromParts(error.message.toString(), null);
    }
    if (error is UnsupportedError) {
      return _fromParts(error.message, null);
    }
    if (error is FileSystemException) {
      return _fromParts(error.message, null);
    }
    if (error is TimeoutException) {
      return const AppError('network.timeout');
    }
    return const AppError('common.unexpected');
  }

  static AppError _fromParts(String code, Object? source) {
    if (!_codePattern.hasMatch(code)) {
      return const AppError('common.unexpected');
    }
    if (source is Map) {
      return AppError(
        code,
        Map<String, Object?>.unmodifiable(
          source.map((key, value) => MapEntry(key.toString(), value)),
        ),
      );
    }
    return AppError(code);
  }

  @override
  String toString() => 'AppError($code, $parameters)';
}
