const String appVersion = String.fromEnvironment(
  'OVDP_APP_VERSION',
  defaultValue: 'development',
);

const String appBuild = String.fromEnvironment(
  'OVDP_APP_BUILD',
  defaultValue: '',
);

String get appDisplayVersion =>
    appBuild.isEmpty ? appVersion : '$appVersion+$appBuild';
