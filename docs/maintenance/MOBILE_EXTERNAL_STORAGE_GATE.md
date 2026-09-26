# Mobile external storage gate

## Scope

Android and iOS external workspace / encrypted portable-backup access must use platform-native capabilities instead of desktop filesystem-path assumptions.

## Contracts

- Android: Storage Access Framework (SAF) with persisted read/write URI permission for workspace folders.
- iOS: security-scoped URLs/bookmarks for external folders and document-picker access for encrypted backup files.
- Dart persists only an opaque grant id and a display label; native URI/bookmark details remain native.
- Losing a persisted grant must fail closed with `workspace.external_permission_lost`; the application must not silently fall back to another folder.
- Portfolio crypto schema and financial/domain calculations remain unchanged.
- Portable backup staging is app-private and temporary; only encrypted vault bytes cross the external-storage boundary.

## Acceptance gates

1. `flutter analyze` and full test suite green.
2. Android release build succeeds with native SAF bridge.
3. iOS no-codesign release build succeeds with security-scoped bridge.
4. Contract tests cover path validation, grant loss, backup byte limits/cancellation, and repository fail-closed behavior.
5. Existing Windows/macOS behavior remains unchanged.

Status: **IN PROGRESS**.
