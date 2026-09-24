import 'dart:convert';

import 'package:decimal/decimal.dart';

import '../../models.dart';
import 'planner_goals.dart';
import 'planner_scenario.dart';

class PlannerReceiptEvent {
  final String id;
  final String date;
  final String sourceDate;
  final String kind;
  final String currency;
  final Decimal amount;
  final String isin;

  const PlannerReceiptEvent({
    required this.id,
    required this.date,
    required this.sourceDate,
    required this.kind,
    required this.currency,
    required this.amount,
    required this.isin,
  });
}

String plannerExportDisplayName(String stored) {
  if (stored == PlannerGeneratedCopy.planName) return 'Plan';
  if (stored == PlannerGeneratedCopy.primaryNeedName) return 'Primary need';
  if (stored == PlannerGeneratedCopy.reserveFloorName) {
    return 'Minimum balance';
  }
  final ordinal = PlannerGeneratedCopy.expenseOrdinal(stored);
  if (ordinal != null) return 'Expense $ordinal';
  return stored;
}

String _csvCell(Object? value) {
  final text = value?.toString() ?? '';
  if (!text.contains(RegExp(r'[",\r\n]'))) return text;
  return '"${text.replaceAll('"', '""')}"';
}

String _csvRow(Iterable<Object?> values) =>
    values.map(_csvCell).join(',');

DateTime _addDays(String date, int days) =>
    isoDate(date).add(Duration(days: days));

String _dateText(DateTime date) =>
    date.toIso8601String().substring(0, 10);

List<PlannerReceiptEvent> plannerReceiptEvents({
  required PlannerScenario scenario,
  required Map<String, Bond> bonds,
}) {
  final exits = {
    for (final exit in scenario.effectivePositionExits) exit.isin: exit,
  };
  final events = <PlannerReceiptEvent>[];

  for (final position in scenario.positions) {
    final bond = bonds[position.isin];
    if (bond == null) {
      throw const FormatException('planner.export_missing_bond');
    }
    final exit = exits[position.isin];
    final saleDate = exit == null ? null : isoDate(exit.date);

    for (final payment in bond.payments) {
      final kind = payment['kind'] as String;
      if (!['COUPON', 'REDEMPTION'].contains(kind)) continue;
      final sourceDate = payment['date'] as String;
      final date = isoDate(sourceDate);
      if (!date.isAfter(isoDate(scenario.startDate)) ||
          date.isAfter(isoDate(bond.maturity)) ||
          (saleDate != null && !date.isBefore(saleDate))) {
        continue;
      }
      final amount =
          (Decimal.parse(payment['amount'].toString()) *
                  Decimal.fromInt(position.quantity))
              .round(scale: 2);
      final available = _dateText(
        _addDays(sourceDate, scenario.settlementDelayDays),
      );
      events.add(
        PlannerReceiptEvent(
          id: 'receipt:${position.isin}:$kind:$sourceDate',
          date: available,
          sourceDate: sourceDate,
          kind: kind.toLowerCase(),
          currency: scenario.currency,
          amount: amount,
          isin: position.isin,
        ),
      );
    }

    if (exit != null) {
      final amount =
          (exit.price.effectiveUnitCost! *
                  Decimal.fromInt(position.quantity))
              .round(scale: 2);
      events.add(
        PlannerReceiptEvent(
          id: 'receipt:${position.isin}:sale:${exit.date}',
          date: _dateText(
            _addDays(exit.date, scenario.settlementDelayDays),
          ),
          sourceDate: exit.date,
          kind: 'sale',
          currency: scenario.currency,
          amount: amount,
          isin: position.isin,
        ),
      );
    }
  }

  events.sort((a, b) {
    final byDate = a.date.compareTo(b.date);
    if (byDate != 0) return byDate;
    final byIsin = a.isin.compareTo(b.isin);
    if (byIsin != 0) return byIsin;
    final byKind = a.kind.compareTo(b.kind);
    if (byKind != 0) return byKind;
    return a.sourceDate.compareTo(b.sourceDate);
  });
  return List.unmodifiable(events);
}

