import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuctionCalendar extends StatelessWidget {
  const AuctionCalendar({super.key});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'План аукціонів Мінфіну',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Text(
            'Збережена редакція від 17.09.2026, вересень 2026. План може змінюватися; це не підтвердження проведення або пропозиція купівлі.',
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            children: [
              Chip(label: Text('01.09.2026')),
              Chip(label: Text('08.09.2026')),
              Chip(label: Text('15.09.2026')),
              Chip(label: Text('22.09.2026')),
              Chip(label: Text('29.09.2026')),
            ],
          ),
          const SelectableText('https://www.mof.gov.ua/uk/kalendar-aukcioniv'),
          TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(
                const ClipboardData(
                  text: 'https://www.mof.gov.ua/uk/kalendar-aukcioniv',
                ),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Посилання Мінфіну скопійовано'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.copy),
            label: const Text('Скопіювати адресу джерела'),
          ),
        ],
      ),
    ),
  );
}
