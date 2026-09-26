# WORKLOG — OVDP Hub

Оновлено: **26.09.2026**

Точка входу: `START_HERE.md`  
Постійні правила: `PROJECT_RULES.md`  
Підтверджений стан main: `PROJECT_STATE.md`  
Append-only ledger: GitHub Issue **#18**

> Детальні проміжні runs і невдалі спроби зберігаються в Issue #18. Тут — остання інтегрована контрольна точка та активний slice, щоб новий чат не повторював завершену роботу.

## Поточний опублікований checkpoint

**v0.9.3 / 0.9.3+20**

- release commit `e2ec96322a1acb953589eeeb45e8ec50cd5d198a`;
- GitHub prerelease v0.9.3;
- release run #106 — success;
- published tag/assets immutable.

## Інтегрований baseline

`main` = **`587d88d157926b7a2e23c59ae75ec7b8df68bb83`** після docs state-sync PR #131.

### Mobile external-storage foundation — DONE

PR #130 → merge **`5934984a3ad763f8c9f77bd0872077c381adacc2`**.

- Android SAF + iOS bookmark/security-scope bridge integrated;
- fail-closed permission semantics;
- external workspace + encrypted backup transport;
- final exact-head #497 — analyze + **212 tests**, Windows/macOS packaged smoke, Android release APK, unsigned iOS release — success;
- post-merge #498 — verify + START/source success;
- PR #131 synchronized `PROJECT_STATE / START_HERE / WORKLOG / roadmap / gate`.

## Активний slice — mobile real-device runtime probe

Branch: **`feat/mobile-storage-runtime-probe`**  
PR: **#132 — Mobile: add real-device external storage runtime probe**  
Base main: `587d88d157926b7a2e23c59ae75ec7b8df68bb83`

### Реалізовано

- production-backed `MobileStorageRuntimeProbe` поверх існуючого `MobileExternalStorage` bridge;
- phase 1: system folder picker → probe write → read → list;
- app-private pending state містить opaque grant id, display label, token та process-launch id;
- той самий process launch не може завершити тест — потрібен новий launch id;
- phase 2 після relaunch: persisted grant/bookmark availability → old probe read/list → rewrite/read → delete → list verification;
- permission/provider loss поверх production bridge показується fail-closed як `workspace.external_permission_lost`;
- reset виконує best-effort remote cleanup, але завжди очищає local pending state;
- у `Сховище` додано видиму Android/iOS validation panel;
- панель локалізована UK / EN / FR / DE / ES / KO / JA;
- панель показує app version + OS для evidence screenshot;
- maintenance protocol: `docs/maintenance/MOBILE_STORAGE_RUNTIME_VALIDATION.md`;
- unit regressions + visible widget regression додані.

### CI історія поточного slice

- run **#504** на `7f9caab…`: analyzer зупинився на одному `use_null_aware_elements` lint; tests/native jobs не запускались.
- fix commit **`4ca3be2c42b4fa800de035de8d86dbd599f00e8d`** змінив лише map syntax, probe semantics не змінені.
- run **#505 — SUCCESS** на `4ca3be2…`: `flutter analyze` PASS + **217 tests PASS**; усі 5 нових restart/grant regressions PASS.

Після #505 додано evidence-friendly panel injection/widget regression та device protocol; поточний head новіший за #505 і потребує нового exact-head verify.

## Що цей slice доведе / не доведе

Harness доводить алгоритм process-relaunch validation і дає повторюваний production UI на Android/iOS.

GitHub CI **не може сам оголосити physical-device PASS**. Остаточне runtime validation потребує запуску на реальному Android та iOS device з фіксацією:
- device/OS;
- exact artifact/build;
- provider/location;
- phase 1;
- повний app termination + relaunch;
- phase 2;
- provider/permission-loss outcome.

Unsigned iOS CI artifact не є physical-device installation proof; для iPhone потрібен development-signed build/Xcode або інший дозволений signed test build.

## Поточний NEXT

1. Отримати green exact-head analyze + full tests після visible panel/widget regression/docs.
2. Зафіксувати PR head і run у Issue #18 / PR #132.
3. Перевести PR #132 у Ready і прогнати Windows/macOS packaged + Android release APK + unsigned iOS compile/package gates.
4. Якщо gates green — інтегрувати harness у `main` як технічний slice.
5. Після інтеграції користувач запускає self-test на реальних пристроях; device evidence записується в Issue #18.
6. Лише після Android + iOS evidence змінити статус mobile external storage на `RUNTIME VALIDATED`.

## Deferred gates

- Windows production code signing;
- macOS Developer ID + notarization;
- Android production keystore/store distribution;
- iOS production signing/distribution;
- installers/auto-update.

## Recovery

Новий чат читає `START_HERE.md` → `PROJECT_RULES.md` → `PROJECT_STATE.md` → цей `WORKLOG.md` → фактичний GitHub PR #132 / head / CI → останні Issue #18 записи. PR #130 implementation і iOS `.withSecurityScope` fix не повторювати.
