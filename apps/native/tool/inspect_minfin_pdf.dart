import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:pdf_document/pdf_document.dart';
import 'package:pdf_graphics/pdf_graphics.dart';

const sources = <String, String>{
  'MONTHLY': 'https://mof.gov.ua/storage/files/%D0%93%D1%80%D0%B0%D1%84%D1%96%D0%BA%20%D0%BD%D0%B0%20%D0%BA%D0%B2%D1%96%D1%82%D0%B5%D0%BD%D1%8C%202026%20(27_03_2026).pdf',
  'QUARTERLY': 'https://mof.gov.ua/storage/files/3%20%D0%BA%D0%B2%D0%B0%D1%80%D1%82%D0%B0%D0%BB%202026%2001_07_2026.pdf',
  'SWITCH': 'https://mof.gov.ua/storage/files/%D0%9A%D0%B0%D0%BB%D0%B5%D0%BD%D0%B4%D0%B0%D1%80%20switch%20%D1%87%D0%B5%D1%80%D0%B2%D0%B5%D0%BD%D1%8C%202026.pdf',
};

Future<void> main() async {
  for (final entry in sources.entries) {
    final response = await http.get(Uri.parse(entry.value));
    if (response.statusCode != 200) {
      throw StateError('${entry.key}: HTTP ${response.statusCode}');
    }
    final bytes = Uint8List.fromList(response.bodyBytes);
    if (bytes.length < 5 || String.fromCharCodes(bytes.take(5)) != '%PDF-') {
      throw StateError('${entry.key}: not a PDF');
    }
    final document = PdfDocument.open(bytes);
    print('===MINFIN_PDF_BEGIN|${entry.key}|pages=${document.pageCount}===');
    for (var page = 0; page < document.pageCount; page++) {
      final extracted = PdfPageText.extract(document, page);
      for (final run in extracted.runs) {
        final text = run.text.replaceAll(RegExp(r'\s+'), ' ').trim();
        if (text.isEmpty) continue;
        final b = run.bounds;
        print(
          'RUN|$page|'
          '${b.left.toStringAsFixed(2)}|'
          '${b.bottom.toStringAsFixed(2)}|'
          '${b.right.toStringAsFixed(2)}|'
          '${b.top.toStringAsFixed(2)}|'
          '$text',
        );
      }
    }
    print('===MINFIN_PDF_END|${entry.key}===');
  }
}
