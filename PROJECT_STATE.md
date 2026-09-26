# PROJECT_STATE — OVDP Hub

Оновлено: **26.09.2026**

Цей файл містить лише підтверджений актуальний стан `main`. Детальна історія версій — у `CHANGELOG.md`, `docs/releases/` та GitHub Issue #18.

## Поточний checkpoint

- Версія: **v0.9.3 / 0.9.3+20**
- Статус: **test / prerelease**
- Release commit: **`e2ec96322a1acb953589eeeb45e8ec50cd5d198a`**
- GitHub Release: **v0.9.3**, published 25.09.2026
- Активний продукт: **Flutter/Dart, `apps/native`**
- Платформи: Windows, macOS, Android, iOS
- Основна гілка: **`main`**
- Основна мова: українська
- Додаткові UI-мови: EN / FR / DE / ES / KO / JA
- Поточний інтегрований product baseline після release: **`4c1617b3f0636c6ca33a35b2f992766dc4649cde`**
- Останній post-merge main verification: **run #466 — success**, including verify + START/source.

## Опубліковані assets v0.9.3

- `OVDP-Hub-0.9.3-Windows-x64.zip`
- `OVDP-Hub-0.9.3-macOS.zip`
- `OVDP-Hub-0.9.3-Android-test.zip`
- `OVDP-Hub-0.9.3-iOS-unsigned.zip`
- `OVDP-Hub-0.9.3-START.zip`
- `SHA256SUMS.txt`
- legal notices.

Published v0.9.3 artifacts remain immutable. PR #127 did **not** republish v0.9.3; push release preflight recognized the existing release and skipped publish/build jobs.

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
- safe criteria/date editing з explicit confirmation при invalidating changes;
- один reusable locale-friendly date control для Planner + Portfolio;
- calendar picker + keyboard/ISO fallback;
- invalid/intermediate drafts не змінюють canonical state;
- persisted/domain date representation лишається `YYYY-MM-DD`.

### UI
- Classic;
- Workbench / «Робочий кабінет»;
- Light Dashboard / «Світла панель»;
- UK / EN / FR / DE / ES / KO / JA;
- selected language та appearance persist у app-support `ui-preferences.json`;
- preferences окремі від workspace/private vault;
- corrupt/unknown preference JSON fails safe to Ukrainian + Workbench.

### Encrypted vault / «Мій портфель»
- local encrypted vault;
- create / open / lock;
- inactivity/background locking;
- recovery secret confirmation + rotation;
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

#### Platform device-key / Portfolio capability

- **Windows:** app-owned DPAPI state; user-facing portable encrypted backup/restore available.
- **macOS:** encrypted Portfolio **enabled** after real packaged-app Keychain validation. Device DEK/revision state uses system Keychain through `flutter_secure_storage` with ordinary app-local Keychain semantics (`usesDataProtectionKeychain: false`) for the current unsigned/non-provisioned test build.
- **Android / iOS:** encrypted Portfolio app-local vault/device-key path remains supported through platform secure storage.
- Platform capability regression freezes Windows/macOS/Android/iOS as supported; Linux/Fuchsia/web unsupported.
- Portable external-file backup/restore UI remains **Windows-only**. macOS external file picker flow and Android/iOS external-folder access are separate storage gates.

## macOS Portfolio Keychain gate — DONE

PR #127 → merge **`4c1617b3f0636c6ca33a35b2f992766dc4649cde`**.

Evidence:

- Gate A, before enablement: native run **#462 — success**; packaged macOS app passed real Keychain/vault create/open/lock/reopen/backup/restore/recovery-rotation/cleanup smoke.
- Gate B, after enablement: native run **#464 — success**; analyze/tests + Windows packaged smoke + macOS packaged Keychain/vault smoke.
- Final docs-synced head `890917667b97a5ff4950e2d4dda43fbc6152881a`.
- Final native run **#465 — success**: **204 tests**, Windows packaged smoke, macOS packaged Keychain/vault smoke.
- Final #465 Windows artifact: `OVDP-Hub-0.9.3-b20-windows-465-1-2f0b228`, SHA-256 `c3df3476537f9ea061521aab9b03f1408f040177aab9e4d968eb538b8eab57d7`.
- Final #465 macOS artifact: `OVDP-Hub-0.9.3-b20-macos-465-1-2f0b228`, SHA-256 `1ad00208a63e1585d524503751c2315ba61593d39653f4af18ad87b641e2bf76`.
- Release-PR run **#110 — success** for exact Windows/macOS release ZIP smoke; mobile/start jobs skipped as expected on PR.
- Post-merge main run **#466 — success**, verify + START/source.
- START artifact: `OVDP-Hub-0.9.3-test-466-1-START`, SHA-256 `5b7dcb427357ab88785223434d6ab3784e1682e6ecb75a592cca9a6431ea21cb`.
- Release push after merge safely skipped republishing existing v0.9.3.

## Ключові інтеграції після v0.9.2

- PR #101 → `c255c937…`: sale/redemption/history + legacy migration wizard.
- PR #104 → `c8d26862…`: factual coupon + per-ISIN ledger.
- PR #106 → `310afcc2…`: factual cash summary + closed positions.
- PR #109 → `e2ec9632…`: v0.9.3+20 release checkpoint.
- PR #116 → `bb961f9d…`: post-v0.9.3 usability/product audit.
- PR #117 → `fc38177a…`: recovery confirmation/rotation + Windows portable encrypted backup/restore UX.
- PR #119 → `ad3a995a…`: safe Planner criteria/date editing.
- PR #120 → `5638f56e…`: Catalog localization + locale-neutral collection variants.
- PR #123 → `6e6326c6…`: language/appearance persistence.
- PR #125 → `c94fbce6…`: unified Planner/Portfolio date controls.
- PR #127 → **`4c1617b3…`**: real packaged macOS Keychain runtime proof + encrypted Portfolio enablement.

## Перевірка user-visible desktop змін

- Ready PR із user-visible desktop змінами автоматично запускає Windows + macOS release build, versioned packaging і exact packaged executable smoke.
- macOS desktop smoke тепер додатково виконує real Keychain/vault lifecycle contract.
- Manual `workflow_dispatch` packages лишається доступним для checkpoint/release перевірок.
- Android/iOS production packaging не є обов’язковим gate кожного звичайного PR.

## Дані та privacy

- OVDP Hub не має центрального сервера приватного портфеля.
- Private portfolio зберігається локально в encrypted vault.
- Legacy workspace JSON може залишатися plaintext.
- Migration не видаляє source JSON автоматично.
- Non-sensitive UI preferences зберігаються окремо від workspace/vault.
- Робочі папки, vault, DB, keys і персональні файли не комітяться в Git.

## Фінансові інваріанти

- продукт не виконує купівлю/продаж;
- НБУ, Мінфін і продавці — різні шари даних;
- yield-only / nominal estimate не є автоматично ринковою ціною;
- unknown fee / tax / FX не означає zero;
- фактичний cash summary не є market valuation або performance metric;
- A/B/C не ранжує і не обирає «кращий» варіант за користувача.

## Distribution readiness — ще не production

- Windows production code signing — TODO;
- macOS Developer ID + notarization — TODO;
- Android production keystore / store distribution — TODO;
- iOS signing/distribution — TODO;
- installers / auto-update — окремий майбутній етап.

## Наступний великий крок

**NEXT — Android SAF + iOS security-scoped external-folder access.** Наступний slice має дати підтримуваний user-facing external workspace/backup file flow на mobile через platform-native contracts, без підміни desktop filesystem API. Production signing/notarization/store distribution лишається окремим пізнішим gate.
