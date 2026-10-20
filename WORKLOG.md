# WORKLOG — OVDP Hub

Оновлено: **20.10.2026** (F1/F2/F3 інтегровано, NEXT F4)

## STATUS

**ACTIVE — власник відновив розробку 01.10.2026.**

Scope: завершення аудиту F1–F10, далі продуктові інтеграції продавців за планом 20.10.2026.

Базовий `main` для NEXT F4: `463207cda15eb47310eba6e178d30b27251eed28`.

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

F4 FOLLOW-UP ACTIVE — branch `fix/lifecycle-key-cleanup-20261020`, draft PR #153, base main `73df0e71a90a0738cf307820dde155b338c97866` після F6.

Контрольований regression-only run 39419555995 (a5f5cf5): analyze PASS, 294 tests PASS + 2 FAIL. Create після lock повернув PrivatePortfolioPayload; dispose під час protection-mode change залишив hasUnlockedKey == true в початковому store. Це додаткові крайові випадки після #151, не спростування primary recovery-open fix.

Fix: key-retaining cleanup тримає original store reference до завершення; create/restore/migration охоплені generation guard від початку всієї gateway operation (включно з picker/workspace waits). Додано 5 tests до main після F6: create lock/dispose, protection-change dispose, restore picker-lock/recovery-dispose. Restore tests використовують synthetic mobile transport + real encrypted vault на CI host, не physical-device runtime. Криптографію, KDF, payload format і release version не змінено. Наступна дія: exact-head analyze/tests → platform gates → merge; до цього follow-up не DONE. Точний head/run — Issue #18.

F6 DONE — PR #152 → main `73df0e71a90a0738cf307820dde155b338c97866`; run 39418461683 SUCCESS (305 tests, 12 нових UI tests, Windows/macOS exact ZIP smoke, Android release, iOS unsigned). Private CSV/ICS мають explicit plaintext consent і destination; cancel/lock/draft/workspace changes не запускають export. Post-merge verify/START — див. GitHub/Issue #18.

F4 primary DONE — PR #151 → main 81639128557afc77777040b5d363b0d7d3701f7e, run 39416807438 SUCCESS (293 tests + усі platform gates); post-merge main run 39417929019 SUCCESS (verify + START).

Після follow-up: F5, окремий docs-only branch `fix/private-collections-20261020`, plan `docs/F5_PRIVATE_COLLECTIONS_PLAN.md` (код F5 ще не реалізовано). F5 branch переприв’язати до actual main і почати з schema compatibility/round-trip tests, потім editor/save/lock та explicit verified move. Інші P2 лишаються backlog.

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
