import 'dart:convert';

import 'build_info.dart';
import 'features/appearance/appearance_cubit.dart';
import 'features/portfolio/private_portfolio.dart';
import 'l10n/hub_locale.dart';

/// User-visible capabilities this build claims. The packaged-artifact smoke
/// compares this exact list, so a release cannot silently drop a feature.
const List<String> releaseCapabilities = [
  'export.formulaSafeCsv',
  'portfolio.recoverySecretOnOpen',
  'portfolio.privatePlannerScenarios',
  'portfolio.localDeleteAndOlderRestore',
  'portfolio.expectedReceipts',
  'calculator.catalogBondAccruedYield',
  'planner.annualYield',
  'catalog.tolerantNbuFeed',
];

Map<String, Object> releaseContract() {
  final strings = HubStrings(AppLanguage.uk);
  return {
    'product': 'OVDP Hub',
    'version': appVersion,
    'build': appBuild,
    'displayVersion': appDisplayVersion,
    'privatePortfolioSchemaVersion': privatePortfolioSchemaVersion,
    'capabilities': releaseCapabilities,
    'defaultAppearance': HubAppearance.studio.name,
    'appearances': HubAppearance.values.map((mode) => mode.name).toList(),
    'appearanceLabelsUk': {
      for (final mode in HubAppearance.values)
        mode.name: strings.text(appearanceTranslationKey(mode)),
    },
  };
}

String releaseContractJson() => jsonEncode(releaseContract());
