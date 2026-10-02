import 'dart:convert';

dynamic freezeJson(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.unmodifiable(
      value.map((k, v) => MapEntry(k as String, freezeJson(v))),
    );
  }
  if (value is List) return List<dynamic>.unmodifiable(value.map(freezeJson));
  return value;
}

DateTime isoDate(String value) {
  final date = DateTime.tryParse('${value}T00:00:00Z');
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value) ||
      date == null ||
      date.toIso8601String().substring(0, 10) != value) {
    throw const FormatException('model.invalid_date');
  }
  return date;
}

String decimalText(Object? value) {
  final text = value.toString();
  if (!RegExp(r'^\d{1,15}(\.\d{1,10})?$').hasMatch(text)) {
    throw const FormatException('model.invalid_amount');
  }
  return text;
}

class Bond {
  final Map<String, dynamic> json;
  Bond(Map<String, dynamic> source)
    : json = freezeJson(source) as Map<String, dynamic> {
    if (!RegExp(r'^UA[A-Z0-9]{9}\d$').hasMatch(isin) ||
        !['UAH', 'USD', 'EUR'].contains(currency)) {
      throw const FormatException('model.invalid_bond');
    }
    if (!isoDate(json['issueDate'] as String).isBefore(isoDate(maturity))) {
      throw const FormatException('model.invalid_terms');
    }
    if (RegExp(r'^0+(\.0+)?$').hasMatch(decimalText(json['nominal']))) {
      throw const FormatException('model.zero_nominal');
    }
    if (json['nominalRate'] != null) decimalText(json['nominalRate']);
    for (final payment in payments) {
      isoDate(payment['date'] as String);
      decimalText(payment['amount']);
      if (![
        'COUPON',
        'REDEMPTION',
        'EARLY_REDEMPTION',
      ].contains(payment['kind'])) {
        throw const FormatException('model.unknown_payment_type');
      }
    }
  }
  String get isin => json['isin'] as String;
  String get currency => json['currency'] as String;
  String get maturity => json['maturityDate'] as String;
  String get rate => json['nominalRate']?.toString() ?? '—';
  List<Map<String, dynamic>> get payments => (json['payments'] as List)
      .map((e) => Map<String, dynamic>.from(e as Map))
      .toList();
}

class Catalog {
  final Map<String, dynamic> json;
  final List<Bond> bonds;
  Catalog._(Map<String, dynamic> source, Iterable<Bond> bonds)
    : json = freezeJson(source) as Map<String, dynamic>,
      bonds = List.unmodifiable(bonds);
  factory Catalog.parse(String content) {
    final json = jsonDecode(content) as Map<String, dynamic>;
    if (json['schemaVersion'] != 1 ||
        DateTime.tryParse(json['retrievedAt'] as String) == null) {
      throw const FormatException('catalog.unsupported');
    }
    final items = json['assets'] as List;
    if (items.isEmpty || items.length > 10000) {
      throw const FormatException('catalog.invalid_size');
    }
    final bonds = items
        .map((e) => Bond(Map<String, dynamic>.from(e as Map)))
        .toList();
    if (bonds.map((e) => e.isin).toSet().length != bonds.length) {
      throw const FormatException('catalog.duplicate_isin');
    }
    return Catalog._(json, bonds);
  }
  /// Builds a catalog from the NBU depository feed.
  ///
  /// Non-government instruments (OZDP, OMP) are excluded. A row that cannot be
  /// validated (unknown instrument or payment type, malformed amount or date)
  /// is listed in `rejected` instead of failing the whole refresh. If more
  /// than half of the government rows are rejected the feed format has most
  /// likely changed, and the refresh fails instead of silently shrinking the
  /// catalog.
  factory Catalog.fromNbu(String content, {DateTime? retrievedAt}) {
    final decoded = jsonDecode(content);
    if (decoded is! List || decoded.isEmpty || decoded.length > 10000) {
      throw const FormatException('nbu.invalid_response');
    }
    final assets = <Map<String, dynamic>>[];
    final rejected = <Map<String, String>>[];
    var excluded = 0;
    for (final raw in decoded) {
      if (raw is! Map) {
        rejected.add({'isin': '', 'reason': 'nbu.invalid_row'});
        continue;
      }
      final r = Map<String, dynamic>.from(raw);
      if (r['cptype'] == 'OZDP' || r['cptype'] == 'OMP') {
        excluded++;
        continue;
      }
      final isin = r['cpcode']?.toString() ?? '';
      if (r['cptype'] != 'DCP' || r['emit_okpo'] != '00013480') {
        rejected.add({'isin': isin, 'reason': 'nbu.unknown_instrument'});
        continue;
      }
      try {
        final asset = <String, dynamic>{
          'isin': r['cpcode'],
          'currency': r['val_code'],
          'nominal': decimalText(r['nominal']),
          'nominalRate': r['auk_proc'] == null
              ? null
              : decimalText(r['auk_proc']),
          'issueDate': r['razm_date'],
          'maturityDate': r['pgs_date'],
          'description': r['cpdescr'] ?? '',
          'couponPeriodDays': r['pay_period'],
          'payments': (r['payments'] as List)
              .map(
                (p) => {
                  'date': p['pay_date'],
                  'amount': decimalText(p['pay_val']),
                  'kind': {
                    '1': 'COUPON',
                    '2': 'REDEMPTION',
                    '3': 'EARLY_REDEMPTION',
                  }[p['pay_type'].toString()],
                },
              )
              .toList(),
        };
        Bond(asset);
        assets.add(asset);
      } on FormatException catch (error) {
        rejected.add({'isin': isin, 'reason': error.message});
      } on TypeError {
        rejected.add({'isin': isin, 'reason': 'nbu.invalid_row'});
      }
    }
    final candidates = assets.length + rejected.length;
    if (assets.isEmpty || rejected.length * 2 > candidates) {
      throw const FormatException('nbu.too_many_rejected');
    }
    return Catalog.parse(
      jsonEncode({
        'schemaVersion': 1,
        'source': 'https://bank.gov.ua/depo_securities?json',
        'sourcePage': 'https://bank.gov.ua/ua/markets/ovdp',
        'retrievedAt':
            (retrievedAt ?? DateTime.now()).toUtc().toIso8601String(),
        'sourceAsOf': null,
        'assets': assets,
        'excludedCount': excluded,
        'rejected': rejected,
      }),
    );
  }

