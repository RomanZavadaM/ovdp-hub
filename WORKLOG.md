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

Активна наступна дія: **F4 — контрольована перевірка recovery/KDF проти lock**. Гілка `fix/recovery-lock-generation-20261020`, база main `463207cda15eb47310eba6e178d30b27251eed28`. PR ще немає; код F4 не змінено.

Спочатку додати відтворювальний test: почати gateway.open із recovery secret, призупинити KDF, виконати gateway.lock, завершити KDF. Перевірити session locked, відсутній кешований DEK (`hasUnlockedKey`), наступне відкриття без secret відмовляється. Наявні generation tests самого VaultSessionController не замінюють перевірку всього gateway. Лише після доказу — виправлення generation/cancellation/cleanup. Це гіпотеза аудиту; не називати її підтвердженим обходом блокування до тесту. Не змінювати криптографічні примітиви або параметри KDF.

## Нещодавно завершено — F1/F2/F3 DONE

- F1/F2: PR #149 → main `00a09b7bc5146cd2355082c01b34b67dcdc18918`, run 39411185021 SUCCESS: analyze, 274 tests (10 нових), Windows/macOS exact ZIP packaged smoke, Android release та iOS unsigned. Post-merge main run 39413010557 SUCCESS (verify + START).
- F3: PR #150 → main `463207cda15eb47310eba6e178d30b27251eed28`, run 39413819496 SUCCESS: analyze, **284 tests** (ще 10 нових), Windows/macOS exact ZIP packaged smoke, Android release та iOS unsigned. Private Planner очищується на session lock, transient dialogs/date picker закриваються, stale completions не повертають UI; нові/public drafts зберігаються.
- F3 перший CI мав 1 UI failure через неправильний finder кнопки lock; виправлено на реальний tooltip, усі подальші перевірки зелені.
- Уже розпочатий до lock export не видаляється ретроспективно. F6 про plaintext export лишається окремим пунктом.
- Post-merge main F3 verify/START: перевірити фактичний GitHub; фінальний запис — Issue #18.
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