String buildPlannerCsv({
  required PlannerScenario scenario,
  required Map<String, Bond> bonds,
  required Iterable<ExpenseBalance> coverage,
}) {
  final rows = <List<Object?>>[
    [
      'record_type',
      'id',
      'date',
      'source_date',
      'name',
      'kind',
      'currency',
      'amount',
      'available',
      'remaining',
      'shortfall',
      'isin',
      'quantity',
      'unit_cost',
      'price_source',
      'every_months',
      'occurrences',
      'value',
    ],
  ];

  void meta(String id, Object value, {String? date}) {
    rows.add([
      'scenario',
      id,
      date ?? '',
      '',
      plannerExportDisplayName(scenario.name),
      '',
      scenario.currency,
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      value,
    ]);
  }

  meta('currency', scenario.currency);
  meta('budget', scenario.budget);
  meta('reserve', scenario.reserve);
  meta('start_date', scenario.startDate, date: scenario.startDate);
  meta('min_maturity', scenario.minMaturity, date: scenario.minMaturity);
  meta('max_maturity', scenario.maxMaturity, date: scenario.maxMaturity);
  meta('strategy', scenario.strategy.name);
  meta('settlement_delay_days', scenario.settlementDelayDays);
  meta('priced_only', scenario.pricedOnly);

  final positions = scenario.positions.toList()
    ..sort((a, b) => a.isin.compareTo(b.isin));
  for (final position in positions) {
    if (!bonds.containsKey(position.isin)) {
      throw const FormatException('planner.export_missing_bond');
    }
    rows.add([
      'position',
      position.isin,
      '',
      '',
      '',
      'position',
      scenario.currency,
      '',
      '',
      '',
      '',
      position.isin,
      position.quantity,
      position.unitCost,
      position.price.meta.sourceId,
      '',
      '',
      '',
    ]);
  }

  final needs = scenario.needs.toList()
    ..sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      if (byDate != 0) return byDate;
      return a.id.compareTo(b.id);
    });
  for (final need in needs) {
    rows.add([
      'need_rule',
      need.id,
      need.date,
      '',
      plannerExportDisplayName(need.name),
      need.type.name,
      scenario.currency,
      need.amount,
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      need.everyMonths ?? '',
      need.occurrences ?? '',
      '',
    ]);
  }

  final coverageRows = coverage.toList()
    ..sort((a, b) {
      final byDate = a.expense.date.compareTo(b.expense.date);
      if (byDate != 0) return byDate;
      final byType = a.expense.type.name.compareTo(b.expense.type.name);
      if (byType != 0) return byType;
      return a.expense.name.compareTo(b.expense.name);
    });
  for (var i = 0; i < coverageRows.length; i++) {
    final row = coverageRows[i];
    rows.add([
      'coverage',
      'coverage-${i + 1}',
      row.expense.date,
      '',
      plannerExportDisplayName(row.expense.name),
      row.expense.type.name,
      scenario.currency,
      row.expense.amount,
      row.available,
      row.remaining,
      row.shortfall,
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ]);
  }

  for (final event in plannerReceiptEvents(
    scenario: scenario,
    bonds: bonds,
  )) {
    rows.add([
      'receipt',
      event.id,
      event.date,
      event.sourceDate,
      '',
      event.kind,
      event.currency,
      event.amount,
      '',
      '',
      '',
      event.isin,
      '',
      '',
      '',
      '',
      '',
      '',
    ]);
  }

  return '\uFEFF${rows.map(_csvRow).join('\r\n')}\r\n';
}

