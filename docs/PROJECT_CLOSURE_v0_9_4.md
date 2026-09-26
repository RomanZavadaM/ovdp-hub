# OVDP Hub — PROJECT CLOSURE v0.9.4

Дата: **26.09.2026**  
Статус: **PARKED / завершено на поточному рівні**

## Фінальний checkpoint

- Version/build: **0.9.4+21**
- GitHub release/tag: **v0.9.4**
- Release target: **`1185ad7f94339cd8865f3123570b9ad14a935114`**
- Product-behavior baseline: **`e6e0a6ae3fb74b6fab8adf155eb6d3d338a11959`**
- Release workflow: **#113 — SUCCESS**
- Pre-merge native gate: **#517 — SUCCESS**
- Release PR gate: **#112 — SUCCESS**

## Опубліковані assets

- `OVDP-Hub-0.9.4-Windows-x64.zip` — SHA-256 `0203b4954af348f00615d9703b2ffaab789a0dc469da046d5b40522fb3a099fb`
- `OVDP-Hub-0.9.4-macOS.zip` — SHA-256 `755f91d58e9fa0380f8afce3208c80f758980c2e76420cb65440ffe03db712a2`
- `OVDP-Hub-0.9.4-Android-test.zip` — SHA-256 `08c27afc8eeef7bcd7ecb72cbc748b6c5b94cb2cdfd2674501cd0612b3404440`
- `OVDP-Hub-0.9.4-iOS-unsigned.zip` — SHA-256 `d71f90b8ab7017a893f52a24a4c5cf74efc7ba47fe744b37389f58b0a867c919`
- `OVDP-Hub-0.9.4-START.zip` — SHA-256 `aed97f11bd77bc0d9ab6f7781053d4470f64f5745e18412e24d2e3bc36d6def2`
- `SHA256SUMS.txt`, `LICENSE.md`, `COPYRIGHT.md`, `THIRD_PARTY_NOTICES.md`, `LEGAL_AND_COPYRIGHT.md`.

## Що є в продукті

- ринкові шари НБУ / Мінфін / продавці з provenance/freshness;
- Planner з fees/tax/FX/early exit/reserve floor/typed needs;
- neutral A/B/C comparison;
- CSV/ICS exports;
- 3 UI appearances;
- UK / EN / FR / DE / ES / KO / JA;
- local encrypted factual Portfolio;
- factual purchase/sale/coupon/redemption + explicit lot allocation;
- recovery rotation, Windows portable encrypted backup/restore;
- macOS Keychain Portfolio support;
- Android SAF / iOS security-scoped external-storage foundation;
- fail-closed mobile permission semantics;
- mobile external workspace + encrypted backup transport;
- two-phase runtime self-test harness across terminate/relaunch.

## Доказ якості checkpoint

- `flutter analyze` PASS;
- **218/218 tests PASS**;
- Windows exact packaged executable smoke PASS;
- macOS exact packaged executable + Keychain/vault lifecycle smoke PASS;
- Android release APK compile/package PASS;
- iOS unsigned release compile/package PASS;
- START/source package PASS;
- release assets + checksums + legal notices published.

## Свідомо відкладено

- Android physical-device SAF persistence/revoke/provider-loss validation;
- iOS development-signed build та physical iPhone runtime validation;
- Windows production signing;
- macOS notarization;
- Android/iOS store distribution;
- installers / auto-update.

Ці пункти **не блокують PARKED-статус** і не є активною роботою.

## Як відновлювати проєкт

1. Почати з `START_HERE.md`.
2. Прочитати `PROJECT_STATE.md` і `WORKLOG.md`.
3. Перевірити фактичний `main`, latest release та Issue #18.
4. Не брати код зі старих work/shadow branches.
5. Не повторювати вже merged slices.
6. Новий roadmap створювати тільки після нового рішення власника про подальший напрямок.

Цей документ є підсумковою точкою закриття OVDP Hub на рівні v0.9.4.
