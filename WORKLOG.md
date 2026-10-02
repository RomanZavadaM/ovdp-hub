# WORKLOG — OVDP Hub

Оновлено: **01.10.2026** (S1, S2 інтегровано)

## STATUS

**ACTIVE — власник відновив розробку 01.10.2026.**

Новий scope: **v0.9.5 security/privacy hardening** за результатами аудиту коду від 01.10.2026, далі — продуктові напрямки B (окреме рішення про порядок після v0.9.5).

Базовий `main`: `60174b37eb22d4e3018f8412924906737045c33e` (v0.9.4 parked checkpoint + closure record).

## Рішення власника (01.10.2026)

- A.1: відкриття портфеля може вимагати **пароль відновлення** (опція; DEK пристрою видаляється, vault відкривається через recovery slot). Нової криптографії не додається.
- A.2: сценарії Planner з приватними сумами зберігаються **у vault**, а не plaintext у робочій папці.
- Slice-и інтегруються у `main` після зелених checks на розсуд розробника; повний реліз — лише за командою «злити у main».
- Локального Flutter немає: перевірка через CI та виконавчі збірки з GitHub.
- Deferred backlog (physical-device validation, signing, notarization, stores, installers) **не береться**.

## План v0.9.5

| # | Slice | Статус |
|---|-------|--------|
| S1 | CSV/ICS export escaping; desktop focus-loss не блокує портфель | DONE — PR #138 → `a339ecfc` |
| S2 | Пароль відновлення при відкритті портфеля (A.1) | DONE — PR #139 → `4ea48cf4` |
| S3 | Сценарії Planner у vault + перенесення/видалення plaintext-сценаріїв (A.2) | VERIFIED — PR #140 (`feat/v095-private-scenarios`), merge після зелених checks на exact head |
| S4 | Видалення локального портфеля з UI; вихід із `device_key_conflict`; свідомий restore старішої копії (A.3) | VERIFIED (verify) — PR #141 (draft, stacked на S3) |
| S5 | Argon2 у фоновому ізоляті; толерантний парсер НБУ; Android SAF I/O поза UI-потоком | DOING — PR #142 (draft, stacked на S4) |

## Поточний slice — S3

- Гілка/PR: `feat/v095-private-scenarios`, PR #140.
- Суть: payload schema v4 `privateScenarios` (повний SavedSet зі знімком облігацій); Planner зберігає сценарії лише у vault (без портфеля/коли заблоковано — пояснення, не plaintext); «Добірки» показують сценарії з vault поки портфель відкрито, позначають vault/plaintext і переносять plaintext-сценарії у vault з видаленням файлів після перевірки.
- Готово, коли: зелені checks на exact head після rebase на `4ea48cf4`; merge.
- Наступна дія: merge PR #140 → rebase S4 (#141) на `main`, зняти draft.

## Попередній checkpoint

**v0.9.4 / 0.9.4+21** — release PR #135, commit `1185ad7f94339cd8865f3123570b9ad14a935114`, release run #113, main verify #518. Деталі — `PROJECT_STATE.md`, `docs/PROJECT_CLOSURE_v0_9_4.md`.

## Deferred backlog — НЕ NEXT

- Android physical SAF persistence/revoke/provider-loss test;
- iOS development signing і physical iPhone runtime validation;
- Windows code signing;
- macOS notarization;
- Android/iOS store signing/distribution;
- installers / auto-update.

## Recovery rule

1. `START_HERE.md`;
2. `PROJECT_RULES.md`;
3. `PROJECT_STATE.md`;
4. цей `WORKLOG.md`;
5. фактичний GitHub `main`, відкриті PR, latest release;
6. останні записи Issue #18.

Не повторювати вже merged роботу; продовжувати з першої незавершеної дії активного slice.
