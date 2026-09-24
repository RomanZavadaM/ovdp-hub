import 'dart:convert';

import 'build_info.dart';
import 'features/appearance/appearance_cubit.dart';
import 'l10n/hub_locale.dart';

Map<String, Object> releaseContract() {
  final strings = HubStrings(AppLanguage.uk);
  return {
    'product': 'OVDP Hub',
    'version': appVersion,
    'build': appBuild,
    'displayVersion': appDisplayVersion,
    'defaultAppearance': HubAppearance.studio.name,
    'appearances': HubAppearance.values.map((mode) => mode.name).toList(),
    'appearanceLabelsUk': {
      for (final mode in HubAppearance.values)
        mode.name: strings.text(appearanceTranslationKey(mode)),
    },
  };
}

String releaseContractJson() => jsonEncode(releaseContract());
