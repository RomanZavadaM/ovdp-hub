# PROJECT_STATE — OVDP Hub

Оновлено: **26.09.2026**

Цей файл містить лише підтверджений актуальний стан `main`. Детальна історія версій — у `CHANGELOG.md`, `docs/releases/` та GitHub Issue #18.

## Поточний checkpoint

- Версія: **v0.9.3 / 0.9.3+20**
- Статус: **test / prerelease**
- Release commit: **`e2ec96322a1acb953589eeeb45e8ec50cd5d198a`**
- Post-merge Flutter checks + START/source: **run #405 — success**
- Publish native prerelease: **run #106 — success**
- GitHub Release: **v0.9.3**, published 25.09.2026
- Активний продукт: **Flutter/Dart, `apps/native`**
- Платформи: Windows, macOS, Android, iOS
- Основна гілка: **`main`**
- Основна мова: українська
- Додаткові UI-мови: EN / FR / DE / ES / KO / JA
- Поточний інтегрований product baseline після release: **`6e6326c6c8ed00e86908a1eb533bd0cb80bdfaaf`**

## Опубліковані assets v0.9.3

- `OVDP-Hub-0.9.3-Windows-x64.zip`
- `OVDP-Hub-0.9.3-macOS.zip`
- `OVDP-Hub-0.9.3-Android-test.zip`
- `OVDP-Hub-0.9.3-iOS-unsigned.zip`
- `OVDP-Hub-0.9.3-START.zip`
- `SHA256SUMS.txt`
- `LICENSE.md`, `COPYRIGHT.md`, `THIRD_PARTY_NOTICES.md`, `LEGAL_AND_COPYRIGHT.md`

Windows/macOS release artifacts пройшли exact packaged ZIP smoke: ZIP розпаковується, запускається саме packaged executable, перевіряються product/version/build та appearance contract.

## Що реально працює

### Ринок
- локальний каталог ОВДП на базі публічних даних НБУ;
- картка ISIN з окремими шарами НБУ / Мінфін / продавці;
- provenance, source date, retrieved time, freshness/status;
- структурований календар аукціонів Мінфіну;
- detailed placement/switch results;
- кілька price observations із явним user priority;
- yield-only і nominal не стають market price автоматично.

### Планувальник
- budget / reserve / horizon / settlement delay;
- purchase fee assumptions з explicit unknown;
- verified tax assumptions;
- explicit FX comparison;
- per-position early sale;
- one-off / recurring needs;
- reserve floor;
- neutral A/B/C comparison для 2–3 compatible scenarios без automatic winner;
- deterministic CSV / ICS exports;
- stable generated-copy localization;
- invalid/intermediate manual date drafts не очищають composition;
- зміни ключових критеріїв, що інвалідовують сформований план, вимагають explicit confirmation.

### UI
- Classic;
- «Робочий кабінет» / Workbench;
- «Світла панель» / Light Dashboard;
- UK / EN / FR / DE / ES / KO / JA;
- selected UI language та appearance зберігаються між запусками в app-support `ui-preferences.json`;
- UI preferences не змішуються з workspace/private vault;
- corrupt/unknown preference JSON fail-safe повертає Ukrainian + Workbench замість блокування запуску.

### Encrypted vault / «Мій портфель»
- local encrypted vault;
- create / open / lock;
- inactivity/background locking;
- recovery secret confirmation at portfolio creation;
- user-facing recovery secret rotation;
- portable encrypted backup/restore primitives;
- Windows user-facing portable encrypted backup and restore into an empty local portfolio;
- Android/iOS external-file backup UI remains deferred to SAF/security-scoped access;
- macOS encrypted Portfolio remains disabled pending real Keychain runtime/provisioning validation;
- rollback/crash recovery controls;
- factual acquisition;
- factual sale/disposal з explicit acquisition-lot allocation;
- factual coupon / redemption;
- deterministic per-ISIN ledger;
- closed positions remain inspectable;
- factual per-currency cash summary;
- unknown acquisition/disposal fees залишаються unknown;
- exact net cash result приховується, якщо релевантна fee unknown;
- current market value відкритих позицій не додається до factual cash result;
- explicit non-destructive legacy migration wizard;
- migration verifies encrypted copy and never auto-deletes source JSON.

## Ключові інтеграції після v0.9.2

