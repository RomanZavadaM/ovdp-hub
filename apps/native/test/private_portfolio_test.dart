import 'dart:io';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/portfolio/private_portfolio.dart';
import 'package:ovdp_hub/security/vault_crypto.dart';
import 'package:ovdp_hub/security/vault_device_key_store.dart';
import 'package:ovdp_hub/security/vault_store.dart';
import 'package:path/path.dart' as p;

class MemoryVaultDeviceKeyStore implements VaultDeviceKeyStore {
  final Map<String, Uint8List> keys = {};
  final Map<String, int> revisions = {};

  @override
  Future<void> storeDek({
    required String vaultId,
    required Uint8List dek,
  }) async {
    if (keys.containsKey(vaultId)) {
      throw StateError('vault.device_key_exists');
    }
    validateDekBytes(dek);
    keys[vaultId] = Uint8List.fromList(dek);
  }

  @override
  Future<Uint8List?> loadDek({required String vaultId}) async {
    final value = keys[vaultId];
    return value == null ? null : Uint8List.fromList(value);
  }

  @override
  Future<void> deleteDek({required String vaultId}) async {
    keys.remove(vaultId);
    revisions.remove(vaultId);
  }

  @override
  Future<int?> loadHighestAcceptedRevision({required String vaultId}) async =>
      revisions[vaultId];

  @override
  Future<void> storeHighestAcceptedRevision({
    required String vaultId,
    required int revision,
  }) async {
    validateRevision(revision);
    final previous = revisions[vaultId];
    if (previous != null && revision < previous) {
      throw StateError('vault.revision_regression');
    }
    revisions[vaultId] = revision;
  }
}

PrivateAcquisitionLot lot({
  required String id,
  required String isin,
  required int units,
  required String date,
  String currency = 'UAH',
  String tradeAmount = '1000',
  AcquisitionFeeStatus feeStatus = AcquisitionFeeStatus.known,
  String? fee = '0',
  String? account,
}) =>
    PrivateAcquisitionLot(
      id: id,
      isin: isin,
      units: units,
      acquiredOn: date,
      currency: currency,
      tradeAmount: Decimal.parse(tradeAmount),
      feeStatus: feeStatus,
      feeTotal: fee == null ? null : Decimal.parse(fee),
      brokerAccountLabel: account,
    );

PrivateCashEvent event({
  required String id,
  required String isin,
  required PrivateCashEventKind kind,
  required String date,
  String currency = 'UAH',
  String amount = '100',
  int? units,
}) =>
    PrivateCashEvent(
      id: id,
      isin: isin,
      kind: kind,
      date: date,
      currency: currency,
      amount: Decimal.parse(amount),
      units: units,
    );

PrivateDisposal disposal({
  required String id,
  required String isin,
  required String date,
  required int units,
  required List<PrivateDisposalLotAllocation> allocations,
  String currency = 'UAH',
  String proceeds = '1000',
  DisposalFeeStatus feeStatus = DisposalFeeStatus.known,
  String? fee = '0',
  String? note,
}) =>
    PrivateDisposal(
      id: id,
      isin: isin,
      disposedOn: date,
      units: units,
      currency: currency,
      proceedsAmount: Decimal.parse(proceeds),
      feeStatus: feeStatus,
      feeTotal: fee == null ? null : Decimal.parse(fee),
      allocations: allocations,
      note: note,
    );

