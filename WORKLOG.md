# WORKLOG — OVDP Hub

Оновлено: **26.09.2026**

Точка входу: `START_HERE.md`  
Постійні правила: `PROJECT_RULES.md`  
Підтверджений стан main: `PROJECT_STATE.md`  
Append-only ledger: GitHub Issue **#18**

> Детальні проміжні runs і невдалі спроби зберігаються в Issue #18. Тут — тільки контрольні точки, поточний PR і точний NEXT.

## Поточний опублікований checkpoint

**v0.9.3 / 0.9.3+20**

- release commit: `e2ec96322a1acb953589eeeb45e8ec50cd5d198a`;
- published GitHub prerelease: v0.9.3;
- release run #106 — success;
- published tag/assets не переписуються.

## Останній інтегрований baseline

До mobile-storage slice `main` = **`89887d39d2bb2c4e894ca09e4141161559992f7b`**.

Раніше завершено: post-v0.9.3 audit; Portfolio recovery/Windows portable backup; Planner safe date/criteria editing; catalog localization; persisted UI preferences; unified date controls; macOS Portfolio Keychain runtime validation + enablement.

## Поточний slice — mobile external storage foundation

Статус: **READY FOR FINAL DOCS-SYNC GATE; NOT MERGED YET**

Branch: `feat/mobile-external-storage`  
PR: **#130 — Mobile: add external storage foundation**

### Реалізовано

- platform-neutral `MobileExternalStorage` MethodChannel contract;
- Android SAF bridge з persisted tree grant і bounded read/write/list/delete;
- iOS document/folder picker bridge, bookmarks, `startAccessingSecurityScopedResource()` і coordinated I/O;
- Android/iOS encrypted Portfolio backup transport через app-private staging, без зміни vault schema/crypto;
- `MobileExternalWorkspace` з app-owned `OVDP-Hub-Workspace` subtree;
- persisted settings містять тільки opaque grant id + display label;
- втрата permission/grant fail-closed, без мовчазного fallback/recreate;
- legacy plaintext migration використовує тільки `WorkspaceSnapshot.localPath`, mobile label не трактується як filesystem path;
- desktop `FileHubRepository` не замінений мобільною логікою;
- Ready PR workflow тепер реально компілює Android release APK та unsigned iOS release поряд із Windows/macOS package gates.

### Виявлені та виправлені проблеми

1. Run **#488**: два Portfolio tests впали, бо test `FakeRepository` не моделював новий `WorkspaceSnapshot.localPath`. Виправлено без послаблення production checks.
2. Head `de16fcc2ba2b40dbe6feda61fd21b0fe49c19c04`, run **#490**: analyze + **212/212 tests PASS**.
3. Ready run **#491**: Windows/macOS green, але iOS compile впав — `withSecurityScope` bookmark option unavailable on iOS SDK.
4. iOS bridge переведено на UIKit-compatible `.minimalBookmark` / `.withoutUI`, при цьому доступ і далі відкривається через `startAccessingSecurityScopedResource()`.
5. Temporary one-shot helper/workflow для патчу прибрані; у PR лишився тільки production change.

### Підтверджений native checkpoint

Verified head before this docs sync: **`7e26ef3cc691e683f7b9ca2a6d2c631690eb95fb`**.

Run **#496 — SUCCESS**:
- verify: `flutter analyze` + **212/212 tests**;
- Windows release package + packaged smoke — success;
- macOS release package + packaged smoke — success;
- Android `flutter build apk --release` + package upload — success;
- iOS `flutter build ios --release --no-codesign` + package upload — success.

Artifacts:
- `OVDP-Hub-0.9.3-b20-windows-496-1-58da42d`, SHA-256 `6bfd224e8d34917fd17d3aa66c091c0c49a5108c6dc142bf1841071bca227879`;
- `OVDP-Hub-0.9.3-b20-macos-496-1-58da42d`, SHA-256 `a1b8bdd58c5f4d1d2bf931fb4113e2f29afabb1765349563a9b82d832006a446`;
- `OVDP-Hub-Android-test-496-1`, SHA-256 `6c6da1dda2489b03b174710be439434899fc5dc3151475dc5b084f507d9eb7d8`;
- `OVDP-Hub-iOS-unsigned-496-1`, SHA-256 `bf533e28070e7ed179d1078563f5eda7b0c9277f840ac67daa828686f6acf6e6`.

### Межа доказу

Цей checkpoint доводить contract tests + release compilation/package на всіх 4 платформах. Він **не замінює реальний mobile device runtime gate**.

Ще треба перевірити на фізичних пристроях:
- Android SAF picker → persistent URI permission → relaunch → read/write → revoked grant fail-closed;
- iOS folder picker → bookmark save/restore → relaunch → scoped read/write → permission/provider loss fail-closed.

## NEXT

1. Final docs-synced exact-head CI на PR #130.
2. Якщо green — звичайна технічна інтеграція PR #130 у `main`.
3. Записати merge SHA + post-merge main run в Issue #18.
4. Наступний окремий slice — **Android/iOS real-device external-storage runtime validation**.

## Deferred gates

- Windows production code signing;
- macOS Developer ID + notarization;
- Android production keystore/store distribution;
- iOS signing/distribution;
- installers/auto-update.

## Термінологія власника

- **«інтегрувати PR у main»** = звичайний технічний merge після green checks.
- **«злити у main»** = повний cross-platform test-release checkpoint з новою version/build, platform artifacts, START/source, checksums/legal, tag і GitHub prerelease.

## Recovery

Новий чат читає `START_HERE.md` → `PROJECT_RULES.md` → `PROJECT_STATE.md` → цей `WORKLOG.md` → фактичний GitHub → останні Issue #18 записи. Завершені checkpoints не повторювати.
