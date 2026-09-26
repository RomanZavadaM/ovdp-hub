import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/ui/date_field.dart';

Widget _app({
  required Locale locale,
  required String value,
  required Future<bool> Function(String) onCommit,
  GlobalKey<HubDateFieldState>? fieldKey,
}) => MaterialApp(
  locale: locale,
  supportedLocales: const [Locale('uk'), Locale('en')],
  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: HubDateField(
        key: fieldKey,
        controlKey: 'test-date',
        canonicalValue: value,
        label: 'Date YYYY-MM-DD',
        invalidDateText: 'Invalid date',
        onCommit: onCommit,
      ),
    ),
  ),
);

void main() {
  test('strict ISO helpers reject impossible dates', () {
    expect(parseHubIsoDate('2026-09-26'), DateTime(2026, 9, 26));
    expect(parseHubIsoDate('2026-02-29'), isNull);
    expect(parseHubIsoDate('26.09.2026'), isNull);
    expect(hubDateToIso(DateTime(2026, 9, 6)), '2026-09-06');
  });

  testWidgets('localized display keeps canonical ISO on commit', (tester) async {
    String? committed;
    final key = GlobalKey<HubDateFieldState>();
    await tester.pumpWidget(
      _app(
        locale: const Locale('en'),
        value: '2026-09-26',
        fieldKey: key,
        onCommit: (value) async {
          committed = value;
          return true;
        },
      ),
    );
    await tester.pumpAndSettle();

    final fieldContext = tester.element(find.byType(HubDateField));
    final localizations = MaterialLocalizations.of(fieldContext);
    final expectedDisplay = localizations.formatCompactDate(DateTime(2026, 9, 26));
    final textField = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(textField.controller!.text, expectedDisplay);
    expect(find.text('Date'), findsOneWidget);
    expect(find.textContaining('YYYY-MM-DD'), findsNothing);

    await tester.enterText(find.byType(TextFormField), '2026-10-05');
    expect(await key.currentState!.commitPending(), isTrue);
    await tester.pump();

    expect(committed, '2026-10-05');
    expect(
      textField.controller!.text,
      localizations.formatCompactDate(DateTime(2026, 10, 5)),
    );
  });

  testWidgets('invalid keyboard draft is explicit and does not commit', (
    tester,
  ) async {
    var commits = 0;
    final key = GlobalKey<HubDateFieldState>();
    await tester.pumpWidget(
      _app(
        locale: const Locale('uk'),
        value: '2026-09-26',
        fieldKey: key,
        onCommit: (_) async {
          commits += 1;
          return true;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '31.02.2026');
    expect(await key.currentState!.commitPending(), isFalse);
    await tester.pump();

    expect(commits, 0);
    expect(find.text('Invalid date'), findsOneWidget);
  });

  testWidgets('calendar picker commits canonical date through visible control', (
    tester,
  ) async {
    String? committed;
    await tester.pumpWidget(
      _app(
        locale: const Locale('en'),
        value: '2026-09-26',
        onCommit: (value) async {
          committed = value;
          return true;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('test-date-picker')));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);

    final dialogContext = tester.element(find.byType(DatePickerDialog));
    final localizations = MaterialLocalizations.of(dialogContext);
    await tester.tap(find.text('27').last);
    await tester.tap(find.text(localizations.okButtonLabel));
    await tester.pumpAndSettle();

    expect(committed, '2026-09-27');
    expect(find.byType(DatePickerDialog), findsNothing);
  });
}
