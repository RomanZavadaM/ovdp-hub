import 'dart:convert';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

import '../../models.dart';

const int privatePortfolioSchemaVersion = 1;
const int maxPrivatePortfolioBytes = 16 * 1024 * 1024;
const int maxPrivateAcquisitionLots = 10000;
const int maxPrivateCashEvents = 50000;

final RegExp _privateRecordId = RegExp(r'^[A-Za-z0-9._:-]{1,120}$');
final RegExp _privateIsin = RegExp(r'^UA[A-Z0-9]{9}\d$');
final RegExp _privateCurrency = RegExp(r'^[A-Z]{3}$');

void _validateId(String value, String code) {
  if (!_privateRecordId.hasMatch(value)) {
    throw FormatException(code);
  }
}

void _validateIsin(String value) {
  if (!_privateIsin.hasMatch(value)) {
    throw const FormatException('portfolio.invalid_isin');
  }
}

void _validateCurrency(String value) {
  if (!_privateCurrency.hasMatch(value)) {
    throw const FormatException('portfolio.invalid_currency');
  }
}

Decimal _portfolioDecimal(
  Object? raw, {
  required String code,
  bool allowZero = true,
}) {
  try {
    final value = Decimal.parse(decimalText(raw));
    if (allowZero ? value < Decimal.zero : value <= Decimal.zero) {
      throw FormatException(code);
    }
    return value;
  } catch (_) {
    throw FormatException(code);
  }
}

String _portfolioDate(Object? raw) {
  if (raw is! String) {
    throw const FormatException('portfolio.invalid_date');
  }
  try {
    isoDate(raw);
    return raw;
  } catch (_) {
    throw const FormatException('portfolio.invalid_date');
  }
}

T _portfolioEnum<T extends Enum>(
  List<T> values,
  Object? raw,
  String code,
) {
  if (raw is String) {
    for (final value in values) {
      if (value.name == raw) return value;
    }
  }
  throw FormatException(code);
}

void _onlyKeys(
  Map<String, dynamic> json,
  Set<String> allowed,
  String code,
) {
  if (json.keys.any((key) => !allowed.contains(key))) {
    throw FormatException(code);
  }
}

enum AcquisitionFeeStatus { unknown, known }

@immutable
class PrivateAcquisitionLot {
  final String id;
  final String isin;
  final int units;
  final String acquiredOn;
  final String currency;
  final Decimal unitPrice;
  final AcquisitionFeeStatus feeStatus;
  final Decimal? feeTotal;
  final String? brokerAccountLabel;

  PrivateAcquisitionLot({
    required this.id,
    required this.isin,
    required this.units,
    required this.acquiredOn,
    required this.currency,
    required this.unitPrice,
    required this.feeStatus,
    required this.feeTotal,
    this.brokerAccountLabel,
  }) {
    _validateId(id, 'portfolio.invalid_lot_id');
    _validateIsin(isin);
    if (units < 1 || units > 1000000000) {
      throw const FormatException('portfolio.invalid_units');
    }
    isoDate(acquiredOn);
    _validateCurrency(currency);
    if (unitPrice <= Decimal.zero) {
      throw const FormatException('portfolio.invalid_unit_price');
    }
    switch (feeStatus) {
      case AcquisitionFeeStatus.unknown:
        if (feeTotal != null) {
          throw const FormatException('portfolio.unknown_fee_has_value');
        }
        break;
      case AcquisitionFeeStatus.known:
        if (feeTotal == null || feeTotal! < Decimal.zero) {
          throw const FormatException('portfolio.known_fee_missing_value');
        }
        break;
    }
    final label = brokerAccountLabel;
    if (label != null && (label.trim().isEmpty || label.length > 160)) {
      throw const FormatException('portfolio.invalid_account_label');
    }
  }

  Decimal get grossTradeValue => unitPrice * Decimal.fromInt(units);

  Map<String, dynamic> toJson() => {
    'id': id,
    'isin': isin,
    'units': units,
    'acquiredOn': acquiredOn,
    'currency': currency,
    'unitPrice': unitPrice.toString(),
    'feeStatus': feeStatus.name,
    if (feeTotal != null) 'feeTotal': feeTotal.toString(),
    if (brokerAccountLabel != null)
      'brokerAccountLabel': brokerAccountLabel,
  };

  factory PrivateAcquisitionLot.fromJson(Map<String, dynamic> json) {
    _onlyKeys(json, const {
      'id',
      'isin',
      'units',
      'acquiredOn',
      'currency',
      'unitPrice',
      'feeStatus',
      'feeTotal',
      'brokerAccountLabel',
    }, 'portfolio.invalid_lot_fields');

    final status = _portfolioEnum(
      AcquisitionFeeStatus.values,
      json['feeStatus'],
      'portfolio.invalid_fee_status',
    );
    return PrivateAcquisitionLot(
      id: json['id'] as String? ?? '',
      isin: json['isin'] as String? ?? '',
      units: json['units'] as int? ?? 0,
      acquiredOn: _portfolioDate(json['acquiredOn']),
      currency: json['currency'] as String? ?? '',
      unitPrice: _portfolioDecimal(
        json['unitPrice'],
        code: 'portfolio.invalid_unit_price',
        allowZero: false,
      ),
      feeStatus: status,
      feeTotal: json['feeTotal'] == null
          ? null
          : _portfolioDecimal(
              json['feeTotal'],
              code: 'portfolio.invalid_fee_total',
            ),
      brokerAccountLabel: json['brokerAccountLabel'] as String?,
    );
  }
}

