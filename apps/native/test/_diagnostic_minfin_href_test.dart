import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('diagnostic: inspect current MinFin auction result targets', () async {
    final indexUri =
        Uri.parse('https://mof.gov.ua/uk/ogoloshennja-ta-rezultati-aukcioniv');
    final response = await http.get(indexUri);
    expect(response.statusCode, 200);

    final rowPattern = RegExp(r'<tr\\b[^>]*>(.*?)</tr>', dotAll: true);
    final anchorPattern = RegExp(
      r'''<a\\b[^>]*href=["']([^"']+)["'][^>]*>(.*?)</a>''',
      dotAll: true,
    );

    final targets = <Uri>[];
    for (final row in rowPattern.allMatches(response.body)) {
      final html = row.group(1)!;
      if (!html.contains('2026')) continue;
      final anchors = anchorPattern.allMatches(html).toList();
      if (!anchors.any((a) => a.group(2)!.contains('Результати проведення'))) {
        continue;
      }

      final compact = html
          .replaceAll(RegExp(r'<[^>]+>'), ' ')
          .replaceAll(RegExp(r'\\s+'), ' ')
          .trim();
      debugPrint('MINFIN_ROW: $compact');

      for (final a in anchors) {
        final label = a
            .group(2)!
            .replaceAll(RegExp(r'<[^>]+>'), ' ')
            .replaceAll(RegExp(r'\\s+'), ' ')
            .trim();
        final href = a.group(1)!;
        debugPrint('MINFIN_LINK: $href | $label');
        if (label.contains('Результати проведення')) {
          final target = indexUri.resolve(href);
          if (!targets.contains(target) && targets.length < 2) {
            targets.add(target);
          }
        }
      }
    }

    for (final target in targets) {
      final result = await http.get(target);
      final status = result.statusCode;
      final contentType = result.headers['content-type'] ?? '';
      final length = result.bodyBytes.length;
      debugPrint('MINFIN_TARGET: $target');
      debugPrint('MINFIN_STATUS: $status');
      debugPrint('MINFIN_CONTENT_TYPE: $contentType');
      debugPrint('MINFIN_LENGTH: $length');

      final prefixHex = result.bodyBytes
          .take(32)
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join(' ');
      debugPrint('MINFIN_PREFIX_HEX: $prefixHex');

      if (contentType.contains('text/') ||
          contentType.contains('html') ||
          contentType.contains('json')) {
        final preview = utf8
            .decode(result.bodyBytes, allowMalformed: true)
            .replaceAll(RegExp(r'\\s+'), ' ')
            .trim();
        final previewLength = preview.length > 1200 ? 1200 : preview.length;
        final clipped = preview.substring(0, previewLength);
        debugPrint('MINFIN_PREVIEW: $clipped');
      }
    }
  }, timeout: const Timeout(Duration(seconds: 45)));
}
