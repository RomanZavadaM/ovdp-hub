import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/hub_repository.dart';
import '../../l10n/hub_locale.dart';
import '../../models.dart';
import 'legacy_plaintext_migration.dart';
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
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                key: const ValueKey('portfolio-create'),
                onPressed: state.busy ? null : () => _createPortfolio(context),
                icon: const Icon(Icons.lock_outline),
                label: Text(strings.text('portfolioCreate')),
              ),
              if (state.portableBackupSupported)
                OutlinedButton.icon(
                  key: const ValueKey('portfolio-restore-backup'),
                  onPressed: state.busy
                      ? null
                      : () => _restorePortableBackup(context),
                  icon: const Icon(Icons.settings_backup_restore_outlined),
                  label: Text(strings.text('portfolioRestoreBackup')),
                ),
            ],
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
    final closedPositionIsins = payload.closedPositionIsins;
    final totalUnits = holdings.fold<int>(0, (sum, item) => sum + item.units);
    final canSell = holdings.any(
      (holding) => !payload.cashEvents.any(
        (event) =>
            event.isin == holding.isin &&
            event.kind == PrivateCashEventKind.redemption,
      ),
    );
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
        if (payload.factualCashSummaries.isNotEmpty) ...[
          Text(
            strings.text('portfolioCashSummary'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(strings.text('portfolioCashSummaryInfo')),
          const SizedBox(height: 8),
          _FactualCashSummary(payload: payload),
          const SizedBox(height: 18),
        ],
        Text(
          strings.text('portfolioHoldings'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              key: const ValueKey('portfolio-add-purchase'),
              onPressed: state.busy ? null : () => _addPurchase(context),
              icon: const Icon(Icons.add),
              label: Text(strings.text('portfolioAddPurchase')),
            ),
            OutlinedButton.icon(
              key: const ValueKey('portfolio-add-sale'),
              onPressed: state.busy || !canSell
                  ? null
                  : () => _addSale(context),
              icon: const Icon(Icons.sell_outlined),
              label: Text(strings.text('portfolioAddSale')),
            ),
            OutlinedButton.icon(
              key: const ValueKey('portfolio-add-redemption'),
              onPressed: state.busy || holdings.isEmpty
                  ? null
                  : () => _addRedemption(context),
              icon: const Icon(Icons.payments_outlined),
              label: Text(strings.text('portfolioAddRedemption')),
            ),
            OutlinedButton.icon(
              key: const ValueKey('portfolio-add-coupon'),
              onPressed: state.busy || holdings.isEmpty
                  ? null
                  : () => _addCoupon(context),
              icon: const Icon(Icons.savings_outlined),
              label: Text(strings.text('portfolioAddCoupon')),
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
          ...holdings.map(
            (holding) => _HoldingCard(holding: holding, payload: payload),
          ),
        if (closedPositionIsins.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            strings.text('portfolioClosedPositions'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...closedPositionIsins.map(
            (isin) => _ClosedPositionCard(
              isin: isin,
              currency: payload.currencyForIsin(isin),
              payload: payload,
            ),
          ),
        ],
        const SizedBox(height: 18),
        Text(
          strings.text('portfolioHistory'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        _PortfolioHistory(payload: payload),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.security_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.text('portfolioRecoveryBackupTitle'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 5),
                      Text(strings.text('portfolioRecoveryBackupInfo')),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (state.portableBackupSupported)
                            OutlinedButton.icon(
                              key: const ValueKey('portfolio-create-backup'),
                              onPressed: state.busy
                                  ? null
                                  : () => _createPortableBackup(context),
                              icon: const Icon(Icons.save_alt_outlined),
                              label: Text(strings.text('portfolioBackupCreate')),
                            ),
                          OutlinedButton.icon(
                            key: const ValueKey('portfolio-rotate-recovery'),
                            onPressed: state.busy
                                ? null
                                : () => _rotateRecovery(context),
                            icon: const Icon(Icons.password_outlined),
                            label: Text(strings.text('portfolioRecoveryChange')),
                          ),
                        ],
                      ),
                      if (!state.portableBackupSupported) ...[
                        const SizedBox(height: 8),
                        Text(
                          strings.text('portfolioBackupUnavailable'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.move_to_inbox_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.text('portfolioMigrationTitle'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 5),
                      Text(strings.text('portfolioMigrationPlaintextWarning')),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        key: const ValueKey('portfolio-migration'),
                        onPressed: state.busy
                            ? null
                            : () => _migrateLegacy(context),
                        icon: const Icon(Icons.enhanced_encryption_outlined),
                        label: Text(strings.text('portfolioMigrationButton')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
    final confirmSecret = TextEditingController();
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
                  key: const ValueKey('portfolio-create-recovery-secret'),
                  controller: secret,
                  obscureText: hidden,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: strings.text('portfolioRecoverySecret'),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => hidden = !hidden),
                      icon: Icon(
                        hidden
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  key: const ValueKey('portfolio-create-recovery-confirm'),
                  controller: confirmSecret,
                  obscureText: hidden,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: strings.text('portfolioRecoveryConfirm'),
                    errorText: localError,
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
              key: const ValueKey('portfolio-create-save'),
              onPressed: () async {
                if (secret.text.length < 12) {
                  setState(() {
                    localError = strings.text('portfolioRecoveryShort');
                  });
                  return;
                }
                if (secret.text != confirmSecret.text) {
                  setState(() {
                    localError = strings.text('portfolioRecoveryMismatch');
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
  }

  Future<void> _createPortableBackup(BuildContext context) async {
    final strings = HubStrings(context.read<LocaleCubit>().state.language);
    final path = await context.read<PortfolioCubit>().createPortableBackup();
    if (!context.mounted || path == null) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          strings.text('portfolioBackupSaved').replaceAll('{path}', path),
        ),
      ),
    );
  }

  Future<void> _restorePortableBackup(BuildContext context) async {
    final strings = HubStrings(context.read<LocaleCubit>().state.language);
    final cubit = context.read<PortfolioCubit>();
    final secret = TextEditingController();
    var hidden = true;
    String? localError;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(strings.text('portfolioRestoreTitle')),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.text('portfolioRestoreExplain')),
                const SizedBox(height: 12),
                TextField(
                  key: const ValueKey('portfolio-restore-recovery-secret'),
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
                        hidden
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
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
              key: const ValueKey('portfolio-restore-run'),
              onPressed: () async {
                if (secret.text.length < 12) {
                  setState(() {
                    localError = strings.text('portfolioRecoveryShort');
                  });
                  return;
                }
                final restored = await cubit.restorePortableBackup(secret.text);
                if (!dialogContext.mounted) return;
                if (restored == true) {
                  Navigator.pop(dialogContext);
                } else if (restored == false) {
                  setState(() {
                    localError = _portfolioErrorText(
                      strings,
                      cubit.state.errorCode ?? 'portfolio.operation_failed',
                    );
                  });
                }
              },
              child: Text(strings.text('portfolioRestoreBackup')),
            ),
          ],
        ),
      ),
    );

    if (!context.mounted || !cubit.state.unlocked) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(strings.text('portfolioRestoreDone'))),
    );
  }

  Future<void> _rotateRecovery(BuildContext context) async {
    final strings = HubStrings(context.read<LocaleCubit>().state.language);
    final cubit = context.read<PortfolioCubit>();
    final secret = TextEditingController();
    final confirmSecret = TextEditingController();
    var hidden = true;
    String? localError;
    var changed = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(strings.text('portfolioRecoveryChangeTitle')),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  key: const ValueKey('portfolio-rotate-recovery-secret'),
                  controller: secret,
                  obscureText: hidden,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: strings.text('portfolioRecoverySecret'),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => hidden = !hidden),
                      icon: Icon(
                        hidden
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  key: const ValueKey('portfolio-rotate-recovery-confirm'),
                  controller: confirmSecret,
                  obscureText: hidden,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: strings.text('portfolioRecoveryConfirm'),
                    errorText: localError,
                  ),
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
              key: const ValueKey('portfolio-rotate-recovery-save'),
              onPressed: () async {
                if (secret.text.length < 12) {
                  setState(() {
                    localError = strings.text('portfolioRecoveryShort');
                  });
                  return;
                }
                if (secret.text != confirmSecret.text) {
                  setState(() {
                    localError = strings.text('portfolioRecoveryMismatch');
                  });
                  return;
                }
                changed = await cubit.rotateRecovery(secret.text);
                if (!dialogContext.mounted) return;
                if (changed) {
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
              child: Text(strings.text('portfolioRecoveryChange')),
            ),
          ],
        ),
      ),
    );

    if (!context.mounted || !changed) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(strings.text('portfolioRecoveryChanged'))),
    );
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

  }

  Future<void> _addSale(BuildContext context) async {
    final strings = HubStrings(context.read<LocaleCubit>().state.language);
    final cubit = context.read<PortfolioCubit>();
    final payload = cubit.state.payload;
    if (payload == null || payload.holdings.isEmpty) return;

    final holdingsByIsin = {
      for (final holding in payload.holdings) holding.isin: holding,
    };
    final sellableIsins = holdingsByIsin.keys
        .where(
          (isin) => !payload.cashEvents.any(
            (event) =>
                event.isin == isin &&
                event.kind == PrivateCashEventKind.redemption,
          ),
        )
        .toList()
      ..sort();
    if (sellableIsins.isEmpty) return;

    var selectedIsin = sellableIsins.first;
    final allocationControllers = <String, TextEditingController>{
      for (final lot in payload.acquisitionLots)
        if (_remainingLotUnits(payload, lot) > 0)
          lot.id: TextEditingController(text: '0'),
    };
    final now = DateTime.now();
    final date = TextEditingController(text: _todayDisplay(now));
    final proceeds = TextEditingController();
    final fee = TextEditingController(text: '0');
    final note = TextEditingController();
    var feeKnown = false;
    String? localError;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          final lots = payload.acquisitionLots
              .where(
                (lot) =>
                    lot.isin == selectedIsin &&
                    _remainingLotUnits(payload, lot) > 0,
              )
              .toList();
          return AlertDialog(
            title: Text(strings.text('portfolioAddSale')),
            content: SizedBox(
              width: 560,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      key: const ValueKey('portfolio-sale-isin'),
                      initialValue: selectedIsin,
                      decoration: const InputDecoration(labelText: 'ISIN'),
                      items: sellableIsins
                          .map(
                            (isin) => DropdownMenuItem(
                              value: isin,
                              child: Text(isin),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedIsin = value;
                            localError = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      key: const ValueKey('portfolio-sale-date'),
                      controller: date,
                      decoration: InputDecoration(
                        labelText: strings.text('portfolioSaleDate'),
                        hintText: 'DD.MM.YYYY',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      key: const ValueKey('portfolio-sale-proceeds'),
                      controller: proceeds,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: strings.text('portfolioSaleProceeds'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      strings.text('portfolioSaleAllocation'),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    ...lots.map(
                      (lot) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TextField(
                          key: ValueKey('portfolio-sale-lot-${lot.id}'),
                          controller: allocationControllers[lot.id],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText:
                                '${strings.text('portfolioLot')} ${_displayIsoDate(lot.acquiredOn)} · '
                                '${strings.text('portfolioSaleAvailable')}: ${_remainingLotUnits(payload, lot)}',
                          ),
                        ),
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(strings.text('portfolioFeeKnown')),
                      value: feeKnown,
                      onChanged: (value) => setState(() => feeKnown = value),
                    ),
                    if (feeKnown)
                      TextField(
                        key: const ValueKey('portfolio-sale-fee'),
                        controller: fee,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: strings.text('portfolioFeeAmount'),
                        ),
                      ),
                    const SizedBox(height: 10),
                    TextField(
                      key: const ValueKey('portfolio-sale-note'),
                      controller: note,
                      decoration: InputDecoration(
                        labelText: strings.text('portfolioSaleNote'),
                      ),
                    ),
                    if (localError != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        localError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
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
                key: const ValueKey('portfolio-save-sale'),
                onPressed: () async {
                  final iso = _dateToIso(date.text.trim());
                  final allocations = <String, int>{};
                  var invalidAllocation = false;
                  for (final lot in lots) {
                    final raw = allocationControllers[lot.id]!.text.trim();
                    final value = int.tryParse(raw);
                    if (value == null ||
                        value < 0 ||
                        value > _remainingLotUnits(payload, lot)) {
                      invalidAllocation = true;
                      break;
                    }
                    if (value > 0) allocations[lot.id] = value;
                  }
                  if (iso == null ||
                      proceeds.text.trim().isEmpty ||
                      invalidAllocation ||
                      allocations.isEmpty) {
                    setState(() {
                      localError = allocations.isEmpty && !invalidAllocation
                          ? strings.text('portfolioAllocationRequired')
                          : strings.text('portfolioInvalidInput');
                    });
                    return;
                  }
                  await cubit.addDisposal(
                    isin: selectedIsin,
                    disposedOn: iso,
                    proceedsAmount:
                        proceeds.text.trim().replaceAll(',', '.'),
                    feeKnown: feeKnown,
                    feeTotal: feeKnown
                        ? fee.text.trim().replaceAll(',', '.')
                        : null,
                    lotAllocations: allocations,
                    note: note.text,
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
                child: Text(strings.text('portfolioSaveSale')),
              ),
            ],
          );
        },
      ),
    );

  }

  Future<void> _addCoupon(BuildContext context) async {
    final strings = HubStrings(context.read<LocaleCubit>().state.language);
    final cubit = context.read<PortfolioCubit>();
    final payload = cubit.state.payload;
    if (payload == null || payload.holdings.isEmpty) return;

    final isins = payload.holdings.map((holding) => holding.isin).toList()
      ..sort();
    var selectedIsin = isins.first;
    final date = TextEditingController(text: _todayDisplay(DateTime.now()));
    final amount = TextEditingController();
    final note = TextEditingController();
    String? localError;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(strings.text('portfolioAddCoupon')),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    key: const ValueKey('portfolio-coupon-isin'),
                    initialValue: selectedIsin,
                    decoration: const InputDecoration(labelText: 'ISIN'),
                    items: isins
                        .map(
                          (isin) => DropdownMenuItem(
                            value: isin,
                            child: Text(isin),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedIsin = value;
                          localError = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    key: const ValueKey('portfolio-coupon-date'),
                    controller: date,
                    decoration: InputDecoration(
                      labelText: strings.text('portfolioCouponDate'),
                      hintText: 'DD.MM.YYYY',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    key: const ValueKey('portfolio-coupon-amount'),
                    controller: amount,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: strings.text('portfolioCouponAmount'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    key: const ValueKey('portfolio-coupon-note'),
                    controller: note,
                    decoration: InputDecoration(
                      labelText: strings.text('portfolioCouponNote'),
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
              key: const ValueKey('portfolio-save-coupon'),
              onPressed: () async {
                final iso = _dateToIso(date.text.trim());
                if (iso == null || amount.text.trim().isEmpty) {
                  setState(() {
                    localError = strings.text('portfolioInvalidInput');
                  });
                  return;
                }
                await cubit.addCoupon(
                  isin: selectedIsin,
                  date: iso,
                  amount: amount.text.trim().replaceAll(',', '.'),
                  note: note.text,
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
              child: Text(strings.text('portfolioSaveCoupon')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addRedemption(BuildContext context) async {
    final strings = HubStrings(context.read<LocaleCubit>().state.language);
    final cubit = context.read<PortfolioCubit>();
    final payload = cubit.state.payload;
    if (payload == null || payload.holdings.isEmpty) return;

    final isins = payload.holdings.map((holding) => holding.isin).toList()
      ..sort();
    var selectedIsin = isins.first;
    final now = DateTime.now();
    final date = TextEditingController(text: _todayDisplay(now));
    final units = TextEditingController(text: '1');
    final amount = TextEditingController();
    final note = TextEditingController();
    String? localError;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          final holding = payload.holdings.singleWhere(
            (item) => item.isin == selectedIsin,
          );
          return AlertDialog(
            title: Text(strings.text('portfolioAddRedemption')),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      key: const ValueKey('portfolio-redemption-isin'),
                      initialValue: selectedIsin,
                      decoration: const InputDecoration(labelText: 'ISIN'),
                      items: isins
                          .map(
                            (isin) => DropdownMenuItem(
                              value: isin,
                              child: Text(isin),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedIsin = value;
                            localError = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      key: const ValueKey('portfolio-redemption-date'),
                      controller: date,
                      decoration: InputDecoration(
                        labelText: strings.text('portfolioRedemptionDate'),
                        hintText: 'DD.MM.YYYY',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      key: const ValueKey('portfolio-redemption-units'),
                      controller: units,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText:
                            '${strings.text('portfolioRedemptionUnits')} · max ${holding.units}',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      key: const ValueKey('portfolio-redemption-amount'),
                      controller: amount,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: strings.text('portfolioRedemptionAmount'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      key: const ValueKey('portfolio-redemption-note'),
                      controller: note,
                      decoration: InputDecoration(
                        labelText: strings.text('portfolioRedemptionNote'),
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
                key: const ValueKey('portfolio-save-redemption'),
                onPressed: () async {
                  final iso = _dateToIso(date.text.trim());
                  final parsedUnits = int.tryParse(units.text.trim());
                  if (iso == null ||
                      parsedUnits == null ||
                      parsedUnits < 1 ||
                      parsedUnits > holding.units ||
                      amount.text.trim().isEmpty) {
                    setState(() {
                      localError = strings.text('portfolioInvalidInput');
                    });
                    return;
                  }
                  await cubit.addRedemption(
                    isin: selectedIsin,
                    units: parsedUnits,
                    date: iso,
                    amount: amount.text.trim().replaceAll(',', '.'),
                    note: note.text,
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
                child: Text(strings.text('portfolioSaveRedemption')),
              ),
            ],
          );
        },
      ),
    );

  }

  Future<void> _migrateLegacy(BuildContext context) async {
    final strings = HubStrings(context.read<LocaleCubit>().state.language);
    final cubit = context.read<PortfolioCubit>();
    cubit.dismissMigrationReport();
    String? localError;
    var executed = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(strings.text('portfolioMigrationTitle')),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.text('portfolioMigrationExplain')),
                const SizedBox(height: 12),
                Material(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      strings.text('portfolioMigrationPlaintextWarning'),
                    ),
                  ),
                ),
                if (localError != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    localError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(strings.text('portfolioCancel')),
            ),
            FilledButton(
              key: const ValueKey('portfolio-migration-run'),
              onPressed: () async {
                await cubit.migrateLegacy();
                if (!dialogContext.mounted) return;
                if (cubit.state.errorCode == null &&
                    cubit.state.migrationReport != null) {
                  executed = true;
                  Navigator.pop(dialogContext);
                } else {
                  setState(() {
                    localError = strings.text('portfolioMigrationFailed');
                  });
                }
              },
              child: Text(strings.text('portfolioMigrationRun')),
            ),
          ],
        ),
      ),
    );

    if (!executed || !context.mounted) return;
    final report = cubit.state.migrationReport;
    if (report == null) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.text('portfolioMigrationTitle')),
        content: _MigrationSummary(report: report),
        actions: [
          FilledButton(
            key: const ValueKey('portfolio-migration-done'),
            onPressed: () {
              cubit.dismissMigrationReport();
              Navigator.pop(dialogContext);
            },
            child: Text(strings.text('portfolioMigrationDone')),
          ),
        ],
      ),
    );
  }
}

int _remainingLotUnits(
  PrivatePortfolioPayload payload,
  PrivateAcquisitionLot lot,
) {
  var allocated = 0;
  for (final disposal in payload.disposals) {
    for (final allocation in disposal.allocations) {
      if (allocation.lotId == lot.id) allocated += allocation.units;
    }
  }
  return lot.units - allocated;
}

String _todayDisplay(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}.'
    '${value.month.toString().padLeft(2, '0')}.'
    '${value.year}';

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
      'portfolio.disposal_after_redemption' =>
        strings.text('portfolioSaleAfterRedemption'),
      'portfolio.disposal_allocation_required' =>
        strings.text('portfolioAllocationRequired'),
      'portfolio.invalid_units' ||
      'portfolio.invalid_date' ||
      'portfolio.invalid_trade_amount' ||
      'portfolio.invalid_fee_total' ||
      'portfolio.invalid_isin' ||
      'portfolio.invalid_disposal_units' ||
      'portfolio.invalid_disposal_proceeds' ||
      'portfolio.invalid_disposal_fee_total' ||
      'portfolio.known_disposal_fee_missing_value' ||
      'portfolio.disposal_allocation_units_mismatch' ||
      'portfolio.disposal_lot_overallocated' ||
      'portfolio.disposal_exceeds_units' ||
      'portfolio.invalid_event_amount' ||
      'portfolio.event_without_acquisition' ||
      'portfolio.event_before_acquisition' ||
      'portfolio.coupon_has_units' ||
      'portfolio.redemption_units_required' ||
      'portfolio.redemption_exceeds_units' =>
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

class _FactualCashSummary extends StatelessWidget {
  final PrivatePortfolioPayload payload;
  const _FactualCashSummary({required this.payload});

  @override
  Widget build(BuildContext context) {
    final strings = HubStrings(context.watch<LocaleCubit>().state.language);
    return Column(
      children: [
        for (final summary in payload.factualCashSummaries)
          Card(
            key: ValueKey('portfolio-cash-${summary.currency}'),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    summary.currency,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _CashRow(
                    label: strings.text('portfolioCashPurchases'),
                    value:
                        '${summary.acquisitionTradeAmount} ${summary.currency}',
                  ),
                  _CashRow(
                    label: strings.text('portfolioCashSales'),
                    value: '${summary.disposalProceeds} ${summary.currency}',
                  ),
                  _CashRow(
                    label: strings.text('portfolioCashCoupons'),
                    value: '${summary.couponReceipts} ${summary.currency}',
                  ),
                  _CashRow(
                    label: strings.text('portfolioCashRedemptions'),
                    value:
                        '${summary.redemptionReceipts} ${summary.currency}',
                  ),
                  _CashRow(
                    label: strings.text('portfolioCashKnownFees'),
                    value:
                        '${summary.knownAcquisitionFees + summary.knownDisposalFees} ${summary.currency}',
                  ),
                  if (summary.hasUnknownFees)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_outlined, size: 18),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              strings.text('portfolioCashUnknownFeesFlag'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Divider(height: 20),
                  _CashRow(
                    label: strings.text('portfolioCashNet'),
                    value: summary.exactNetCashResult == null
                        ? strings.text('portfolioCashNetUnknown')
                        : '${summary.exactNetCashResult} ${summary.currency}',
                    emphasize: true,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _CashRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _CashRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(label)),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: emphasize
                    ? const TextStyle(fontWeight: FontWeight.w700)
                    : null,
              ),
            ),
          ],
        ),
      );
}

