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
- `WORKLOG.md` — активний slice / точний NEXT.
- GitHub Issue #18 — append-only development ledger.
- `apps/native/pubspec.yaml` — machine source version/build.
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
- Current integrated `main`: **`5934984a3ad763f8c9f77bd0872077c381adacc2`**
- Platforms: Windows / macOS / Android / iOS
- Languages: UK / EN / FR / DE / ES / KO / JA

## Останні інтегровані slices

- macOS Portfolio Keychain runtime validation + enablement — PR #127 → `4c1617b3…`.
- Mobile external-storage foundation — **PR #130 → `5934984a…` — DONE**.

### PR #130 — підтверджений стан

Реалізовано:
- Android SAF bridge з persisted tree grants;
- iOS document/folder picker + bookmark/security-scope bridge;
- Android/iOS encrypted Portfolio backup transport через app-private staging;
- `MobileExternalWorkspace` з app-owned `OVDP-Hub-Workspace` subtree;
- opaque grant id + display label замість вигаданих filesystem paths;
- permission loss / missing grant fail-closed;
- legacy plaintext migration використовує тільки реальний `WorkspaceSnapshot.localPath`;
- Ready PR CI тепер компілює Android release APK та unsigned iOS release поряд із desktop packaged gates.

Фінальний exact-head PR run **#497 — SUCCESS** на `f6243794…`:
- `flutter analyze` + **212/212 tests**;
- Windows/macOS packaged smoke;
- Android release APK compile/package;
- iOS unsigned release compile/package.

PR #130 merged у `main` як **`5934984a3ad763f8c9f77bd0872077c381adacc2`**.
Post-merge main run **#498 — SUCCESS**, verify + START/source.
START artifact: `OVDP-Hub-0.9.3-test-498-1-START`, SHA-256 `caf066800744f7b9a055f9577d59e47e5ceeaf8100569949d93cc2253f3253fd`.

### Межа доказу

PR #130 доводить contract tests і release compilation/package на всіх 4 платформах, але **не є доказом persistent external-storage runtime на фізичних Android/iOS пристроях**.

## NEXT

**Наступний окремий slice — Android/iOS real-device external-storage runtime validation.**

Потрібно зафіксувати реальні сценарії:
- Android SAF picker → persisted URI permission → relaunch → read/write/list/delete → revoked grant fail-closed;
- iOS folder picker → bookmark save/restore → relaunch → security-scoped read/write/list/delete → stale/lost/provider failure fail-closed.

До появи такого device evidence mobile external storage не називати повністю runtime-validated.
Production signing/notarization/store distribution — окремий пізніший gate.

## Rule for new chats

Recommended phrase:

> **Продовжуємо OVDP Hub. Відкрий у GitHub `START_HERE.md` і продовжуй строго за ним.**

Цього достатньо: не покладатися на пам’ять старого чату й не відновлювати merged branches як джерела коду.
