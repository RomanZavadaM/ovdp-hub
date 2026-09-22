import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('diagnostic: inspect current MinFin placement and switch result targets',
      () async {
    final indexUri =
        Uri.parse('https://mof.gov.ua/uk/ogoloshennja-ta-rezultati-aukcioniv');
    final response = await http.get(indexUri);
    expect(response.statusCode, 200);

    final rowPattern = RegExp(r'<tr\b[^>]*>(.*?)</tr>', dotAll: true);
    final anchorPattern = RegExp(
      r'''<a\b[^>]*href=["']([^"']+)["'][^>]*>(.*?)</a>''',
      dotAll: true,
    );

    Uri? placementTarget;
    Uri? switchTarget;

    for (final row in rowPattern.allMatches(response.body)) {
      final html = row.group(1)!;
      if (!html.contains('2026')) continue;

      for (final a in anchorPattern.allMatches(html)) {
        final label = a
            .group(2)!
            .replaceAll(RegExp(r'<[^>]+>'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
        if (!label.startsWith('Результати проведення')) continue;

        final target = indexUri.resolve(a.group(1)!);
        if (label.contains('обміну')) {
          switchTarget ??= target;
        } else {
          placementTarget ??= target;
        }
      }

      if (placementTarget != null && switchTarget != null) break;
    }

    expect(placementTarget, isNotNull);
    expect(switchTarget, isNotNull);

    for (final entry in <MapEntry<String, Uri>>[
      MapEntry('PLACEMENT', placementTarget!),
      MapEntry('SWITCH', switchTarget!),
    ]) {
      final result = await http.get(entry.value);
      final kind = entry.key;
      final target = entry.value;
      final status = result.statusCode;
      final contentType = result.headers['content-type'] ?? '';
      final length = result.bodyBytes.length;
      final prefixHex = result.bodyBytes
          .take(16)
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join(' ');

      debugPrint('MINFIN_$kind' '_TARGET: $target');
      debugPrint('MINFIN_$kind' '_STATUS: $status');
      debugPrint('MINFIN_$kind' '_CONTENT_TYPE: $contentType');
      debugPrint('MINFIN_$kind' '_LENGTH: $length');
      debugPrint('MINFIN_$kind' '_PREFIX_HEX: $prefixHex');

      expect(status, 200);
      expect(result.bodyBytes.length, greaterThan(4));
    }
  }, timeout: const Timeout(Duration(seconds: 45)));
}
