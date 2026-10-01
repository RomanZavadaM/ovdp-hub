import 'package:flutter/widgets.dart';

/// Whether an app lifecycle transition should start the portfolio background
/// grace timer.
///
/// On desktop, [AppLifecycleState.inactive] only means the window lost focus
/// (for example, the user switched to a browser for a moment). That must not
/// lock the portfolio; minimising or hiding the window still does, and the
/// inactivity timeout keeps protecting an unattended desktop session.
bool lifecycleStartsPortfolioBackgroundLock(
  AppLifecycleState state,
  TargetPlatform platform,
) {
  switch (state) {
    case AppLifecycleState.resumed:
      return false;
    case AppLifecycleState.inactive:
      return !isDesktopLifecyclePlatform(platform);
    case AppLifecycleState.hidden:
    case AppLifecycleState.paused:
    case AppLifecycleState.detached:
      return true;
  }
}

bool isDesktopLifecyclePlatform(TargetPlatform platform) => const {
  TargetPlatform.windows,
  TargetPlatform.macOS,
  TargetPlatform.linux,
}.contains(platform);
