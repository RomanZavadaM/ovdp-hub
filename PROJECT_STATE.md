# PROJECT_STATE — OVDP Hub

Оновлено: **26.09.2026**

Цей файл містить лише підтверджений актуальний стан продукту в `main`. Детальна історія — у `CHANGELOG.md`, `docs/releases/` та GitHub Issue #18.

> **Baseline semantics:** SHA product baseline нижче означає останній коміт, що змінював product code. Пізніші docs-only sync коміти не змінюють цей baseline. Фактичний branch head `main` завжди перевіряється безпосередньо в GitHub під час startup protocol.

## Поточний checkpoint

- Версія: **v0.9.3 / 0.9.3+20**
- Статус: **test / prerelease**
- Published release commit: **`e2ec96322a1acb953589eeeb45e8ec50cd5d198a`**
- GitHub Release: **v0.9.3**, published 25.09.2026
- Активний продукт: **Flutter/Dart, `apps/native`**
- Платформи: Windows, macOS, Android, iOS
- Основна гілка: `main`
- Основна мова: українська
- Додаткові UI-мови: EN / FR / DE / ES / KO / JA
- Поточний product-code baseline: **`e6e0a6ae3fb74b6fab8adf155eb6d3d338a11959`** (PR #132)
- Останній post-merge product verification: **run #512 — success**, `flutter analyze` + **218 tests** + START/source.
- Post-merge state docs synchronized separately by PR #133; docs-only sync не створює нового product-code baseline.

## Published assets v0.9.3

- `OVDP-Hub-0.9.3-Windows-x64.zip`
- `OVDP-Hub-0.9.3-macOS.zip`
- `OVDP-Hub-0.9.3-Android-test.zip`
- `OVDP-Hub-0.9.3-iOS-unsigned.zip`
- `OVDP-Hub-0.9.3-START.zip`
- `SHA256SUMS.txt`
- legal notices.

Published v0.9.3 artifacts remain immutable. Після post-release integration slices існуючий release не переписується.

## Що реально працює

### Ринок
- локальний каталог ОВДП на базі публічних даних НБУ;
- картка ISIN з окремими шарами НБУ / Мінфін / продавці;
- provenance, source date, retrieved time, freshness/status;
- календар аукціонів Мінфіну + placement/switch results;
- multiple price observations з explicit user priority;
- yield-only / nominal не стають market price автоматично.

### Планувальник
- budget / reserve / horizon / settlement delay;
- purchase fee, tax, FX assumptions з explicit unknown;
- per-position early sale;
- one-off / recurring needs;
- reserve floor;
- neutral A/B/C comparison без automatic winner;
- deterministic CSV / ICS exports;
- safe criteria/date editing;
- shared locale-friendly date control для Planner + Portfolio;
- canonical persisted date representation `YYYY-MM-DD`.

### UI / localization
- Classic;
- Workbench / «Робочий кабінет»;
- Light Dashboard / «Світла панель»;
- UK / EN / FR / DE / ES / KO / JA;
- selected language та appearance persist у non-sensitive app preferences;
- corrupt/unknown preference JSON fails safe to Ukrainian + Workbench.

### Encrypted vault / «Мій портфель»
- local encrypted vault;
- create / open / lock;
- inactivity/background locking;
- recovery secret confirmation + rotation;
- rollback/crash recovery controls;
- factual acquisition;
- factual sale/disposal з explicit lot allocation;
- factual coupon / redemption;
- deterministic per-ISIN ledger;
- closed positions remain inspectable;
- factual per-currency cash summary;
- unknown fees remain unknown;
- explicit non-destructive legacy migration wizard;
- migration verifies encrypted copy and never auto-deletes source JSON.

## Platform storage / device-key capability

### Windows
- encrypted Portfolio supported;
- app-owned DPAPI device state;
- user-facing portable encrypted backup/restore supported;
- packaged executable smoke enforced in Ready PR gates.

### macOS
- encrypted Portfolio supported;
- device DEK/revision state uses system Keychain via `flutter_secure_storage`;
- real packaged Keychain/vault lifecycle smoke enforced;
- external portable file-flow remains a separate gate.

### Android
- encrypted app-local Portfolio/device-key path supported;
- Android SAF external-storage foundation integrated in PR #130;
- persisted tree-grant contract, bounded read/write/list/delete, encrypted backup transport and fail-closed semantics implemented;
- **real-device runtime probe UI integrated in PR #132**;
- release APK compile/package verified;
- physical-device persisted-grant/revoke runtime evidence still pending.

### iOS
- encrypted app-local Portfolio/device-key path supported;
- iOS external-storage foundation integrated in PR #130;
- document/folder picker, bookmark persistence contract, `startAccessingSecurityScopedResource()` and coordinated I/O implemented;
- **real-device runtime probe UI integrated in PR #132**;
- unsigned release compile/package verified;
- physical-device bookmark/provider-loss runtime evidence still pending.

## Mobile external storage foundation — DONE for implementation/compile scope

PR #130 → merge **`5934984a3ad763f8c9f77bd0872077c381adacc2`**.

Evidence:
- exact-head docs-synced PR head `f6243794eea927e4b73cb85f666739d62c633e8f`;
- final PR run **#497 — success**: `flutter analyze`, **212 tests**, Windows/macOS packaged smoke, Android release APK compile/package, iOS unsigned release compile/package;
- post-merge main run **#498 — success**, verify + START/source.

## Mobile real-device runtime probe harness — DONE for implementation/CI scope

PR #132 → squash merge **`e6e0a6ae3fb74b6fab8adf155eb6d3d338a11959`**.

Реалізовано:
- production-backed two-phase `MobileStorageRuntimeProbe` поверх Android SAF / iOS bookmark bridge;
- phase 1: picker → write → read → list;
- app-private pending state with opaque grant/bookmark ref, display label, token, launch id;
- completion у тому самому process launch заборонена;
- phase 2 після terminate/relaunch: persisted access check → old probe read/list → rewrite/read → delete → final list verification;
- permission/provider loss fail-closed;
- видима mobile validation panel у `Сховище`;
- локалізація UK / EN / FR / DE / ES / KO / JA;
- app version + OS visible for evidence screenshot;
- maintenance protocol: `docs/maintenance/MOBILE_STORAGE_RUNTIME_VALIDATION.md`.

Verification:
- exact PR head **`4d59750c0bea01d39cf495ab054befc1beb6e266`**;
- run #510 — `flutter analyze` + **218/218 tests** success;
- final Ready run **#511 — success**: verify, Windows/macOS packaged smoke, Android release APK, unsigned iOS release;
- Windows #511 SHA-256 `749375aa8666c2205840d2f41723ffdd3526fe017d219337dae78952f5374214`;
- macOS #511 SHA-256 `4664f2cdea03d4fcb61469037192c395c0fc8a92f9e62af61e6a94a091a69431`;
- Android #511 SHA-256 `9e848a0330986f67e6df1c0c98413e34c8ce2ace5dbd3b5e6cacc781ca3894e0`;
- iOS #511 SHA-256 `ab5a6755ffd016d4b3e38892e2ac45f1694e80c0245dbfbdd89f5be6b959872a`;
- post-merge `main` run **#512 — success**: `flutter analyze`, **218/218 tests**, START/source;
- START #512 SHA-256 `a9d62bd77b433c26f3ab9fdfa4d1ac9b8b385dab22b4e5b2a5b6a12798e4a4f9`.

Important boundary: implementation, regression and compile/package evidence are proven. **Physical-device persistent external-access semantics are not yet claimed as validated.**

## Ключові post-release integrations

- PR #116: post-v0.9.3 usability/product audit.
- PR #117: recovery confirmation/rotation + Windows portable encrypted backup/restore.
- PR #119: safe Planner criteria/date editing.
- PR #120: Catalog localization + locale-neutral collection variants.
- PR #123: language/appearance persistence.
- PR #125: unified Planner/Portfolio date controls.
- PR #127 → `4c1617b3…`: macOS Keychain runtime proof + encrypted Portfolio enablement.
- PR #130 → `5934984a…`: Android SAF + iOS security-scoped external-storage foundation.
- **PR #132 → `e6e0a6ae…`: mobile two-phase real-device runtime probe harness.**
- PR #133: docs-only post-merge recovery/state sync.

## CI / verification rules now active

- Ready PR with user-visible desktop changes builds/packages Windows + macOS and smokes packaged executable.
- macOS smoke includes real Keychain/vault lifecycle contract.
- Ready PR mobile-storage changes compile/package Android release APK and unsigned iOS release build.
- `main` push verification runs analyze/tests and produces START/source artifact.
- Production signing/distribution remains separate.

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
- factual cash summary не є market valuation або performance metric;
- A/B/C не ранжує і не обирає «кращий» варіант за користувача.

## Distribution readiness — ще не production

- Windows production code signing — TODO;
- macOS Developer ID + notarization — TODO;
- Android production keystore/store distribution — TODO;
- iOS signing/distribution — TODO;
- installers / auto-update — окремий майбутній етап.

## Наступний крок

**NEXT — Android/iOS real-device external-storage runtime validation через інтегровану self-test панель.**

Потрібен фактичний device evidence для:
- Android SAF picker → persisted URI grant → terminate/relaunch → read/write/list/delete → revoked grant/provider loss fail-closed;
- iOS folder picker → bookmark save/restore → terminate/relaunch → security-scoped read/write/list/delete → stale/lost/provider access fail-closed.

Android можна тестувати на APK із run #511. iOS unsigned CI artifact є лише compile evidence; для iPhone потрібен development-signed build/Xcode або інша підписана тестова збірка.

Без Android + iOS device evidence mobile external storage не називати повністю `RUNTIME VALIDATED`.
