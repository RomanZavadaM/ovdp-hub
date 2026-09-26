# START_HERE — OVDP Hub

> Перша точка входу для нового чату або відновлення після обриву.

## Startup protocol

Перед будь-якою роботою:

1. Прочитати `PROJECT_RULES.md`.
2. Прочитати `PROJECT_STATE.md`.
3. Прочитати `WORKLOG.md`.
4. Перевірити фактичний GitHub:
   - `main` SHA;
   - відкриті PR;
   - active PR head;
   - останні workflow runs.
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
- `CHANGELOG.md` і `docs/releases/` — історія релізів; не переносити стару історію назад у active state docs.

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
- Full publish: **#106 success**
- Platforms: Windows / macOS / Android / iOS
- Languages: UK / EN / FR / DE / ES / KO / JA
- Current integrated product baseline: **`4c1617b3f0636c6ca33a35b2f992766dc4649cde`**.

### Останні інтегровані slices

- Post-v0.9.3 audit — PR #116 → `bb961f9d…`.
- Portfolio recovery / Windows portable encrypted backup UX — PR #117 → `fc38177a…`.
- Planner safe criteria/date editing — PR #119 → `ad3a995a…`.
- Catalog localization + locale-neutral collection variant — PR #120 → `5638f56e…`.
- UI language + appearance persistence — PR #123 → `6e6326c6…`.
- Unified Planner/Portfolio date controls — PR #125 → `c94fbce6…`.
- **macOS encrypted Portfolio Keychain runtime gate + enablement — DONE:** PR #127 → **`4c1617b3f0636c6ca33a35b2f992766dc4649cde`**.

### macOS Portfolio — підтверджений стан

- До enablement packaged macOS app реально пройшов Keychain/vault create → open → lock/reopen → backup/restore → recovery rotation → cleanup: Gate A run **#462 — success**.
- Після enablement той самий runtime contract повторно пройшов у run **#464 — success**.
- Final docs-synced exact-head run **#465 — success**: `flutter analyze`, **204 tests**, Windows packaged smoke, macOS packaged Keychain/vault smoke.
- PR #127 merged у `main` як **`4c1617b3…`**.
- Post-merge main run **#466 — success**, including verify + START/source.
- START artifact: `OVDP-Hub-0.9.3-test-466-1-START`, SHA-256 `5b7dcb427357ab88785223434d6ab3784e1682e6ecb75a592cca9a6431ea21cb`.
- Encrypted Portfolio now supports Windows / macOS / Android / iOS at the app-local vault/device-key level.
- macOS device key/revision state uses system Keychain with packaged runtime validation.
- Portable external-file backup/restore UI remains **Windows-only**; macOS file flow is not silently enabled.
- Existing v0.9.3 release was not republished after merge: release push preflight correctly skipped publish/build jobs.

## Deferred / NEXT

- **NEXT — Android SAF + iOS security-scoped external-folder access.** Ціль: нормальний user-facing external workspace/backup file flow на mobile без підміни desktop filesystem API.
- Production signing/notarization/store distribution remains a separate later gate.
- Windows production code signing, macOS Developer ID + notarization, Android production keystore, iOS signing/distribution, installers/auto-update — deferred.

## Rule for new chats

Recommended phrase:

> **Продовжуємо OVDP Hub. Відкрий у GitHub `START_HERE.md` і продовжуй строго за ним.**

Цього достатньо: не покладатися на пам’ять старого чату й не відновлювати старі branches як джерела коду.
