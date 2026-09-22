import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/errors.dart';
import 'package:ovdp_hub/l10n/hub_locale.dart';
import 'package:ovdp_hub/main.dart';
import 'package:ovdp_hub/models.dart';
import 'package:ovdp_hub/ui/components.dart';

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
    expect(find.text('Refresh directly from NBU'), findsOneWidget);
    expect(find.byTooltip('Language'), findsOneWidget);

    await tester.tap(find.text('Calculator').first);
    await tester.pumpAndSettle();
    expect(find.text('Educational calculator'), findsOneWidget);

    await tester.tap(find.text('Sellers').first);
    await tester.pumpAndSettle();
    expect(find.text('Sellers · public quotes'), findsOneWidget);

    await tester.tap(find.text('Storage').first);
    await tester.pumpAndSettle();
    expect(find.text('Workspace folder'), findsOneWidget);

    await tester.tap(find.text('Collections').first);
    await tester.pumpAndSettle();
    expect(find.text('Saved collections'), findsOneWidget);

    await tester.tap(find.text('Planning').first);
    await tester.pumpAndSettle();
    expect(find.text('Goals and income planner'), findsOneWidget);
    expect(find.text('Budget in selected currency'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('typed error follows the selected UI language', (tester) async {
    final locale = LocaleCubit()..select(AppLanguage.en);
    await tester.pumpWidget(
      BlocProvider.value(
        value: locale,
        child: MaterialApp(
          home: Scaffold(
            body: ErrorNotice(
              const AppError('planner.reserve_exceeds_budget'),
              () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('The reserve exceeds the budget.'), findsOneWidget);
    await locale.close();
  });

}
