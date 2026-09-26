import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../features/economy/economic_pulse_model.dart';
import '../features/market/minfin_repository.dart';
import '../models.dart';
import '../platform/mobile_external_storage.dart';
import '../platform/mobile_external_workspace.dart';
import '../workspace.dart';

@immutable
class WorkspaceSnapshot {
  final String path;
  final String? localPath;
  final bool external;
  final Catalog catalog;
  final List<SavedSet> sets;

  WorkspaceSnapshot(
    this.path,
    this.catalog,
    Iterable<SavedSet> sets, {
    this.localPath,
    this.external = false,
  }) : sets = List.unmodifiable(sets);
}

abstract interface class HubRepository {
  Stream<WorkspaceSnapshot> get changes;
  WorkspaceSnapshot? get current;
  bool get supportsExternalFolders;
  Future<void> initialize();
  Future<bool> chooseWorkspace({bool copy = false});
  Future<void> refreshCatalog();
  Future<void> reloadCollections();
  Future<void> saveCollection(SavedSet collection);
  Future<String> saveTextExport(String fileName, String content);
  Future<EconomicPulseSnapshot> loadEconomicPulse();
  Future<void> dispose();
}

class FileHubRepository implements HubRepository {
  final http.Client _client;
  final MobileExternalStorage _mobileExternalStorage;
  final _changes = StreamController<WorkspaceSnapshot>.broadcast(sync: true);
  Future<void> _tail = Future.value();
  Workspace? _workspace;
  MobileExternalWorkspace? _mobileWorkspace;
  WorkspaceSnapshot? _current;
  bool _disposed = false;

  FileHubRepository({
    http.Client? client,
    MobileExternalStorage mobileExternalStorage =
        const MethodChannelMobileExternalStorage(),
  }) : _client = client ?? http.Client(),
       _mobileExternalStorage = mobileExternalStorage;

  @override
  Stream<WorkspaceSnapshot> get changes => _changes.stream;

  @override
  WorkspaceSnapshot? get current => _current;

  @override
  bool get supportsExternalFolders =>
      Platform.isWindows ||
      Platform.isMacOS ||
      Platform.isLinux ||
      _mobileExternalStorage.supported;

