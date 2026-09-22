import 'package:flutter/material.dart';

import '../data/source_observation.dart';
import '../l10n/hub_locale.dart';

class SourceStatusBlock extends StatelessWidget {
  final SourceObservationMeta meta;
  final HubStrings strings;
  final String sourceName;
  final DateTime? now;

  const SourceStatusBlock({
    required this.meta,
    required this.strings,
    required this.sourceName,
    this.now,
    super.key,
  });

  String _freshnessText() => strings.text(
        switch (meta.freshness((now ?? DateTime.now()).toUtc())) {
          DataFreshness.current => 'freshnessCurrent',
          DataFreshness.stale => 'freshnessStale',
          DataFreshness.futureDated => 'freshnessFuture',
          DataFreshness.unknown => 'freshnessUnknown',
        },
      );

  String _confidenceText() => strings.text(
        switch (meta.confidence) {
          ObservationConfidence.officialPublished => 'confidenceOfficial',
          ObservationConfidence.publicIndicative =>
            'confidencePublicIndicative',
          ObservationConfidence.authenticatedIndicative =>
            'confidenceAuthenticatedIndicative',
          ObservationConfidence.executableConfirmed =>
            'confidenceExecutableConfirmed',
          ObservationConfidence.userAssumption => 'confidenceUserAssumption',
        },
      );

  @override
  Widget build(BuildContext context) {
    final sourceDate = meta.sourceDate ?? strings.text('notAvailable');
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${strings.text('dataSource')}: $sourceName',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text('${strings.text('sourceAsOf')}: $sourceDate'),
          Text('${strings.text('retrievedAt')}: ${meta.retrievedAt}'),
          Text('${strings.text('freshnessLabel')}: ${_freshnessText()}'),
          Text('${strings.text('confidenceLabel')}: ${_confidenceText()}'),
          const SizedBox(height: 4),
          Text(strings.text('evidenceUrl')),
          SelectableText(meta.sourceUrl),
        ],
      ),
    );
  }
}
