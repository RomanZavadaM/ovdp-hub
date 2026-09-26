# Roadmap OVDP Hub

Оновлено: **26.09.2026**. Цей roadmap стосується активного Flutter-продукту `apps/native`.

## Продуктовий принцип

Рухаємося вертикальними user-visible slices: **перевірені факти → явна актуальність → явні assumptions → план → порівняння → factual encrypted portfolio → безпечний platform storage/distribution**. Завершений і перевірений slice інтегрується у `main` до старту наступного.

Команда власника **«злити у main»** означає окремий full cross-platform test-release checkpoint із новою version/build, Windows/macOS/Android/iOS + START/source, checksums/legal, immutable tag і GitHub prerelease.

## Завершені продуктові етапи

### 0.9 «Ринок» — DONE / RELEASED
- NBU instrument/contractual payments;
- MinFin calendar + placement/switch results з provenance і fail-closed parsers;
- seller observations без вигаданої market price;
- source date / freshness/status;
- multiple `PriceObservation` + explicit user priority;
- v0.9.0 released.

### Planner next generation — DONE
- typed scenarios, fees/tax/FX assumptions;
- per-position early exit;
- one-off / recurring needs + reserve floor;
- neutral A/B/C comparison;
- deterministic CSV/ICS;
- safe criteria/date editing + shared locale-friendly date control.

### UI / localization — DONE for current scope
- Classic / Workbench / Light Dashboard;
- UK / EN / FR / DE / ES / KO / JA;
- locale-neutral user names;
- language + appearance persistence outside private vault/workspace.

### Encrypted factual portfolio — DONE for current factual scope
- audited crypto/vault lifecycle and recovery;
- Windows DPAPI, macOS Keychain, Android/iOS secure device state;
- factual acquisition / sale allocation / coupon / redemption / ledger / cash summary;
- non-destructive plaintext migration;
- Windows portable encrypted backup/restore;
- v0.9.3+20 released.

## Після v0.9.3 — завершені інтегровані slices

- Post-v0.9.3 usability/product audit — PR #116.
- Portfolio recovery / backup UX — PR #117.
- Planner safe criteria/date editing — PR #119.
- Catalog localization + collection cleanup — PR #120.
- Persist language/appearance — PR #123.
- Unified date controls — PR #125.
- macOS Portfolio Keychain runtime validation + enablement — PR #127; final #465, merge `4c1617b3…`, post-merge #466.

## Поточний mobile storage foundation

PR **#130** implements Android SAF + iOS picker/bookmark external-storage contracts without changing Portfolio crypto or financial math.

Verified pre-docs head `7e26ef3cc691e683f7b9ca2a6d2c631690eb95fb`, run **#496 — SUCCESS**:
- analyze + **212/212 tests**;
- Windows/macOS packaged smoke;
- Android release APK compile/package;
- unsigned iOS release compile/package.

This closes the **implementation + release compile gate**, not the real-device runtime gate.

## Current NEXT — mobile real-device runtime validation

- [ ] Android physical device:
  - SAF folder selection;
  - persisted read/write URI grant across app relaunch;
  - workspace read/write/list/delete;
  - revoked/missing provider permission fails closed.
- [ ] iOS physical device:
  - folder picker selection;
  - bookmark persistence/resolution across relaunch;
  - security-scoped workspace read/write/list/delete;
  - stale/lost/provider permission fails closed.
- [ ] Record device/OS, exact build/artifact, steps and outcomes in Issue #18 + maintenance gate.
- [ ] Only after this evidence may mobile external workspace/backup be described as runtime-validated.

## Після mobile runtime gate

- [ ] Production signing / distribution readiness:
  - Windows Authenticode;
  - macOS Developer ID + notarization;
  - Android production keystore/store distribution;
  - iOS signing/distribution.
- [ ] Installers / auto-update — separate decision.
- [ ] Further audit UX/domain slices based on confirmed product findings.

## Platform capability snapshot

- Encrypted app-local Portfolio: Windows / macOS / Android / iOS.
- Windows device state: DPAPI.
- macOS device state: system Keychain, real packaged lifecycle smoke enforced.
- Android/iOS device state: platform secure storage.
- Windows portable encrypted external backup: runtime-supported.
- Android/iOS external storage bridge: implementation + release compile validated; **real-device persistent-access gate still pending**.

## Незмінні межі

Без окремого рішення власника не додаються централізований private portfolio server, KYC, private relay, embedded partner secrets або виконання угод.
