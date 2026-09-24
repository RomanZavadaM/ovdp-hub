import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'build_info.dart';
import 'data/hub_repository.dart';
import 'features/appearance/appearance_cubit.dart';
import 'features/calculator/calculator_cubit.dart';
import 'features/calculator/calculator_view.dart';
import 'features/catalog/catalog_cubit.dart';
import 'features/catalog/catalog_view.dart';
import 'features/collections/collections_cubit.dart';
import 'features/collections/collections_view.dart';
import 'features/collections/editor_cubit.dart';
import 'features/economy/economic_pulse_cubit.dart';
import 'features/economy/economic_pulse_view.dart';
import 'features/navigation/navigation_cubit.dart';
import 'features/planner/planner_cubit.dart';
import 'features/planner/planner_view.dart';
import 'features/portfolio/portfolio_cubit.dart';
import 'features/portfolio/portfolio_gateway.dart';
import 'features/portfolio/portfolio_view.dart';
import 'features/sellers/seller_repository.dart';
import 'features/sellers/sellers_cubit.dart';
import 'features/sellers/sellers_view.dart';
import 'features/workspace/workspace_cubit.dart';
import 'features/workspace/workspace_view.dart';
import 'l10n/hub_locale.dart';
import 'release_contract.dart';
import 'ui/components.dart';
import 'ui/dashboard_design.dart';
import 'ui/studio_design.dart';

void main(List<String> args) {
  final contractFileFromEnvironment =
      Platform.environment['OVDP_RELEASE_CONTRACT_FILE'];
  if (contractFileFromEnvironment != null &&
      contractFileFromEnvironment.isNotEmpty) {
    File(contractFileFromEnvironment).writeAsStringSync(
      releaseContractJson(),
      flush: true,
    );
    return;
  }

  const contractFilePrefix = '--release-contract-file=';
  final contractFileArg = args.where(
    (arg) => arg.startsWith(contractFilePrefix),
  );
  if (contractFileArg.isNotEmpty) {
    final path = contractFileArg.single.substring(contractFilePrefix.length);
    File(path).writeAsStringSync(releaseContractJson(), flush: true);
    return;
  }
  if (args.contains('--release-contract')) {
    stdout.writeln(releaseContractJson());
    return;
  }
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OvdpApp());
}

class OvdpApp extends StatelessWidget {
  final HubRepository? repository;
  final PortfolioGateway? portfolioGateway;
  const OvdpApp({
    super.key,
    this.repository,
    this.portfolioGateway,
  });

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
        BlocProvider(create: (_) => LocaleCubit()),
        BlocProvider(
          create: (context) =>
              EconomicPulseCubit(context.read<HubRepository>())..load(),
          lazy: false,
        ),
        BlocProvider(create: (_) => SellersCubit(SellerRepository())),
        BlocProvider(create: (_) => NavigationCubit()),
        BlocProvider(
          create: (context) => PortfolioCubit(
            context.read<HubRepository>(),
            portfolioGateway ?? LocalEncryptedPortfolioGateway(),
          )..initialize(),
          lazy: false,
        ),
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

class StyledApp extends StatefulWidget {
  const StyledApp({super.key});

  @override
  State<StyledApp> createState() => _StyledAppState();
}

class _StyledAppState extends State<StyledApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final portfolio = context.read<PortfolioCubit>();
    switch (state) {
      case AppLifecycleState.resumed:
        portfolio.onForeground();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        portfolio.onBackground();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleCubit>().state.language;
    final appearance = context.watch<AppearanceCubit>().state;
    return MaterialApp(
      title: 'OVDP Hub',
      debugShowCheckedModeBanner: false,
      theme: appearance.dashboard
          ? dashboardTheme()
          : hubTheme(appearance.studio),
      locale: language.locale,
      supportedLocales: AppLanguage.values.map((e) => e.locale).toList(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = context.watch<NavigationCubit>().state.index;
    final workspace = context.watch<WorkspaceCubit>().state;
    final appearance = context.watch<AppearanceCubit>().state;
    final studio = appearance.studio;
    final dashboard = appearance.dashboard;
    final language = context.watch<LocaleCubit>().state.language;
    final strings = HubStrings(language);
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    final workspaceOpen = workspace.path != null;

    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.analytics_outlined),
        label: strings.text('catalog'),
      ),
      NavigationDestination(
        icon: const Icon(Icons.bookmarks_outlined),
        label: strings.text('collections'),
      ),
      NavigationDestination(
        icon: const Icon(Icons.calculate_outlined),
        label: strings.text('calculator'),
      ),
      NavigationDestination(
        icon: const Icon(Icons.folder_outlined),
        label: strings.text('workspace'),
      ),
      NavigationDestination(
        icon: const Icon(Icons.event_available_outlined),
        label: strings.text('planning'),
      ),
      NavigationDestination(
        icon: const Icon(Icons.storefront_outlined),
        label: strings.text('sellers'),
      ),
      NavigationDestination(
        icon: const Icon(Icons.account_balance_wallet_outlined),
        label: strings.text('portfolio'),
      ),
    ];