enum PrivateCashEventKind { coupon, redemption }

@immutable
class PrivateCashEvent {
  final String id;
  final String isin;
  final PrivateCashEventKind kind;
  final String date;
  final String currency;
  final Decimal amount;
  final int? units;
  final String? note;

  PrivateCashEvent({
    required this.id,
    required this.isin,
    required this.kind,
    required this.date,
    required this.currency,
    required this.amount,
    this.units,
    this.note,
  }) {
    _validateId(id, 'portfolio.invalid_event_id');
    _validateIsin(isin);
    isoDate(date);
    _validateCurrency(currency);
    if (amount <= Decimal.zero) {
      throw const FormatException('portfolio.invalid_event_amount');
    }
    switch (kind) {
      case PrivateCashEventKind.coupon:
        if (units != null) {
          throw const FormatException('portfolio.coupon_has_units');
        }
        break;
      case PrivateCashEventKind.redemption:
        if (units == null || units! < 1 || units! > 1000000000) {
          throw const FormatException('portfolio.redemption_units_required');
        }
        break;
    }
    final value = note;
    if (value != null && value.length > 2000) {
      throw const FormatException('portfolio.note_too_long');
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'isin': isin,
    'kind': kind.name,
    'date': date,
    'currency': currency,
    'amount': amount.toString(),
    if (units != null) 'units': units,
    if (note != null) 'note': note,
  };

  factory PrivateCashEvent.fromJson(Map<String, dynamic> json) {
    _onlyKeys(json, const {
      'id',
      'isin',
      'kind',
      'date',
      'currency',
      'amount',
      'units',
      'note',
    }, 'portfolio.invalid_event_fields');

    return PrivateCashEvent(
      id: json['id'] as String? ?? '',
      isin: json['isin'] as String? ?? '',
      kind: _portfolioEnum(
        PrivateCashEventKind.values,
        json['kind'],
        'portfolio.invalid_event_kind',
      ),
      date: _portfolioDate(json['date']),
      currency: json['currency'] as String? ?? '',
      amount: _portfolioDecimal(
        json['amount'],
        code: 'portfolio.invalid_event_amount',
        allowZero: false,
      ),
      units: json['units'] as int?,
      note: json['note'] as String?,
    );
  }
}

@immutable
class PrivateHolding {
  final String isin;
  final String currency;
  final int units;

  const PrivateHolding({
    required this.isin,
    required this.currency,
    required this.units,
  });
}

@immutable
class PrivatePortfolioPayload {
  final String portfolioId;
  final List<PrivateAcquisitionLot> acquisitionLots;
  final List<PrivateCashEvent> cashEvents;

  PrivatePortfolioPayload({
    required this.portfolioId,
    Iterable<PrivateAcquisitionLot> acquisitionLots = const [],
    Iterable<PrivateCashEvent> cashEvents = const [],
  }) : acquisitionLots = List.unmodifiable(
         acquisitionLots.toList()
           ..sort((a, b) {
             final byDate = a.acquiredOn.compareTo(b.acquiredOn);
             if (byDate != 0) return byDate;
             final byIsin = a.isin.compareTo(b.isin);
             if (byIsin != 0) return byIsin;
             return a.id.compareTo(b.id);
           }),
       ),
       cashEvents = List.unmodifiable(
         cashEvents.toList()
           ..sort((a, b) {
             final byDate = a.date.compareTo(b.date);
             if (byDate != 0) return byDate;
             final byIsin = a.isin.compareTo(b.isin);
             if (byIsin != 0) return byIsin;
             final byKind = a.kind.name.compareTo(b.kind.name);
             if (byKind != 0) return byKind;
             return a.id.compareTo(b.id);
           }),
       ) {
    _validateId(portfolioId, 'portfolio.invalid_portfolio_id');
    if (this.acquisitionLots.length > maxPrivateAcquisitionLots ||
        this.cashEvents.length > maxPrivateCashEvents) {
      throw const FormatException('portfolio.too_many_records');
    }
    _validateSemantics();
  }

