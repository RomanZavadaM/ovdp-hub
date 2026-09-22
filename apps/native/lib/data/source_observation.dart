import 'package:flutter/foundation.dart';

enum DataFreshness { current, stale, futureDated, unknown }

enum ObservationKind {
  instrument,
  primaryAuction,
  secondaryQuote,
  tariff,
  manual,
}

enum ObservationConfidence {
  publicIndicative,
  authenticatedIndicative,
  executableConfirmed,
}

@immutable
class SourceObservationMeta {
  final String sourceId;
  final String sourceUrl;
  final String? sourceDate;
  final String retrievedAt;
  final String? validUntil;
  final ObservationKind kind;
  final ObservationConfidence confidence;

  const SourceObservationMeta({
    required this.sourceId,
    required this.sourceUrl,
    required this.retrievedAt,
    required this.kind,
    required this.confidence,
    this.sourceDate,
    this.validUntil,
  });

  DataFreshness freshness(DateTime now) {
    if (sourceDate == null) return DataFreshness.unknown;
    final parts = sourceDate!.split('-');
    if (parts.length != 3) return DataFreshness.unknown;
    final source = DateTime.tryParse('${sourceDate!}T00:00:00Z');
    if (source == null) return DataFreshness.unknown;
    final today = DateTime.utc(now.year, now.month, now.day);
    final date = DateTime.utc(source.year, source.month, source.day);
    if (date.isAfter(today)) return DataFreshness.futureDated;
    if (date.isBefore(today)) return DataFreshness.stale;
    return DataFreshness.current;
  }
}
