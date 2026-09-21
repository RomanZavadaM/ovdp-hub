import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../ui/components.dart';
import '../navigation/navigation_cubit.dart';
import 'planner_cubit.dart';

class PlannerView extends StatelessWidget {
  const PlannerView({super.key});
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlannerCubit>(),
        state = context.watch<PlannerCubit>().state;
    final c = state.criteria,
        summary = state.summary,
        disabled = state.busy || state.locked;
    final currency = c['currency'];
    final maximum =
        summary?.months.fold<double>(
          0,
          (m, v) => v.total.toDouble() > m ? v.total.toDouble() : m,
        ) ??
        0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading('Планувальник цілей і доходу'),
        const Text(
          'Один сценарій — одна валюта. Суми різних валют не додаються. Це план на основі каталогу, а не список доступних до купівлі пропозицій.',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            for (final cur in ['UAH', 'USD', 'EUR'])
              ChoiceChip(
                label: Text(cur),
                selected: currency == cur,
                onSelected: disabled
                    ? null
                    : (_) => cubit.edit('currency', cur),
              ),
          ],
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final field in {
              'budget': 'Бюджет у вибраній валюті',
              'reserve': 'Залишити грошовий резерв',
              'start': 'Дата розрахунку YYYY-MM-DD',
              'minDate': 'Погашення від YYYY-MM-DD',
              'maxDate': 'Погашення до YYYY-MM-DD',
              'needDate': 'Кошти потрібні до YYYY-MM-DD',
              'needAmount': 'Потрібна сума до цієї дати',
            }.entries)
              SizedBox(
                width: 280,
                child: TextFormField(
                  key: ValueKey('${field.key}-${state.revision}'),
                  initialValue: c[field.key],
                  enabled: !disabled,
                  decoration: InputDecoration(labelText: field.value),
                  onChanged: (v) => cubit.edit(field.key, v),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        const SectionHeading('Що важливіше для цього сценарію?'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final strategy in const {
              'ladder': 'Розподіл строків',
              'profit': 'Більший прибуток',
              'expenses': 'Витрати за датами',
            }.entries)
              ChoiceChip(
                label: Text(strategy.value),
                selected: (c['strategy'] ?? 'ladder') == strategy.key,
                onSelected: disabled
                    ? null
                    : (_) => cubit.edit('strategy', strategy.key),
              ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Прибуток — сума майбутніх купонів і погашень мінус повна вартість до кінця строку, без реінвестування. Пошук порівнює кілька цілочисельних варіантів; глобальний максимум не гарантується. Режим витрат додатково зберігає резерв після кожної потреби.',
        ),
        if (c['strategy'] != 'ladder')
          SwitchListTile(
            title: const Text('Використовувати лише введені ціни'),
            subtitle: const Text(
              'Додайте випуски вручну нижче та введіть повну ціну. Інакше пошук використовує також оцінки за номіналом.',
            ),
            value: c['pricedOnly'] == 'true',
            onChanged: disabled ? null : (v) => cubit.edit('pricedOnly', '$v'),
          ),
        const SectionHeading('Мої майбутні витрати'),
        const Text(
          'Основна потреба — дата й сума вище. Додайте навчання, ремонт, подорож чи регулярний платіж. Кожна витрата віднімається з залишку; від’ємний баланс означає непокриту потребу.',
        ),
        for (var i = 0; i < int.parse(c['expenseCount'] ?? '0'); i++)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final field in {
                    'expenseName$i': 'Назва витрати',
                    'expenseDate$i': 'Дата YYYY-MM-DD',
                    'expenseAmount$i': 'Сума, $currency',
                  }.entries)
                    SizedBox(
                      width: 220,
                      child: TextFormField(
                        key: ValueKey('${field.key}-${state.revision}'),
                        initialValue: c[field.key],
                        enabled: !disabled,
                        decoration: InputDecoration(labelText: field.value),
                        onChanged: (v) => cubit.edit(field.key, v),
                      ),
                    ),
                  IconButton(
                    tooltip: 'Видалити витрату',
                    onPressed: disabled ? null : () => cubit.removeExpense(i),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          ),
        TextButton.icon(
          onPressed: disabled ? null : cubit.addExpense,
          icon: const Icon(Icons.add),
          label: const Text('Додати витрату'),
        ),
        TextButton.icon(
          onPressed: disabled ? null : cubit.repeatMonthly,
          icon: const Icon(Icons.repeat),
          label: const Text('Повторити основну потребу ще 5 місяців'),
        ),
        SizedBox(
          width: 300,
          child: TextFormField(
            key: ValueKey('delay-${state.revision}'),
            initialValue: c['delay'] ?? '2',
            enabled: !disabled,
            decoration: const InputDecoration(
              labelText: 'Запас на зарахування, днів (0–30)',
            ),
            onChanged: (v) => cubit.edit('delay', v),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: disabled ? null : cubit.generate,
          icon: const Icon(Icons.auto_awesome_outlined),
          label: Text(
            c['strategy'] == 'ladder'
                ? 'Розподілити за строками'
                : 'Підібрати варіант',
          ),
        ),
        const Text(
          'Розподіл строків ділить бюджет за номіналом. Режим прибутку не обмежує вкладення майбутніми витратами — перевірте їх покриття в календарі. Купівля і доступність випусків тут не підтверджуються.',
        ),
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              state.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (state.inputs.isNotEmpty) ...[
          const SectionHeading('Склад сценарію'),
          const Text(
            'Ціна за замовчуванням — номінал. Для точнішого бюджету введіть повну ціну за штуку з НКД і врахованими витратами. Введена ціна не підтверджується продавцем автоматично.',
          ),
          ...state.inputs.values.map(
            (i) => Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('${i.bond.isin} · ${i.bond.maturity}'),
                        ),
                        IconButton(
                          tooltip: 'Прибрати позицію',
                          onPressed: disabled
                              ? null
                              : () => cubit.toggle(i.bond, false),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    Text(
                      i.nominalEstimate
                          ? 'Оцінка за номіналом'
                          : 'Ціна введена вручну',
                    ),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        SizedBox(
                          width: 160,
                          child: TextFormField(
                            key: ValueKey('q-${i.bond.isin}-${state.revision}'),
                            initialValue: i.quantity,
                            enabled: !disabled,
                            decoration: const InputDecoration(
                              labelText: 'Кількість, шт.',
                            ),
                            onChanged: (v) =>
                                cubit.position(i.bond.isin, quantity: v),
                          ),
                        ),
                        SizedBox(
                          width: 230,
                          child: TextFormField(
                            key: ValueKey('p-${i.bond.isin}-${state.revision}'),
                            initialValue: i.price,
                            enabled: !disabled,
                            decoration: InputDecoration(
                              labelText: 'Повна ціна за 1 шт., $currency',
                            ),
                            onChanged: (v) =>
                                cubit.position(i.bond.isin, price: v),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        ExpansionTile(
          title: Text('Вибрати випуски вручну · ${state.candidates.length}'),
          children: [
            ...state.candidates.map(
              (b) => CheckboxListTile(
                value: state.inputs.containsKey(b.isin),
                onChanged: disabled ? null : (v) => cubit.toggle(b, v == true),
                title: Text(b.isin),
                subtitle: Text('${b.maturity} · ${b.rate}% номінальна ставка'),
              ),
            ),
          ],
        ),
        if (summary != null) ...[
          const SectionHeading('Результат сценарію'),
          Text(
            'Вкладено: ${summary.cost.toStringAsFixed(2)} $currency · Вільно: ${summary.reserve.toStringAsFixed(2)} $currency',
          ),
          Text(
            'Розрахунковий прибуток до погашення: ${state.profit} $currency',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Text(
            'Повна ціна має включати НКД та витрати придбання. Податки, додаткові комісії, реінвестування та продаж до погашення не моделюються.',
          ),
          const SectionHeading('Покриття витрат за датами'),
          for (final row in state.expenseBalances)
            Card(
              child: ListTile(
                leading: Icon(
                  row.shortfall.toDouble() > 0
                      ? Icons.warning_amber
                      : Icons.check_circle_outline,
                ),
                title: Text(
                  '${row.expense.date} · ${row.expense.name} · ${row.expense.amount.toStringAsFixed(2)} $currency',
                ),
                subtitle: Text(
                  'До витрати: ${row.available.toStringAsFixed(2)} · Після: ${row.remaining.toStringAsFixed(2)} · Не вистачає: ${row.shortfall.toStringAsFixed(2)} $currency',
                ),
              ),
            ),
          const Text(
            'Календар витрат ураховує попередні витрати й задану затримку зарахування. Графік нижче показує дати виплат емітента без цієї затримки.',
          ),
          if (summary.containsEstimates)
            const Text(
              'У складі є ціни за номіналом: бюджет і залишок попередні.',
            ),
          if (summary.hasConditionalPayments)
            const Text(
              'Умовні дострокові погашення не включено в календар, щоб не подвоювати повернення номіналу.',
            ),
          const SectionHeading('Помесячні надходження'),
          const Text(
            'Купони — дохід за графіком. Погашення — повернення вкладеного номіналу. Місяці без виплат теж показано.',
          ),
          ...summary.months.map(
            (m) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${m.month} · купони ${m.coupons.toStringAsFixed(2)} · погашення ${m.principal.toStringAsFixed(2)} $currency',
                  ),
                  LinearProgressIndicator(
                    value: maximum == 0 ? 0 : m.total.toDouble() / maximum,
                    minHeight: 7,
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        TextFormField(
          key: ValueKey('plan-name-${state.revision}'),
          initialValue: c['name'],
          enabled: !disabled,
          decoration: const InputDecoration(labelText: 'Назва сценарію'),
          onChanged: (v) => cubit.edit('name', v),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: disabled || summary == null || state.inputs.isEmpty
              ? null
              : () async {
                  final navigation = context.read<NavigationCubit>();
                  if (await cubit.save() && context.mounted) {
                    navigation.select(1);
                  }
                },
          icon: const Icon(Icons.save_outlined),
          label: Text(
            state.saved
                ? 'Зберегти новий варіант'
                : 'Зберегти сценарій із кількістю та цінами',
          ),
        ),
      ],
    );
  }
}
