import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/portfolio/portfolio_gateway.dart';

void main() {
  test('encrypted portfolio support remains explicit by platform', () {
    for (final os in ['windows', 'android', 'ios', 'macos']) {
      expect(isEncryptedPortfolioPlatformSupported(os), isTrue, reason: os);
    }
    for (final os in ['linux', 'fuchsia', 'web']) {
      expect(isEncryptedPortfolioPlatformSupported(os), isFalse, reason: os);
    }
  });

  test('portable backup support is Windows plus mobile only', () {
    for (final os in ['windows', 'android', 'ios']) {
      expect(isPortablePortfolioBackupPlatformSupported(os), isTrue, reason: os);
    }
    for (final os in ['macos', 'linux', 'fuchsia', 'web']) {
      expect(isPortablePortfolioBackupPlatformSupported(os), isFalse, reason: os);
    }
  });
}