  // Switches and writes share a queue. An in-flight save cannot land in a
  // different workspace, and switching never publishes a half-loaded session.
  Future<T> _exclusive<T>(Future<T> Function() operation) {
    final result = _tail.then((_) {
      if (_disposed) throw StateError('workspace.closed');
      return operation();
    });
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<File> _settings() async => File(
    p.join(
      (await getApplicationSupportDirectory()).path,
      'workspace-path.json',
    ),
  );

  void _publish(WorkspaceSnapshot snapshot) {
    _current = snapshot;
    if (!_disposed) _changes.add(snapshot);
  }

  Future<Map<String, dynamic>?> _readSettings() async {
    final config = await _settings();
    if (!await config.exists()) return null;
    final decoded = jsonDecode(await config.readAsString());
    if (decoded is! Map) {
      throw const FormatException('workspace.settings_invalid');
    }
    return Map<String, dynamic>.from(decoded);
  }

  Future<void> _writeSettings(Map<String, Object?> value) async {
    final config = await _settings();
    await config.parent.create(recursive: true);
    final temporary = File('${config.path}.pending');
    try {
      await temporary.writeAsString(jsonEncode(value), flush: true);
      if (await config.exists()) await config.delete();
      await temporary.rename(config.path);
    } finally {
      if (await temporary.exists()) await temporary.delete();
    }
  }

  Future<Catalog> _catalogOrBootstrap({
    required Future<Catalog?> Function() read,
    required Future<void> Function(Catalog) save,
  }) async {
    var catalog = await read();
    if (catalog == null) {
      catalog = Catalog.parse(
        await rootBundle.loadString('assets/nbu-snapshot.json'),
      );
      await save(catalog);
    }
    return catalog;
  }

  Future<void> _activateLocal(Workspace candidate, {bool persist = true}) async {
    final catalog = await _catalogOrBootstrap(
      read: candidate.catalog,
      save: candidate.saveCatalog,
    );
    final sets = await candidate.sets();
    if (persist) {
      await _writeSettings({'path': candidate.directory.path});
    }
    _workspace = candidate;
    _mobileWorkspace = null;
    _publish(
      WorkspaceSnapshot(
        candidate.directory.path,
        catalog,
        sets,
        localPath: candidate.directory.path,
      ),
    );
  }

  Future<void> _activateMobile(
    MobileExternalWorkspace candidate, {
    bool persist = true,
  }) async {
    final catalog = await _catalogOrBootstrap(
      read: candidate.catalog,
      save: candidate.saveCatalog,
    );
    final sets = await candidate.sets();
    if (persist) {
      await _writeSettings({
        'kind': 'mobile-external',
        'grantId': candidate.grant.id,
        'label': candidate.grant.label,
      });
    }
    _workspace = null;
    _mobileWorkspace = candidate;
    _publish(
      WorkspaceSnapshot(
        candidate.displayLocation,
        catalog,
        sets,
        external: true,
      ),
    );
  }

  Future<Catalog?> _readCatalog() {
    final mobile = _mobileWorkspace;
    if (mobile != null) return mobile.catalog();
    final local = _workspace;
    if (local != null) return local.catalog();
    throw StateError('workspace.not_open');
  }

  Future<List<SavedSet>> _readSets() {
    final mobile = _mobileWorkspace;
    if (mobile != null) return mobile.sets();
    final local = _workspace;
    if (local != null) return local.sets();
    throw StateError('workspace.not_open');
  }

  Future<void> _saveCatalog(Catalog catalog) {
    final mobile = _mobileWorkspace;
    if (mobile != null) return mobile.saveCatalog(catalog);
    final local = _workspace;
    if (local != null) return local.saveCatalog(catalog);
    throw StateError('workspace.not_open');
  }

  Future<void> _saveSet(SavedSet set) {
    final mobile = _mobileWorkspace;
    if (mobile != null) return mobile.saveSet(set);
    final local = _workspace;
    if (local != null) return local.saveSet(set);
    throw StateError('workspace.not_open');
  }

  Future<String> _writeTextExport(String fileName, String content) {
    final mobile = _mobileWorkspace;
    if (mobile != null) return mobile.writeTextExport(fileName, content);
    final local = _workspace;
    if (local != null) return local.writeTextExport(fileName, content);
    throw StateError('workspace.not_open');
  }

  @override
  Future<void> initialize() => _exclusive(() async {
    final saved = await _readSettings();
    if (saved?['kind'] == 'mobile-external') {
      if (!_mobileExternalStorage.supported) {
        throw UnsupportedError('workspace.external_unsupported');
      }
      final grantId = saved?['grantId'];
      final label = saved?['label'];
      if (grantId is! String || label is! String) {
        throw const FormatException('workspace.settings_invalid');
      }
      final candidate = await MobileExternalWorkspace.open(
        storage: _mobileExternalStorage,
        grant: ExternalFolderGrant(id: grantId, label: label),
      );
      await _activateMobile(candidate, persist: false);
      return;
    }

    final savedPath = saved?['path'];
    if (savedPath != null && savedPath is! String) {
      throw const FormatException('workspace.settings_invalid');
    }
    final defaultPath = p.join(
      (await getApplicationSupportDirectory()).path,
      'OVDP Hub',
    );
    await _activateLocal(
      await Workspace.open(
        Directory(savedPath as String? ?? defaultPath),
        create: savedPath == null,
      ),
      persist: savedPath == null,
    );
  });

  @override
  Future<bool> chooseWorkspace({bool copy = false}) => _exclusive(() async {
    if (!supportsExternalFolders) {
      throw UnsupportedError('workspace.external_unsupported');
    }

    if (_mobileExternalStorage.supported) {
      final grant = await _mobileExternalStorage.chooseWorkspaceFolder();
      if (grant == null) return false;

      if (copy) {
        var alreadyWorkspace = false;
        try {
          await MobileExternalWorkspace.open(
            storage: _mobileExternalStorage,
            grant: grant,
          );
          alreadyWorkspace = true;
        } on StateError catch (error) {
          if (error.message != 'workspace.empty_or_hub_required') rethrow;
        }
        if (alreadyWorkspace) {
          throw StateError('workspace.destination_empty');
        }
      }

      final candidate = await MobileExternalWorkspace.open(
        storage: _mobileExternalStorage,
        grant: grant,
        create: true,
      );
      if (copy) {
        final snapshot = current ?? (throw StateError('workspace.not_open'));
        await candidate.copySnapshot(
          catalog: snapshot.catalog,
          sets: snapshot.sets,
        );
      }
      await _activateMobile(candidate);
      return true;
    }

    final path = await getDirectoryPath();
    if (path == null) return false;
    final Workspace candidate;
    if (copy) {
      final local = _workspace;
      if (local != null) {
        candidate = await local.copyTo(Directory(path));
      } else {
        candidate = await Workspace.open(Directory(path), create: true);
        final snapshot = current ?? (throw StateError('workspace.not_open'));
        await candidate.saveCatalog(snapshot.catalog);
        for (final set in snapshot.sets.reversed) {
          await candidate.saveSet(set);
        }
      }
    } else {
      candidate = await Workspace.open(Directory(path), create: true);
    }
    await _activateLocal(candidate);
    return true;
  });

  @override
  Future<void> refreshCatalog() => _exclusive(() async {
    final response = await _client
        .get(Uri.parse('https://bank.gov.ua/depo_securities?json'))
        .timeout(const Duration(seconds: 30));
    if (response.statusCode != 200 ||
        response.bodyBytes.length > 20 * 1024 * 1024) {
      throw const FormatException('nbu.catalog_fetch_failed');
    }
    final catalog = Catalog.fromNbu(utf8.decode(response.bodyBytes));
    await _saveCatalog(catalog);
    _publish(
      WorkspaceSnapshot(
        current!.path,
        catalog,
        current!.sets,
        localPath: current!.localPath,
        external: current!.external,
      ),
    );
  });

  @override
  Future<void> reloadCollections() => _exclusive(() async {
    final sets = await _readSets();
    _publish(
      WorkspaceSnapshot(
        current!.path,
        current!.catalog,
        sets,
        localPath: current!.localPath,
        external: current!.external,
      ),
    );
  });

  @override
  Future<void> saveCollection(SavedSet collection) => _exclusive(() async {
    await _saveSet(collection);
    // A successful durable write must not be reported as a failed save merely
    // because reading some unrelated synced file fails afterwards.
    _publish(
      WorkspaceSnapshot(
        current!.path,
        current!.catalog,
        [collection, ...current!.sets],
        localPath: current!.localPath,
        external: current!.external,
      ),
    );
  });

  @override
  Future<String> saveTextExport(String fileName, String content) =>
      _exclusive(() => _writeTextExport(fileName, content));

  static const _nbuFxUrl =
      'https://bank.gov.ua/NBUStatService/v1/statdirectory/exchangenew?json';

  String _isoNbuDate(Object? raw) {
    if (raw is! String) {
      throw const FormatException('pulse.invalid_nbu_date');
    }
    final match = RegExp(r'^(\d{2})\.(\d{2})\.(\d{4})$').firstMatch(raw);
    if (match == null) {
      throw const FormatException('pulse.invalid_nbu_date');
    }
    final result = '${match.group(3)}-${match.group(2)}-${match.group(1)}';
    isoDate(result);
    return result;
  }

  Future<(EconomicFxQuote?, EconomicFxQuote?)> _safeNbuFx() async {
    try {
      final response = await _client
          .get(Uri.parse(_nbuFxUrl))
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200 ||
          response.bodyBytes.isEmpty ||
          response.bodyBytes.length > 2 * 1024 * 1024) {
        throw const FormatException('pulse.nbu_fx_fetch_failed');
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! List) {
        throw const FormatException('pulse.nbu_fx_invalid');
      }
      EconomicFxQuote? quote(String code) {
        final matches = decoded.where(
          (row) => row is Map && row['cc']?.toString().toUpperCase() == code,
        ).toList();
        if (matches.length != 1) {
          throw const FormatException('pulse.nbu_fx_invalid');
        }
        final row = Map<String, dynamic>.from(matches.single as Map);
        final rate = row['rate'];
        if (rate is! num || rate <= 0) {
          throw const FormatException('pulse.nbu_fx_invalid');
        }
        final rateText = decimalText(rate);
        return EconomicFxQuote(
          currency: code,
          rate: rateText,
          sourceDate: _isoNbuDate(row['exchangedate']),
          sourceUrl: _nbuFxUrl,
        );
      }

      return (quote('USD'), quote('EUR'));
    } catch (_) {
      return (null, null);
    }
  }

