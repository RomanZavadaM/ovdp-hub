import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/appearance/appearance_cubit.dart';
import '../l10n/hub_locale.dart';

ThemeData dashboardTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xff0b88d1),
    brightness: Brightness.light,
  ).copyWith(
    primary: const Color(0xff087fc4),
    onPrimary: Colors.white,
    secondary: const Color(0xffe4a51f),
    surface: const Color(0xfffafdff),
    onSurface: const Color(0xff133d67),
    outline: const Color(0xffa9cce2),
    outlineVariant: const Color(0xffd7eaf5),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xffedf7fd),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xffedf7fd),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xfffbfdff),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xffcfe5f3)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xffa9cce2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xffb8d7e9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xff0b88d1), width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xfff7fcff),
      side: const BorderSide(color: Color(0xffcfe5f3)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xffd3e8f4),
      thickness: 1,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Color(0xfff8fcff),
      indicatorColor: Color(0xffccecff),
    ),
  );
}

class DashboardHeader extends StatelessWidget {
  final bool compact;
  final bool workspaceOpen;
  final AppLanguage language;
  final HubAppearance appearance;
  final ValueChanged<AppLanguage> onLanguage;
  final ValueChanged<HubAppearance> onAppearance;
  final VoidCallback onAbout;

  const DashboardHeader({
    super.key,
    required this.compact,
    required this.workspaceOpen,
    required this.language,
    required this.appearance,
    required this.onLanguage,
    required this.onAppearance,
    required this.onAbout,
  });

  @override
  Widget build(BuildContext context) {
    final strings = HubStrings(context.watch<LocaleCubit>().state.language);
    return Container(
      height: compact ? 76 : 108,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xfff7fcff), Color(0xffdff3ff)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border(bottom: BorderSide(color: Color(0xffb9deef))),
      ),
      child: Stack(
        children: [
          Positioned(
            right: compact ? 130 : 360,
            top: -54,
            child: Icon(
              Icons.account_balance_outlined,
              size: compact ? 116 : 178,
              color: const Color(0x0A0B79B8),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 14 : 24,
              vertical: compact ? 10 : 16,
            ),
            child: Row(
              children: [
                Container(
                  width: compact ? 50 : 68,
                  height: compact ? 50 : 68,
                  decoration: BoxDecoration(
                    color: const Color(0xfffff4c7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xffffdc69)),
                  ),
                  child: Icon(
                    Icons.account_balance,
                    size: compact ? 30 : 40,
                    color: const Color(0xff123e6b),
                  ),
                ),
                SizedBox(width: compact ? 10 : 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'OVDP Hub',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xff123e6b),
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (!compact) ...[
                        const SizedBox(height: 3),
                        Text(
                          strings.text('spaceForDecisions'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xff2875aa),
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 3,
                          width: 170,
                          decoration: BoxDecoration(
                            color: const Color(0xffe4a51f),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!compact)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 10,
                          color: Color(0xff20a45b),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          workspaceOpen
                              ? strings.text('localData')
                              : strings.text('workspaceClosed'),
                          style: const TextStyle(
                            color: Color(0xff2b628c),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                IconButton(
                  tooltip: strings.text('about'),
                  onPressed: onAbout,
                  icon: const Icon(Icons.info_outline),
                ),
                PopupMenuButton<AppLanguage>(
                  tooltip: strings.text('language'),
                  icon: const Icon(Icons.language),
                  initialValue: language,
                  onSelected: onLanguage,
                  itemBuilder: (_) => AppLanguage.values
                      .map(
                        (item) => PopupMenuItem<AppLanguage>(
                          value: item,
                          child: Text(item.nativeName),
                        ),
                      )
                      .toList(),
                ),
                PopupMenuButton<HubAppearance>(
                  tooltip: strings.text('appearance'),
                  icon: const Icon(Icons.palette_outlined),
                  initialValue: appearance,
                  onSelected: onAppearance,
                  itemBuilder: (_) => HubAppearance.values
                      .map(
                        (mode) => PopupMenuItem<HubAppearance>(
                          value: mode,
                          child: Row(
                            children: [
                              if (mode == appearance)
                                const Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Icon(Icons.check, size: 18),
                                )
                              else
                                const SizedBox(width: 26),
                              Text(strings.text(appearanceTranslationKey(mode))),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardSidebar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;

  const DashboardSidebar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final strings = HubStrings(context.watch<LocaleCubit>().state.language);
    final items = [
      (0, Icons.analytics_outlined, strings.text('catalog')),
      (1, Icons.bookmarks_outlined, strings.text('collections')),
      (2, Icons.calculate_outlined, strings.text('calculator')),
      (3, Icons.folder_outlined, strings.text('workspace')),
      (4, Icons.event_available_outlined, strings.text('planning')),
      (5, Icons.storefront_outlined, strings.text('sellers')),
    ];

    return Container(
      width: 208,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff0c689d), Color(0xff07517f)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(right: BorderSide(color: Color(0xffc0deed))),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(10, 14, 10, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final item in items) _destination(item.$1, item.$2, item.$3),
              const SizedBox(height: 28),
              const Divider(color: Color(0x55ffffff)),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      color: Color(0xffccecff),
                      size: 18,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        '${strings.text('noAccount')}\n${strings.text('scenariosLocal')}',
                        style: const TextStyle(
                          color: Color(0xffd8eef9),
                          fontSize: 11,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _destination(int index, IconData icon, String text) {
    final active = selected == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Material(
        color: active ? const Color(0xff109be5) : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          leading: Icon(
            icon,
            color: active ? Colors.white : const Color(0xffd5edfa),
            size: 21,
          ),
          title: Text(
            text,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xffedf8fe),
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
          onTap: () => onSelected(index),
        ),
      ),
    );
  }
}

class DashboardSurface extends StatelessWidget {
  final Widget child;
  const DashboardSurface({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xffedf7fd)),
          const Positioned(
            right: 64,
            top: 92,
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 330,
              color: Color(0x090b6fa4),
            ),
          ),
          child,
        ],
      );
}

class DashboardStatusBar extends StatelessWidget {
  final bool workspaceOpen;
  const DashboardStatusBar({super.key, required this.workspaceOpen});

  @override
  Widget build(BuildContext context) {
    final strings = HubStrings(context.watch<LocaleCubit>().state.language);
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xfff7fcff),
        border: Border(top: BorderSide(color: Color(0xffb9deef))),
      ),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 10,
            color: workspaceOpen
                ? const Color(0xff20a45b)
                : const Color(0xff8aa9bb),
          ),
          const SizedBox(width: 7),
          Text(
            workspaceOpen
                ? strings.text('localData')
                : strings.text('workspaceClosed'),
            style: const TextStyle(fontSize: 11, color: Color(0xff2d6085)),
          ),
          const Spacer(),
          const Icon(
            Icons.account_balance_outlined,
            size: 16,
            color: Color(0xff2d6085),
          ),
          const SizedBox(width: 6),
          Text(
            strings.text('spaceForDecisions'),
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xff4b7da0),
              letterSpacing: .8,
            ),
          ),
        ],
      ),
    );
  }
}
