import 'package:flutter/material.dart';
import '../models.dart';

class SectionHeading extends StatelessWidget {
  final String text;
  const SectionHeading(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(text, style: Theme.of(context).textTheme.headlineSmall),
  );
}

class ErrorNotice extends StatelessWidget {
  final String? message;
  final VoidCallback onDismiss;
  const ErrorNotice(this.message, this.onDismiss, {super.key});
  @override
  Widget build(BuildContext context) => message == null
      ? const SizedBox.shrink()
      : MaterialBanner(
          content: Text(message!),
          actions: [
            TextButton(onPressed: onDismiss, child: const Text('Закрити')),
          ],
        );
}

Future<bool> confirmDiscard(BuildContext context) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Є незбережена добірка'),
        content: const Text(
          'Збережіть її перед продовженням або відкиньте чернетку.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Повернутися'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Відкинути чернетку'),
          ),
        ],
      ),
    ) ??
    false;

void showBondDetails(BuildContext context, Bond bond) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(bond.isin),
    content: SizedBox(
      width: 520,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${bond.json['description']}\n${bond.currency} · Номінал ${bond.json['nominal']}\nСтавка ${bond.rate}% · Погашення ${bond.maturity}',
            ),
            const SizedBox(height: 16),
            const Text('Графік виплат на одну облігацію'),
            ...bond.payments.map(
              (v) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${v['date']} · ${v['amount']} ${bond.currency}'),
                subtitle: Text(
                  {
                    'COUPON': 'Купон',
                    'REDEMPTION': 'Погашення',
                    'EARLY_REDEMPTION': 'Дострокове погашення',
                  }[v['kind']]!,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Закрити'),
      ),
    ],
  ),
);
