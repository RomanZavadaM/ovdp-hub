import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'l10n/hub_locale.dart';

class AuctionCalendar extends StatelessWidget {
  const AuctionCalendar({super.key});
  @override
  Widget build(BuildContext context) {
    final strings = HubStrings(context.watch<LocaleCubit>().state.language);
    return Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.text('auctionPlan'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(strings.text('auctionSnapshot')),
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
                  SnackBar(content: Text(strings.text('sourceCopied'))),
                );
              }
            },
            icon: const Icon(Icons.copy),
            label: Text(strings.text('copySource')),
          ),
        ],
      ),
    ),
    );
  }
}