void main() {
  const isinA = 'UA4000221111';
  const isinB = 'UA4000222222';

  test('payload encoding is deterministic regardless input order', () {
    final lot1 = lot(
      id: 'lot-1',
      isin: isinA,
      units: 10,
      date: '2026-01-15',
      account: 'Broker A',
    );
    final lot2 = lot(
      id: 'lot-2',
      isin: isinB,
      units: 4,
      date: '2025-12-01',
      currency: 'USD',
      tradeAmount: '3961.00',
      fee: null,
      feeStatus: AcquisitionFeeStatus.unknown,
    );
    final coupon = event(
      id: 'event-coupon',
      isin: isinA,
      kind: PrivateCashEventKind.coupon,
      date: '2026-06-01',
      amount: '42.50',
    );

    final first = PrivatePortfolioPayload(
      portfolioId: 'portfolio-main',
      acquisitionLots: [lot1, lot2],
      cashEvents: [coupon],
    );
    final second = PrivatePortfolioPayload(
      portfolioId: 'portfolio-main',
      acquisitionLots: [lot2, lot1],
      cashEvents: [coupon],
    );

    final encodedFirst = PrivatePortfolioPayloadCodec.encode(first);
    final encodedSecond = PrivatePortfolioPayloadCodec.encode(second);
    expect(encodedFirst, encodedSecond);

    final decoded = PrivatePortfolioPayloadCodec.decode(encodedFirst);
    expect(decoded.portfolioId, 'portfolio-main');
    expect(decoded.acquisitionLots.map((e) => e.id), ['lot-2', 'lot-1']);
    expect(decoded.cashEvents.single.id, 'event-coupon');
  });

  test('known zero fee is distinct from unknown fee', () {
    final knownZero = lot(
      id: 'known-zero',
      isin: isinA,
      units: 1,
      date: '2026-01-01',
      feeStatus: AcquisitionFeeStatus.known,
      fee: '0',
    );
    final unknown = lot(
      id: 'unknown',
      isin: isinA,
      units: 1,
      date: '2026-01-02',
      feeStatus: AcquisitionFeeStatus.unknown,
      fee: null,
    );

    expect(knownZero.feeTotal, Decimal.zero);
    expect(unknown.feeTotal, isNull);
    expect(knownZero.toJson().containsKey('feeTotal'), true);
    expect(unknown.toJson().containsKey('feeTotal'), false);

    expect(
      () => PrivateAcquisitionLot(
        id: 'invalid-known',
        isin: isinA,
        units: 1,
        acquiredOn: '2026-01-03',
        currency: 'UAH',
        tradeAmount: Decimal.parse('1000'),
        feeStatus: AcquisitionFeeStatus.known,
        feeTotal: null,
      ),
      throwsFormatException,
    );
  });

  test('record IDs are globally unique across lots and cash events', () {
    expect(
      () => PrivatePortfolioPayload(
        portfolioId: 'portfolio-duplicate',
        acquisitionLots: [
          lot(
            id: 'record-1',
            isin: isinA,
            units: 2,
            date: '2026-01-01',
          ),
        ],
        cashEvents: [
          event(
            id: 'record-1',
            isin: isinA,
            kind: PrivateCashEventKind.coupon,
            date: '2026-02-01',
          ),
        ],
      ),
      throwsFormatException,
    );
  });

  test('cash events require acquired instrument and matching currency', () {
    expect(
      () => PrivatePortfolioPayload(
        portfolioId: 'portfolio-no-lot',
        cashEvents: [
          event(
            id: 'event-1',
            isin: isinA,
            kind: PrivateCashEventKind.coupon,
            date: '2026-02-01',
          ),
        ],
      ),
      throwsFormatException,
    );

    expect(
      () => PrivatePortfolioPayload(
        portfolioId: 'portfolio-currency',
        acquisitionLots: [
          lot(
            id: 'lot-1',
            isin: isinA,
            units: 2,
            date: '2026-01-01',
          ),
        ],
        cashEvents: [
          event(
            id: 'event-1',
            isin: isinA,
            kind: PrivateCashEventKind.coupon,
            date: '2026-02-01',
            currency: 'USD',
          ),
        ],
      ),
      throwsFormatException,
    );
  });

  test('redemption cannot precede acquisition or make holdings negative', () {
    expect(
      () => PrivatePortfolioPayload(
        portfolioId: 'portfolio-before',
        acquisitionLots: [
          lot(
            id: 'lot-1',
            isin: isinA,
            units: 2,
            date: '2026-02-01',
          ),
        ],
        cashEvents: [
          event(
            id: 'redemption-1',
            isin: isinA,
            kind: PrivateCashEventKind.redemption,
            date: '2026-01-01',
            units: 1,
          ),
        ],
      ),
      throwsFormatException,
    );

    expect(
      () => PrivatePortfolioPayload(
        portfolioId: 'portfolio-negative',
        acquisitionLots: [
          lot(
            id: 'lot-1',
            isin: isinA,
            units: 2,
            date: '2026-01-01',
          ),
        ],
        cashEvents: [
          event(
            id: 'redemption-1',
            isin: isinA,
            kind: PrivateCashEventKind.redemption,
            date: '2026-03-01',
            units: 3,
          ),
        ],
      ),
      throwsFormatException,
    );
  });

  test('holdings are derived from acquisitions minus represented redemptions', () {
    final payload = PrivatePortfolioPayload(
      portfolioId: 'portfolio-holdings',
      acquisitionLots: [
        lot(
          id: 'lot-a1',
          isin: isinA,
          units: 10,
          date: '2026-01-01',
        ),
        lot(
          id: 'lot-a2',
          isin: isinA,
          units: 5,
          date: '2026-02-01',
        ),
        lot(
          id: 'lot-b1',
          isin: isinB,
          units: 3,
          date: '2026-01-10',
          currency: 'USD',
        ),
      ],
      cashEvents: [
        event(
          id: 'coupon-a',
          isin: isinA,
          kind: PrivateCashEventKind.coupon,
          date: '2026-03-01',
        ),
        event(
          id: 'redemption-a',
          isin: isinA,
          kind: PrivateCashEventKind.redemption,
          date: '2026-04-01',
          units: 4,
          amount: '4000',
        ),
        event(
          id: 'redemption-b',
          isin: isinB,
          kind: PrivateCashEventKind.redemption,
          date: '2026-05-01',
          currency: 'USD',
          units: 3,
          amount: '3000',
        ),
      ],
    );

    expect(payload.holdings, hasLength(1));
    expect(payload.holdings.single.isin, isinA);
    expect(payload.holdings.single.currency, 'UAH');
    expect(payload.holdings.single.units, 11);
  });

  test('schema v1 payload decodes compatibly and re-encodes as v2', () {
    final legacy = Uint8List.fromList(
      '{"schemaVersion":1,"portfolioId":"legacy","acquisitionLots":[{"id":"lot-legacy","isin":"$isinA","units":2,"acquiredOn":"2026-01-01","currency":"UAH","tradeAmount":"2000","feeStatus":"known","feeTotal":"0"}],"cashEvents":[]}'
          .codeUnits,
    );

    final decoded = PrivatePortfolioPayloadCodec.decode(legacy);
    expect(decoded.portfolioId, 'legacy');
    expect(decoded.disposals, isEmpty);
    expect(decoded.holdings.single.units, 2);

    final reencoded = String.fromCharCodes(
      PrivatePortfolioPayloadCodec.encode(decoded),
    );
    expect(reencoded, contains('"schemaVersion":2'));
    expect(reencoded, contains('"disposals":[]'));
  });

  test('disposal allocation order is deterministic and holdings subtract sales', () {
    final payload = PrivatePortfolioPayload(
      portfolioId: 'portfolio-sale',
      acquisitionLots: [
        lot(
          id: 'lot-a2',
          isin: isinA,
          units: 5,
          date: '2026-02-01',
          tradeAmount: '5050',
          fee: '5',
        ),
        lot(
          id: 'lot-a1',
          isin: isinA,
          units: 10,
          date: '2026-01-01',
          tradeAmount: '10000',
          fee: '10',
        ),
      ],
      disposals: [
        disposal(
          id: 'sale-1',
          isin: isinA,
          date: '2026-03-01',
          units: 6,
          proceeds: '6600',
          fee: '12',
          allocations: [
            PrivateDisposalLotAllocation(lotId: 'lot-a2', units: 2),
            PrivateDisposalLotAllocation(lotId: 'lot-a1', units: 4),
          ],
        ),
      ],
    );

    expect(payload.holdings.single.units, 9);
    expect(
      payload.disposals.single.allocations.map((value) => value.lotId),
      ['lot-a1', 'lot-a2'],
    );
    expect(payload.disposals.single.knownNetProceeds, Decimal.parse('6588'));

    final inputs = payload.realizedCostInputsFor('sale-1');
    expect(inputs.map((value) => value.lotId), ['lot-a1', 'lot-a2']);
    expect(inputs[0].allocatedUnits, 4);
    expect(inputs[0].lotUnits, 10);
    expect(inputs[0].lotTradeAmount, Decimal.parse('10000'));
    expect(inputs[0].acquisitionFeeStatus, AcquisitionFeeStatus.known);
    expect(inputs[0].lotFeeTotal, Decimal.parse('10'));

    final first = PrivatePortfolioPayloadCodec.encode(payload);
    final reordered = PrivatePortfolioPayload(
      portfolioId: 'portfolio-sale',
      acquisitionLots: payload.acquisitionLots.reversed,
      disposals: [
        disposal(
          id: 'sale-1',
          isin: isinA,
          date: '2026-03-01',
          units: 6,
          proceeds: '6600',
          fee: '12',
          allocations: [
            PrivateDisposalLotAllocation(lotId: 'lot-a1', units: 4),
            PrivateDisposalLotAllocation(lotId: 'lot-a2', units: 2),
          ],
        ),
      ],
    );
    expect(first, PrivatePortfolioPayloadCodec.encode(reordered));
  });

  test('unknown disposal fee is not silently converted to zero', () {
    final value = disposal(
      id: 'sale-unknown-fee',
      isin: isinA,
      date: '2026-02-01',
      units: 1,
      proceeds: '1100',
      feeStatus: DisposalFeeStatus.unknown,
      fee: null,
      allocations: [
        PrivateDisposalLotAllocation(lotId: 'lot-1', units: 1),
      ],
    );
    expect(value.feeTotal, isNull);
    expect(value.knownNetProceeds, isNull);
    expect(value.toJson().containsKey('feeTotal'), false);

    expect(
      () => disposal(
        id: 'invalid-unknown-fee',
        isin: isinA,
        date: '2026-02-01',
        units: 1,
        feeStatus: DisposalFeeStatus.unknown,
        fee: '0',
        allocations: [
          PrivateDisposalLotAllocation(lotId: 'lot-1', units: 1),
        ],
      ),
      throwsFormatException,
    );
  });

  test('disposals require exact factual allocations to existing matching lots', () {
    final baseLots = [
      lot(
        id: 'lot-a',
        isin: isinA,
        units: 5,
        date: '2026-01-01',
      ),
      lot(
        id: 'lot-b',
        isin: isinB,
        units: 5,
        date: '2026-01-01',
        currency: 'USD',
      ),
    ];

    expect(
      () => disposal(
        id: 'bad-sum',
        isin: isinA,
        date: '2026-02-01',
        units: 3,
        allocations: [
          PrivateDisposalLotAllocation(lotId: 'lot-a', units: 2),
        ],
      ),
      throwsFormatException,
    );

    expect(
      () => PrivatePortfolioPayload(
        portfolioId: 'unknown-lot',
        acquisitionLots: baseLots,
        disposals: [
          disposal(
            id: 'sale-unknown',
            isin: isinA,
            date: '2026-02-01',
            units: 1,
            allocations: [
              PrivateDisposalLotAllocation(lotId: 'missing', units: 1),
            ],
          ),
        ],
      ),
      throwsFormatException,
    );

    expect(
      () => PrivatePortfolioPayload(
        portfolioId: 'wrong-isin-lot',
        acquisitionLots: baseLots,
        disposals: [
          disposal(
            id: 'sale-wrong',
            isin: isinA,
            date: '2026-02-01',
            units: 1,
            allocations: [
              PrivateDisposalLotAllocation(lotId: 'lot-b', units: 1),
            ],
          ),
        ],
      ),
      throwsFormatException,
    );

    expect(
      () => PrivatePortfolioPayload(
        portfolioId: 'future-lot',
        acquisitionLots: [
          lot(
            id: 'future',
            isin: isinA,
            units: 5,
            date: '2026-03-01',
          ),
        ],
        disposals: [
          disposal(
            id: 'sale-before-lot',
            isin: isinA,
            date: '2026-02-01',
            units: 1,
            allocations: [
              PrivateDisposalLotAllocation(lotId: 'future', units: 1),
            ],
          ),
        ],
      ),
      throwsFormatException,
    );
  });

  test('same acquisition lot cannot be overallocated across disposals', () {
    expect(
      () => PrivatePortfolioPayload(
        portfolioId: 'overallocation',
        acquisitionLots: [
          lot(
            id: 'lot-1',
            isin: isinA,
            units: 5,
            date: '2026-01-01',
          ),
        ],
        disposals: [
          disposal(
            id: 'sale-1',
            isin: isinA,
            date: '2026-02-01',
            units: 3,
            allocations: [
              PrivateDisposalLotAllocation(lotId: 'lot-1', units: 3),
            ],
          ),
          disposal(
            id: 'sale-2',
            isin: isinA,
            date: '2026-03-01',
            units: 3,
            allocations: [
              PrivateDisposalLotAllocation(lotId: 'lot-1', units: 3),
            ],
          ),
        ],
      ),
      throwsFormatException,
    );
  });

  test('disposal after represented redemption fails closed without redemption allocation', () {
    expect(
      () => PrivatePortfolioPayload(
        portfolioId: 'post-redemption-sale',
        acquisitionLots: [
          lot(
            id: 'lot-1',
            isin: isinA,
            units: 10,
            date: '2026-01-01',
          ),
        ],
        cashEvents: [
          event(
            id: 'redemption-1',
            isin: isinA,
            kind: PrivateCashEventKind.redemption,
            date: '2026-02-01',
            units: 2,
            amount: '2000',
          ),
        ],
        disposals: [
          disposal(
            id: 'sale-after-redemption',
            isin: isinA,
            date: '2026-03-01',
            units: 2,
            allocations: [
              PrivateDisposalLotAllocation(lotId: 'lot-1', units: 2),
            ],
          ),
        ],
      ),
      throwsFormatException,
    );
  });

  test('codec rejects unknown schema and unknown fields', () {
    expect(
      () => PrivatePortfolioPayloadCodec.decode(
        Uint8List.fromList(
          '{"schemaVersion":3,"portfolioId":"p","acquisitionLots":[],"cashEvents":[],"disposals":[]}'
              .codeUnits,
        ),
      ),
      throwsFormatException,
    );

    expect(
      () => PrivatePortfolioPayloadCodec.decode(
        Uint8List.fromList(
          '{"schemaVersion":1,"portfolioId":"p","acquisitionLots":[],"cashEvents":[],"future":true}'
              .codeUnits,
        ),
      ),
      throwsFormatException,
    );
  });

  test('private payload round-trips through encrypted LocalVaultStore', () async {
    final root = await Directory.systemTemp.createTemp('ovdp-private-payload-');
    addTearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });

    final crypto = await SodiumVaultCrypto.create();
    final device = MemoryVaultDeviceKeyStore();
    final store = LocalVaultStore(
      directory: Directory(p.join(root.path, 'active')),
      crypto: crypto,
      deviceKeyStore: device,
    );
    final payload = PrivatePortfolioPayload(
      portfolioId: 'portfolio-secret',
      acquisitionLots: [
        lot(
          id: 'lot-secret',
          isin: isinA,
          units: 7,
          date: '2026-01-01',
          tradeAmount: '7086.38',
          fee: '15.75',
          account: 'Private Broker Account',
        ),
      ],
      cashEvents: [
        event(
          id: 'coupon-secret',
          isin: isinA,
          kind: PrivateCashEventKind.coupon,
          date: '2026-06-01',
          amount: '123.45',
        ),
      ],
    );

    await store.create(
      vaultId: 'vault-private-payload',
      plainText: PrivatePortfolioPayloadCodec.encode(payload),
      recoverySecret: 'portable payload recovery secret',
      recoveryParameters: VaultRecoveryKdfParameters.interactive,
    );

    final physical = await store.fileFor('vault-private-payload').readAsString();
    expect(physical, isNot(contains('portfolio-secret')));
    expect(physical, isNot(contains(isinA)));
    expect(physical, isNot(contains('Private Broker Account')));

    final opened = await store.open(vaultId: 'vault-private-payload');
    final decoded = PrivatePortfolioPayloadCodec.decode(opened.plainText);
    opened.plainText.fillRange(0, opened.plainText.length, 0);

    expect(decoded.portfolioId, 'portfolio-secret');
    expect(decoded.acquisitionLots.single.id, 'lot-secret');
    expect(decoded.cashEvents.single.id, 'coupon-secret');
    expect(decoded.holdings.single.units, 7);
  });
}
