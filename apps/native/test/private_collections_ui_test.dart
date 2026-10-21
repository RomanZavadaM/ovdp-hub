import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/collections/editor_cubit.dart';
import 'package:ovdp_hub/features/collections/editor_view.dart';
import 'package:ovdp_hub/features/navigation/navigation_cubit.dart';
import 'package:ovdp_hub/features/portfolio/portfolio_cubit.dart';
import 'package:ovdp_hub/features/portfolio/private_portfolio.dart';
import 'package:ovdp_hub/features/workspace/workspace_cubit.dart';
import 'package:ovdp_hub/l10n/hub_locale.dart';
import 'package:ovdp_hub/models.dart';
import 'support/fake_portfolio_gateway.dart';
import 'support/fake_repository.dart';

void main() {
  for (final language in AppLanguage.values) {
    for (final width in [430.0, 1280.0]) {
      testWidgets('private editor controls save and purge ${language.code} $width', (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final catalog = Catalog.parse(File('assets/nbu-snapshot.json').readAsStringSync());
        final hub = FakeRepository(catalog);
        final gateway = FakePortfolioGateway(stored: PrivatePortfolioPayload(portfolioId: 'primary'));
        final portfolio = PortfolioCubit(hub, gateway);
        await tester.runAsync(() => portfolio.open());
        final editor = CollectionEditorCubit(hub, portfolio: portfolio);
        editor.toggle(catalog.bonds.first, true);
        final workspace = WorkspaceCubit(hub, editor);
        final locale = LocaleCubit(initialLanguage: language);
        final navigation = NavigationCubit();
        final strings = HubStrings(language);
        await tester.pumpWidget(MultiBlocProvider(providers: [
          BlocProvider.value(value: portfolio), BlocProvider.value(value: editor),
          BlocProvider.value(value: workspace), BlocProvider.value(value: locale),
          BlocProvider.value(value: navigation),
        ], child: const MaterialApp(home: Scaffold(body: SingleChildScrollView(child: CollectionEditorView())))));
        await tester.pumpAndSettle();
        expect(strings.text('privateCollectionMode'), isNot('privateCollectionMode'));
        final name = find.widgetWithText(TextFormField, strings.text('collectionName'));
        final note = find.widgetWithText(TextFormField, strings.text('notesAssumptions'));
        await tester.ensureVisible(name);
        await tester.enterText(name, 'UI private title');
        await tester.ensureVisible(note);
        await tester.enterText(note, 'UI private note');
        final save = find.text(strings.text('savePrivateCollection'));
        await tester.ensureVisible(save);
        await tester.tap(save);
        await tester.pumpAndSettle();
        expect(gateway.stored!.privateCollections.single.set.note, 'UI private note');
        expect(hub.saves, 0);
        // Reopen the vault collection in the editor, then lock while visible.
        editor.variant(portfolio.privateCollectionSets.single);
        await tester.pumpAndSettle();
        expect(find.text('UI private title'), findsOneWidget);
        await gateway.lock();
        await tester.pumpAndSettle();
        expect(find.text('UI private title'), findsNothing);
        expect(find.text('UI private note'), findsNothing);
        expect(editor.state.selected, isEmpty);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.runAsync(() async {
          await editor.close(); await workspace.close(); await locale.close();
          await navigation.close(); await portfolio.close(); await hub.dispose();
        });
      }, timeout: const Timeout(Duration(seconds: 20)));
    }
  }
}
