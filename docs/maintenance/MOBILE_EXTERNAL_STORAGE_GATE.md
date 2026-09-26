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

## Implementation / compile gate — DONE

PR **#130** merged into `main` as **`5934984a3ad763f8c9f77bd0872077c381adacc2`**.

Final docs-synced PR head: **`f6243794eea927e4b73cb85f666739d62c633e8f`**.

Run **#497 — SUCCESS**:
1. `flutter analyze` + **212/212 tests** green.
2. Android release APK build/package green.
3. iOS no-codesign release build/package green.
4. Windows/macOS packaged release smoke green.
5. Contract regressions cover traversal rejection, malformed grant ids, grant loss, byte limits/cancellation, external workspace reopen, and fail-closed permission loss.

Final #497 artifacts:
- Windows: `OVDP-Hub-0.9.3-b20-windows-497-1-e0ebc58`, SHA-256 `a7a8484354ce7500dd775e6db20efa9d38e6f940d1d479c176e59de4908bd2d5`.
- macOS: `OVDP-Hub-0.9.3-b20-macos-497-1-e0ebc58`, SHA-256 `6b45a99794c394a1e6d55ef4b8e0a332a43b063d16f951d58e49a0417036c7f9`.
- Android: `OVDP-Hub-Android-test-497-1`, SHA-256 `835e8993f91d8f03db4922bc630619a3be69dabcd0bb5ea3dd146260aa386fac`.
- iOS: `OVDP-Hub-iOS-unsigned-497-1`, SHA-256 `dfcabda484a0fb507c382eb47b3ae54e9341976f348ee077665ba5230a84e88d`.

Post-merge `main` run **#498 — SUCCESS**, verify + START/source.
START artifact: `OVDP-Hub-0.9.3-test-498-1-START`, SHA-256 `caf066800744f7b9a055f9577d59e47e5ceeaf8100569949d93cc2253f3253fd`.

## Native issues caught by the gate

- Run #488: test fake did not model new `WorkspaceSnapshot.localPath`; corrected without weakening production checks.
- Run #491: iOS compilation rejected macOS-only `.withSecurityScope` bookmark options.
- iOS bridge corrected to UIKit-compatible `.minimalBookmark` creation / `.withoutUI` resolution while retaining `startAccessingSecurityScopedResource()` for scoped access.
- Runs #496 and #497 then compiled/packaged iOS successfully.

## Remaining runtime gate — NEXT

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

For each run record:
- device model;
- OS version;
- exact build/artifact;
- selected provider/location;
- steps;
- expected vs actual outcome;
- screenshots/logs if a failure occurs.

Status: **FOUNDATION + RELEASE COMPILE GATE DONE; REAL-DEVICE RUNTIME VALIDATION NEXT**.
