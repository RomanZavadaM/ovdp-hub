# WORKLOG — OVDP Hub

Оновлено: **25.09.2026**

Точка входу: `START_HERE.md`  
Постійні правила: `PROJECT_RULES.md`  
Підтверджений стан main: `PROJECT_STATE.md`  
Append-only ledger: GitHub Issue **#18**

## Поточний опублікований checkpoint

**v0.9.3 / 0.9.3+20**

- release commit: `e2ec96322a1acb953589eeeb45e8ec50cd5d198a`;
- post-release documentation merge: `df505e9ff7f3ebc2d9635935216bfe1eefaaf82d`;
- release run #106 — success;
- documentation PR #110 exact-head run #407 — success;
- post-merge documentation run #408 — success.

## Останні завершені slices

### Post-v0.9.3 usability/product audit — DONE
- audit base: `63227a8951f02acf426f1064e0f115c73a22fa80`;
- audit document: `docs/AUDIT_POST_0_9_3.md`;
- PR #116 exact head `3aed94c46f72e0edc40b42f76171b7f5c3016bd0`;
- exact-head run #414 — success;
- merge: `bb961f9d11d8c5a245e0fa0689fa74e7f092eb93`.

### Portfolio recovery / backup UX — DONE
- base main: `bb961f9d11d8c5a245e0fa0689fa74e7f092eb93`;
- PR #117 final exact head: `5d396b15f38c22457d2e1f37fb5357ef241a3d3a`;
- exact-head run #417 — success;
- merge: **`fc38177a69f387153ff3984d3a917a7975a4a647`**;
- post-merge main run #418 — success, including START/source;
- branch hygiene run #9 — success;
- recovery secret при створенні тепер підтверджується повторним вводом;
- recovery secret можна змінити через user-facing control;
- Windows має user-facing portable encrypted backup та restore у порожній локальний портфель;
- Android SAF / iOS security-scoped external-file flows не підмінені desktop API й залишаються deferred;
- macOS Portfolio лишається окремим runtime Keychain validation gate;
- UI та user guides синхронізовані UK / EN / FR / DE / ES / KO / JA.

### Planner safe criteria/date editing — DONE
- PR #119 exact head `adc6d5798c097dd78e8d1678afaad71ce00c1842`;
- exact-head run #420 — success;
- merge: **`ad3a995a3f5e405cdde7d17b00b54fa105b926e5`**;
- post-merge run #421 — success, including START/source;
- invalid/intermediate `start/minDate/maxDate` text no longer mutates Planner state;
- invalidating `currency/start/minDate/maxDate` changes require explicit confirmation when composition/exits exist;
- Cancel preserves the current plan; Apply performs the deliberate reset;
- persisted Planner schema and calculation math unchanged.

## Останні завершені slices

### Catalog localization + persisted collection variant cleanup — DONE
- PR #120 final exact head `fa0d6e829c2c5e54e5b03fe5d59f45efd437f782`;
- first runs #422/#424 correctly failed and exposed a no-op CRLF patch;
- final exact-head run #428 — success;
- merge: **`5638f56e43ba81fadb3420f53b0eda54d7eb5f7a`**;
- post-merge run #429 — success, including START/source;
- remaining Catalog user-facing literals now use existing `HubStrings` UK/EN/FR/DE/ES/KO/JA;
- visible English regression reaches the actual search/horizon controls;
- collection variant no longer persists automatic Ukrainian suffix `— варіант`; user-authored name stays locale-neutral.

## Поточний slice

Статус: **IDLE / SAVED**

Активного implementation PR немає. Поточний інтегрований `main`:
**`5638f56e43ba81fadb3420f53b0eda54d7eb5f7a`**.

## Поточна наступна дія

**NEXT — persist non-sensitive UI preferences: selected language + appearance.**  
Зберігати їх окремо від workspace/private vault; не змішувати з приватними даними. Потрібні restart/persistence regressions. Після цього окремо повернутися до unified date-control UX/picker, macOS Portfolio runtime validation та mobile external-folder gates.

## Deferred gates

- Android SAF / iOS security-scoped external-folder access;
- Windows production code signing;
- macOS Developer ID + notarization;
- Android production keystore/store distribution;
- iOS signing/distribution;
- installers/auto-update.

## Термінологія власника

- **«інтегрувати PR у main»** = звичайний технічний merge після green checks.
- **«злити у main»** = повний cross-platform test-release checkpoint з новою version/build, platform artifacts, START/source, checksums/legal, tag і GitHub prerelease.

## Recovery

Новий чат:
1. `START_HERE.md`;
2. `PROJECT_RULES.md`;
3. `PROJECT_STATE.md`;
4. цей `WORKLOG.md`;
5. фактичний GitHub `main` / open PR / CI;
6. останні записи Issue #18;
7. продовжити `NEXT`.
