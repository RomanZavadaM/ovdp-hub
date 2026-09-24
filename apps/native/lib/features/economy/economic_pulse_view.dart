import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/hub_locale.dart';
import 'economic_pulse_cubit.dart';
import 'economic_pulse_model.dart';

String _pulseDate(String? value) {
  if (value == null || value.length != 10) return value ?? '—';
  return '${value.substring(8, 10)}.${value.substring(5, 7)}.${value.substring(0, 4)}';
}

class EconomicPulseBar extends StatelessWidget {
  final bool compact;

  const EconomicPulseBar({
    super.key,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final strings = HubStrings(context.watch<LocaleCubit>().state.language);
    final state = context.watch<EconomicPulseCubit>().state;
    final snapshot = state.snapshot;
    final items = <Widget>[
      _PulseItem(
        icon: Icons.attach_money,
        label: strings.text('pulseUsd'),
        value: snapshot?.usd == null ? '—' : '${snapshot!.usd!.rate} ₴',
        detail: _sourceDetail(
          strings,
          snapshot?.usd?.sourceDate,
          strings.text('sourceNbu'),
        ),
      ),
      _PulseItem(
        icon: Icons.euro,
        label: strings.text('pulseEur'),
        value: snapshot?.eur == null ? '—' : '${snapshot!.eur!.rate} ₴',
        detail: _sourceDetail(
          strings,
          snapshot?.eur?.sourceDate,
          strings.text('sourceNbu'),
        ),
      ),
      _PulseItem(
        icon: Icons.trending_up,
        label: strings.text('pulseAuctionYield'),
        value: _yieldValue(snapshot?.uahAuctionYield),
        detail: _sourceDetail(
          strings,
          snapshot?.uahAuctionYield?.sourceDate,
          strings.text('sourceMinfin'),
        ),
      ),
      _PulseItem(
        icon: Icons.event_outlined,
        label: strings.text('pulseNextAuction'),
        value: snapshot?.nextAuction == null
            ? '—'
            : _pulseDate(snapshot!.nextAuction!.date),
        detail: snapshot?.nextAuction == null
            ? strings.text('pulseUnavailable')
            : strings.text('sourceMinfin'),
      ),
    ];

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          compact ? 10 : 18,
          compact ? 6 : 8,
          compact ? 6 : 10,
          compact ? 6 : 8,
        ),
        child: Row(
          children: [
            if (!compact) ...[
              Icon(
                Icons.monitor_heart_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                strings.text('economicPulse'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: items),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: strings.text('pulseRefresh'),
              onPressed: state.busy
                  ? null
                  : context.read<EconomicPulseCubit>().refresh,
              icon: state.busy
                  ? const SizedBox.square(
                      dimension: 17,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh, size: 19),
            ),
          ],
        ),
      ),
    );
  }

  String _sourceDetail(
    HubStrings strings,
    String? date,
    String source,
  ) => date == null
      ? strings.text('pulseUnavailable')
      : '$source · ${_pulseDate(date)}';

  String _yieldValue(EconomicAuctionYield? value) {
    if (value == null) return '—';
    return value.isRange
        ? '${value.minRate}–${value.maxRate}%'
        : '${value.minRate}%';
  }
}

class _PulseItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String detail;

  const _PulseItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 132),
    margin: const EdgeInsets.only(right: 8),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              detail,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                  ),
            ),
          ],
        ),
      ],
    ),
  );
}
