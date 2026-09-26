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
- Post-merge run: **#405 success**
- Full publish: **#106 success**
- Platforms: Windows / macOS / Android / iOS
- Languages: UK / EN / FR / DE / ES / KO / JA
- v0.9.3 includes factual sale/redemption/history, coupon, per-ISIN ledger, factual cash summary, closed positions and explicit non-destructive legacy migration wizard.
- Unknown fees remain explicit; market value is not presented as factual result.
- v0.9.3 documentation/user-guide cleanup is **DONE**: PR #110 → `df505e9f…`, exact-head run #407 and post-merge run #408 — success.
- Repository branch cleanup is **DONE**: 109 obsolete branches deleted, 0 failures; stale PR #103/#108 closed; tags/releases/history preserved.
- Post-v0.9.3 usability/product audit is **DONE**: PR #116 → `bb961f9d…`; canonical findings are in `docs/AUDIT_POST_0_9_3.md`.
- First audit fix is **DONE**: PR #117 → `fc38177a…`; recovery confirmation/rotation plus Windows portable encrypted backup/restore; exact-head #417 and post-merge #418 — success.
- Planner safe criteria/date editing is **DONE**: PR #119 → `ad3a995a…`; exact-head #420 and post-merge #421 — success.
- Catalog localization + locale-neutral collection variant cleanup is **DONE**: PR #120 → `5638f56e…`; final exact-head #428 and post-merge #429 — success. Runs #422/#424 are retained as useful failed evidence that caught a no-op CRLF patch.
- Language + appearance persistence is **DONE**: PR #123 → `6e6326c6…`; exact-head run #439 — 197/197 tests + Windows/macOS packaged smoke; post-merge main run #440 — verify + START/source success.
- Non-sensitive UI preferences are stored in app-support `ui-preferences.json`, separate from workspace/private vault; corrupt/unknown data fails safe to Ukrainian + Workbench.
- Ready user-visible PRs now automatically enforce packaged Windows + macOS smoke before merge.
- Current integrated product baseline: **`6e6326c6c8ed00e86908a1eb533bd0cb80bdfaaf`**.
- Android SAF / iOS security-scoped external-folder access remains deferred.
- macOS encrypted Portfolio remains gated on real Keychain runtime/provisioning validation.
- Production signing/notarization remains deferred.
- **NEXT:** unified reusable date-control UX / picker for Planner + Portfolio: locale-friendly display, picker + keyboard fallback, canonical existing persistence, explicit validation, no persisted-schema change.

## Rule for new chats

Recommended phrase:

> **Продовжуємо OVDP Hub. Відкрий у GitHub `START_HERE.md` і продовжуй строго за ним.**

Цього достатньо: не покладатися на пам’ять старого чату й не відновлювати старі branches як джерела коду.
