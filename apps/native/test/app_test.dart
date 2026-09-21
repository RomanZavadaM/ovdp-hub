import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/main.dart';
import 'package:ovdp_hub/models.dart';
import 'support/fake_repository.dart';

void main() {
  late Catalog catalog;
  setUpAll(() async {
    final json =
        jsonDecode(await File('assets/nbu-snapshot.json').readAsString())
            as Map<String, dynamic>;
    json['assets'] = [(json['assets'] as List).last];
    catalog = Catalog.parse(jsonEncode(json));
  });
  testWidgets('phone layout saves a collection through Cubit and reopens it', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = FakeRepository(catalog);
    await tester.pumpWidget(OvdpApp(repository: repository));
    await tester.pumpAndSettle();
    final checkbox = find.byType(Checkbox).first;
    await tester.ensureVisible(checkbox);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();
    final name = find.widgetWithText(TextFormField, 'Назва добірки');
    await tester.ensureVisible(name);
    await tester.enterText(name, 'Мій сценарій');
    final save = find.text('Зберегти в робочій папці');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Мій сценарій'), findsOneWidget);
    expect(repository.current!.sets.single.name, 'Мій сценарій');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
  testWidgets('desktop calculator retains input across navigation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(OvdpApp(repository: FakeRepository(catalog)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Калькулятор'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Кількість облігацій'),
      '2',
    );
    await tester.tap(find.text('Каталог'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Калькулятор'));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
    await tester.tap(find.text('Розрахувати локально'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Витрати: 1800.00'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
