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
import '../workspace.dart';

@immutable
class WorkspaceSnapshot {
  final String path;
  final Catalog catalog;
  final List<SavedSet> sets;
  WorkspaceSnapshot(this.path, this.catalog, Iterable<SavedSet> sets)
    : sets = List.unmodifiable(sets);
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
  final _changes = StreamController<WorkspaceSnapshot>.broadcast(sync: true);
  Future<void> _tail = Future.value();
  Workspace? _workspace;
  WorkspaceSnapshot? _current;
  bool _disposed = false;
  FileHubRepository({http.Client? client}) : _client = client ?? http.Client();
  @override
  Stream<WorkspaceSnapshot> get changes => _changes.stream;
  @override
  WorkspaceSnapshot? get current => _current;
  @override
  bool get supportsExternalFolders =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

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
  Workspace get _opened =>
      _workspace ?? (throw StateError('workspace.not_open'));
  void _publish(WorkspaceSnapshot snapshot) {
    _current = snapshot;
    if (!_disposed) _changes.add(snapshot);
  }

  Future<void> _activate(Workspace candidate) async {
    var catalog = await candidate.catalog();
    if (catalog == null) {
      catalog = Catalog.parse(
        await rootBundle.loadString('assets/nbu-snapshot.json'),
      );
      await candidate.saveCatalog(catalog);
    }
    final sets = await candidate.sets();
    final config = await _settings();
    await config.parent.create(recursive: true);
    final temporary = File('${config.path}.pending');
    await temporary.writeAsString(
      jsonEncode({'path': candidate.directory.path}),
      flush: true,
    );
    await temporary.rename(config.path);
    _workspace = candidate;
    _publish(WorkspaceSnapshot(candidate.directory.path, catalog, sets));
  }

  @override
  Future<void> initialize() => _exclusive(() async {
    final config = await _settings();
    final saved = await config.exists()
        ? (jsonDecode(await config.readAsString()) as Map)['path'] as String?
        : null;
    final defaultPath = p.join(
      (await getApplicationSupportDirectory()).path,
      'OVDP Hub',
    );
    await _activate(
      await Workspace.open(
        Directory(saved ?? defaultPath),
        create: saved == null,
      ),
    );
  });
  @override
  Future<bool> chooseWorkspace({bool copy = false}) => _exclusive(() async {
    if (!supportsExternalFolders) {
      throw UnsupportedError(
        'workspace.external_unsupported',
      );
    }
    final path = await getDirectoryPath();
    if (path == null) return false;
    final candidate = copy
        ? await _opened.copyTo(Directory(path))
        : await Workspace.open(Directory(path), create: true);
    await _activate(candidate);
    return true;
  });
  @override
  Future<void> refreshCatalog() => _exclusive(() async {
    final workspace = _opened;
    final response = await _client
        .get(Uri.parse('https://bank.gov.ua/depo_securities?json'))
        .timeout(const Duration(seconds: 30));
    if (response.statusCode != 200 ||
        response.bodyBytes.length > 20 * 1024 * 1024) {
      throw const FormatException('nbu.catalog_fetch_failed');
    }
    final catalog = Catalog.fromNbu(utf8.decode(response.bodyBytes));
    await workspace.saveCatalog(catalog);
    _publish(
      WorkspaceSnapshot(workspace.directory.path, catalog, current!.sets),
    );
  });
  @override
  Future<void> reloadCollections() => _exclusive(() async {
    final sets = await _opened.sets();
    _publish(WorkspaceSnapshot(current!.path, current!.catalog, sets));
  });
  @override
  Future<void> saveCollection(SavedSet collection) => _exclusive(() async {
    await _opened.saveSet(collection);
    // A successful durable write must not be reported as a failed save merely
    // because reading some unrelated synced file fails afterwards.
    _publish(
      WorkspaceSnapshot(current!.path, current!.catalog, [
        collection,
        ...current!.sets,
      ]),
    );
  });

  @override
  Future<String> saveTextExport(String fileName, String content) =>
      _exclusive(() => _opened.writeTextExport(fileName, content));

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
