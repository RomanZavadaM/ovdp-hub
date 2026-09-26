# WORKLOG — OVDP Hub

Оновлено: **26.09.2026**

Точка входу: `START_HERE.md`  
Постійні правила: `PROJECT_RULES.md`  
Підтверджений стан main: `PROJECT_STATE.md`  
Append-only ledger: GitHub Issue **#18**

> Детальний append-only розвиток і проміжні невдалі/успішні runs зберігаються в Issue #18. Цей файл тримає останні інтегровані slices і поточний NEXT, щоб новий чат не повертався назад.

## Поточний опублікований checkpoint

**v0.9.3 / 0.9.3+20**

- release commit: `e2ec96322a1acb953589eeeb45e8ec50cd5d198a`;
- published GitHub prerelease: v0.9.3;
- release run #106 — success;
- published tag/assets не переписуються.

## Останні завершені slices

### Post-v0.9.3 usability/product audit — DONE
- PR #116 → `bb961f9d11d8c5a245e0fa0689fa74e7f092eb93`;
- canonical findings: `docs/AUDIT_POST_0_9_3.md`.

### Portfolio recovery / backup UX — DONE
- PR #117 → `fc38177a69f387153ff3984d3a917a7975a4a647`;
- recovery confirmation/rotation;
- Windows portable encrypted backup/restore;
- exact-head #417, post-merge #418 — success.

### Planner safe criteria/date editing — DONE
- PR #119 → `ad3a995a3f5e405cdde7d17b00b54fa105b926e5`;
- invalid/intermediate date input no longer mutates canonical Planner state;
- invalidating criteria changes require explicit confirmation;
- exact-head #420, post-merge #421 — success.

### Catalog localization + collection variant cleanup — DONE
- PR #120 → `5638f56e43ba81fadb3420f53b0eda54d7eb5f7a`;
- final exact-head #428, post-merge #429 — success;
- user-authored collection names remain locale-neutral.

### UI language + appearance persistence — DONE
- PR #123 → `6e6326c6c8ed00e86908a1eb533bd0cb80bdfaaf`;
- exact-head #439 — **197/197 tests** + Windows/macOS packaged smoke;
- post-merge #440 — verify + START/source success;
- selected language/appearance restore across launches from non-sensitive app preferences.

### Unified reusable date-control UX — DONE
- PR #125 → `c94fbce63bc53cc9f1a2b87a555f056c14e533f5`;
- one shared locale-friendly date control for Planner + Portfolio;
- canonical persistence remains `YYYY-MM-DD`;
- final exact-head #452, Ready #453 packaged Windows/macOS smoke, post-merge #454 — success.

### macOS Portfolio Keychain runtime validation + enablement — DONE

Base main before slice: `e1b20add6b674b02bb83a8d0a1362de2d2c471f0`  
Branch: `feat/macos-portfolio-keychain-runtime`  
PR: **#127**

#### Gate A — proof before enablement
- macOS secure-storage moved to ordinary app-local system Keychain for current unsigned/non-provisioned test build: `usesDataProtectionKeychain: false`;
- packaged macOS runtime smoke validates real Keychain DEK/revision state and vault lifecycle;
- pre-enablement head `4568de2d6a833e5a723ebf50c6f289a75f842cbf`;
- Ready run **#462 — success**;
- real packaged sequence: create/open → lock/reopen → save → backup/delete/restore → recovery rotation → old-secret rejection → new-secret restore → cleanup;
- macOS artifact `OVDP-Hub-0.9.3-b20-macos-462-1-404de25`, SHA-256 `26eba99618fd40758aaa7a2c91deb1f4653596d4fadc114bed220abd66201c78`.

#### Gate B — enablement after proof
- macOS added to encrypted Portfolio supported platform capability only after Gate A green;
- capability regression: Windows/macOS/Android/iOS supported; Linux/Fuchsia/web unsupported;
- portable external-file backup/restore UI remains Windows-only;
- enablement commit `3d32a05dd61327e219653e418a9ce448a58fc0e8`;
- platform-contract head `c5a23e087b0bf168ee757cc0fc63849ebb802f4b`;
- native run **#464 — success**: verify + Windows packaged smoke + macOS packaged Keychain/vault smoke.

#### Final exact-head + integration
- docs-synced PR head: **`890917667b97a5ff4950e2d4dda43fbc6152881a`**;
- final native run **#465 — success**: `flutter analyze`, **204 tests**, Windows packaged smoke, macOS packaged real Keychain/vault smoke;
- final Windows artifact: `OVDP-Hub-0.9.3-b20-windows-465-1-2f0b228`, SHA-256 `c3df3476537f9ea061521aab9b03f1408f040177aab9e4d968eb538b8eab57d7`;
- final macOS artifact: `OVDP-Hub-0.9.3-b20-macos-465-1-2f0b228`, SHA-256 `1ad00208a63e1585d524503751c2315ba61593d39653f4af18ad87b641e2bf76`;
- release-PR run **#110 — success** for exact Windows/macOS release ZIP smoke;
- merge: **`4c1617b3f0636c6ca33a35b2f992766dc4649cde`**;
- post-merge main run **#466 — success**, including verify + START/source;
- START artifact `OVDP-Hub-0.9.3-test-466-1-START`, SHA-256 `5b7dcb427357ab88785223434d6ab3784e1682e6ecb75a592cca9a6431ea21cb`;
- release workflow after merge recognized existing v0.9.3 and safely skipped republishing.

## Поточний slice

Статус: **IDLE / SAVED — NEXT READY**

Поточний інтегрований product baseline:
**`4c1617b3f0636c6ca33a35b2f992766dc4649cde`**.

Поточна `docs/sync-after-macos-keychain` — лише state-sync після вже інтегрованого PR #127; не є implementation source.

## Поточна наступна дія

**NEXT — Android SAF + iOS security-scoped external-folder access.**

Scope наступного implementation slice:
- user-facing external workspace / backup file flow на Android через SAF, без прямого desktop path assumption;
- user-facing external file/folder access на iOS через security-scoped platform contract/bookmarks;
- не змінювати encrypted Portfolio schema або фінансову математику;
- не змішувати цей slice з production signing/notarization/store distribution;
- fail closed, якщо external permission/persistent access втрачений;
- додати реальні platform regressions/gates, а не лише compile mocks.

## Deferred gates

- Windows production code signing;
- macOS Developer ID + notarization;
- Android production keystore/store distribution;
- iOS signing/distribution;
- installers/auto-update;
- подальші audit UX/domain slices після mobile storage gate.

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
