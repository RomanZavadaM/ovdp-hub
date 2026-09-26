import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/portfolio/portfolio_gateway.dart';

void main() {
  test('encrypted Portfolio supports validated desktop and mobile platforms', () {
    expect(isEncryptedPortfolioPlatformSupported('windows'), isTrue);
    expect(isEncryptedPortfolioPlatformSupported('macos'), isTrue);
    expect(isEncryptedPortfolioPlatformSupported('android'), isTrue);
    expect(isEncryptedPortfolioPlatformSupported('ios'), isTrue);

    expect(isEncryptedPortfolioPlatformSupported('linux'), isFalse);
    expect(isEncryptedPortfolioPlatformSupported('fuchsia'), isFalse);
    expect(isEncryptedPortfolioPlatformSupported('web'), isFalse);
  });
}
