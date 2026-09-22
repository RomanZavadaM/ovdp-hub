import 'package:flutter/material.dart';

import '../l10n/hub_locale.dart';
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
  Widget build(BuildContext context) {
    final strings = HubStrings.of(context);
    return message == null
        ? const SizedBox.shrink()
        : MaterialBanner(
            content: Text(message!),
            actions: [
              TextButton(
                onPressed: onDismiss,
                child: Text(strings.text('close')),
              ),
            ],
          );
  }
}

Future<bool> confirmDiscard(BuildContext context) async {
  final strings = HubStrings.of(context);
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(strings.text('unsavedTitle')),
          content: Text(strings.text('unsavedBody')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(strings.text('back')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(strings.text('discardDraft')),
            ),
          ],
        ),
      ) ??
      false;
}

void showBondDetails(BuildContext context, Bond bond) {
  final strings = HubStrings.of(context);
  showDialog<void>(
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
                '${bond.json['description']}\n'
                '${bond.currency} · ${strings.text('bondNominal')} ${bond.json['nominal']}\n'
                '${strings.text('bondRate')} ${bond.rate}% · '
                '${strings.text('bondMaturity')} ${bond.maturity}',
              ),
              const SizedBox(height: 16),
              Text(strings.text('paymentSchedule')),
              ...bond.payments.map(
                (v) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${v['date']} · ${v['amount']} ${bond.currency}',
                  ),
                  subtitle: Text(
                    {
                      'COUPON': strings.text('coupon'),
                      'REDEMPTION': strings.text('redemption'),
                      'EARLY_REDEMPTION': strings.text('earlyRedemption'),
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
          child: Text(strings.text('close')),
        ),
      ],
    ),
  );
}