- PR #101 → `c255c937500d17b41cf0ac8542698139539fa047`: sale/redemption/history + legacy migration wizard; exact-head run #390, post-merge #391.
- PR #104 → `c8d26862430ac14dc25ad63da71bd016824ce91a`: factual coupon + per-ISIN ledger; exact-head #395, post-merge #396.
- PR #106 → `310afcc26728597e01d31c896d39b860bf4f20b5`: factual cash summary + closed positions; exact-head #399, post-merge #400.
- PR #109 → `e2ec96322a1acb953589eeeb45e8ec50cd5d198a`: v0.9.3+20 release checkpoint; PR release run #105, post-merge #405, publish #106.
- PR #116 → `bb961f9d11d8c5a245e0fa0689fa74e7f092eb93`: post-v0.9.3 usability/product audit; exact-head run #414.
- PR #117 → `fc38177a69f387153ff3984d3a917a7975a4a647`: recovery confirmation + recovery rotation + Windows portable encrypted backup/restore UX; exact-head run #417, post-merge #418.
- PR #119 → `ad3a995a3f5e405cdde7d17b00b54fa105b926e5`: safe committed Planner criteria/date editing; exact-head #420, post-merge #421.
- PR #120 → `5638f56e43ba81fadb3420f53b0eda54d7eb5f7a`: real Catalog localization wiring + locale-neutral collection variants; final exact-head #428, post-merge #429.
- PR #123 → `6e6326c6c8ed00e86908a1eb533bd0cb80bdfaaf`: language/appearance persistence + fail-safe app preferences; exact-head #439 with **197/197 tests** and packaged Windows/macOS smoke, post-merge #440 with verify + START/source success.

## Перевірка user-visible desktop змін

- Ready PR із user-visible змінами тепер автоматично запускає Windows + macOS release build, versioned packaging і exact packaged executable smoke.
- Manual `workflow_dispatch` packages лишається доступним для окремих checkpoint/release перевірок.
- Android/iOS production/release packaging не перетворюється на обов’язковий gate кожного звичайного PR.

## Дані та privacy

- OVDP Hub не має центрального сервера приватного портфеля.
- Private portfolio зберігається локально в encrypted vault.
- Legacy workspace JSON може залишатися plaintext.
- Migration не видаляє source JSON автоматично.
- Non-sensitive UI preferences зберігаються окремо від workspace/vault.
- Не зберігати signing keys, KYC-документи чи інші secrets у legacy plaintext workspace.
- Робочі папки, vault, DB, keys і персональні файли не комітяться в Git.

## Фінансові інваріанти

- продукт не виконує купівлю/продаж;
- НБУ, Мінфін і продавці — різні шари даних;
- yield-only / nominal estimate не є автоматично ринковою ціною;
- unknown fee / tax / FX не означає zero;
- фактичний cash summary не є market valuation або performance metric;
- A/B/C не ранжує і не обирає «кращий» політичний/фінансовий варіант за користувача.

## Distribution readiness — ще не production

- Windows production code signing — TODO;
- macOS Developer ID + notarization — TODO;
- Android production keystore / store distribution — TODO;
- iOS signing/distribution — TODO;
- installers / auto-update — окремий майбутній етап;
- Android SAF / iOS security-scoped external-folder access — **DEFERRED** до mobile storage gate.

## Документація

- `README.md` + `docs/readme/` — GitHub product description сімома мовами;
- `docs/user-guide/` — user guides сімома мовами;
- `docs/releases/RELEASE_NOTES_v0_9_3.md` — release notes;
- `CHANGELOG.md` — історія помітних змін;
- `PROJECT_RULES.md` — постійні правила;
- `WORKLOG.md` — активний slice;
- `START_HERE.md` — recovery protocol.

## Repository cleanup

- Documentation PR #110 merged into `main` as **`df505e9ff7f3ebc2d9635935216bfe1eefaaf82d`**.
- PR #110 exact-head run **#407 — success**; post-merge main run **#408 — success**, including START/source.
- Stale duplicate PR #103 and #108 closed.
- One-time cleanup workflow run **#1** on `maintenance/one-time-branch-cleanup` — success.
- **109 obsolete non-main branches deleted; 0 failed deletions.**
- Old `docs/*`, `feat/*`, `feature/*`, `release/*`, `stabilize/*` and other dead branch refs are no longer development sources.
- Published Git tags, GitHub Releases and commit history were not deleted.
- Temporary active branch/PR refs are development transport only; merged code in `main` remains source of truth.
- Repository hygiene workflow is safe-by-default: it auto-deletes only a same-repository branch after its PR is merged; bulk deletion is manual-only (`workflow_dispatch`).

## Наступний великий крок

**NEXT — unified reusable date-control UX / picker для Planner + Portfolio.** Ціль: locale-friendly display, picker + keyboard fallback, explicit validation, canonical existing persistence і **без зміни persisted schema**. Planner state-safety foundation уже інтегрований, тому цей slice має уніфікувати саме користувацький ввід/вибір дат, а не переписувати Planner domain. Після нього окремими gate лишаються macOS Portfolio runtime Keychain validation, mobile external-folder permissions і production signing/distribution.