  /// Rows of the source feed that were skipped because they failed
  /// validation, with the reason code.
  List<Map<String, dynamic>> get rejectedRows => [
    for (final row in json['rejected'] as List? ?? const [])
      Map<String, dynamic>.from(row as Map),
  ];
}

final RegExp _savedSetRecordId = RegExp(r'^[A-Za-z0-9._:-]{1,120}$');

bool isValidSavedSetRecordId(String value) =>
    _savedSetRecordId.hasMatch(value) && !value.contains('..');

class SavedSet {
  final String name, note, savedAt;
  final List<Bond> bonds;
  final Map<String, dynamic>? scenario;

  /// Where the set was read from: a workspace record file name (without
  /// `.json`) or a private vault record id. Not serialized.
  final String? recordId;

  /// True when the set lives inside the encrypted portfolio vault rather than
  /// as plaintext in the workspace folder. Not serialized.
  final bool storedInVault;

  SavedSet(
    this.name,
    this.note,
    this.savedAt,
    Iterable<Bond> bonds, {
    Map<String, dynamic>? scenario,
    this.recordId,
    this.storedInVault = false,
  }) : bonds = List.unmodifiable(bonds),
       scenario = scenario == null
           ? null
           : freezeJson(scenario) as Map<String, dynamic>;

  SavedSet withStorage({String? recordId, bool storedInVault = false}) =>
      SavedSet(
        name,
        note,
        savedAt,
        bonds,
        scenario: scenario,
        recordId: recordId,
        storedInVault: storedInVault,
      );
  Map<String, dynamic> toJson() => {
    'schemaVersion': scenario == null ? 1 : 2,
    'name': name,
    'note': note,
    'savedAt': savedAt,
    'assets': bonds.map((e) => e.json).toList(),
    if (scenario != null) 'scenario': scenario,
  };
  factory SavedSet.parse(String content) {
    final j = jsonDecode(content) as Map<String, dynamic>;
    if (!const [1, 2].contains(j['schemaVersion']) ||
        (j['schemaVersion'] == 2 && j['scenario'] is! Map) ||
        (j['name'] as String).trim().isEmpty ||
        DateTime.tryParse(j['savedAt'] as String) == null) {
      throw const FormatException('collection.invalid');
    }
    final bonds = (j['assets'] as List)
        .map((e) => Bond(Map<String, dynamic>.from(e as Map)))
        .toList();
    if (bonds.isEmpty || bonds.length > 10000) {
      throw const FormatException('collection.invalid_size');
    }
    return SavedSet(
      j['name'] as String,
      j['note'] as String,
      j['savedAt'] as String,
      bonds,
      scenario: j['scenario'] == null
          ? null
          : Map<String, dynamic>.from(j['scenario'] as Map),
    );
  }
}
