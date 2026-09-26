# PROJECT_STATE — OVDP Hub

Оновлено: **26.09.2026**

## Поточний стан

- Статус розвитку: **PARKED / завершений на поточному рівні**.
- Активного NEXT: **немає**.
- Версія: **v0.9.4 / 0.9.4+21**.
- Статус релізу: **test / prerelease parked checkpoint**.
- Release/product checkpoint commit: **`1185ad7f94339cd8865f3123570b9ad14a935114`**.
- GitHub prerelease: **v0.9.4**, published 26.09.2026.
- Release run **#113 — SUCCESS**.
- Main verification run **#518 — SUCCESS**.
- Активний продукт: Flutter/Dart, `apps/native`.
- Платформи checkpoint: Windows / macOS / Android / iOS unsigned.
- UI-мови: UK / EN / FR / DE / ES / KO / JA.

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

## Verification v0.9.4

Release run **#113**:
- `flutter analyze` PASS;
- **218/218 tests PASS**;
- Windows exact release ZIP build/package/smoke PASS;
- macOS exact release ZIP build/package/smoke PASS;
- Android release APK package PASS;
- iOS unsigned release package PASS;
- START/source PASS;
- SHA256SUMS + legal notices PASS;
- publish PASS.

Release assets / SHA-256:
- Windows `OVDP-Hub-0.9.4-Windows-x64.zip` — `0203b4954af348f00615d9703b2ffaab789a0dc469da046d5b40522fb3a099fb`;
- macOS `OVDP-Hub-0.9.4-macOS.zip` — `755f91d58e9fa0380f8afce3208c80f758980c2e76420cb65440ffe03db712a2`;
- Android `OVDP-Hub-0.9.4-Android-test.zip` — `08c27afc8eeef7bcd7ecb72cbc748b6c5b94cb2cdfd2674501cd0612b3404440`;
- iOS `OVDP-Hub-0.9.4-iOS-unsigned.zip` — `d71f90b8ab7017a893f52a24a4c5cf74efc7ba47fe744b37389f58b0a867c919`;
- START `OVDP-Hub-0.9.4-START.zip` — `aed97f11bd77bc0d9ab6f7781053d4470f64f5745e18412e24d2e3bc36d6def2`.

## Межа доказу / deferred

Нижче — **не активна робота**, а відкладений backlog для можливого майбутнього відновлення:
- Android physical-device SAF persistence/revoke/provider-loss validation;
- iOS development signing + physical-device bookmark/security-scope validation;
- Windows production signing;
- macOS Developer ID + notarization;
- Android/iOS production store signing/distribution;
- installers / auto-update.

CI/compile evidence не прирівнюється до physical-device `RUNTIME VALIDATED`. Це чесно зафіксована межа v0.9.4, але вона не блокує PARKED-статус.

## Відновлення розробки

Нову роботу не починати автоматично. Якщо власник вирішить повернутися до OVDP Hub, спочатку прочитати `START_HERE.md`, перевірити actual `main`/latest release/Issue #18, а потім створити новий scope. Merged PR #116–#135 не використовувати як окремі джерела коду і не повторювати завершені slices.
