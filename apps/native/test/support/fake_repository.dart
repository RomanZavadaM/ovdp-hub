import 'dart:async';
import 'package:ovdp_hub/data/hub_repository.dart';
import 'package:ovdp_hub/models.dart';

class FakeRepository implements HubRepository {
  final controller = StreamController<WorkspaceSnapshot>.broadcast(sync: true);
  @override
  WorkspaceSnapshot? current;
  @override
  bool supportsExternalFolders = true;
  Object? saveError, refreshError, switchError;
  bool switchAccepted = false;
  int saves = 0, switches = 0;
  Completer<void>? gate;
  FakeRepository(Catalog catalog)
    : current = WorkspaceSnapshot('local', catalog, []);
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
      current = WorkspaceSnapshot('new', current!.catalog, []);
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
    current = WorkspaceSnapshot(current!.path, current!.catalog, [
      collection,
      ...current!.sets,
    ]);
    controller.add(current!);
  }

  @override
  Future<void> dispose() async {
    await controller.close();
  }
}
