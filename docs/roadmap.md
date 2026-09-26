# Roadmap OVDP Hub

Оновлено: **26.09.2026**

## Статус roadmap

**PARKED — поточний roadmap завершений на checkpoint v0.9.4 / 0.9.4+21.**

Активного наступного етапу немає. Новий roadmap створюється лише після окремого рішення власника відновити OVDP Hub.

## Завершений scope

### Ринок
- NBU instrument/contractual data;
- MinFin calendar + placement/switch results;
- seller observations;
- provenance/freshness/status;
- multiple price observations + explicit source priority.

### Planner
- budget/reserve/horizon;
- fees/tax/FX assumptions;
- recurring/one-off needs + reserve floor;
- per-position early exit;
- neutral A/B/C comparison;
- deterministic CSV/ICS;
- safe criteria/date editing.

### UI / localization
- Classic / Workbench / Light Dashboard;
- UK / EN / FR / DE / ES / KO / JA;
- persisted language/appearance;
- shared locale-friendly date controls.

### Encrypted factual Portfolio
- encrypted local vault and session lifecycle;
- recovery confirmation/rotation;
- factual purchase/sale/coupon/redemption;
- explicit acquisition-lot allocation;
- per-ISIN ledger + closed positions;
- factual per-currency cash summary;
- non-destructive legacy migration;
- Windows portable encrypted backup/restore;
- macOS Keychain runtime proof and Portfolio support.

### Platform storage
- Android SAF external-storage foundation;
- iOS security-scoped bookmark foundation;
- mobile external workspace and encrypted backup transport;
- fail-closed permission semantics;
- integrated two-phase terminate/relaunch runtime self-test;
- Android/iOS compile/package gates.

### Distribution checkpoint
- **v0.9.4 / 0.9.4+21**;
- release run #113 SUCCESS;
- Windows/macOS exact packaged release smoke;
- Android test APK;
- unsigned iOS build;
- START/source;
- SHA256SUMS + legal notices;
- GitHub prerelease/tag `v0.9.4`.

## Deferred — лише якщо власник відновить проєкт

- Android physical-device SAF persisted-access/revoke/provider-loss validation;
- iOS development signing + physical-device security-scoped validation;
- Windows Authenticode;
- macOS Developer ID + notarization;
- Android production keystore/store distribution;
- iOS production signing/distribution;
- installers / auto-update;
- нові UX/domain/data-source slices.

Deferred пункти не вважаються активним backlog і не блокують PARKED checkpoint.

## Незмінні межі

Без окремого рішення власника не додаються централізований private portfolio server, KYC, private relay, embedded partner secrets або виконання угод. OVDP Hub лишається local-first інформаційно-аналітичним інструментом і не виконує купівлю/продаж.
