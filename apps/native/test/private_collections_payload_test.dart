import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/portfolio/private_portfolio.dart';
import 'package:ovdp_hub/models.dart';

void main() {
  late Bond bond;

  setUpAll(() {
    final json =
        jsonDecode(File('assets/nbu-snapshot.json').readAsStringSync())
            as Map<String, dynamic>;
    bond = Catalog.parse(jsonEncode(json)).bonds.first;
  });

  SavedSet collection(String name) => SavedSet(
    name,
    'Private collection note',
    '2026-10-20T12:00:00Z',
    [bond],
  );

  SavedSet scenario(String name) => SavedSet(
    name,
    'Private scenario note',
    '2026-10-20T12:00:00Z',
    [bond],
    scenario: {'schemaVersion': 99, 'budget': '250000'},
  );

  test('schema v5 round-trips private collections and existing scenarios', () {
    final payload = PrivatePortfolioPayload(
      portfolioId: 'primary',
      privateCollections: [
        PrivateCollectionRecord(id: 'collection-1', set: collection('Watchlist')),
      ],
      privateScenarios: [
        PrivateScenarioRecord(id: 'scenario-1', set: scenario('Plan')),
      ],
    );

    final encoded = PrivatePortfolioPayloadCodec.encode(payload);
    final decoded = PrivatePortfolioPayloadCodec.decode(encoded);

    expect(utf8.decode(encoded), contains('"schemaVersion":5'));
    expect(decoded.privateCollections.single.id, 'collection-1');
    expect(decoded.privateCollections.single.set.name, 'Watchlist');
    expect(decoded.privateCollections.single.set.note, 'Private collection note');
    expect(decoded.privateCollections.single.set.bonds.single.isin, bond.isin);
    expect(decoded.privateScenarios.single.set.scenario!['budget'], '250000');
  });

  test('schema v1 through v4 remain readable with no private collections', () {
    final payloads = <String>[
      '{"schemaVersion":1,"portfolioId":"v1","acquisitionLots":[],"cashEvents":[]}',
      '{"schemaVersion":2,"portfolioId":"v2","acquisitionLots":[],"cashEvents":[],"disposals":[]}',
      '{"schemaVersion":3,"portfolioId":"v3","acquisitionLots":[],"cashEvents":[],"disposals":[],"legacyCollections":[]}',
      '{"schemaVersion":4,"portfolioId":"v4","acquisitionLots":[],"cashEvents":[],"disposals":[],"legacyCollections":[],"privateScenarios":[]}',
    ];

    for (final source in payloads) {
      final decoded = PrivatePortfolioPayloadCodec.decode(
        Uint8List.fromList(utf8.encode(source)),
      );
      expect(decoded.privateCollections, isEmpty);
      expect(
        utf8.decode(PrivatePortfolioPayloadCodec.encode(decoded)),
        contains('"schemaVersion":5'),
      );
    }
  });

  test('private collection rejects Planner scenarios and duplicate ids', () {
    expect(
      () => PrivateCollectionRecord(id: 'collection-1', set: scenario('Plan')),
      throwsFormatException,
    );
    expect(
      () => PrivatePortfolioPayload(
        portfolioId: 'primary',
        privateCollections: [
          PrivateCollectionRecord(id: 'same', set: collection('A')),
          PrivateCollectionRecord(id: 'same', set: collection('B')),
        ],
      ),
      throwsFormatException,
    );
  });

  test('private collection parsing is strict', () {
    final valid = PrivateCollectionRecord(
      id: 'collection-1',
      set: collection('Watchlist'),
    ).toJson();
    final withUnknownField = Map<String, dynamic>.from(valid)
      ..['unexpected'] = true;

    expect(
      () => PrivateCollectionRecord.fromJson(withUnknownField),
      throwsFormatException,
    );

    final encoded = jsonEncode({
      'schemaVersion': 5,
      'portfolioId': 'primary',
      'acquisitionLots': [],
      'cashEvents': [],
      'disposals': [],
      'legacyCollections': [],
      'privateScenarios': [],
      'privateCollections': [
        {'id': 'collection-1', 'set': scenario('Plan').toJson()},
      ],
    });
    expect(
      () => PrivatePortfolioPayloadCodec.decode(
        Uint8List.fromList(utf8.encode(encoded)),
      ),
      throwsFormatException,
    );
  });
}
