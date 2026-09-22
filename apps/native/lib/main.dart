import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/hub_repository.dart';
import 'features/catalog/catalog_cubit.dart';
import 'features/catalog/catalog_view.dart';
import 'features/collections/collections_cubit.dart';
import 'features/collections/collections_view.dart';
import 'features/collections/editor_cubit.dart';
import 'features/calculator/calculator_cubit.dart';
import 'features/calculator/calculator_view.dart';
import 'features/workspace/workspace_cubit.dart';
import 'features/workspace/workspace_view.dart';
import 'features/navigation/navigation_cubit.dart';
import 'ui/components.dart';
import 'ui/studio_design.dart';
import 'features/appearance/appearance_cubit.dart';
import 'features/planner/planner_cubit.dart';
import 'features/planner/planner_view.dart';
import 'features/sellers/seller_repository.dart';
import 'features/sellers/sellers_cubit.dart';
import 'features/sellers/sellers_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OvdpApp());
}

class OvdpApp extends StatelessWidget {
  final HubRepository? repository;
  const OvdpApp({super.key, this.repository});
  @override
  Widget build(BuildContext context) => RepositoryProvider<HubRepository>(
    create: (_) => repository ?? FileHubRepository(),
    dispose: (repo) => repo.dispose(),
    child: MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CatalogCubit(context.read<HubRepository>()),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => CollectionsCubit(context.read<HubRepository>()),
          lazy: false,
        ),
        BlocProvider(
          create: (context) =>
              CollectionEditorCubit(context.read<HubRepository>()),
          lazy: false,
        ),
        BlocProvider(create: (_) => CalculatorCubit()),
        BlocProvider(create: (_) => AppearanceCubit()),
        BlocProvider(create: (_) => SellersCubit(SellerRepository())),
        BlocProvider(create: (_) => NavigationCubit()),
        BlocProvider(
          create: (context) => PlannerCubit(context.read<HubRepository>()),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => WorkspaceCubit(
            context.read<HubRepository>(),
            context.read<CollectionEditorCubit>(),
            planner: context.read<PlannerCubit>(),
          )..initialize(),
          lazy: false,
        ),
      ],
      child: const StyledApp(),
    ),
  );
}

class StyledApp extends StatelessWidget {
  const StyledApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ОВДП Hub',
    debugShowCheckedModeBanner: false,
    theme: hubTheme(context.watch<AppearanceCubit>().state.studio),
    home: const Home(),
  );
}

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    final screen = context.watch<NavigationCubit>().state.index;
    final workspace = context.watch<WorkspaceCubit>().state;
    final studio = context.watch<AppearanceCubit>().state.studio;
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    const destinations = [
      NavigationDestination(
        icon: Icon(Icons.analytics_outlined),
        label: 'Каталог',
      ),
      NavigationDestination(
        icon: Icon(Icons.bookmarks_outlined),
        label: 'Добірки',
      ),
      NavigationDestination(
        icon: Icon(Icons.calculate_outlined),
        label: 'Калькулятор',
      ),
      NavigationDestination(
        icon: Icon(Icons.folder_outlined),
        label: 'Сховище',
      ),
      NavigationDestination(
        icon: Icon(Icons.event_available_outlined),
        label: 'Планування',
      ),
      NavigationDestination(
        icon: Icon(Icons.storefront_outlined),
        label: 'Продавці',
      ),
    ];
    final content = Column(
      children: [
        if (workspace.busy) const LinearProgressIndicator(),
        ErrorNotice(
          workspace.error,
          context.read<WorkspaceCubit>().dismissError,
        ),
        Expanded(
          child: SingleChildScrollView(
            key: ValueKey(screen),
            padding: EdgeInsets.all(wide ? 32 : 16),
            child: switch (screen) {
              0 => const CatalogView(),
              1 => const CollectionsView(),
              2 => const CalculatorView(),
              4 => const PlannerView(),
              5 => const SellersView(),
              _ => const WorkspaceView(),
            },
          ),
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(studio ? 'Аналітичний кабінет' : '◈ ОВДП Hub'),
        actions: [
          IconButton(
            tooltip: 'Про програму',
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'ОВДП Hub',
                applicationLegalese:
                    'Copyright © 2026 Roman Zavada (Роман Завада). All rights reserved.',
                children: const [
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      'ОВДП Hub є proprietary software. Публічна видимість вихідного коду не є open-source ліцензією. Повні умови використання містяться у LICENSE.md у комплекті програми та репозиторії.',
                    ),
                  ),
                ],
              );
            },
            icon: const Icon(Icons.info_outline),
          ),
          IconButton(
            tooltip: studio ? 'Класичний дизайн' : 'Дизайн «Робочий кабінет»',
            onPressed: context.read<AppearanceCubit>().toggle,
            icon: Icon(
              studio
                  ? Icons.view_sidebar_outlined
                  : Icons.dashboard_customize_outlined,
            ),
          ),
          if (wide)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                workspace.path == null
                    ? 'Сховище не відкрито'
                    : 'Дані на вашому пристрої',
              ),
            ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (wide && studio)
            StudioSidebar(
              selected: screen,
              onSelected: context.read<NavigationCubit>().select,
            ),
          if (wide && !studio)
            NavigationRail(
              selectedIndex: screen,
              labelType: NavigationRailLabelType.all,
              onDestinationSelected: context.read<NavigationCubit>().select,
              destinations: destinations
                  .map(
                    (d) => NavigationRailDestination(
                      icon: d.icon,
                      label: Text(d.label),
                    ),
                  )
                  .toList(),
            ),
          Expanded(child: content),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              selectedIndex: screen,
              destinations: destinations,
              onDestinationSelected: context.read<NavigationCubit>().select,
            ),
    );
  }
}
