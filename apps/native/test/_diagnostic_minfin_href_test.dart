import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('diagnostic: inspect current MinFin auction result hrefs', () async {
    final response = await http.get(
      Uri.parse('https://mof.gov.ua/uk/ogoloshennja-ta-rezultati-aukcioniv'),
    );
    expect(response.statusCode, 200);

    final rowPattern = RegExp(r'<tr\\b[^>]*>(.*?)</tr>', dotAll: true);
    final anchorPattern = RegExp(
      r'''<a\\b[^>]*href=["']([^"']+)["'][^>]*>(.*?)</a>''',
      dotAll: true,
    );

    for (final row in rowPattern.allMatches(response.body)) {
      final html = row.group(1)!;
      if (!html.contains('2026')) continue;
      final anchors = anchorPattern.allMatches(html).toList();
      if (anchors.any((a) => a.group(2)!.contains('Результати проведення'))) {
        final compact = html
            .replaceAll(RegExp(r'<[^>]+>'), ' ')
            .replaceAll(RegExp(r'\\s+'), ' ')
            .trim();
        print('MINFIN_ROW: ' + compact);
        for (final a in anchors) {
          final label = a
              .group(2)!
              .replaceAll(RegExp(r'<[^>]+>'), ' ')
              .replaceAll(RegExp(r'\\s+'), ' ')
              .trim();
          print('MINFIN_LINK: ' + a.group(1)! + ' | ' + label);
        }
      }
    }
  }, timeout: const Timeout(Duration(seconds: 30)));
}