class _HoldingCard extends StatelessWidget {
  final PrivateHolding holding;
  final PrivatePortfolioPayload payload;

  const _HoldingCard({
    required this.holding,
    required this.payload,
  });

  @override
  Widget build(BuildContext context) {
    final strings = HubStrings(context.watch<LocaleCubit>().state.language);
    final bond = _portfolioBondFor(context, holding.isin);
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '× ${holding.units}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              key: ValueKey('portfolio-details-${holding.isin}'),
              tooltip: strings.text('portfolioDetails'),
              onPressed: () => _showPortfolioIsinDetails(
                context,
                payload: payload,
                isin: holding.isin,
                currency: holding.currency,
                units: holding.units,
                bond: bond,
              ),
              icon: const Icon(Icons.receipt_long_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClosedPositionCard extends StatelessWidget {
  final String isin;
  final String currency;
  final PrivatePortfolioPayload payload;

  const _ClosedPositionCard({
    required this.isin,
    required this.currency,
    required this.payload,
  });

  @override
  Widget build(BuildContext context) {
    final strings = HubStrings(context.watch<LocaleCubit>().state.language);
    final bond = _portfolioBondFor(context, isin);
    return Card(
      child: ListTile(
        key: ValueKey('portfolio-closed-$isin'),
        leading: const Icon(Icons.task_alt_outlined),
        title: Text(
          isin,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          [
            currency,
            strings.text('portfolioClosedPosition'),
            if (bond != null)
              '${strings.text('portfolioMaturity')} ${_displayIsoDate(bond.maturity)}',
          ].join(' · '),
        ),
        trailing: IconButton(
          key: ValueKey('portfolio-closed-details-$isin'),
          tooltip: strings.text('portfolioDetails'),
          onPressed: () => _showPortfolioIsinDetails(
            context,
            payload: payload,
            isin: isin,
            currency: currency,
            units: 0,
            bond: bond,
          ),
          icon: const Icon(Icons.receipt_long_outlined),
        ),
      ),
    );
  }
}

Bond? _portfolioBondFor(BuildContext context, String isin) {
  final catalog = context.read<HubRepository>().current?.catalog;
  if (catalog == null) return null;
  for (final item in catalog.bonds) {
    if (item.isin == isin) return item;
  }
  return null;
}

Future<void> _showPortfolioIsinDetails(
  BuildContext context, {
  required PrivatePortfolioPayload payload,
  required String isin,
  required String currency,
  required int units,
  required Bond? bond,
}) async {
  final strings = HubStrings(context.read<LocaleCubit>().state.language);
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      key: ValueKey('portfolio-isin-dialog-$isin'),
      title: Text(
        '${strings.text('portfolioIsinDetails')} · $isin',
      ),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(
                      '${strings.text('portfolioCurrentUnits')}: $units',
                    ),
                  ),
                  Chip(label: Text(currency)),
                  if (units == 0)
                    Chip(label: Text(strings.text('portfolioClosedPosition'))),
                  if (bond != null)
                    Chip(
                      label: Text(
                        '${strings.text('portfolioMaturity')}: ${_displayIsoDate(bond.maturity)}',
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                strings.text('portfolioHistory'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              _PortfolioHistory(payload: payload, isin: isin),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          key: ValueKey('portfolio-details-close-$isin'),
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(strings.text('portfolioClose')),
        ),
      ],
    ),
  );
}

String _displayIsoDate(String value) =>
    value.length == 10
        ? '${value.substring(8, 10)}.${value.substring(5, 7)}.${value.substring(0, 4)}'
        : value;

class _HistoryEntry {
  final String date;
  final String isin;
  final String kindKey;
  final int? units;
  final String amount;
  final String currency;
  final String? note;

