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
  userAssumption,
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

  Map<String, dynamic> toJson() => {
    'sourceId': sourceId,
    'sourceUrl': sourceUrl,
    if (sourceDate != null) 'sourceDate': sourceDate,
    'retrievedAt': retrievedAt,
    if (validUntil != null) 'validUntil': validUntil,
    'kind': kind.name,
    'confidence': confidence.name,
  };

  factory SourceObservationMeta.fromJson(Map<String, dynamic> json) {
    final sourceId = json['sourceId'];
    final sourceUrl = json['sourceUrl'];
    final retrievedAt = json['retrievedAt'];

    if (sourceId is! String ||
        sourceId.trim().isEmpty ||
        sourceUrl is! String ||
        sourceUrl.trim().isEmpty ||
        retrievedAt is! String ||
        DateTime.tryParse(retrievedAt) == null) {
      throw const FormatException('Некоректні метадані джерела');
    }

    final sourceDate = json['sourceDate'];
    if (sourceDate != null &&
        (sourceDate is! String ||
            !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(sourceDate) ||
            DateTime.tryParse('${sourceDate}T00:00:00Z') == null)) {
      throw const FormatException('Некоректна дата джерела');
    }

    final validUntil = json['validUntil'];
    if (validUntil != null &&
        (validUntil is! String || DateTime.tryParse(validUntil) == null)) {
      throw const FormatException('Некоректний строк дії джерела');
    }

    ObservationKind kind;
    ObservationConfidence confidence;
    try {
      kind = ObservationKind.values.byName(json['kind'] as String);
      confidence = ObservationConfidence.values.byName(
        json['confidence'] as String,
      );
    } catch (_) {
      throw const FormatException('Невідомий тип метаданих джерела');
    }

    return SourceObservationMeta(
      sourceId: sourceId,
      sourceUrl: sourceUrl,
      sourceDate: sourceDate as String?,
      retrievedAt: retrievedAt,
      validUntil: validUntil as String?,
      kind: kind,
      confidence: confidence,
    );
  }

  DataFreshness freshness(DateTime now) {
    if (sourceDate == null) return DataFreshness.unknown;
    final source = DateTime.tryParse('${sourceDate!}T00:00:00Z');
    if (source == null) return DataFreshness.unknown;
    final today = DateTime.utc(now.year, now.month, now.day);
    final date = DateTime.utc(source.year, source.month, source.day);
    if (date.isAfter(today)) return DataFreshness.futureDated;
    if (date.isBefore(today)) return DataFreshness.stale;
    return DataFreshness.current;
  }
}
