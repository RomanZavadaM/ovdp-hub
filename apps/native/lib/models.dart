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
    throw const FormatException('Некоректна дата');
  }
  return date;
}

String decimalText(Object? value) {
  final text = value.toString();
  if (!RegExp(r'^\d{1,15}(\.\d{1,10})?$').hasMatch(text)) {
    throw const FormatException('Некоректна сума');
  }
  return text;
}

class Bond {
  final Map<String, dynamic> json;
  Bond(Map<String, dynamic> source)
    : json = freezeJson(source) as Map<String, dynamic> {
    if (!RegExp(r'^UA[A-Z0-9]{9}\d$').hasMatch(isin) ||
        !['UAH', 'USD', 'EUR'].contains(currency)) {
      throw const FormatException('Некоректний випуск');
    }
    if (!isoDate(json['issueDate'] as String).isBefore(isoDate(maturity))) {
      throw const FormatException('Некоректні строки випуску');
    }
    if (RegExp(r'^0+(\.0+)?$').hasMatch(decimalText(json['nominal']))) {
      throw const FormatException('Нульовий номінал');
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
        throw const FormatException('Невідомий тип виплати');
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
      throw const FormatException('Непідтримуваний каталог');
    }
    final items = json['assets'] as List;
    if (items.isEmpty || items.length > 10000) {
      throw const FormatException('Порожній або завеликий каталог');
    }
    final bonds = items
        .map((e) => Bond(Map<String, dynamic>.from(e as Map)))
        .toList();
    if (bonds.map((e) => e.isin).toSet().length != bonds.length) {
      throw const FormatException('Повторний ISIN');
    }
    return Catalog._(json, bonds);
  }
  factory Catalog.fromNbu(String content) {
    final rows = jsonDecode(content) as List;
    if (rows.isEmpty || rows.length > 10000) {
      throw const FormatException('Некоректна відповідь НБУ');
    }
    final assets = <Map<String, dynamic>>[];
    for (final r in rows) {
      if (r['cptype'] == 'OZDP' || r['cptype'] == 'OMP') continue;
      if (r['cptype'] != 'DCP' || r['emit_okpo'] != '00013480') {
        throw const FormatException(
          'Невідомий інструмент: попередній каталог збережено',
        );
      }
      assets.add({
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
      });
    }
    return Catalog.parse(
      jsonEncode({
        'schemaVersion': 1,
        'source': 'https://bank.gov.ua/depo_securities?json',
        'sourcePage': 'https://bank.gov.ua/ua/markets/ovdp',
        'retrievedAt': DateTime.now().toUtc().toIso8601String(),
        'sourceAsOf': null,
        'assets': assets,
      }),
    );
  }
}

class SavedSet {
  final String name, note, savedAt;
  final List<Bond> bonds;
  SavedSet(this.name, this.note, this.savedAt, Iterable<Bond> bonds)
    : bonds = List.unmodifiable(bonds);
  Map<String, dynamic> toJson() => {
    'schemaVersion': 1,
    'name': name,
    'note': note,
    'savedAt': savedAt,
    'assets': bonds.map((e) => e.json).toList(),
  };
  factory SavedSet.parse(String content) {
    final j = jsonDecode(content) as Map<String, dynamic>;
    if (j['schemaVersion'] != 1 ||
        (j['name'] as String).trim().isEmpty ||
        DateTime.tryParse(j['savedAt'] as String) == null) {
      throw const FormatException('Некоректна добірка');
    }
    final bonds = (j['assets'] as List)
        .map((e) => Bond(Map<String, dynamic>.from(e as Map)))
        .toList();
    if (bonds.isEmpty || bonds.length > 10000) {
      throw const FormatException('Некоректний розмір добірки');
    }
    return SavedSet(
      j['name'] as String,
      j['note'] as String,
      j['savedAt'] as String,
      bonds,
    );
  }
}
