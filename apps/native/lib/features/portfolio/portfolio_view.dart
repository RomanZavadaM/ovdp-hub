import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/hub_repository.dart';
import '../../l10n/hub_locale.dart';
import '../../models.dart';
import 'portfolio_cubit.dart';
import 'private_portfolio.dart';

class PortfolioView extends StatelessWidget {
  const PortfolioView({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = HubStrings(context.watch<LocaleCubit>().state.language);
    final state = context.watch<PortfolioCubit>().state;

    if (!state.supported) {
      return _PortfolioShell(
        children: [
          _PortfolioHero(
            title: strings.text('portfolioTitle'),
            body: strings.text('portfolioPlatformPending'),
            icon: Icons.phonelink_lock_outlined,
          ),
        ],
      );
    }

    if (!state.exists) {
      return _PortfolioShell(
        children: [
          _PortfolioHero(
            title: strings.text('portfolioTitle'),
            body: strings.text('portfolioCreateIntro'),
            icon: Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: state.busy ? null : () => _createPortfolio(context),
            icon: const Icon(Icons.lock_outline),
            label: Text(strings.text('portfolioCreate')),
          ),
          const SizedBox(height: 10),
          _SecurityNote(text: strings.text('portfolioSecurityNote')),
          if (state.busy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          if (state.errorCode != null) ...[
            const SizedBox(height: 12),
            _PortfolioError(code: state.errorCode!),
          ],
        ],
      );
    }

    if (!state.unlocked) {
      return _PortfolioShell(
        children: [
          _PortfolioHero(
            title: strings.text('portfolioTitle'),
            body: strings.text('portfolioLockedBody'),
            icon: Icons.lock_outline,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: state.busy
                ? null
                : () => context.read<PortfolioCubit>().open(),
            icon: const Icon(Icons.lock_open_outlined),
            label: Text(strings.text('portfolioOpen')),
          ),
          if (state.busy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          if (state.errorCode != null) ...[
            const SizedBox(height: 12),
            _PortfolioError(code: state.errorCode!),
          ],
        ],
      );
    }

    final payload = state.payload!;
    final holdings = payload.holdings;
    final totalUnits = holdings.fold<int>(0, (sum, item) => sum + item.units);
    return _PortfolioShell(
      children: [
        Row(
          children: [
            Expanded(
              child: _PortfolioHero(
                title: strings.text('portfolioTitle'),
                body: strings.text('portfolioUnlockedBody'),
                icon: Icons.shield_outlined,
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filledTonal(
              tooltip: strings.text('portfolioLock'),
              onPressed: state.busy
                  ? null
                  : () => context.read<PortfolioCubit>().lock(),
              icon: const Icon(Icons.lock_outline),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _SummaryTile(
              label: strings.text('portfolioPositions'),
              value: '${holdings.length}',
            ),
            _SummaryTile(
              label: strings.text('portfolioUnits'),
              value: '$totalUnits',
            ),
            _SummaryTile(
              label: strings.text('portfolioLots'),
              value: '${payload.acquisitionLots.length}',
            ),
            _SummaryTile(
              label: strings.text('portfolioFacts'),
              value:
                  '${payload.cashEvents.length + payload.disposals.length}',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                strings.text('portfolioHoldings'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            FilledButton.icon(
              onPressed: state.busy ? null : () => _addPurchase(context),
              icon: const Icon(Icons.add),
              label: Text(strings.text('portfolioAddPurchase')),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (holdings.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Text(strings.text('portfolioEmpty')),
            ),
          )
        else
          ...holdings.map((holding) => _HoldingCard(holding: holding)),
        if (state.busy) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
        ],
        if (state.errorCode != null) ...[
          const SizedBox(height: 12),
          _PortfolioError(code: state.errorCode!),
        ],
        const SizedBox(height: 10),
        _SecurityNote(text: strings.text('portfolioSecurityNote')),
      ],
    );
  }

  Future<void> _createPortfolio(BuildContext context) async {
    final strings = HubStrings(context.read<LocaleCubit>().state.language);
    final cubit = context.read<PortfolioCubit>();
    final secret = TextEditingController();
    var hidden = true;
    String? localError;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(strings.text('portfolioCreate')),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.text('portfolioRecoveryExplain')),
                const SizedBox(height: 12),
                TextField(
                  controller: secret,
                  obscureText: hidden,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: strings.text('portfolioRecoverySecret'),
                    errorText: localError,
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => hidden = !hidden),
                      icon: Icon(
                        hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.text('portfolioRecoveryKeep'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(strings.text('portfolioCancel')),
            ),
            FilledButton(
              onPressed: () async {
                if (secret.text.length < 12) {
                  setState(() {
                    localError = strings.text('portfolioRecoveryShort');
                  });
                  return;
                }
                await cubit.create(secret.text);
                if (!dialogContext.mounted) return;
                if (cubit.state.unlocked) {
                  Navigator.pop(dialogContext);
                } else {
                  setState(() {
                    localError = _portfolioErrorText(
                      strings,
                      cubit.state.errorCode ?? 'portfolio.operation_failed',
                    );
                  });
                }
              },
              child: Text(strings.text('portfolioCreate')),
            ),
          ],
        ),
      ),
    );
    secret.dispose();
  }

  Future<void> _addPurchase(BuildContext context) async {
    final strings = HubStrings(context.read<LocaleCubit>().state.language);
    final cubit = context.read<PortfolioCubit>();
    final now = DateTime.now();
    final isin = TextEditingController();
    final units = TextEditingController(text: '1');
    final date = TextEditingController(
      text:
          '${now.day.toString().padLeft(2, '0')}.'
          '${now.month.toString().padLeft(2, '0')}.'
          '${now.year}',
    );
    final amount = TextEditingController();
    final fee = TextEditingController(text: '0');
    final broker = TextEditingController();
    var feeKnown = false;
    String? localError;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(strings.text('portfolioAddPurchase')),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: isin,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: 'ISIN',
                      hintText: 'UA…',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: units,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: strings.text('portfolioPurchaseUnits'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: date,
                    decoration: InputDecoration(
                      labelText: strings.text('portfolioPurchaseDate'),
                      hintText: 'DD.MM.YYYY',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: amount,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: strings.text('portfolioTradeAmount'),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(strings.text('portfolioFeeKnown')),
                    value: feeKnown,
                    onChanged: (value) => setState(() => feeKnown = value),
                  ),
                  if (feeKnown)
                    TextField(
                      controller: fee,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: strings.text('portfolioFeeAmount'),
                      ),
                    ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: broker,
                    decoration: InputDecoration(
                      labelText: strings.text('portfolioBrokerLabel'),
                    ),
                  ),
                  if (localError != null) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        localError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(strings.text('portfolioCancel')),
            ),
            FilledButton(
              onPressed: () async {
                final parsedUnits = int.tryParse(units.text.trim());
                final iso = _dateToIso(date.text.trim());
                if (parsedUnits == null ||
                    parsedUnits < 1 ||
                    iso == null ||
                    amount.text.trim().isEmpty) {
                  setState(() {
                    localError = strings.text('portfolioInvalidInput');
                  });
                  return;
                }
                await cubit.addAcquisition(
                  isin: isin.text,
                  units: parsedUnits,
                  acquiredOn: iso,
                  tradeAmount: amount.text.trim().replaceAll(',', '.'),
                  feeKnown: feeKnown,
                  feeTotal:
                      feeKnown ? fee.text.trim().replaceAll(',', '.') : null,
                  brokerAccountLabel: broker.text,
                );
                if (!dialogContext.mounted) return;
                if (cubit.state.errorCode == null) {
                  Navigator.pop(dialogContext);
                } else {
                  setState(() {
                    localError = _portfolioErrorText(
                      strings,
                      cubit.state.errorCode!,
                    );
                  });
                }
              },
              child: Text(strings.text('portfolioSavePurchase')),
            ),
          ],
        ),
      ),
    );

    for (final controller in [isin, units, date, amount, fee, broker]) {
      controller.dispose();
    }
  }
}