  Future<EconomicAuctionYield?> _safeUahAuctionYield(Catalog catalog) async {
    try {
      final snapshot = await MinfinRepository(client: _client).fetch();
      final currencyByIsin = {
        for (final bond in catalog.bonds) bond.isin: bond.currency,
      };
      final uah = snapshot.rates
          .where((rate) => currencyByIsin[rate.isin] == 'UAH')
          .toList();
      if (uah.isEmpty) return null;
      final latestDate = uah
          .map((rate) => rate.placementDate)
          .reduce((a, b) => a.compareTo(b) >= 0 ? a : b);
      final latest = uah
          .where((rate) => rate.placementDate == latestDate)
          .toList();
      var minRate = latest.first.rate;
      var maxRate = latest.first.rate;
      for (final rate in latest.skip(1)) {
        if (rate.rate < minRate) minRate = rate.rate;
        if (rate.rate > maxRate) maxRate = rate.rate;
      }
      return EconomicAuctionYield(
        minRate: minRate.toString(),
        maxRate: maxRate.toString(),
        sourceDate: latestDate,
        sourceUrl: snapshot.meta.sourceUrl,
      );
    } catch (_) {
      return null;
    }
  }

  Future<EconomicNextAuction?> _safeNextAuction() async {
    try {
      final snapshot = await MinfinRepository(client: _client).fetchAuctionEvents();
      final now = DateTime.now();
      final today =
          '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
      final futurePlacements = snapshot.events
          .where(
            (event) =>
                event.kind == MinfinAuctionEventKind.placement &&
                event.auctionDate.compareTo(today) >= 0,
          )
          .toList()
        ..sort((a, b) => a.auctionDate.compareTo(b.auctionDate));
      if (futurePlacements.isEmpty) return null;
      return EconomicNextAuction(
        date: futurePlacements.first.auctionDate,
        sourceUrl: snapshot.meta.sourceUrl,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<EconomicPulseSnapshot> loadEconomicPulse() async {
    var catalog = current?.catalog;
    catalog ??= Catalog.parse(
      await rootBundle.loadString('assets/nbu-snapshot.json'),
    );

    final fxFuture = _safeNbuFx();
    final yieldFuture = _safeUahAuctionYield(catalog);
    final nextAuctionFuture = _safeNextAuction();

    final fx = await fxFuture;
    final auctionYield = await yieldFuture;
    final nextAuction = await nextAuctionFuture;
    return EconomicPulseSnapshot(
      usd: fx.$1,
      eur: fx.$2,
      uahAuctionYield: auctionYield,
      nextAuction: nextAuction,
      retrievedAt: DateTime.now().toUtc().toIso8601String(),
    );
  }

  @override
  Future<void> dispose() async {
    await _tail;
    _disposed = true;
    _client.close();
    await _changes.close();
  }
}
