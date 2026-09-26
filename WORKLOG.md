# WORKLOG — OVDP Hub

Оновлено: **26.09.2026**

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

### Catalog localization + persisted collection variant cleanup — DONE
- PR #120 final exact head `fa0d6e829c2c5e54e5b03fe5d59f45efd437f782`;
- first runs #422/#424 correctly failed and exposed a no-op CRLF patch;
- final exact-head run #428 — success;
- merge: **`5638f56e43ba81fadb3420f53b0eda54d7eb5f7a`**;
- post-merge run #429 — success, including START/source;
- remaining Catalog user-facing literals now use existing `HubStrings` UK/EN/FR/DE/ES/KO/JA;
- visible English regression reaches the actual search/horizon controls;
- collection variant no longer persists automatic Ukrainian suffix `— варіант`; user-authored name stays locale-neutral.

### UI language + appearance persistence — DONE
- base main: `d6ed407af6c1106f9cd8f3808f4e0f2d52a5b2ef`;
- replacement branch: `feat/ui-preferences-persistence-v2`;
- PR #121 was closed as superseded after docs-sync moved the current `main` base;
- active replacement PR #123 final head: **`bc07bbb35ff5f06ead51ac00e3e62a158576b708`**;
- old run #430 exposed one stale `pumpAndSettle` widget timeout;
- run #435 exposed two real `dart:io` waits inside `testWidgets` fake-async after **195 tests passed**;
- regression structure fixed without weakening production persistence: real file round-trip/corrupt fallback stays in ordinary async tests; visible controls use an in-memory persistence contract; app reconstruction applies the restored snapshot;
- exact-head run **#439 — success**: `flutter analyze`, **197/197 tests**, Windows package + exact packaged executable smoke, macOS package + exact packaged executable smoke;
- Windows PR artifact: `OVDP-Hub-0.9.3-b20-windows-439-1-fec7e71`, digest `aeb82caa1a315cdd2119e08856b916e4943c432fd7d8804f1933290e4bcd3a7b`;
- macOS PR artifact: `OVDP-Hub-0.9.3-b20-macos-439-1-fec7e71`, digest `91023cb20145e293349874af4048f9ae5f4b5d41b8f485111dbe8a5ecb416651`;
- merge: **`6e6326c6c8ed00e86908a1eb533bd0cb80bdfaaf`**;
- post-merge main run **#440 — success**, including verify + START/source;
- START artifact: `OVDP-Hub-0.9.3-test-440-1-START`, digest `1a3cd5dd7e14792d126c10d45ec4f54d7eaca5f4f3fd3f440ae52c6badd31d49`;
- selected UK/EN/FR/DE/ES/KO/JA language and Classic/Workbench/Light Dashboard now restore across launches;
- corrupt/invalid preference JSON fails safe to Ukrainian + Workbench;
- UI preferences live in app-support `ui-preferences.json`, not workspace/private vault;
- user guides updated in all seven languages;
- CI now enforces Windows + macOS packaged desktop smoke automatically when a PR is Ready.

## Поточний slice

Статус: **IDLE / SAVED**

Активного implementation PR немає. Поточний інтегрований product baseline:
**`6e6326c6c8ed00e86908a1eb533bd0cb80bdfaaf`**.

Поточна `docs/sync-after-ui-preferences` — лише state-sync документації після вже інтегрованого PR #123; не є окремим implementation source.

## Поточна наступна дія

**NEXT — unified reusable date-control UX / picker для Planner + Portfolio.**

Scope наступного implementation slice:
- один reusable date control замість двох несумісних manual UX;
- locale-friendly display;
- calendar picker + keyboard fallback;
- explicit invalid/intermediate validation;
- canonical existing date persistence;
- **без зміни persisted Planner/Portfolio schema**;
- не ламати вже інтегровану Planner confirmation/state-safety поведінку;
- real visible-control regressions для Planner і Portfolio, включно з phone-sized reachability.

Після цього окремо повернутися до macOS Portfolio runtime Keychain validation/enablement, mobile external-folder access і distribution signing gates.

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