String? _dateToIso(String value) {
  final match = RegExp(r'^(\d{2})\.(\d{2})\.(\d{4})$').firstMatch(value);
  if (match == null) return null;
  final result = '${match.group(3)}-${match.group(2)}-${match.group(1)}';
  try {
    isoDate(result);
    return result;
  } catch (_) {
    return null;
  }
}

String _portfolioErrorText(HubStrings strings, String code) => switch (code) {
      'portfolio.recovery_secret_too_short' =>
        strings.text('portfolioRecoveryShort'),
      'portfolio.issue_not_in_catalog' =>
        strings.text('portfolioIssueMissing'),
      'vault.session_locked' => strings.text('portfolioLockedBody'),
      'portfolio.invalid_units' ||
      'portfolio.invalid_date' ||
      'portfolio.invalid_trade_amount' ||
      'portfolio.invalid_fee_total' ||
      'portfolio.invalid_isin' =>
        strings.text('portfolioInvalidInput'),
      _ => strings.text('portfolioOperationFailed'),
    };

class _PortfolioError extends StatelessWidget {
  final String code;
  const _PortfolioError({required this.code});

  @override
  Widget build(BuildContext context) {
    final strings = HubStrings(context.watch<LocaleCubit>().state.language);
    return Material(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                _portfolioErrorText(strings, code),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortfolioShell extends StatelessWidget {
  final List<Widget> children;
  const _PortfolioShell({required this.children});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
}

class _PortfolioHero extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;

  const _PortfolioHero({
    required this.title,
    required this.body,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 34,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text(body),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 150,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      );
}

class _HoldingCard extends StatelessWidget {
  final PrivateHolding holding;
  const _HoldingCard({required this.holding});

  @override
  Widget build(BuildContext context) {
    final strings = HubStrings(context.watch<LocaleCubit>().state.language);
    final catalog = context.read<HubRepository>().current?.catalog;
    Bond? bond;
    if (catalog != null) {
      for (final item in catalog.bonds) {
        if (item.isin == holding.isin) {
          bond = item;
          break;
        }
      }
    }
    return Card(
      child: ListTile(
        leading: const Icon(Icons.account_balance_outlined),
        title: Text(
          holding.isin,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          bond == null
              ? holding.currency
              : '${holding.currency} · ${strings.text('portfolioMaturity')} ${_displayIsoDate(bond.maturity)}',
        ),
        trailing: Text(
          '× ${holding.units}',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

String _displayIsoDate(String value) =>
    value.length == 10
        ? '${value.substring(8, 10)}.${value.substring(5, 7)}.${value.substring(0, 4)}'
        : value;

class _SecurityNote extends StatelessWidget {
  final String text;
  const _SecurityNote({required this.text});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.security_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(text)),
            ],
          ),
        ),
      );
}
