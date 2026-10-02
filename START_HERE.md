# START_HERE — OVDP Hub

> Перша точка входу для нового чату або відновлення після обриву.

## Статус

**ACTIVE — останній тестовий реліз v0.10.0 / 0.10.0+22 опубліковано 02.10.2026. Новий scope визначає власник (див. `docs/roadmap.md`).**

Останній опублікований checkpoint: **v0.10.0 / 0.10.0+22**.  
Release/product checkpoint commit: **`933a7bd27e0f4babe47f44a32f8bf9214b4b18a4`**.  
Release run **#116 — SUCCESS**.  
Post-merge main verify run **#561 — SUCCESS**.

Не відновлювати старі work/feature branches як джерело коду і не повторювати merged slices.

## Startup protocol при майбутньому поверненні

1. Прочитати `PROJECT_RULES.md`.
2. Прочитати `PROJECT_STATE.md`.
3. Прочитати `WORKLOG.md`.
4. Перевірити фактичний GitHub: `main` SHA, відкриті PR, останні workflow runs і latest release.
5. Прочитати останні записи GitHub Issue **#18**.
6. Якщо GitHub і текст суперечать одне одному — GitHub має пріоритет, після чого документацію синхронізувати.
7. **Не починати відкладені роботи автоматично.** Новий етап починається лише після окремого рішення власника про відновлення OVDP Hub.

## Джерела істини

- `PROJECT_RULES.md` — постійні правила.
- `PROJECT_STATE.md` — підтверджений стан продукту.
- `WORKLOG.md` — активний slice і точна наступна дія.
- GitHub Issue #18 — append-only development ledger.
- `apps/native/pubspec.yaml` — machine source version/build.
- `docs/releases/RELEASE_NOTES_v0_10_0.md` — останній опублікований реліз.
- `docs/roadmap.md` — завершений scope, планована робота за аудитом і deferred backlog.
- `docs/maintenance/AUDIT_BACKLOG_2026_10_02.md` / Issue #147 — F1–F10, пріоритети та критерії; PLANNED, не активний NEXT.

## Що зафіксовано у v0.10.0

Після відновлення розробки (01.10.2026, аудит коду) інтегровано PR #138–#142:
- опційний пароль відновлення при відкритті портфеля;
- сценарії Planner із приватними сумами лише в зашифрованому портфелі (payload schema v4) і перевірене перенесення старих plaintext-сценаріїв;
- видалення локального портфеля, підтверджений restore старішої копії;
- Argon2id у фоновому ізоляті, formula-safe CSV, толерантне оновлення каталогу НБУ, Android SAF I/O поза UI-потоком;
- калькулятор облігації з каталогу (НКД, YTM), очікувані надходження портфеля, річна дохідність плану.

Final gates release run #116: **264 tests**, Windows/macOS exact packaged ZIP smoke (з release-contract capabilities), Android release APK, iOS unsigned, START/source, SHA256SUMS і legal notices.

## Deferred — не є активним NEXT

Повернутися лише за окремим рішенням власника:
- Android physical-device SAF persistence/revoke/provider-loss validation;
- iOS development signing і physical-device bookmark/security-scope validation;
- Windows production code signing;
- macOS Developer ID + notarization;
- Android/iOS production store signing/distribution;
- installers / auto-update;
- будь-які нові продуктові slices.

Ці пункти **не блокують тестові релізи** і не дозволяють називати невиконані physical-device сценарії `RUNTIME VALIDATED`.

## Команда власника «злити у main»

Якщо розробку колись буде відновлено, **«злити у main / зливай у main»** знову означає повний test-release checkpoint: new version/build, green exact-head checks, merge, Windows/macOS/Android/iOS + START/source, packaged desktop smoke, checksums/legal, tag + GitHub prerelease, docs/ledger sync.

## Для нового чату

Достатньо фрази:

> **Продовжуємо OVDP Hub. Відкрий у GitHub `START_HERE.md` і продовжуй строго за ним.**

Після прочитання новий чат продовжує активний slice з `WORKLOG.md` (гілка/PR + остання дія в Issue #18). Відкладені пункти не брати без окремого рішення власника.
