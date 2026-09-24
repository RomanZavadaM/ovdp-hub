import 'dart:convert';

import 'package:decimal/decimal.dart';

import '../../models.dart';
import '../../pricing.dart';
import 'planner_engine.dart';
import 'planner_fees.dart';
import 'planner_goals.dart';
import 'planner_scenario.dart';

class PlannerExportBundle {
  final String csv;
  final String ics;

  const PlannerExportBundle({
    required this.csv,
    required this.ics,
  });

  Map<String, String> get files => {
        'planner.csv': csv,
        'planner.ics': ics,
      };
}

class _ExportRow {
  final String eventDate;
  final String eventType;
  final String label;
  final Decimal? amount;
  final String? isin;
  final int? quantity;
  final Decimal? unitCost;
  final Decimal? available;
  final Decimal? remaining;
  final Decimal? shortfall;

  const _ExportRow({
    required this.eventDate,
    required this.eventType,
    required this.label,
    this.amount,
    this.isin,
    this.quantity,
    this.unitCost,
    this.available,
    this.remaining,
    this.shortfall,
  });
}

int _rowCompare(_ExportRow a, _ExportRow b) {
  final date = a.eventDate.compareTo(b.eventDate);
  if (date != 0) return date;
  final type = a.eventType.compareTo(b.eventType);
  if (type != 0) return type;
  final isin = (a.isin ?? '').compareTo(b.isin ?? '');
  if (isin != 0) return isin;
  return a.label.compareTo(b.label);
}

String _csvCell(String value) {
  if (!value.contains(RegExp(r'[,"\r\n]'))) return value;
  return '"${value.replaceAll('"', '""')}"';
}

String _csvValue(Object? value) => value == null ? '' : value.toString();

String _needEventType(PlannerNeedType type) => switch (type) {
      PlannerNeedType.oneOff => 'NEED_ONE_OFF',
      PlannerNeedType.recurring => 'NEED_RECURRING',
      PlannerNeedType.reserveFloor => 'RESERVE_FLOOR',
    };

DateTime _availableDate(String date, int delayDays) =>
    isoDate(date).add(Duration(days: delayDays));

String _dateText(DateTime value) =>
    value.toIso8601String().substring(0, 10);

List<PlanPosition> _materializePositions(
  PlannerScenario scenario,
  Iterable<Bond> bonds,
) {
  final byIsin = {for (final bond in bonds) bond.isin: bond};
  return scenario.positions.map((draft) {
    final bond = byIsin[draft.isin];
    if (bond == null) {
      throw const FormatException('planner.export_missing_bond');
    }
    return PlanPosition(
      bond,
      draft.quantity,
      draft.unitCost,
      nominalEstimate: draft.price.kind == PriceValueKind.nominalEstimate,
    );
  }).toList(growable: false);
}

