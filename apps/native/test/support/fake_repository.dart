import 'dart:async';
import 'package:ovdp_hub/data/hub_repository.dart';
import 'package:ovdp_hub/features/economy/economic_pulse_model.dart';
import 'package:ovdp_hub/models.dart';

class FakeRepository implements HubRepository {
  final controller = StreamController<WorkspaceSnapshot>.broadcast(sync: true);
  @override
  WorkspaceSnapshot? current;
  @override
  bool supportsExternalFolders = true;
  Object? saveError, refreshError, switchError, exportError;
  bool switchAccepted = false;
  int saves = 0, switches = 0, exports = 0;
  final Map<String, String> exportedFiles = {};
  Completer<void>? gate;
  FakeRepository(Catalog catalog)
    : current = WorkspaceSnapshot(
        'local',
        catalog,
        [],
        localPath: 'local',
      );
  @override
  Stream<WorkspaceSnapshot> get changes => controller.stream;
  @override
  Future<void> initialize() async {
    controller.add(current!);
  }

  @override
  Future<bool> chooseWorkspace({bool copy = false}) async {
    switches++;
    await gate?.future;
    if (switchError != null) throw switchError!;
    if (switchAccepted) {
      current = WorkspaceSnapshot(
        'new',
        current!.catalog,
        [],
        localPath: 'new',
      );
      controller.add(current!);
    }
    return switchAccepted;
  }

  @override
  Future<void> refreshCatalog() async {
    if (refreshError != null) throw refreshError!;
    controller.add(current!);
  }

  @override
  Future<void> reloadCollections() async {
    controller.add(current!);
  }

  @override
  Future<void> saveCollection(SavedSet collection) async {
    saves++;
    await gate?.future;
    if (saveError != null) throw saveError!;
    current = WorkspaceSnapshot(
      current!.path,
      current!.catalog,
      [collection, ...current!.sets],
      localPath: current!.localPath,
      external: current!.external,
    );
    controller.add(current!);
  }

  @override
  Future<String> saveTextExport(String fileName, String content) async {
    exports++;
    if (exportError != null) throw exportError!;
    exportedFiles[fileName] = content;
    return 'local/exports/$fileName';
  }

  @override
  Future<EconomicPulseSnapshot> loadEconomicPulse() async =>
      const EconomicPulseSnapshot(
        usd: EconomicFxQuote(
          currency: 'USD',
          rate: '41.25',
          sourceDate: '2026-09-24',
          sourceUrl: 'https://bank.gov.ua/',
        ),
        eur: EconomicFxQuote(
          currency: 'EUR',
          rate: '48.50',
          sourceDate: '2026-09-24',
          sourceUrl: 'https://bank.gov.ua/',
        ),
        uahAuctionYield: EconomicAuctionYield(
          minRate: '15.10',
          maxRate: '17.20',
          sourceDate: '2026-09-22',
          sourceUrl: 'https://mof.gov.ua/',
        ),
        nextAuction: EconomicNextAuction(
          date: '2026-09-29',
          sourceUrl: 'https://mof.gov.ua/',
        ),
        retrievedAt: '2026-09-24T18:00:00Z',
      );

  @override
  Future<void> dispose() async {
    await controller.close();
  }
}