int _fnv1a32(String value) {
  var hash = 0x811c9dc5;
  for (final byte in utf8.encode(value)) {
    hash ^= byte;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash;
}

String _hex32(int value) =>
    value.toRadixString(16).padLeft(8, '0');

String plannerExportStem(PlannerScenario scenario) {
  final needs = scenario.needs.toList()
    ..sort((a, b) => a.id.compareTo(b.id));
  final positions = scenario.positions.toList()
    ..sort((a, b) => a.isin.compareTo(b.isin));
  final exits = scenario.effectivePositionExits.toList()
    ..sort((a, b) => a.isin.compareTo(b.isin));

  final canonical = [
    scenario.currency,
    scenario.budget.toString(),
    scenario.reserve.toString(),
    scenario.startDate,
    scenario.minMaturity,
    scenario.maxMaturity,
    scenario.strategy.name,
    scenario.settlementDelayDays.toString(),
    scenario.pricedOnly.toString(),
    ...needs.map(
      (n) =>
          '${n.id}|${n.type.name}|${n.date}|${n.amount}|'
          '${n.everyMonths ?? ''}|${n.occurrences ?? ''}|${n.name}',
    ),
    ...positions.map(
      (p) =>
          '${p.isin}|${p.quantity}|${p.unitCost}|'
          '${p.price.meta.sourceId}|${p.price.kind.name}',
    ),
    ...exits.map(
      (e) =>
          '${e.isin}|${e.date}|${e.price.effectiveUnitCost}|'
          '${e.price.meta.sourceId}',
    ),
    jsonEncode(scenario.fees.toJson()),
    jsonEncode(scenario.taxes.toJson()),
    jsonEncode(scenario.fx.map((e) => e.toJson()).toList()),
  ].join('\n');

  final date = scenario.startDate.replaceAll('-', '');
  return 'ovdp-planner-$date-${_hex32(_fnv1a32(canonical))}';
}

String _icsEscape(String value) => value
    .replaceAll('\\', '\\\\')
    .replaceAll('\r\n', '\\n')
    .replaceAll('\n', '\\n')
    .replaceAll(';', '\\;')
    .replaceAll(',', '\\,');

String _icsDate(String date) => date.replaceAll('-', '');

String _foldIcsLine(String line) {
  final parts = <String>[];
  var current = StringBuffer();
  var bytes = 0;
  var first = true;

  for (final rune in line.runes) {
    final char = String.fromCharCode(rune);
    final size = utf8.encode(char).length;
    final limit = first ? 75 : 74;
    if (bytes + size > limit && current.isNotEmpty) {
      parts.add(current.toString());
      current = StringBuffer();
      bytes = 0;
      first = false;
    }
    current.write(char);
    bytes += size;
  }
  parts.add(current.toString());
  return parts.asMap().entries
      .map((e) => e.key == 0 ? e.value : ' ${e.value}')
      .join('\r\n');
}

String _icsEvent({
  required String uidSeed,
  required String dtstamp,
  required String date,
  required String summary,
  required String description,
}) {
  final uid = 'ovdp-${_hex32(_fnv1a32(uidSeed))}@ovdp-hub.local';
  return [
    'BEGIN:VEVENT',
    'UID:$uid',
    'DTSTAMP:$dtstamp',
    'DTSTART;VALUE=DATE:${_icsDate(date)}',
    'SUMMARY:${_icsEscape(summary)}',
    'DESCRIPTION:${_icsEscape(description)}',
    'END:VEVENT',
  ].map(_foldIcsLine).join('\r\n');
}

String buildPlannerIcs({
  required PlannerScenario scenario,
  required Map<String, Bond> bonds,
  required Iterable<ExpenseBalance> coverage,
}) {
  final dtstamp = '${_icsDate(scenario.startDate)}T000000Z';
  final events = <({String sort, String value})>[];

  for (final row in coverage) {
    final kind = row.expense.isReserveFloor
        ? 'RESERVE_FLOOR'
        : row.expense.type.name.toUpperCase();
    final name = plannerExportDisplayName(row.expense.name);
    events.add((
      sort: '${row.expense.date}|need|$kind|$name',
      value: _icsEvent(
        uidSeed:
            'need|${row.expense.date}|$kind|$name|${row.expense.amount}',
        dtstamp: dtstamp,
        date: row.expense.date,
        summary: '$kind · $name',
        description:
            'Amount: ${row.expense.amount} ${scenario.currency}; '
            'available before: ${row.available}; '
            'remaining: ${row.remaining}; '
            'shortfall: ${row.shortfall}.',
      ),
    ));
  }

  for (final receipt in plannerReceiptEvents(
    scenario: scenario,
    bonds: bonds,
  )) {
    events.add((
      sort:
          '${receipt.date}|receipt|${receipt.kind}|${receipt.isin}|'
          '${receipt.sourceDate}',
      value: _icsEvent(
        uidSeed:
            'receipt|${receipt.isin}|${receipt.kind}|'
            '${receipt.sourceDate}|${receipt.amount}',
        dtstamp: dtstamp,
        date: receipt.date,
        summary: '${receipt.kind.toUpperCase()} · ${receipt.isin}',
        description:
            'Amount: ${receipt.amount} ${receipt.currency}; '
            'source date: ${receipt.sourceDate}; '
            'expected available after settlement delay: ${receipt.date}.',
      ),
    ));
  }

  events.sort((a, b) => a.sort.compareTo(b.sort));

  final lines = [
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//OVDP Hub//Planner Export//EN',
    'CALSCALE:GREGORIAN',
    'METHOD:PUBLISH',
    'X-WR-CALNAME:${_icsEscape(plannerExportDisplayName(scenario.name))}',
    ...events.map((e) => e.value),
    'END:VCALENDAR',
  ];

  return '${lines.map(_foldIcsLine).join('\r\n')}\r\n';
}