    void showHubAbout() {
      showAboutDialog(
        context: context,
        applicationName: 'OVDP Hub',
        applicationVersion: appDisplayVersion,
        applicationLegalese:
            'Copyright © 2026 Roman Zavada (Роман Завада). All rights reserved.',
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(strings.text('aboutLegal')),
          ),
        ],
      );
    }

    PopupMenuButton<HubAppearance> appearanceMenu() =>
        PopupMenuButton<HubAppearance>(
          tooltip: strings.text('appearance'),
          icon: const Icon(Icons.palette_outlined),
          initialValue: appearance.mode,
          onSelected: context.read<AppearanceCubit>().select,
          itemBuilder: (_) => HubAppearance.values
              .map(
                (mode) => PopupMenuItem<HubAppearance>(
                  value: mode,
                  child: Row(
                    children: [
                      if (mode == appearance.mode)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(Icons.check, size: 18),
                        )
                      else
                        const SizedBox(width: 26),
                      Flexible(
                        child: Text(
                          strings.text(appearanceTranslationKey(mode)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );

    final content = Column(
      children: [
        if (workspace.busy) const LinearProgressIndicator(),
        ErrorNotice(
          workspace.error,
          context.read<WorkspaceCubit>().dismissError,
        ),
        EconomicPulseBar(compact: !wide),
        Expanded(
          child: SingleChildScrollView(
            key: ValueKey(screen),
            padding: EdgeInsets.all(
              dashboard ? (wide ? 22 : 14) : (wide ? 32 : 16),
            ),
            child: switch (screen) {
              0 => const CatalogView(),
              1 => const CollectionsView(),
              2 => const CalculatorView(),
              4 => const PlannerView(),
              5 => const SellersView(),
              6 => const PortfolioView(),
              _ => const WorkspaceView(),
            },
          ),
        ),
      ],
    );

    final standardBody = Row(
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
    );

    final dashboardBody = Column(
      children: [
        DashboardHeader(
          compact: !wide,
          workspaceOpen: workspaceOpen,
          language: language,
          appearance: appearance.mode,
          onLanguage: context.read<LocaleCubit>().select,
          onAppearance: context.read<AppearanceCubit>().select,
          onAbout: showHubAbout,
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (wide)
                DashboardSidebar(
                  selected: screen,
                  onSelected: context.read<NavigationCubit>().select,
                ),
              Expanded(child: DashboardSurface(child: content)),
            ],
          ),
        ),
        if (wide) DashboardStatusBar(workspaceOpen: workspaceOpen),
      ],
    );

    return Scaffold(
      appBar: dashboard
          ? null
          : AppBar(
              title: Text(studio ? strings.text('studioTitle') : '◈ OVDP Hub'),
              actions: [
                IconButton(
                  tooltip: strings.text('about'),
                  onPressed: showHubAbout,
                  icon: const Icon(Icons.info_outline),
                ),
                PopupMenuButton<AppLanguage>(
                  tooltip: strings.text('language'),
                  icon: const Icon(Icons.language),
                  initialValue: language,
                  onSelected: context.read<LocaleCubit>().select,
                  itemBuilder: (_) => AppLanguage.values
                      .map(
                        (item) => PopupMenuItem<AppLanguage>(
                          value: item,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.nativeName),
                              Text(
                                item.ukrainianDescription,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
                appearanceMenu(),
                if (wide)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      workspaceOpen
                          ? strings.text('localData')
                          : strings.text('workspaceClosed'),
                    ),
                  ),
              ],
            ),
      body: dashboard ? dashboardBody : standardBody,
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
