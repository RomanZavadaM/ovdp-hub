# WORKLOG — OVDP Hub

Оновлено: **20.10.2026** (F1–F4/F6 DONE; NEXT F5)

## STATUS

**ACTIVE — власник відновив розробку 01.10.2026.**

Scope: завершення аудиту F1–F10, далі продуктові інтеграції продавців за планом 20.10.2026.

Базовий `main` для NEXT F5: `4440dd4175aa250d22f65c07866cb236b5c9d644`.

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

F5 — приватні назви й нотатки collections. Branch `fix/private-collections-20261020`, база main `4440dd4175aa250d22f65c07866cb236b5c9d644`. Підготовлено лише дизайн і цей docs checkpoint; код F5 ще не змінено, PR F5 немає.

План: [F5_PRIVATE_COLLECTIONS_PLAN.md](docs/F5_PRIVATE_COLLECTIONS_PLAN.md). Точна наступна дія: додати окремий PrivateCollectionRecord/payload v5 та compatibility/round-trip tests v1–v4; потім editor/save/lock, collections reopen та explicit verified legacy move. Приватні annotations не переводити у plaintext через UI-попередження. До завершення всіх етапів F5 не DONE.

Завершено 20.10.2026:
- F4 primary #151 → main 81639128557afc77777040b5d363b0d7d3701f7e, run 39416807438 SUCCESS (293 tests + усі platform gates).
- F6 #152 → main 73df0e71a90a0738cf307820dde155b338c97866, run 39418461683 SUCCESS (305 tests, 12 нових UI tests + усі platform gates). Private CSV/ICS мають plaintext consent/destination; cancel/lock/draft/workspace change не запускають export.
- F4 follow-up #153 → main `4440dd4175aa250d22f65c07866cb236b5c9d644`, tested head c5edd792aae9e6830c680391d5b72f4dd4bf9fd1, run 39421143980 SUCCESS: analyze, 314 tests (9 нових), Windows/macOS exact ZIP smoke, Android release APK, iOS unsigned. Original store cleanup після dispose; generation від початку create/restore/migration; окремі internal transient locks, які не маскують timer/user/background cancellation. Normal create/restore PASS.
- Контрольовані red regressions: recovery-open run 39415913784 (284 pass + 1 fail), lifecycle run 39419555995 (294 pass + 2 fail). Це real-store/domain тести, не physical-device runtime.
- Post-merge F4/F6 verify+START runs 39417929019 / 39419709164 SUCCESS. Post-merge final main run 39422596744 ще перевіряється; фінальний статус — Issue #18.

Published release лишається v0.10.0 / 0.10.0+22; новий реліз не публікувався. F7–F10 та продуктові етапи — за DEVELOPMENT_PLAN; physical-device/signing/store backlog не активовано.

Локальний checkout востаннє підтверджено clean на c5edd792. Після зміни середовища локальний exec заблокований помилкою Windows sandbox path URI file:///workspace; GitHub checkpoint є актуальним. Перед наступною локальною реалізацією синхронізувати цю гілку, не перезаписуючи можливі локальні зміни.

## Нещодавно завершено — F1/F2/F3 DONE

- F1/F2: PR #149 → main `00a09b7bc5146cd2355082c01b34b67dcdc18918`, run 39411185021 SUCCESS: analyze, 274 tests (10 нових), Windows/macOS exact ZIP packaged smoke, Android release та iOS unsigned. Post-merge main run 39413010557 SUCCESS (verify + START).
- F3: PR #150 → main `463207cda15eb47310eba6e178d30b27251eed28`, run 39413819496 SUCCESS: analyze, **284 tests** (ще 10 нових), Windows/macOS exact ZIP packaged smoke, Android release та iOS unsigned. Private Planner очищується на session lock, transient dialogs/date picker закриваються, stale completions не повертають UI; нові/public drafts зберігаються.
- F3 перший CI мав 1 UI failure через неправильний finder кнопки lock; виправлено на реальний tooltip, усі подальші перевірки зелені.
- Уже розпочатий до lock export не видаляється ретроспективно. F6 про plaintext export лишається окремим пунктом.
- Post-merge main F3 verify/START: run 39414901881 SUCCESS (verify + START/source).
- Публічний реліз **v0.10.0 / 0.10.0+22** не переписували й новий реліз не публікували. Реальні physical-device mobile сценарії залишаються deferred.

План: [DEVELOPMENT_PLAN_2026_10_20.md](docs/DEVELOPMENT_PLAN_2026_10_20.md), tracker #147. Висновки порівняння Shell і межі 61 module tests збережені в Issue #18; native UI Shell не запускали. Docs PR #148 окремо; його старі PLANNED-статуси не є поточними.

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
