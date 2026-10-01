import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/models.dart';

Map<String, dynamic> _row(
  String isin, {
  String cptype = 'DCP',
  String okpo = '00013480',
  Object nominal = 1000,
  Object payType = 1,
  Object payValue = 59.7,
}) => {
  'cpcode': isin,
  'nominal': nominal,
  'auk_proc': 16.5,
  'pgs_date': '2028-06-21',
  'razm_date': '2025-06-25',
  'cptype': cptype,
  'cpdescr': 'Довгострокові',
  'pay_period': 182,
  'val_code': 'UAH',
  'emit_okpo': okpo,
  'payments': [
    {'pay_date': '2025-12-24', 'pay_type': payType, 'pay_val': payValue},
    {'pay_date': '2028-06-21', 'pay_type': 2, 'pay_val': 1000},
  ],
};

void main() {
  final retrievedAt = DateTime.utc(2026, 10, 1, 12);

  test('valid government rows are kept and other issuers are excluded', () {
    final catalog = Catalog.fromNbu(
      jsonEncode([
        _row('UA4000000001'),
        _row('UA4000000002'),
        _row('UA4000000003', cptype: 'OZDP', okpo: '12345678'),
      ]),
      retrievedAt: retrievedAt,
    );
    expect(catalog.bonds.map((b) => b.isin), [
      'UA4000000001',
      'UA4000000002',
    ]);
    expect(catalog.json['excludedCount'], 1);
    expect(catalog.rejectedRows, isEmpty);
    expect(catalog.json['retrievedAt'], '2026-10-01T12:00:00.000Z');
  });

  test('an unexpected row is rejected without failing the refresh', () {
    final catalog = Catalog.fromNbu(
      jsonEncode([
        _row('UA4000000001'),
        _row('UA4000000002'),
        _row('UA4000000003'),
        _row('UA4000000004', payType: 9),
        _row('UA4000000005', cptype: 'NEW'),
        _row('UA4000000006', payValue: -1),
      ]),
      retrievedAt: retrievedAt,
    );
    expect(catalog.bonds, hasLength(3));
    expect(
      catalog.rejectedRows.map((row) => row['isin']),
      ['UA4000000004', 'UA4000000005', 'UA4000000006'],
    );
    expect(
      catalog.rejectedRows.map((row) => row['reason']),
      [
        'model.unknown_payment_type',
        'nbu.unknown_instrument',
        'model.invalid_amount',
      ],
    );
  });

  test('a mostly unreadable feed fails instead of shrinking the catalog', () {
    expect(
      () => Catalog.fromNbu(
        jsonEncode([
          _row('UA4000000001'),
          _row('UA4000000002', payType: 9),
          _row('UA4000000003', cptype: 'NEW'),
        ]),
      ),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          'nbu.too_many_rejected',
        ),
      ),
    );
    expect(
      () => Catalog.fromNbu(jsonEncode(<Object>[])),
      throwsFormatException,
    );
    expect(() => Catalog.fromNbu('{"error":true}'), throwsFormatException);
  });

  test('rejected rows survive a workspace round-trip', () {
    final catalog = Catalog.fromNbu(
      jsonEncode([
        _row('UA4000000001'),
        _row('UA4000000002'),
        _row('UA4000000003', cptype: 'NEW'),
      ]),
      retrievedAt: retrievedAt,
    );
    final reparsed = Catalog.parse(jsonEncode(catalog.json));
    expect(reparsed.bonds, hasLength(2));
    expect(reparsed.rejectedRows.single['isin'], 'UA4000000003');
  });
}
