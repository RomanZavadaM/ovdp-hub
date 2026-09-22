import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/main.dart';
import 'package:ovdp_hub/models.dart';
import 'support/fake_repository.dart';

void main() {
  Future<void> capture(WidgetTester tester, GlobalKey key, String name) async {
    final directory = Platform.environment['OVDP_PREVIEW_DIR'];
    if (directory == null) return;
    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
      await Directory(directory).create(recursive: true);
      await File(
        '$directory/$name.png',
      ).writeAsBytes(bytes.buffer.asUint8List());
      image.dispose();
    });
  }

  for (final size in [const Size(1440, 1000), const Size(390, 844)]) {
    testWidgets('design switch and navigation at ${size.width}', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final font = Platform.environment['OVDP_PREVIEW_FONT'];
      if (font != null) {
        await tester.runAsync(() async {
          final bytes = await File(font).readAsBytes();
          final loader = FontLoader('Roboto')
            ..addFont(Future.value(ByteData.sublistView(bytes)));
          await loader.load();
          final icons = Platform.environment['OVDP_PREVIEW_ICONS'];
          if (icons != null) {
            final iconBytes = await File(icons).readAsBytes();
            final iconLoader = FontLoader('MaterialIcons')
              ..addFont(Future.value(ByteData.sublistView(iconBytes)));
            await iconLoader.load();
          }
        });
      }
      final data =
          jsonDecode(File('assets/nbu-snapshot.json').readAsStringSync())
              as Map<String, dynamic>;
      final today = DateTime.now().toIso8601String().substring(0, 10);
      data['assets'] = (data['assets'] as List)
          .where((b) => (b['maturityDate'] as String).compareTo(today) > 0)
          .take(8)
          .toList();
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: OvdpApp(
            repository: FakeRepository(Catalog.parse(jsonEncode(data))),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Облігації під ваші плани'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await capture(
        tester,
        key,
        size.width > 1000 ? 'studio-desktop' : 'studio-phone',
      );
      final plan = find.text('Планувати кошти');
      await tester.ensureVisible(plan);
      await tester.tap(plan);
      await tester.pumpAndSettle();
      expect(find.text('Планувальник цілей і доходу'), findsOneWidget);
      final budget = find.widgetWithText(
        TextFormField,
        'Бюджет у вибраній валюті',
      );
      await tester.ensureVisible(budget);
      await tester.enterText(budget, '120000');
      await tester.tap(find.byTooltip('Класичний дизайн'));
      await tester.pumpAndSettle();
      expect(find.text('120000'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Каталог'));
      await tester.pumpAndSettle();
      if (size.width > 1000) await capture(tester, key, 'classic-desktop');
      await tester.tap(find.byTooltip('Дизайн «Робочий кабінет»'));
      await tester.pumpAndSettle();
      expect(find.text('Облігації під ваші плани'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }
}