List<_ExportRow> _rows({
  required PlannerScenario scenario,
  required Iterable<Bond> bonds,
  required Iterable<ExpenseBalance> expenseBalances,
}) {
  final positions = _materializePositions(scenario, bonds);
  final exits = {
    for (final exit in scenario.effectivePositionExits) exit.isin: exit,
  };
  final rows = <_ExportRow>[];

  for (final position in positions) {
    rows.add(
      _ExportRow(
        eventDate: scenario.startDate,
        eventType: 'POSITION',
        label: position.bond.isin,
        amount: position.cost,
        isin: position.bond.isin,
        quantity: position.quantity,
        unitCost: position.unitCost,
      ),
    );

    final exit = exits[position.bond.isin];
    final exitDate = exit == null ? null : isoDate(exit.date);
    for (final payment in position.bond.payments) {
      final kind = payment['kind'] as String;
      if (!['COUPON', 'REDEMPTION'].contains(kind)) continue;
      final paymentDate = isoDate(payment['date'] as String);
      if (!paymentDate.isAfter(isoDate(scenario.startDate)) ||
          paymentDate.isAfter(isoDate(position.bond.maturity)) ||
          (exitDate != null && !paymentDate.isBefore(exitDate))) {
        continue;
      }
      final amount =
          (money(payment['amount'].toString()) *
                  Decimal.fromInt(position.quantity))
              .round(scale: 2);
      rows.add(
        _ExportRow(
          eventDate: _dateText(
            paymentDate.add(
              Duration(days: scenario.settlementDelayDays),
            ),
          ),
          eventType: kind,
          label: 'OVDP $kind · ${position.bond.isin}',
          amount: amount,
          isin: position.bond.isin,
          quantity: position.quantity,
        ),
      );
    }

    if (exit != null) {
      rows.add(
        _ExportRow(
          eventDate: _dateText(
            _availableDate(exit.date, scenario.settlementDelayDays),
          ),
          eventType: 'SALE',
          label: 'OVDP SALE · ${position.bond.isin}',
          amount:
              (exit.price.effectiveUnitCost! *
                      Decimal.fromInt(position.quantity))
                  .round(scale: 2),
          isin: position.bond.isin,
          quantity: position.quantity,
          unitCost: exit.price.effectiveUnitCost,
        ),
      );
    }
  }

  final fee = purchaseFeeAmount(
    fees: scenario.fees,
    positions: positions,
    currency: scenario.currency,
  );
  if (fee != null) {
    rows.add(
      _ExportRow(
        eventDate: scenario.startDate,
        eventType: 'PURCHASE_FEE',
        label: 'Purchase fee',
        amount: fee,
      ),
    );
  }

  for (final balance in expenseBalances) {
    rows.add(
      _ExportRow(
        eventDate: balance.expense.date,
        eventType: _needEventType(balance.expense.type),
        label: balance.expense.name,
        amount: balance.expense.amount,
        available: balance.available,
        remaining: balance.remaining,
        shortfall: balance.shortfall,
      ),
    );
  }

  rows.sort(_rowCompare);
  return List.unmodifiable(rows);
}

String _csv(
  PlannerScenario scenario,
  List<_ExportRow> rows,
) {
  const header = [
    'scenario_name',
    'currency',
    'budget',
    'base_reserve',
    'start_date',
    'event_date',
    'event_type',
    'label',
    'amount',
    'isin',
    'quantity',
    'unit_cost',
    'available',
    'remaining',
    'shortfall',
  ];
  final out = StringBuffer('\ufeff')..writeln(header.join(','));
  for (final row in rows) {
    final values = [
      scenario.name,
      scenario.currency,
      scenario.budget.toString(),
      scenario.reserve.toString(),
      scenario.startDate,
      row.eventDate,
      row.eventType,
      row.label,
      _csvValue(row.amount),
      row.isin ?? '',
      _csvValue(row.quantity),
      _csvValue(row.unitCost),
      _csvValue(row.available),
      _csvValue(row.remaining),
      _csvValue(row.shortfall),
    ];
    out.writeln(values.map(_csvCell).join(','));
  }
  return out.toString();
}

String _icsText(String value) => value
    .replaceAll('\\', '\\\\')
    .replaceAll('\r\n', '\\n')
    .replaceAll('\n', '\\n')
    .replaceAll(';', '\\;')
    .replaceAll(',', '\\,');

String _icsDate(String value) => value.replaceAll('-', '');

String _signature(PlannerScenario scenario) {
  final needs = [...scenario.needs]
    ..sort((a, b) {
      final date = a.date.compareTo(b.date);
      if (date != 0) return date;
      final type = a.type.name.compareTo(b.type.name);
      if (type != 0) return type;
      return a.id.compareTo(b.id);
    });
  final positions = [...scenario.positions]
    ..sort((a, b) => a.isin.compareTo(b.isin));
  return [
    scenario.name,
    scenario.currency,
    scenario.budget,
    scenario.reserve,
    scenario.startDate,
    scenario.minMaturity,
    scenario.maxMaturity,
    scenario.settlementDelayDays,
    for (final need in needs)
      '${need.type.name}|${need.date}|${need.amount}|'
          '${need.everyMonths ?? ''}|${need.occurrences ?? ''}',
    for (final position in positions)
      '${position.isin}|${position.quantity}|${position.unitCost}',
  ].join('||');
}

