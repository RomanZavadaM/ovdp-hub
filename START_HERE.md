# START_HERE — OVDP Hub

> Перша точка входу для нового чату або відновлення після обриву.

## Startup protocol

Перед будь-якою роботою:

1. Прочитати `PROJECT_RULES.md`.
2. Прочитати `PROJECT_STATE.md`.
3. Прочитати `WORKLOG.md`.
4. Перевірити фактичний GitHub: `main` SHA, відкриті PR, active PR head, останні workflow runs.
5. Прочитати останні записи GitHub Issue **#18**.
6. Якщо GitHub і текст суперечать одне одному — GitHub має пріоритет, після чого документацію треба синхронізувати.
7. Продовжити перший `DOING` / `NEXT`; merged роботу не повторювати.

## Джерела істини

- `PROJECT_RULES.md` — незмінні правила проєкту.
- `PROJECT_STATE.md` — лише підтверджений інтегрований стан `main`.
- `WORKLOG.md` — активний slice, branch/PR/head/checks/next action.
- GitHub Issue #18 — append-only development ledger.
- `apps/native/pubspec.yaml` — machine source of version/build.
- `docs/roadmap.md` — середньостроковий roadmap.
- `CHANGELOG.md` і `docs/releases/` — історія релізів.

## Команда власника «злити у main»

**«злити у main / зливай у main»** означає повний test-release checkpoint, а не простий merge:

1. new version/build;
2. green exact-head PR checks;
3. merge у `main`;
4. Windows/macOS/Android/iOS + START/source;
5. packaged desktop executable smoke;
6. SHA256/legal notices;
7. immutable tag + GitHub prerelease;
8. asset verification;
9. docs/worklog/ledger sync.

## Поточний технічний контекст

- Repository: `RomanZavadaM/ovdp-hub`
- Active product: `apps/native` Flutter/Dart
- Published checkpoint: **v0.9.3 / 0.9.3+20**
- Release commit: `e2ec96322a1acb953589eeeb45e8ec50cd5d198a`
- Current integrated product baseline before mobile-storage PR: `89887d39d2bb2c4e894ca09e4141161559992f7b`
- Platforms: Windows / macOS / Android / iOS
- Languages: UK / EN / FR / DE / ES / KO / JA

### Mobile external storage foundation — current checkpoint

- Branch: `feat/mobile-external-storage`
- PR: **#130 — Ready**
- Verified implementation head before docs sync: **`7e26ef3cc691e683f7b9ca2a6d2c631690eb95fb`**.
- Run **#496 — SUCCESS**:
  - `flutter analyze` + **212/212 tests**;
  - Windows release package + packaged smoke;
  - macOS release package + packaged smoke;
  - Android release APK compile/package;
  - iOS release `--no-codesign` compile/package.
- Android artifact: `OVDP-Hub-Android-test-496-1`, SHA-256 `6c6da1dda2489b03b174710be439434899fc5dc3151475dc5b084f507d9eb7d8`.
- iOS artifact: `OVDP-Hub-iOS-unsigned-496-1`, SHA-256 `bf533e28070e7ed179d1078563f5eda7b0c9277f840ac67daa828686f6acf6e6`.
- Windows/macOS artifacts also uploaded and packaged-smoke green.
- Run #491 intentionally exposed an iOS SDK compile error (`withSecurityScope` unavailable on iOS); fixed by UIKit-compatible bookmark options, then #496 proved the fix.

### What this proves / does not prove

Confirmed now:
- Android SAF bridge compiles in release APK;
- iOS security-scoped picker/bookmark bridge compiles in unsigned release build;
- Dart contract and fail-closed regressions are covered;
- desktop behavior remains green.

Not yet claimed as complete:
- physical Android device runtime: folder picker, persisted URI grant after relaunch, grant loss/revocation;
- physical iOS device runtime: folder picker, bookmark restore after relaunch, security-scope access and revocation/provider edge cases.

## NEXT

1. Finish this docs-synced exact-head PR gate.
2. Integrate PR #130 into `main` if final exact-head remains green.
3. Next slice: **real-device runtime validation for Android SAF and iOS external-folder/bookmark persistence**. Do not call mobile external storage fully production-ready before those runtime gates are recorded.
4. Production signing/notarization/store distribution remains a later separate gate.

## Rule for new chats

Recommended phrase:

> **Продовжуємо OVDP Hub. Відкрий у GitHub `START_HERE.md` і продовжуй строго за ним.**

Цього достатньо: не покладатися на пам’ять старого чату й не відновлювати старі branches як джерела коду.
