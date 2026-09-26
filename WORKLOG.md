# WORKLOG — OVDP Hub

Оновлено: **26.09.2026**

Точка входу: `START_HERE.md`  
Постійні правила: `PROJECT_RULES.md`  
Підтверджений стан main: `PROJECT_STATE.md`  
Append-only ledger: GitHub Issue **#18**

> Детальні проміжні runs і невдалі спроби зберігаються в Issue #18. Тут — остання інтегрована контрольна точка і точний NEXT.

## Поточний опублікований checkpoint

**v0.9.3 / 0.9.3+20**

- release commit: `e2ec96322a1acb953589eeeb45e8ec50cd5d198a`;
- published GitHub prerelease: v0.9.3;
- release run #106 — success;
- published tag/assets не переписуються.

## Останній інтегрований baseline

`main` = **`5934984a3ad763f8c9f77bd0872077c381adacc2`**.

## Mobile external storage foundation — DONE

PR: **#130 — Mobile: add external storage foundation**  
Merge: **`5934984a3ad763f8c9f77bd0872077c381adacc2`**

### Реалізовано

- platform-neutral `MobileExternalStorage` MethodChannel contract;
- Android SAF bridge з persisted tree grant і bounded read/write/list/delete;
- iOS document/folder picker bridge, bookmarks, `startAccessingSecurityScopedResource()` і coordinated I/O;
- Android/iOS encrypted Portfolio backup transport через app-private staging без зміни vault schema/crypto;
- `MobileExternalWorkspace` з app-owned `OVDP-Hub-Workspace` subtree;
- persisted settings містять opaque grant id + display label;
- permission/grant loss fail-closed, без мовчазного fallback/recreate;
- legacy plaintext migration використовує тільки `WorkspaceSnapshot.localPath`;
- desktop `FileHubRepository` не замінений мобільною логікою;
- Ready PR workflow компілює Android release APK та unsigned iOS release поряд із Windows/macOS packaged gates.

### Проблеми, які gate реально зловив

1. Run **#488**: test `FakeRepository` не моделював новий `WorkspaceSnapshot.localPath`; виправлено без послаблення production checks.
2. Run **#491**: iOS compile впав через macOS-only `.withSecurityScope` bookmark option.
3. iOS bridge переведено на UIKit-compatible `.minimalBookmark` / `.withoutUI`, при цьому scoped access лишився через `startAccessingSecurityScopedResource()`.

### Фінальний exact-head gate

Docs-synced PR head: **`f6243794eea927e4b73cb85f666739d62c633e8f`**.

Run **#497 — SUCCESS**:
- `flutter analyze` + **212/212 tests**;
- Windows release package + packaged smoke;
- macOS release package + packaged smoke;
- Android `flutter build apk --release` + package upload;
- iOS `flutter build ios --release --no-codesign` + package upload.

Artifacts #497:
- Windows `OVDP-Hub-0.9.3-b20-windows-497-1-e0ebc58`, SHA-256 `a7a8484354ce7500dd775e6db20efa9d38e6f940d1d479c176e59de4908bd2d5`;
- macOS `OVDP-Hub-0.9.3-b20-macos-497-1-e0ebc58`, SHA-256 `6b45a99794c394a1e6d55ef4b8e0a332a43b063d16f951d58e49a0417036c7f9`;
- Android `OVDP-Hub-Android-test-497-1`, SHA-256 `835e8993f91d8f03db4922bc630619a3be69dabcd0bb5ea3dd146260aa386fac`;
- iOS `OVDP-Hub-iOS-unsigned-497-1`, SHA-256 `dfcabda484a0fb507c382eb47b3ae54e9341976f348ee077665ba5230a84e88d`.

### Post-merge

- PR #130 merged into `main` as **`5934984a…`**;
- post-merge run **#498 — SUCCESS**, verify + START/source;
- START artifact `OVDP-Hub-0.9.3-test-498-1-START`, SHA-256 `caf066800744f7b9a055f9577d59e47e5ceeaf8100569949d93cc2253f3253fd`.

## Межа доказу

PR #130 закриває implementation + contract-test + release compile/package gate. Він **не закриває physical-device persistent-access runtime gate**.

Не вважати ще доведеним:
- Android SAF grant persistence після relaunch на реальному пристрої;
- Android revoke/provider-loss behavior на реальному пристрої;
- iOS bookmark persistence/resolution після relaunch на реальному пристрої;
- iOS stale/lost/provider edge cases на реальному пристрої.

## Поточний NEXT

**Android/iOS real-device external-storage runtime validation.**

Порядок:
1. Підготувати вузький runtime-validation harness/checklist без зміни crypto/schema/financial math.
2. Android: picker → persisted grant → relaunch → read/write/list/delete → revoked grant fail-closed.
3. iOS: picker → bookmark restore → relaunch → security-scoped read/write/list/delete → permission/provider loss fail-closed.
4. Для кожного тесту записати device/OS, exact build/artifact, steps і outcome в Issue #18 + maintenance gate.
5. Лише після фактичного device evidence можна позначити mobile external storage runtime-validated.

## Deferred gates

- Windows production code signing;
- macOS Developer ID + notarization;
- Android production keystore/store distribution;
- iOS signing/distribution;
- installers/auto-update.

## Термінологія власника

- **«інтегрувати PR у main»** = звичайний технічний merge після green checks.
- **«злити у main»** = full cross-platform test-release checkpoint з новою version/build, platform artifacts, START/source, checksums/legal, tag і GitHub prerelease.

## Recovery

Новий чат читає `START_HERE.md` → `PROJECT_RULES.md` → `PROJECT_STATE.md` → цей `WORKLOG.md` → фактичний GitHub → останні Issue #18 записи. Завершений PR #130 не повторювати.
