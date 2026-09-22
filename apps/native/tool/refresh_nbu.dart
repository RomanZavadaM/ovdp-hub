import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:ovdp_hub/models.dart';

Future<void> main() async {
  final client = http.Client();
  try {
    final response = await client
        .get(Uri.parse('https://bank.gov.ua/depo_securities?json'))
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200 ||
        response.bodyBytes.length > 20 * 1024 * 1024) {
      throw StateError('NBU refresh failed: HTTP ${response.statusCode}');
    }

    final catalog = Catalog.fromNbu(utf8.decode(response.bodyBytes));
    final target = File('assets/nbu-snapshot.json');
    final temporary = File('${target.path}.pending');

    await temporary.writeAsString(jsonEncode(catalog.json), flush: true);
    await temporary.rename(target.path);

    stdout.writeln(
      'Updated ${catalog.bonds.length} OVDP instruments; '
      'retrievedAt=${catalog.json['retrievedAt']}',
    );
  } finally {
    client.close();
  }
}
