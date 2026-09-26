# START_HERE — OVDP Hub

> Перша точка входу для нового чату або відновлення після обриву.

## Статус

**PARKED — проєкт завершений на поточному рівні. Активного NEXT немає.**

Поточний опублікований checkpoint: **v0.9.4 / 0.9.4+21**.  
Release/product checkpoint commit: **`1185ad7f94339cd8865f3123570b9ad14a935114`**.  
Release run **#113 — SUCCESS**.  
Post-merge main verify run **#518 — SUCCESS**.

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
- `WORKLOG.md` — parked/recovery checkpoint.
- GitHub Issue #18 — append-only development ledger.
- `apps/native/pubspec.yaml` — machine source version/build.
- `docs/releases/RELEASE_NOTES_v0_9_4.md` — фінальний checkpoint цього етапу.
- `docs/roadmap.md` — завершений scope і deferred backlog.

## Що зафіксовано у v0.9.4

Після v0.9.3 інтегровано:
- Portfolio recovery/rotation та Windows portable encrypted backup/restore;
- безпечне редагування Planner criteria/date;
- localization cleanup і persistence language/appearance;
- shared locale-friendly dates;
- macOS Keychain runtime proof та encrypted Portfolio enablement;
- Android SAF + iOS security-scoped external-storage foundation;
- mobile external workspace / encrypted backup transport;
- двоетапний mobile storage self-test через terminate/relaunch.

Final gates:
- **218/218 tests**;
- Windows exact packaged ZIP smoke;
- macOS exact packaged ZIP smoke + Keychain/vault lifecycle;
- Android release APK compile/package;
- iOS unsigned release compile/package;
- START/source, SHA256SUMS і legal notices.

## Deferred — не є активним NEXT

Повернутися лише за окремим рішенням власника:
- Android physical-device SAF persistence/revoke/provider-loss validation;
- iOS development signing і physical-device bookmark/security-scope validation;
- Windows production code signing;
- macOS Developer ID + notarization;
- Android/iOS production store signing/distribution;
- installers / auto-update;
- будь-які нові продуктові slices.

Ці пункти **не блокують parked checkpoint v0.9.4** і не дозволяють називати невиконані physical-device сценарії `RUNTIME VALIDATED`.

## Команда власника «злити у main»

Якщо розробку колись буде відновлено, **«злити у main / зливай у main»** знову означає повний test-release checkpoint: new version/build, green exact-head checks, merge, Windows/macOS/Android/iOS + START/source, packaged desktop smoke, checksums/legal, tag + GitHub prerelease, docs/ledger sync.

## Для нового чату

Достатньо фрази:

> **Продовжуємо OVDP Hub. Відкрий у GitHub `START_HERE.md` і продовжуй строго за ним.**

Після прочитання нового чату відповідь має бути: проєкт PARKED; нічого не розробляти, доки власник не задасть новий scope.
