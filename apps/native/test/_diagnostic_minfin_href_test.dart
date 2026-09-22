import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

String _xmlText(String value) => value
    .replaceAll('&amp;', '&')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&apos;', "'");

List<String> _docxRows(String xml) {
  final rows = <String>[];
  final rowPattern = RegExp(r'<w:tr\b[^>]*>(.*?)</w:tr>', dotAll: true);
  final cellPattern = RegExp(r'<w:tc\b[^>]*>(.*?)</w:tc>', dotAll: true);
  final textPattern = RegExp(r'<w:t(?:\s[^>]*)?>(.*?)</w:t>', dotAll: true);

  for (final row in rowPattern.allMatches(xml)) {
    final cells = <String>[];
    for (final cell in cellPattern.allMatches(row.group(1)!)) {
      final parts = textPattern
          .allMatches(cell.group(1)!)
          .map((match) => _xmlText(match.group(1)!))
          .toList();
      final text = parts.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
      cells.add(text);
    }
    if (cells.any((cell) => cell.isNotEmpty)) {
      rows.add(cells.join(' || '));
    }
  }
  return rows;
}

Future<void> _inspectDocx(String kind, Uri target) async {
  final result = await http.get(target);
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

  final dir = await Directory.systemTemp.createTemp('minfin-docx-');
  try {
    final file = File('${dir.path}/result.docx');
    await file.writeAsBytes(result.bodyBytes);
    final unzip = await Process.run(
      'unzip',
      ['-p', file.path, 'word/document.xml'],
    );
    expect(unzip.exitCode, 0, reason: unzip.stderr.toString());

    final rows = _docxRows(unzip.stdout.toString());
    expect(rows, isNotEmpty);
    final cap = rows.length > 40 ? 40 : rows.length;
    for (var i = 0; i < cap; i++) {
      final number = i + 1;
      final row = rows[i];
      debugPrint('MINFIN_$kind' '_ROW_$number: $row');
    }
  } finally {
    await dir.delete(recursive: true);
  }
}

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

    await _inspectDocx('PLACEMENT', placementTarget!);
    await _inspectDocx('SWITCH', switchTarget!);
  }, timeout: const Timeout(Duration(seconds: 45)));
}
