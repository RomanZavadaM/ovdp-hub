# PROJECT_STATE — OVDP Hub

Оновлено: **02.10.2026**

## Поточний стан

- Статус розвитку: **ACTIVE** — розробку відновлено власником 01.10.2026.
- Версія: **v0.10.0 / 0.10.0+22**.
- Статус релізу: **test / prerelease**.
- Release/product commit: **`933a7bd27e0f4babe47f44a32f8bf9214b4b18a4`** (release PR #142).
- GitHub prerelease: **v0.10.0**, published 02.10.2026.
- Release run **#116 — SUCCESS**; main verification **#561 — SUCCESS**.
- Активний продукт: Flutter/Dart, `apps/native`.
- Платформи: Windows / macOS / Android / iOS unsigned.
- UI-мови: UK / EN / FR / DE / ES / KO / JA.
- Активного NEXT немає до нового рішення власника про scope (кандидати — продуктові напрямки B.3–B.6 у `docs/roadmap.md`).

Детальна історія зберігається в `CHANGELOG.md`, `docs/releases/`, merged PR і GitHub Issue #18. Цей файл навмисно не дублює повний журнал розробки.

## Що працює на цьому checkpoint

### Ринок і Planner
- локальний каталог ОВДП та окремі шари НБУ / Мінфін / продавці;
- provenance/freshness/status;
- календар і результати аукціонів Мінфіну;
- Planner budget/reserve/horizon, fees/tax/FX, recurring/one-off needs, reserve floor;
- per-position early exit;
- neutral A/B/C comparison;
- deterministic CSV/ICS;
- safe criteria/date editing і locale-friendly shared date controls.

### UI
- Classic / Workbench / Light Dashboard;
- UK / EN / FR / DE / ES / KO / JA;
- persistence language + appearance у non-sensitive app preferences.

### Encrypted Portfolio
- local encrypted factual portfolio;
- create/open/lock, inactivity/background locking;
- recovery confirmation/rotation;
- factual purchase/sale/coupon/redemption;
- explicit sale lot allocation, без invented FIFO/LIFO;
- per-ISIN ledger, closed positions, factual per-currency cash summary;
- unknown fees remain unknown;
- non-destructive legacy migration;
- Windows portable encrypted backup/restore;
- macOS system Keychain device state з real packaged lifecycle smoke.

### Mobile external storage
- Android SAF bridge з persisted tree-grant contract;
- iOS security-scoped bookmark bridge;
- external mobile workspace + encrypted backup transport;
- permission/provider loss fail-closed;
- integrated two-phase terminate/relaunch self-test panel;
- implementation/regression/compile gates закриті.

### Нове у v0.10.0
- опційний пароль відновлення при відкритті портфеля (DEK лише в пам'яті сесії, лічильник ревізій зберігається);
- сценарії Planner із приватними сумами лише у vault (payload schema v4), перевірене перенесення plaintext-сценаріїв;
- видалення локального портфеля, підтверджений restore старішої копії, повідомлення про конфлікти;
- калькулятор облігації з каталогу (НКД, YTM), очікувані надходження портфеля на 12 місяців, річна дохідність плану;
- Argon2id у фоновому ізоляті, formula-safe CSV, толерантне оновлення каталогу НБУ, Android SAF I/O поза UI-потоком.

## Verification v0.10.0

Release run **#116**:
- `flutter analyze` PASS;
- **264 tests PASS**;
- Windows / macOS exact release ZIP build/package/smoke PASS (version/build + release-contract capabilities + private portfolio schema v4);
- Android release APK package PASS;
- iOS unsigned release package PASS;
- START/source, SHA256SUMS + legal notices, publish PASS.

Release assets / SHA-256:
- Windows `OVDP-Hub-0.10.0-Windows-x64.zip` — `7b8b981ad6f05050992c9ba4b5940870ca499e65513228cf5dbe0694ed64ad8d`;
- macOS `OVDP-Hub-0.10.0-macOS.zip` — `1ad8ecfde0b4a7230cb629496ef8821e7420cd98821e5ededb6640f95ac1bae2`;
- Android `OVDP-Hub-0.10.0-Android-test.zip` — `d47659e58c63cf49352b4947ae449aae217abe00d0a9e48bbceafa5276bc0281`;
- iOS `OVDP-Hub-0.10.0-iOS-unsigned.zip` — `78eb17e38270695cd3f3421149c4a5cd7a2b82abe246f135c4e776e3e3570caa`;
- START `OVDP-Hub-0.10.0-START.zip` — `ae7cb6b7d8b698faf0360678f26679ad16f8aad1cc3ebb17d99a931e32eedba4`;

## Межа доказу / deferred

Нижче — **не активна робота**, а відкладений backlog для можливого майбутнього відновлення:
- Android physical-device SAF persistence/revoke/provider-loss validation;
- iOS development signing + physical-device bookmark/security-scope validation;
- Windows production signing;
- macOS Developer ID + notarization;
- Android/iOS production store signing/distribution;
- installers / auto-update.

CI/compile evidence не прирівнюється до physical-device `RUNTIME VALIDATED`. Це чесно зафіксована межа тестових релізів.

## Продовження розробки

Новий чат починати з `START_HERE.md` → `PROJECT_RULES.md` → цей файл → `WORKLOG.md` → фактичний GitHub (`main`, open PR, latest release) → Issue #18. Merged PR #138–#142 не повторювати.
