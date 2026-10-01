import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/features/portfolio/portfolio_lifecycle.dart';

void main() {
  test('desktop focus loss does not start the portfolio background lock', () {
    for (final platform in [
      TargetPlatform.windows,
      TargetPlatform.macOS,
      TargetPlatform.linux,
    ]) {
      expect(
        lifecycleStartsPortfolioBackgroundLock(
          AppLifecycleState.inactive,
          platform,
        ),
        isFalse,
        reason: platform.name,
      );
      for (final state in [
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.detached,
      ]) {
        expect(
          lifecycleStartsPortfolioBackgroundLock(state, platform),
          isTrue,
          reason: '${platform.name} ${state.name}',
        );
      }
    }
  });

  test('mobile inactive still starts the portfolio background lock', () {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      expect(
        lifecycleStartsPortfolioBackgroundLock(
          AppLifecycleState.inactive,
          platform,
        ),
        isTrue,
        reason: platform.name,
      );
    }
  });

  test('resumed never starts the background lock', () {
    for (final platform in TargetPlatform.values) {
      expect(
        lifecycleStartsPortfolioBackgroundLock(
          AppLifecycleState.resumed,
          platform,
        ),
        isFalse,
      );
    }
  });
}
