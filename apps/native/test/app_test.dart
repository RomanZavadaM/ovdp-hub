import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/main.dart';
import 'package:ovdp_hub/data/hub_repository.dart';
import 'package:ovdp_hub/models.dart';
import 'support/fake_repository.dart';
import 'support/planner_comparison_fixtures.dart';

void main() {
  late Catalog catalog;
  setUpAll(() async {
    final json =
        jsonDecode(await File('assets/nbu-snapshot.json').readAsString())
            as Map<String, dynamic>;
    json['assets'] = [(json['assets'] as List).last];
    catalog = Catalog.parse(jsonEncode(json));
  });
  testWidgets('planner generates and reopens a saved cashflow scenario', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final now = DateTime.now();
    final maturity = DateTime(
      now.year + 1,
      now.month,
      now.day,
    ).toIso8601String().substring(0, 10);
    final json = jsonDecode(jsonEncode(catalog.json)) as Map<String, dynamic>;
    final asset = (json['assets'] as List).single as Map<String, dynamic>;
    asset['maturityDate'] = maturity;
    asset['currency'] = 'UAH';
    asset['payments'] = [
      {'date': maturity, 'kind': 'REDEMPTION', 'amount': '1000'},
    ];
    final repository = FakeRepository(Catalog.parse(jsonEncode(json)));
    await tester.pumpWidget(OvdpApp(repository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Планування'));
    await tester.pumpAndSettle();
    final generate = find.text('Розподілити за строками');
    await tester.ensureVisible(generate);
    await tester.tap(generate);
    await tester.pumpAndSettle();
    final save = find.text('Зберегти сценарій із кількістю та цінами');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(repository.current!.sets.single.scenario, isNotNull);
    await tester.tap(find.text('Мій план'));
    await tester.pumpAndSettle();
    final open = find.text('Відкрити план і календар коштів');
    await tester.ensureVisible(open);
    await tester.tap(open);
    await tester.pumpAndSettle();
    expect(find.text('Планувальник цілей і доходу'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
  testWidgets('planner price source controls are usable end to end', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    final maturity = DateTime(
      now.year + 1,
      now.month,
      now.day,
    ).toIso8601String().substring(0, 10);
    final json = jsonDecode(jsonEncode(catalog.json)) as Map<String, dynamic>;
    final asset = (json['assets'] as List).single as Map<String, dynamic>;
    asset['maturityDate'] = maturity;
    asset['currency'] = 'UAH';
    asset['payments'] = [
      {'date': maturity, 'kind': 'REDEMPTION', 'amount': '1000'},
    ];

    final repository = FakeRepository(Catalog.parse(jsonEncode(json)));
    await tester.pumpWidget(OvdpApp(repository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Планування'));
    await tester.pumpAndSettle();

    final generate = find.text('Розподілити за строками');
    await tester.ensureVisible(generate);
    await tester.tap(generate);
    await tester.pumpAndSettle();

    final addSource = find.widgetWithText(
      OutlinedButton,
      'Додати джерело ціни',
    );
    await tester.ensureVisible(addSource);
    await tester.tap(addSource);
    await tester.pumpAndSettle();

    final dialogFields = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    expect(dialogFields, findsNWidgets(2));
    await tester.enterText(dialogFields.at(0), 'Тестовий продавець');
    await tester.enterText(dialogFields.at(1), '990');
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Додати джерело ціни'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Пріоритет джерел ціни'), findsOneWidget);
    expect(
      find.text('Вибране джерело ціни: Тестовий продавець'),
      findsOneWidget,
    );
    expect(find.text('Тестовий продавець · 990 UAH'), findsOneWidget);

    final nominal = find.widgetWithText(
      OutlinedButton,
      'Використати оцінку за номіналом',
    );
    await tester.ensureVisible(nominal);
    await tester.tap(nominal);
    await tester.pumpAndSettle();
    expect(find.text('Оцінка за номіналом'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await repository.dispose();
  });
  testWidgets('planner purchase fee is explicit and affects displayed result', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    final maturity = DateTime(
      now.year + 1,
      now.month,
      now.day,
    ).toIso8601String().substring(0, 10);
    final json = jsonDecode(jsonEncode(catalog.json)) as Map<String, dynamic>;
    final asset = (json['assets'] as List).single as Map<String, dynamic>;
    asset['maturityDate'] = maturity;
    asset['currency'] = 'UAH';
    asset['payments'] = [
      {'date': maturity, 'kind': 'REDEMPTION', 'amount': '1000'},
    ];
    final repository = FakeRepository(Catalog.parse(jsonEncode(json)));

    await tester.pumpWidget(OvdpApp(repository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Планування'));
    await tester.pumpAndSettle();

    expect(find.text('Комісії придбання'), findsOneWidget);
    expect(find.text('Комісії невідомі'), findsOneWidget);
    expect(
      find.textContaining('Комісії невідомі: показані суми'),
      findsOneWidget,
    );

    final knownFees = find.text('Комісію підтверджено');
    await tester.ensureVisible(knownFees);
    await tester.tap(knownFees);
    await tester.pumpAndSettle();
    final feeField = find.widgetWithText(
      TextFormField,
      'Загальна комісія придбання, UAH',
    );
    expect(feeField, findsOneWidget);
    await tester.ensureVisible(feeField);
    await tester.enterText(feeField, '100');
    await tester.pumpAndSettle();

    final generate = find.text('Розподілити за строками');
    await tester.ensureVisible(generate);
    await tester.tap(generate);
    await tester.pumpAndSettle();

    expect(find.text('Врахована комісія придбання: 100.00 UAH'), findsOneWidget);
    expect(find.textContaining('Комісії невідомі: показані суми'), findsNothing);
    expect(tester.takeException(), isNull);

    final unknown = find.text('Комісії невідомі');
    await tester.ensureVisible(unknown);
    await tester.tap(unknown);
    await tester.pumpAndSettle();
    expect(find.textContaining('Комісії невідомі: показані суми'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await repository.dispose();
  });
  testWidgets('planner tax preset is explicit and shows verified zero', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    final maturity = DateTime(
      now.year + 1,
      now.month,
      now.day,
    ).toIso8601String().substring(0, 10);
    final json = jsonDecode(jsonEncode(catalog.json)) as Map<String, dynamic>;
    final asset = (json['assets'] as List).single as Map<String, dynamic>;
    asset['maturityDate'] = maturity;
    asset['currency'] = 'UAH';
    asset['payments'] = [
      {'date': maturity, 'kind': 'REDEMPTION', 'amount': '1000'},
    ];
    final repository = FakeRepository(Catalog.parse(jsonEncode(json)));

    await tester.pumpWidget(OvdpApp(repository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Планування'));
    await tester.pumpAndSettle();

    final taxHeading = find.text('Податки');
    await tester.ensureVisible(taxHeading);
    expect(taxHeading, findsOneWidget);
    expect(find.text('Податки невідомі'), findsOneWidget);
    expect(
      find.textContaining('Податки невідомі: показаний прибуток'),
      findsOneWidget,
    );

    final preset = find.text('Резидент України · ОВДП · 2026');
    await tester.ensureVisible(preset);
    await tester.tap(preset);
    await tester.pumpAndSettle();

    expect(find.textContaining('Правила перевірено: 2026-09-23'), findsOneWidget);
    expect(find.text('Враховані податки: 0.00 UAH'), findsOneWidget);
    expect(
      find.textContaining('Податки невідомі: показаний прибуток'),
      findsNothing,
    );
    expect(tester.takeException(), isNull);

    final unknown = find.text('Податки невідомі');
    await tester.ensureVisible(unknown);
    await tester.tap(unknown);
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Податки невідомі: показаний прибуток'),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await repository.dispose();
  });
  testWidgets('planner FX comparison is explicit and does not alter base currency', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    final maturity = DateTime(
      now.year + 1,
      now.month,
      now.day,
    ).toIso8601String().substring(0, 10);
    final json = jsonDecode(jsonEncode(catalog.json)) as Map<String, dynamic>;
    final asset = (json['assets'] as List).single as Map<String, dynamic>;
    asset['maturityDate'] = maturity;
    asset['currency'] = 'UAH';
    asset['payments'] = [
      {'date': maturity, 'kind': 'REDEMPTION', 'amount': '1000'},
    ];
    final repository = FakeRepository(Catalog.parse(jsonEncode(json)));
    await tester.pumpWidget(OvdpApp(repository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Планування'));
    await tester.pumpAndSettle();

    final heading = find.text('FX-порівняння');
    await tester.ensureVisible(heading);
    expect(heading, findsOneWidget);
    expect(find.text('FX-порівняння не задане.'), findsOneWidget);

    final add = find.text('Додати FX-порівняння');
    await tester.ensureVisible(add);
    await tester.tap(add);
    await tester.pumpAndSettle();

    expect(find.text('Налаштувати FX-порівняння'), findsOneWidget);
    final fxFields = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextFormField),
    );
    expect(fxFields, findsNWidgets(3));
    await tester.enterText(fxFields.at(0), '0.025');
    await tester.enterText(fxFields.at(1), '2026-09-23');
    await tester.enterText(fxFields.at(2), 'https://bank.gov.ua/');
    await tester.tap(find.text('Застосувати FX'));
    await tester.pumpAndSettle();

    expect(find.textContaining('1 UAH = 0.025 USD'), findsWidgets);
    final generate = find.text('Розподілити за строками');
    await tester.ensureVisible(generate);
    await tester.tap(generate);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Порівняльний результат у валюті FX:'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Базові суми та cashflow у валюті сценарію'),
      findsOneWidget,
    );
    expect(find.textContaining('UAH'), findsWidgets);
    expect(tester.takeException(), isNull);

    final clear = find.text('Очистити FX');
    await tester.ensureVisible(clear);
    await tester.tap(clear);
    await tester.pumpAndSettle();
    expect(find.text('FX-порівняння не задане.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await repository.dispose();
  });
  testWidgets('planner early sale is explicit per position and reversible', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    final sale = now.add(const Duration(days: 30));
    final maturity = DateTime(
      now.year + 1,
      now.month,
      now.day,
    ).toIso8601String().substring(0, 10);
    final saleDate = sale.toIso8601String().substring(0, 10);
    final json = jsonDecode(jsonEncode(catalog.json)) as Map<String, dynamic>;
    final asset = (json['assets'] as List).single as Map<String, dynamic>;
    asset['maturityDate'] = maturity;
    asset['currency'] = 'UAH';
    asset['payments'] = [
      {'date': maturity, 'kind': 'REDEMPTION', 'amount': '1000'},
    ];
    final repository = FakeRepository(Catalog.parse(jsonEncode(json)));

    await tester.pumpWidget(OvdpApp(repository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Планування'));
    await tester.pumpAndSettle();

    final generate = find.text('Розподілити за строками');
    await tester.ensureVisible(generate);
    await tester.tap(generate);
    await tester.pumpAndSettle();

    final addExit = find.text('Задати достроковий продаж');
    await tester.ensureVisible(addExit);
    await tester.tap(addExit);
    await tester.pumpAndSettle();

    expect(find.text('Достроковий продаж позиції'), findsOneWidget);
    final fields = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextFormField),
    );
    expect(fields, findsNWidgets(3));
    await tester.enterText(fields.at(0), saleDate);
    await tester.enterText(fields.at(1), '1020');
    await tester.tap(find.text('Застосувати продаж'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Достроковий продаж:'), findsOneWidget);
    expect(
      find.textContaining('Є дострокові продажі: cashflow'),
      findsOneWidget,
    );
    expect(find.textContaining('продаж'), findsWidgets);
    expect(tester.takeException(), isNull);

    final returnToMaturity = find.text('Повернути до погашення');
    await tester.ensureVisible(returnToMaturity);
    await tester.tap(returnToMaturity);
    await tester.pumpAndSettle();
    expect(find.text('Утримання до погашення'), findsOneWidget);
    expect(find.textContaining('Є дострокові продажі: cashflow'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await repository.dispose();
  });

  testWidgets('planner needs block exposes recurrence and one-off additions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeRepository(catalog);
    await tester.pumpWidget(OvdpApp(repository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Планування'));
    await tester.pumpAndSettle();

    final heading = find.text('Мої майбутні потреби й витрати');
    await tester.ensureVisible(heading);
    expect(heading, findsOneWidget);
    expect(find.text('Основна потреба'), findsWidgets);
    expect(find.text('Додаткові одноразові потреби'), findsOneWidget);

    final recurring = find.text('Повторювати цю потребу');
    await tester.ensureVisible(recurring);
    await tester.tap(recurring);
    await tester.pumpAndSettle();

    expect(find.text('Повторювати кожні, місяців'), findsOneWidget);
    expect(
      find.text('Кількість платежів разом із першим'),
      findsOneWidget,
    );

    final add = find.text('Додати витрату');
    await tester.ensureVisible(add);
    await tester.tap(add);
    await tester.pumpAndSettle();

    expect(find.text('Витрата 2'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await repository.dispose();
  });

  testWidgets('saved plans can be compared neutrally as A/B', (tester) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final comparison = comparisonCatalog();
    final bond = comparison.bonds.first;
    final sets = [
      comparisonSavedSet(
        bond,
        name: 'Сценарій один',
        savedAt: '2026-09-23T10:00:00Z',
      ),
      comparisonSavedSet(
        bond,
        name: 'Сценарій два',
        savedAt: '2026-09-23T10:01:00Z',
        variantLabel: 'B',
        purchasePrice: '990',
      ),
    ];
    final repository = FakeRepository(comparison);
    repository.current = WorkspaceSnapshot('local', comparison, sets);

    await tester.pumpWidget(OvdpApp(repository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Добірки'));
    await tester.pumpAndSettle();

    final choices = find.widgetWithText(
      CheckboxListTile,
      'Додати до порівняння A/B/C',
    );
    expect(choices, findsNWidgets(2));

    await tester.tap(choices.at(0));
    await tester.pumpAndSettle();
    expect(find.text('Вибрано: 1/3'), findsOneWidget);

    await tester.tap(
      find.widgetWithText(
        CheckboxListTile,
        'Додати до порівняння A/B/C',
      ).at(1),
    );
    await tester.pumpAndSettle();

    expect(find.text('Вибрано: 2/3'), findsOneWidget);
    expect(find.text('Порівняння A/B/C'), findsWidgets);
    expect(
      find.text(
        'Таблиця не визначає переможця: вона показує фактичні відмінності сценаріїв.',
      ),
      findsOneWidget,
    );
    expect(find.text('Сценарій один'), findsWidgets);
    expect(find.text('Сценарій два'), findsWidgets);
    expect(find.text('A'), findsWidgets);
    expect(find.text('B'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await repository.dispose();
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
