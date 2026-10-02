# WORKLOG — OVDP Hub

Оновлено: **02.10.2026** (S1–S3 інтегровано)

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
| S3 | Сценарії Planner у vault + перенесення/видалення plaintext-сценаріїв (A.2) | DONE — PR #140 → `cc697691` |
| S4 | Видалення локального портфеля з UI; вихід із `device_key_conflict`; свідомий restore старішої копії (A.3) | VERIFIED — PR #141 (`feat/v095-vault-management`), merge після зелених checks на exact head |
| S5 | Argon2 у фоновому ізоляті; толерантний парсер НБУ; Android SAF I/O поза UI-потоком | VERIFIED (verify) — PR #142 (draft, stacked на S4) |

## Продуктові напрямки B (після v0.9.5, у роботі паралельно стеком)

| # | Slice | Статус |
|---|-------|--------|
| B.1 | Калькулятор облігації з каталогу: НКД за графіком, YTM ACT/365F, валюта випуску | DOING — PR #143 (draft, stacked на S5) |
| B.2 | Портфель: очікувані надходження на 12 міс. + підказки «можливо, не записано» з префілом купона | DOING — PR #144 (draft, stacked на B.1) |

## Поточний slice — S4

- Гілка/PR: `feat/v095-vault-management`, PR #141.
- Суть: «Видалити локальний портфель» з явним підтвердженням (`discardLocalVault` без ключа — вихід при забутому паролі/відсутньому ключі пристрою); restore старішої копії лише після підтвердження з перепечатуванням як наступна ревізія; restore доступний і при відкритому портфелі; зрозумілі повідомлення про конфлікти.
- Готово, коли: зелені checks на exact head після rebase на `cc697691`; merge.
- Наступна дія: merge PR #141 → rebase S5 (#142) на `main`, зняти draft.

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