  const _HistoryEntry({
    required this.date,
    required this.isin,
    required this.kindKey,
    required this.units,
    required this.amount,
    required this.currency,
    this.note,
  });
}

class _PortfolioHistory extends StatelessWidget {
  final PrivatePortfolioPayload payload;
  final String? isin;
  const _PortfolioHistory({required this.payload, this.isin});

  @override
  Widget build(BuildContext context) {
    final strings = HubStrings(context.watch<LocaleCubit>().state.language);
    final entries = <_HistoryEntry>[
      for (final lot in payload.acquisitionLots)
        if (isin == null || lot.isin == isin)
          _HistoryEntry(
          date: lot.acquiredOn,
          isin: lot.isin,
          kindKey: 'portfolioHistoryPurchase',
          units: lot.units,
          amount: lot.tradeAmount.toString(),
          currency: lot.currency,
          note: lot.brokerAccountLabel,
        ),
      for (final disposal in payload.disposals)
        if (isin == null || disposal.isin == isin)
          _HistoryEntry(
          date: disposal.disposedOn,
          isin: disposal.isin,
          kindKey: 'portfolioHistorySale',
          units: disposal.units,
          amount: disposal.proceedsAmount.toString(),
          currency: disposal.currency,
          note: disposal.note,
        ),
      for (final event in payload.cashEvents)
        if (isin == null || event.isin == isin)
          _HistoryEntry(
          date: event.date,
          isin: event.isin,
          kindKey: event.kind == PrivateCashEventKind.coupon
              ? 'portfolioHistoryCoupon'
              : 'portfolioHistoryRedemption',
          units: event.units,
          amount: event.amount.toString(),
          currency: event.currency,
          note: event.note,
        ),
    ]..sort((a, b) {
        final byDate = b.date.compareTo(a.date);
        if (byDate != 0) return byDate;
        final byIsin = a.isin.compareTo(b.isin);
        if (byIsin != 0) return byIsin;
        return a.kindKey.compareTo(b.kindKey);
      });

    if (entries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(strings.text('portfolioHistoryEmpty')),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          for (var index = 0; index < entries.length; index++) ...[
            if (index > 0) const Divider(height: 1),
            ListTile(
              leading: Icon(
                switch (entries[index].kindKey) {
                  'portfolioHistoryPurchase' => Icons.add_shopping_cart_outlined,
                  'portfolioHistorySale' => Icons.sell_outlined,
                  'portfolioHistoryCoupon' => Icons.savings_outlined,
                  _ => Icons.payments_outlined,
                },
              ),
              title: Text(
                '${strings.text(entries[index].kindKey)} · ${entries[index].isin}',
              ),
              subtitle: Text(
                [
                  _displayIsoDate(entries[index].date),
                  if (entries[index].units != null) '× ${entries[index].units}',
                  '${entries[index].amount} ${entries[index].currency}',
                  if (entries[index].note != null &&
                      entries[index].note!.trim().isNotEmpty)
                    entries[index].note!.trim(),
                ].join(' · '),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MigrationSummary extends StatelessWidget {
  final LegacyPlaintextMigrationReport report;
  const _MigrationSummary({required this.report});

  @override
  Widget build(BuildContext context) {
    final strings = HubStrings(context.watch<LocaleCubit>().state.language);
    Widget row(String label, Object value, {IconData? icon}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Expanded(child: Text(label)),
              Text(
                '$value',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        );

    return SizedBox(
      width: 480,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          row(strings.text('portfolioMigrationMigrated'), report.migratedCount),
          row(
            strings.text('portfolioMigrationAlready'),
            report.alreadyMigratedCount,
          ),
          row(
            strings.text('portfolioMigrationConflicts'),
            report.conflictCount,
          ),
          row(strings.text('portfolioMigrationInvalid'), report.invalidCount),
          row(
            strings.text('portfolioMigrationVerified'),
            report.encryptedCopyVerified ? '✓' : '—',
            icon: report.encryptedCopyVerified
                ? Icons.verified_user_outlined
                : Icons.warning_amber_outlined,
          ),
          row(
            strings.text('portfolioMigrationPlaintextRemaining'),
            report.plaintextFilesStillPresent,
          ),
          const SizedBox(height: 8),
          Text(strings.text('portfolioMigrationPlaintextWarning')),
        ],
      ),
    );
  }
}

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