String _stableHash(String value) {
  var hash = 0x811c9dc5;
  for (final byte in utf8.encode(value)) {
    hash ^= byte;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}

String _foldIcsLine(String line) {
  final result = StringBuffer();
  var lineBytes = 0;
  var continuation = false;
  for (final rune in line.runes) {
    final text = String.fromCharCode(rune);
    final runeBytes = utf8.encode(text).length;
    final limit = continuation ? 74 : 75;
    if (lineBytes > 0 && lineBytes + runeBytes > limit) {
      result.write('\r\n ');
      lineBytes = 0;
      continuation = true;
    }
    result.write(text);
    lineBytes += runeBytes;
  }
  return result.toString();
}

String _ics(
  PlannerScenario scenario,
  List<_ExportRow> rows,
) {
  final calendarTypes = {
    'NEED_ONE_OFF',
    'NEED_RECURRING',
    'RESERVE_FLOOR',
    'COUPON',
    'REDEMPTION',
    'SALE',
  };
  final events = rows
      .where((row) => calendarTypes.contains(row.eventType))
      .toList(growable: false);
  final scenarioHash = _stableHash(_signature(scenario));
  final stamp = '${_icsDate(scenario.startDate)}T000000Z';
  final lines = <String>[
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//OVDP Hub//Planner Export//EN',
    'CALSCALE:GREGORIAN',
    'METHOD:PUBLISH',
  ];

  for (var i = 0; i < events.length; i++) {
    final row = events[i];
    final amount = row.amount == null
        ? ''
        : '${row.amount} ${scenario.currency}';
    final description = [
      row.eventType,
      if (amount.isNotEmpty) amount,
      if (row.isin != null) row.isin!,
    ].join(' · ');
    lines.addAll([
      'BEGIN:VEVENT',
      'UID:ovdp-hub-$scenarioHash-${i + 1}-'
          '${_icsDate(row.eventDate)}@local',
      'DTSTAMP:$stamp',
      'DTSTART;VALUE=DATE:${_icsDate(row.eventDate)}',
      'SUMMARY:${_icsText(row.label)}',
      'DESCRIPTION:${_icsText(description)}',
      'END:VEVENT',
    ]);
  }
  lines.add('END:VCALENDAR');
  return '${lines.map(_foldIcsLine).join('\r\n')}\r\n';
}

PlannerExportBundle buildPlannerExportBundle({
  required PlannerScenario scenario,
  required Iterable<Bond> bonds,
  required Iterable<ExpenseBalance> expenseBalances,
}) {
  final rows = _rows(
    scenario: scenario,
    bonds: bonds,
    expenseBalances: expenseBalances,
  );
  return PlannerExportBundle(
    csv: _csv(scenario, rows),
    ics: _ics(scenario, rows),
  );
}

String plannerExportFolderName(
  String scenarioName,
  DateTime now,
) {
  var safe = scenarioName
      .trim()
      .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_')
      .replaceAll(RegExp(r'\s+'), ' ');
  safe = safe.replaceAll(RegExp(r'[. ]+$'), '');
  if (safe.isEmpty) safe = 'Scenario';
  if (safe.length > 60) safe = safe.substring(0, 60).trimRight();
  final local = now;
  String two(int value) => value.toString().padLeft(2, '0');
  final stamp = '${local.year}-${two(local.month)}-${two(local.day)}_'
      '${two(local.hour)}${two(local.minute)}${two(local.second)}';
  return 'OVDP-Hub-$safe-$stamp';
}
