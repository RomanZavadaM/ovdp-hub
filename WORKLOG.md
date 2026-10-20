# WORKLOG — OVDP Hub

Оновлено: **20.10.2026** (відновлено розробку; F1/F2)

## STATUS

**ACTIVE — власник відновив розробку 01.10.2026.**

Scope: security/privacy hardening за аудитом 01.10.2026 + перші продуктові напрямки B → release checkpoint **v0.10.0**.

Базовий `main`: `60174b37eb22d4e3018f8412924906737045c33e` (v0.9.4 parked checkpoint + closure record).

## Рішення власника (01.10.2026)

- A.1: відкриття портфеля може вимагати **пароль відновлення** (опція; DEK пристрою видаляється, vault відкривається через recovery slot). Нової криптографії не додається.
- A.2: сценарії Planner з приватними сумами зберігаються **у vault**, а не plaintext у робочій папці.
- Slice-и інтегруються у `main` після зелених checks на розсуд розробника; повний реліз — лише за командою «злити у main».
- Локального Flutter немає: перевірка через CI та виконавчі збірки з GitHub.
- Deferred backlog (physical-device validation, signing, notarization, stores, installers) **не береться**.

## Release checkpoint v0.10.0 — DONE (02.10.2026)

- Версія **0.10.0+22**; release PR #142 → `933a7bd27e0f4babe47f44a32f8bf9214b4b18a4`.
- Release run **#116 — SUCCESS** (264 tests, Windows/macOS exact packaged smoke з capabilities, Android, iOS unsigned, START/source, SHA256SUMS, legal, publish).
- Main verify **#561 — SUCCESS**. GitHub prerelease `v0.10.0` опубліковано 02.10.2026.
- Інтегровано: S1 #138, S2 #139, S3 #140, S4 #141, S5 + B.1 + B.2 + B.1b + release metadata #142.
- Docs-sync: README ×7, PROJECT_STATE, roadmap, START_HERE, user guides ×7 — PR `docs/v0-10-0-sync`.

## NEXT

Активний slice: **F3 — очищення приватного Planner після lock**. Гілка `fix/private-planner-lock-20261020`, база main `00a09b7bc5146cd2355082c01b34b67dcdc18918` після squash PR #149. Draft PR #150.

Критерії: завантажений vault-сценарій позначений приватним; manual/inactivity/background gateway lock очищує draft і обчислення незалежно від busy; діалоги/datepicker та повідомлення з приватними даними закриваються; stale async completions не відновлюють draft; export після lock не створюється. Нові/public drafts не очищуються. Додати domain/race та visible-control UI regression tests.

Реалізовано private provenance, синхронне очищення через gateway lock, privacy revision для transient UI та stale completions. Додано 7 domain/race і 3 visible-control UI tests. Перший CI: analyze PASS, 282 tests PASS, 1 UI failure через неправильний finder кнопки lock; виправлено на її реальний tooltip. Додано перевірку невдалого save нового public draft у вже locked vault. Наступна дія: analyze/tests для актуального head на базі main; після success — платформні gates перед інтеграцією. Не змінювати криптографію чи правила TTL сесії. Файл, який користувач уже почав експортувати до lock, не видаляється заднім числом; F6 про plaintext export залишається окремим пунктом.

## Нещодавно завершено — F1/F2 DONE

PR #149 → main `00a09b7bc5146cd2355082c01b34b67dcdc18918`. Run 39411185021 SUCCESS: analyze, **274 tests PASS** (10 нових), Windows/macOS exact ZIP packaged smoke, Android та iOS unsigned PASS. Версія опублікованого релізу лишається v0.10.0+22.

План: [DEVELOPMENT_PLAN_2026_10_20.md](docs/DEVELOPMENT_PLAN_2026_10_20.md), tracker аудиту #147. Docs PR #148 окремо. Реліз v0.10.0+22 не змінено.

## Попередній checkpoint (історія)


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
