import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../ui/components.dart';
import 'seller_repository.dart';
import 'sellers_cubit.dart';

class SellersView extends StatelessWidget {
  const SellersView({super.key});
  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<SellersCubit>();
    final state = cubit.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading('Продавці · публічні котирування'),
        const Text(
          'НБУ описує випуски та виплати. Тут — окремі дані продавця, отримані безпосередньо з його сайту. Ваші плани й портфель не передаються.',
        ),
        const SizedBox(height: 12),
        const Text(
          'ПриватБанк',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SelectableText(SellerRepository.url),
        FilledButton.icon(
          onPressed: state.busy ? null : cubit.refresh,
          icon: const Icon(Icons.refresh),
          label: const Text('Завантажити котирування ПриватБанку'),
        ),
        if (state.busy) const LinearProgressIndicator(),
        if (state.error != null)
          Text(
            state.error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        if (state.snapshot != null)
          Text(
            'Дата на сайті: ${state.snapshot!.sourceDate} · Завантажено: ${state.snapshot!.retrievedAt}',
          ),
        if (cubit.dateWarning != null)
          Text(
            cubit.dateWarning!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        const Text(
          'ASK — дохідність продажу банком клієнту; BID — купівлі банком. Це не ціна за облігацію. SIM і YTM — різні методи розрахунку, їх не слід прямо порівнювати. Обсяг, остаточна ціна з НКД та комісії потребують підтвердження. Автоматично в ціни планувальника ці котирування не переносяться.',
        ),
        Wrap(
          spacing: 8,
          children: [
            for (final c in ['UAH', 'USD', 'EUR'])
              ChoiceChip(
                label: Text(c),
                selected: state.currency == c,
                onSelected: (_) => cubit.currency(c),
              ),
          ],
        ),
        SwitchListTile(
          title: const Text('Лише з котируванням продажу (ASK)'),
          value: state.askOnly,
          onChanged: cubit.askOnly,
        ),
        if (state.snapshot == null)
          const Text(
            'Натисніть завантаження. Вбудованих або вигаданих котирувань немає.',
          ),
        if (state.snapshot != null && cubit.visible.isEmpty)
          const Text('Немає непогашених випусків за цим фільтром.'),
        for (final q in cubit.visible)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    '${q.isin} · ${q.currency} · погашення ${q.maturity}',
                  ),
                  Text(
                    'ASK: ${q.askYield ?? 'немає'}${q.askYield == null ? '' : '%'} · BID: ${q.bidYield ?? 'немає'}${q.bidYield == null ? '' : '%'} · ${q.method}',
                  ),
                  const Text('Наявність і кількість не підтверджені'),
                ],
              ),
            ),
          ),
        const SectionHeading('Інші продавці'),
        const Text(
          'ICU Trade — торгівля в сервісі брокера. Автоматичне джерело котирувань ще не підключене.',
        ),
        const SelectableText('https://icu.ua/investments'),
        const Text(
          'Sense Bank — пропозиції в Sense SuperApp. Автоматичне джерело котирувань ще не підключене.',
        ),
        const SelectableText(
          'https://help.sensebank.com.ua/uk_UA/4879522845714',
        ),
        const SizedBox(height: 12),
        const Text(
          'Для сценарію: скопіюйте ISIN, знайдіть випуск у каталозі та введіть у планувальнику повну ціну продавця. Завантажені тут котирування зберігаються лише до закриття застосунку.',
        ),
      ],
    );
  }
}
