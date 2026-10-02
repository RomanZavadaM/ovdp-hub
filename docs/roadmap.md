# Roadmap OVDP Hub

Оновлено: **02.10.2026**

## Статус roadmap

**ACTIVE — останній тестовий реліз v0.10.0 / 0.10.0+22 (02.10.2026).** Наступний scope визначає власник.

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

Deferred пункти не вважаються активним backlog і не блокують тестові релізи.

## Незмінні межі

Без окремого рішення власника не додаються централізований private portfolio server, KYC, private relay, embedded partner secrets або виконання угод. OVDP Hub лишається local-first інформаційно-аналітичним інструментом і не виконує купівлю/продаж.

## v0.10.0 — завершено (02.10.2026)

- Захист приватних даних за аудитом 01.10.2026: пароль відновлення при відкритті, сценарії у vault, керування локальним портфелем, KDF у фоні, formula-safe CSV.
- B.1 калькулятор облігації з каталогу (НКД, YTM) + річна дохідність плану.
- B.2 очікувані надходження портфеля + підказки «можливо, не записано».

## Кандидати наступного scope (рішення власника)

- B.3 симулятор реінвестування купонів і погашень;
- B.4 локальний імпорт виписок брокера/банку з ручним підтвердженням;
- B.5 аналітика аукціонів Мінфіну (історія ставок за строками);
- B.6 річний звіт за фактичними даними (довідково, без податкових порад).

## Планована робота за аудитом 02.10.2026

Власник доручив зберегти F1–F10 як майбутню роботу. **PLANNED, реалізація не почата; активного slice немає.**

- P1: F1 перевірка вмісту перед видаленням plaintext; F2 незмінний workspace міграції; F3 приватний Planner після lock; F4 перевірка recovery/KDF race.
- P2: F5 приватність notes; F6 plaintext export notice; F7 inactivity activity; F8 partial NBU status; F9 поведінкові packaged докази; F10 актуальні технічні документи.

Деталі, критерії завершення і порядок: [audit backlog](maintenance/AUDIT_BACKLOG_2026_10_02.md), [Issue #147](https://github.com/RomanZavadaM/ovdp-hub/issues/147). F4 потребує відтворення; F9 описує межу доказу. Scope наступного етапу визначає власник; B.3–B.6 залишаються кандидатами.
