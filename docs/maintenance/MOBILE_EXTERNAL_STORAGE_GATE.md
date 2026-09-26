# Mobile external storage gate

Оновлено: **26.09.2026**

## Scope

Android and iOS external workspace / encrypted portable-backup access must use platform-native capabilities instead of desktop filesystem-path assumptions.

## Contracts

- Android: Storage Access Framework (SAF) with persisted read/write URI permission for workspace folders.
- iOS: document/folder picker + bookmarks + `startAccessingSecurityScopedResource()` for external access.
- Dart persists only opaque grant id + display label; native URI/bookmark details remain native.
- Lost persisted grant fails closed with `workspace.external_permission_lost`; no silent fallback to another folder.
- Portfolio crypto schema and financial/domain calculations remain unchanged.
- Portable backup staging is app-private and temporary; only encrypted vault bytes cross the external-storage boundary.

## Implementation / compile gate — GREEN

PR **#130**, verified implementation head **`7e26ef3cc691e683f7b9ca2a6d2c631690eb95fb`**.

Run **#496 — SUCCESS**:
1. `flutter analyze` + **212/212 tests** green.
2. Android release APK build/package green.
3. iOS no-codesign release build/package green.
4. Windows/macOS packaged release smoke green — desktop regression gate preserved.
5. Contract regressions cover traversal rejection, malformed grant ids, grant loss, byte limits/cancellation, external workspace reopen, and fail-closed permission loss.

Artifacts:
- Android: `OVDP-Hub-Android-test-496-1`, SHA-256 `6c6da1dda2489b03b174710be439434899fc5dc3151475dc5b084f507d9eb7d8`.
- iOS: `OVDP-Hub-iOS-unsigned-496-1`, SHA-256 `bf533e28070e7ed179d1078563f5eda7b0c9277f840ac67daa828686f6acf6e6`.

## Native issue caught by the gate

Ready run #491 failed iOS compilation because macOS-only `.withSecurityScope` bookmark options were used in iOS code. The bridge was corrected to UIKit-supported `.minimalBookmark` creation / `.withoutUI` resolution while retaining `startAccessingSecurityScopedResource()` for scoped access. Run #496 then compiled and packaged iOS successfully.

## Remaining runtime gate — NOT YET CLAIMED

Compile/package success is not equivalent to persistent provider access on a real phone/tablet.

Required before declaring mobile external storage fully runtime-validated:

### Android physical-device evidence
- select external folder through SAF;
- persist URI read/write permission;
- relaunch app and reopen same workspace;
- read/write/list/delete inside app-owned subtree;
- revoke/move/unmount provider access and confirm explicit fail-closed behavior.

### iOS physical-device evidence
- select folder through document picker;
- persist bookmark;
- relaunch app and resolve bookmark;
- read/write/list/delete while security scope is active;
- exercise stale/lost/provider-unavailable cases and confirm explicit fail-closed behavior.

Status: **FOUNDATION + RELEASE COMPILE GATE GREEN; REAL-DEVICE RUNTIME VALIDATION NEXT**.
