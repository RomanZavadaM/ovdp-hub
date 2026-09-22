import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/main.dart';
import 'package:ovdp_hub/models.dart';

import 'support/fake_repository.dart';

void main() {
  testWidgets('Ukrainian is default and shell can switch to English', (
    tester,
  ) async {
    final data =
        jsonDecode(File('assets/nbu-snapshot.json').readAsStringSync())
            as Map<String, dynamic>;
    data['assets'] = [(data['assets'] as List).last];

    await tester.pumpWidget(
      OvdpApp(repository: FakeRepository(Catalog.parse(jsonEncode(data)))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Каталог'), findsWidgets);
    await tester.tap(find.byTooltip('Мова / Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Catalog'), findsWidgets);
    expect(find.text('Planning'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