  void _validateSemantics() {
    final ids = <String>{};
    for (final lot in acquisitionLots) {
      if (!ids.add(lot.id)) {
        throw const FormatException('portfolio.duplicate_record_id');
      }
    }
    for (final event in cashEvents) {
      if (!ids.add(event.id)) {
        throw const FormatException('portfolio.duplicate_record_id');
      }
    }

    final lotsByIsin = <String, List<PrivateAcquisitionLot>>{};
    for (final lot in acquisitionLots) {
      lotsByIsin.putIfAbsent(lot.isin, () => []).add(lot);
    }

    final currencyByIsin = <String, String>{};
    for (final entry in lotsByIsin.entries) {
      final currencies = entry.value.map((lot) => lot.currency).toSet();
      if (currencies.length != 1) {
        throw const FormatException('portfolio.currency_mismatch');
      }
      currencyByIsin[entry.key] = currencies.single;
    }

    for (final event in cashEvents) {
      final lots = lotsByIsin[event.isin];
      if (lots == null || lots.isEmpty) {
        throw const FormatException('portfolio.event_without_acquisition');
      }
      if (currencyByIsin[event.isin] != event.currency) {
        throw const FormatException('portfolio.currency_mismatch');
      }
      final firstAcquisition = lots.first.acquiredOn;
      if (event.date.compareTo(firstAcquisition) < 0) {
        throw const FormatException('portfolio.event_before_acquisition');
      }
    }

    for (final isin in lotsByIsin.keys) {
      final acquisitionsByDate = <String, int>{};
      for (final lot in lotsByIsin[isin]!) {
        acquisitionsByDate.update(
          lot.acquiredOn,
          (value) => value + lot.units,
          ifAbsent: () => lot.units,
        );
      }
      final redemptionsByDate = <String, int>{};
      for (final event in cashEvents.where(
        (event) =>
            event.isin == isin &&
            event.kind == PrivateCashEventKind.redemption,
      )) {
        redemptionsByDate.update(
          event.date,
          (value) => value + event.units!,
          ifAbsent: () => event.units!,
        );
      }

      final dates = <String>{
        ...acquisitionsByDate.keys,
        ...redemptionsByDate.keys,
      }.toList()..sort();

      var units = 0;
      for (final date in dates) {
        units += acquisitionsByDate[date] ?? 0;
        units -= redemptionsByDate[date] ?? 0;
        if (units < 0) {
          throw const FormatException('portfolio.redemption_exceeds_units');
        }
      }
    }
  }

  List<PrivateHolding> get holdings {
    final units = <String, int>{};
    final currency = <String, String>{};
    for (final lot in acquisitionLots) {
      units.update(
        lot.isin,
        (value) => value + lot.units,
        ifAbsent: () => lot.units,
      );
      currency[lot.isin] = lot.currency;
    }
    for (final event in cashEvents) {
      if (event.kind == PrivateCashEventKind.redemption) {
        units.update(event.isin, (value) => value - event.units!);
      }
    }

    final result = units.entries
        .where((entry) => entry.value > 0)
        .map(
          (entry) => PrivateHolding(
            isin: entry.key,
            currency: currency[entry.key]!,
            units: entry.value,
          ),
        )
        .toList()
      ..sort((a, b) => a.isin.compareTo(b.isin));
    return List.unmodifiable(result);
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': privatePortfolioSchemaVersion,
    'portfolioId': portfolioId,
    'acquisitionLots': acquisitionLots.map((lot) => lot.toJson()).toList(),
    'cashEvents': cashEvents.map((event) => event.toJson()).toList(),
  };

  factory PrivatePortfolioPayload.fromJson(Map<String, dynamic> json) {
    _onlyKeys(json, const {
      'schemaVersion',
      'portfolioId',
      'acquisitionLots',
      'cashEvents',
    }, 'portfolio.invalid_payload_fields');
    if (json['schemaVersion'] != privatePortfolioSchemaVersion) {
      throw const FormatException('portfolio.unsupported_schema');
    }
    final rawLots = json['acquisitionLots'];
    final rawEvents = json['cashEvents'];
    if (rawLots is! List || rawEvents is! List) {
      throw const FormatException('portfolio.invalid_payload');
    }

    return PrivatePortfolioPayload(
      portfolioId: json['portfolioId'] as String? ?? '',
      acquisitionLots: rawLots.map((value) {
        if (value is! Map) {
          throw const FormatException('portfolio.invalid_lot');
        }
        return PrivateAcquisitionLot.fromJson(
          Map<String, dynamic>.from(value),
        );
      }),
      cashEvents: rawEvents.map((value) {
        if (value is! Map) {
          throw const FormatException('portfolio.invalid_event');
        }
        return PrivateCashEvent.fromJson(
          Map<String, dynamic>.from(value),
        );
      }),
    );
  }
}

abstract final class PrivatePortfolioPayloadCodec {
  static Uint8List encode(PrivatePortfolioPayload payload) =>
      Uint8List.fromList(utf8.encode(jsonEncode(payload.toJson())));

  static PrivatePortfolioPayload decode(Uint8List bytes) {
    if (bytes.isEmpty || bytes.length > maxPrivatePortfolioBytes) {
      throw const FormatException('portfolio.invalid_payload_size');
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map) {
        throw const FormatException('portfolio.invalid_payload');
      }
      return PrivatePortfolioPayload.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('portfolio.invalid_payload');
    }
  }
}
