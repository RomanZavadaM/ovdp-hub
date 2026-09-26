# WORKLOG — OVDP Hub

Оновлено: **26.09.2026**

Точка входу: `START_HERE.md`  
Постійні правила: `PROJECT_RULES.md`  
Підтверджений стан main: `PROJECT_STATE.md`  
Append-only ledger: GitHub Issue **#18**

> Детальні проміжні runs і невдалі спроби зберігаються в Issue #18. Тут — остання інтегрована контрольна точка та точний NEXT, щоб новий чат не повторював завершену роботу.

## Поточний опублікований checkpoint

**v0.9.3 / 0.9.3+20**

- release commit `e2ec96322a1acb953589eeeb45e8ec50cd5d198a`;
- GitHub prerelease v0.9.3;
- release run #106 — success;
- published tag/assets immutable.

## Інтегрований baseline

`main` = **`e6e0a6ae3fb74b6fab8adf155eb6d3d338a11959`**.

Post-merge main run **#512 — SUCCESS**:
- `flutter analyze` PASS;
- **218/218 tests PASS**;
- START/source PASS.

START artifact: `OVDP-Hub-0.9.3-test-512-1-START`  
SHA-256: `a9d62bd77b433c26f3ab9fdfa4d1ac9b8b385dab22b4e5b2a5b6a12798e4a4f9`.

## Mobile external-storage foundation — DONE

PR #130 → merge **`5934984a3ad763f8c9f77bd0872077c381adacc2`**.

- Android SAF + iOS bookmark/security-scope bridge integrated;
- fail-closed permission semantics;
- external workspace + encrypted backup transport;
- final exact-head #497 — analyze + 212 tests, Windows/macOS packaged smoke, Android release APK, unsigned iOS release — success;
- post-merge #498 — verify + START/source success;
- PR #131 synchronized post-merge state.

## Mobile real-device runtime probe harness — DONE for implementation/CI scope

PR: **#132 — Mobile: add real-device external storage runtime probe**  
Exact PR head: **`4d59750c0bea01d39cf495ab054befc1beb6e266`**  
Squash merge: **`e6e0a6ae3fb74b6fab8adf155eb6d3d338a11959`**

### Реалізовано

- production-backed `MobileStorageRuntimeProbe` поверх існуючого Android SAF / iOS bookmark bridge;
- phase 1: system folder picker → probe write → read → list;
- app-private pending state містить opaque grant/bookmark ref, label, token та process-launch id;
- той самий process launch не може завершити тест;
- phase 2 після реального terminate/relaunch: persisted access → old probe read/list → rewrite/read → delete → final list verification;
- permission/provider loss fail-closed;
- reset робить best-effort remote cleanup і гарантований local state cleanup;
- у `Сховище` є видима Android/iOS validation panel;
- локалізація UK / EN / FR / DE / ES / KO / JA;
- panel показує app version + OS для evidence screenshot;
- maintenance protocol: `docs/maintenance/MOBILE_STORAGE_RUNTIME_VALIDATION.md`;
- 5 core restart/grant regressions + visible widget regression.

### Реальні CI findings у slice

- #504 зловив один analyzer lint `use_null_aware_elements`; виправлено без зміни semantics.
- #505: analyze PASS + 217 tests PASS.
- #509 показав зависання widget test через real `dart:io` futures у Flutter fake-async; widget test переписаний на scripted probe, а real File I/O лишився у core tests.
- #510 на exact head: analyze PASS + **218/218 tests PASS**.

### Final Ready gate #511 — SUCCESS

На exact head `4d59750c…`:
- verify success;
- Windows release package + packaged smoke success;
- macOS release package + packaged smoke success;
- Android release APK compile/package success;
- iOS unsigned release compile/package success.

Artifacts / SHA-256:
- Windows `OVDP-Hub-0.9.3-b20-windows-511-1-089f849` — `749375aa8666c2205840d2f41723ffdd3526fe017d219337dae78952f5374214`;
- macOS `OVDP-Hub-0.9.3-b20-macos-511-1-089f849` — `4664f2cdea03d4fcb61469037192c395c0fc8a92f9e62af61e6a94a091a69431`;
- Android `OVDP-Hub-Android-test-511-1` — `9e848a0330986f67e6df1c0c98413e34c8ce2ace5dbd3b5e6cacc781ca3894e0`;
- iOS `OVDP-Hub-iOS-unsigned-511-1` — `ab5a6755ffd016d4b3e38892e2ac45f1694e80c0245dbfbdd89f5be6b959872a`.

### Post-merge #512 — SUCCESS

- main `e6e0a6ae…`;
- analyze PASS;
- **218 tests PASS**;
- START/source PASS.

## Межа доказу

Harness implementation, regression tests та compile/package gates закриті.

**Physical-device runtime validation ще НЕ закрита.** GitHub CI не може довести:
- Android SAF grant persistence після terminate/relaunch на реальному пристрої;
- Android revoke/provider-loss semantics на реальному пристрої;
- iOS bookmark restore/security-scope після terminate/relaunch на реальному пристрої;
- iOS stale/lost/provider edge cases на реальному пристрої.

Не ставити статус `RUNTIME VALIDATED`, доки немає Android + iOS device evidence.

## Поточний NEXT

**Виконати реальний Android/iOS external-storage runtime validation через інтегровану self-test панель.**

### Android
1. Встановити APK із run #511: `OVDP-Hub-Android-test-511-1`.
2. Відкрити `Сховище` → mobile storage validation.
3. Почати тест і вибрати реальну папку/provider.
4. Зафіксувати phase 1 screenshot з app version + OS.
5. Повністю terminate застосунок.
6. Запустити знову та завершити phase 2.
7. Окремо перевірити revoked grant/provider loss → fail-closed.
8. Записати device model / Android version / provider / build / outcome у Issue #18 за `docs/maintenance/MOBILE_STORAGE_RUNTIME_VALIDATION.md`.

### iOS
1. Потрібен development-signed build/Xcode або інша підписана тестова збірка; unsigned CI artifact не є інсталяційним proof для iPhone.
2. Виконати picker → phase 1 → terminate → relaunch → phase 2.
3. Перевірити stale/lost/provider access fail-closed.
4. Записати device model / iOS version / provider / build / outcome у Issue #18.

Після Android + iOS PASS можна окремим docs/status slice змінити статус mobile external storage на `RUNTIME VALIDATED`.

## Deferred gates

- Windows production code signing;
- macOS Developer ID + notarization;
- Android production keystore/store distribution;
- iOS production signing/distribution;
- installers/auto-update.

## Recovery

Новий чат читає `START_HERE.md` → `PROJECT_RULES.md` → `PROJECT_STATE.md` → цей `WORKLOG.md` → фактичний GitHub → останні Issue #18 записи.

PR #130, #131 і #132 не повторювати. Код harness інтегрований у `main`; наступна робота залежить від фізичного Android/iOS device evidence.
