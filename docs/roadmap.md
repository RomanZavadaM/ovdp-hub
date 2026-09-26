# Roadmap OVDP Hub

Оновлено: **26.09.2026**. Цей roadmap стосується лише активного Flutter-продукту `apps/native`.

## Продуктовий принцип

Рухаємося вертикальними user-visible slices: **перевірені факти → явна актуальність → явні assumptions → план → порівняння → factual encrypted portfolio → безпечний platform storage/distribution**. Завершений і перевірений slice інтегрується у `main` до старту наступного.

Команда власника **«злити у main»** означає окремий full cross-platform test-release checkpoint із новою version/build, Windows/macOS/Android/iOS + START/source, checksums/legal, immutable tag і GitHub prerelease.

## Завершені продуктові етапи

### 0.9 «Ринок» — DONE / RELEASED
- [x] NBU instrument/contractual payments.
- [x] MinFin calendar + placement/switch results з provenance і fail-closed parsers.
- [x] Seller observations без вигаданої market price.
- [x] Source date / retrievedAt / freshness/status.
- [x] Multiple `PriceObservation` + explicit user priority.
- [x] Yield-only / nominal не стають market price автоматично.
- [x] v0.9.0 released.

### Planner next generation — DONE
- [x] Typed scenario/schema adapters.
- [x] Explicit purchase fees / unknown state.
- [x] Effective-dated tax assumptions.
- [x] Explicit FX assumptions.
- [x] Per-position early exit.
- [x] One-off / recurring needs.
- [x] Reserve floor.
- [x] Neutral A/B/C comparison для 2–3 compatible scenarios без automatic winner.
- [x] Deterministic CSV/ICS exports.
- [x] Safe criteria/date editing with explicit reset confirmation.
- [x] Unified locale-friendly Planner/Portfolio date-control UX; canonical persisted dates remain `YYYY-MM-DD`.

### UI / localization — DONE for current scope
- [x] Classic / Workbench / Light Dashboard.
- [x] UK / EN / FR / DE / ES / KO / JA.
- [x] Catalog and domain/error localization.
- [x] Locale-neutral user-authored collection names.
- [x] Language + appearance persistence in non-sensitive app preferences, separate from workspace/private vault.

### Encrypted vault / factual portfolio — DONE for current factual scope
- [x] Threat model and audited crypto stack.
- [x] Platform device-key adapters.
- [x] Local encrypted vault lifecycle, recovery-wrapped DEK, atomic recovery, rollback detection.
- [x] Session/inactivity/background locking.
- [x] Recovery enable/rotate/remove + local deletion lifecycle.
- [x] Private factual payload/domain.
- [x] Acquisition lots / derived holdings.
- [x] Explicit factual sale/disposal allocation.
- [x] Coupon / redemption.
- [x] Per-ISIN ledger + closed positions.
- [x] Factual per-currency cash summary with unknown-fee semantics.
- [x] Non-destructive legacy plaintext migration wizard.
- [x] Recovery-secret confirmation/rotation UX.
- [x] Windows user-facing portable encrypted backup/restore.
- [x] v0.9.3+20 released after factual Portfolio slices.

## Після v0.9.3

- [x] Post-v0.9.3 usability/product audit — PR #116; findings in `docs/AUDIT_POST_0_9_3.md`.
- [x] Portfolio recovery / backup UX — PR #117; exact-head #417, merge `fc38177a…`, post-merge #418.
- [x] Planner safe criteria/date editing — PR #119; exact-head #420, merge `ad3a995a…`, post-merge #421.
- [x] Catalog localization + persisted collection variant cleanup — PR #120; final exact-head #428, merge `5638f56e…`, post-merge #429.
- [x] Persist language/appearance preferences — PR #123; exact-head #439, merge `6e6326c6…`, post-merge #440.
- [x] Unified date-control UX / picker for Planner + Portfolio — PR #125; final exact-head #452, Ready #453 packaged desktop smoke, merge `c94fbce6…`, post-merge #454.
- [x] **macOS Portfolio runtime Keychain validation + enablement — PR #127.** Proof-before-enable run #462; post-enable run #464; final docs-synced #465 with **204 tests** + Windows/macOS packaged smoke; merge **`4c1617b3…`**; post-merge #466 + START/source success.

## Поточний NEXT

- [ ] **NEXT — Android SAF + iOS security-scoped external-folder access.**
  - Android: supported user-facing external workspace/backup file flow через SAF; no desktop path assumptions.
  - iOS: supported external file/folder flow через security-scoped platform contract/bookmarks.
  - Persistent access/permission loss must fail closed and surface explicitly.
  - Add platform-specific runtime/regression evidence, not compile-only mocks.
  - Do not change encrypted Portfolio schema or financial math in this slice.

## Після mobile storage gate

- [ ] Production signing / distribution readiness:
  - Windows Authenticode code signing;
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
- Portable external-file backup/restore UI: **Windows-only** until mobile/macOS file-flow gates are explicitly completed.

## Незмінні межі

Без окремого рішення власника не додаються централізований private portfolio server, KYC, private relay, embedded partner secrets або виконання угод.
