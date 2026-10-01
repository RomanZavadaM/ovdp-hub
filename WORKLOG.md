# WORKLOG — OVDP Hub

Оновлено: **01.10.2026**

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
| S1 | CSV/ICS export escaping; desktop focus-loss не блокує портфель | DOING — `fix/v095-export-lifecycle-hardening` |
| S2 | Пароль відновлення при відкритті портфеля (A.1) | TODO |
| S3 | Сценарії Planner у vault + очищення старих plaintext-файлів (A.2) | TODO |
| S4 | Видалення локального vault з UI; вихід із `device_key_conflict`; restore старішої копії (A.3) | TODO |
| S5 | Argon2 поза UI-ізолятом; Android SAF bridge (UI thread, persisted grants); толерантний парсер НБУ | TODO |

## Поточний slice — S1

- Гілка: `fix/v095-export-lifecycle-hardening`.
- Мета: CSV-клітинки, що починаються з `=`, `+`, `@`, табуляції/CR або нечислового `-`, екрануються від виконання формул; ICS екранує одиночний `\r`; на desktop `AppLifecycleState.inactive` (втрата фокуса) не запускає background-lock.
- Готово, коли: regression tests додані, `flutter analyze` + `flutter test` зелені у CI.
- Наступна дія: відкрити PR, дочекатися CI.

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
