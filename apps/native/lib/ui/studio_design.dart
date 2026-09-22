import 'package:flutter/material.dart';

ThemeData hubTheme(bool studio) {
  if (!studio) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff16624c)),
      scaffoldBackgroundColor: const Color(0xfff5f7f4),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
  final scheme = ColorScheme.fromSeed(seedColor: const Color(0xff315add))
      .copyWith(
        primary: const Color(0xff315add),
        onPrimary: Colors.white,
        secondary: const Color(0xffa24a11),
        surface: Colors.white,
        onSurface: const Color(0xff182537),
        outlineVariant: const Color(0xffdce3ec),
      );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xfff3f5f9),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xffe0e6ef)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffc9d3e2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffc9d3e2)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    chipTheme: ChipThemeData(
      side: const BorderSide(color: Color(0xffdce3ec)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xffe0e6ef),
      thickness: 1,
    ),
  );
}

class StudioSidebar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;
  const StudioSidebar({
    super.key,
    required this.selected,
    required this.onSelected,
  });
  @override
  Widget build(BuildContext context) => Container(
    width: 220,
    color: const Color(0xff142338),
    child: SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 28, 14, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.diamond_outlined,
                      color: Color(0xff91b4ff),
                      size: 28,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'ОВДП HUB',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(12, 10, 0, 38),
                child: Text(
                  'ПРОСТІР ДЛЯ РІШЕНЬ',
                  style: TextStyle(
                    color: Color(0xffaabbd3),
                    fontSize: 10,
                    letterSpacing: 1.8,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 0, 12),
                child: Text(
                  'ДОСЛІДИТИ',
                  style: TextStyle(
                    color: Color(0xffaabbd3),
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              for (final item in const [
                (0, Icons.analytics_outlined, 'Каталог'),
                (5, Icons.storefront_outlined, 'Продавці'),
              ])
                _destination(item.$1, item.$2, item.$3),
              const Padding(
                padding: EdgeInsets.fromLTRB(12, 28, 0, 12),
                child: Text(
                  'МОЇ РІШЕННЯ',
                  style: TextStyle(
                    color: Color(0xffaabbd3),
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              for (final item in const [
                (4, Icons.event_available_outlined, 'Планування'),
                (1, Icons.bookmarks_outlined, 'Добірки'),
                (2, Icons.calculate_outlined, 'Калькулятор'),
                (3, Icons.folder_outlined, 'Сховище'),
              ])
                _destination(item.$1, item.$2, item.$3),
              const SizedBox(height: 42),
              const Divider(color: Color(0xff35445a)),
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Без облікового запису\nСценарії у вашій робочій папці\n\nТестова версія 0.8.1',
                  style: TextStyle(
                    color: Color(0xffb5c5dc),
                    height: 1.7,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  Widget _destination(int index, IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Material(
      color: selected == index ? const Color(0xff315add) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        selected: selected == index,
        selectedColor: Colors.white,
        iconColor: const Color(0xffb5c5dc),
        textColor: const Color(0xffdce6f5),
        leading: Icon(icon, size: 21),
        title: Text(text, style: const TextStyle(fontSize: 14)),
        onTap: () => onSelected(index),
      ),
    ),
  );
}

class StudioHero extends StatelessWidget {
  final VoidCallback plan, sellers;
  const StudioHero({super.key, required this.plan, required this.sellers});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: const LinearGradient(
        colors: [Color(0xff192e4b), Color(0xff294c73)],
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ДОСЛІДЖУЙТЕ. ПОРІВНЮЙТЕ. ПЛАНУЙТЕ.',
          style: TextStyle(
            color: Color(0xffb6cef5),
            letterSpacing: 1.3,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Облігації під ваші плани',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Від випуску ОВДП — до календаря ваших коштів.\nПорівнюйте строки та перевіряйте майбутні витрати.',
          style: TextStyle(color: Color(0xffd3e0f3), height: 1.6),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xfff2c879),
                foregroundColor: const Color(0xff192e4b),
              ),
              onPressed: plan,
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('Планувати кошти'),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xff8ca3c2)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 17,
                ),
              ),
              onPressed: sellers,
              child: const Text('Переглянути продавців'),
            ),
          ],
        ),
      ],
    ),
  );
}

class MetricTile extends StatelessWidget {
  final String label, value;
  const MetricTile(this.label, this.value, {super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: MediaQuery.sizeOf(context).width < 600
        ? (MediaQuery.sizeOf(context).width - 44) / 2
        : 174,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Color(0xff586779), fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );
}
