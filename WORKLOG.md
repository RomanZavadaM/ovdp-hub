# WORKLOG — OVDP Hub

Оновлено: **02.10.2026** (v0.10.0 опубліковано; додано план аудиту)

## STATUS

**ACTIVE — власник відновив розробку 01.10.2026.**

Scope: security/privacy hardening за аудитом 01.10.2026 + перші продуктові напрямки B → release checkpoint **v0.10.0**.

Базовий `main`: `60174b37eb22d4e3018f8412924906737045c33e` (v0.9.4 parked checkpoint + closure record).

## Рішення власника (01.10.2026)

- A.1: відкриття портфеля може вимагати **пароль відновлення** (опція; DEK пристрою видаляється, vault відкривається через recovery slot). Нової криптографії не додається.
- A.2: сценарії Planner з приватними сумами зберігаються **у vault**, а не plaintext у робочій папці.
- Slice-и інтегруються у `main` після зелених checks на розсуд розробника; повний реліз — лише за командою «злити у main».
- Локального Flutter немає: перевірка через CI та виконавчі збірки з GitHub.
- Deferred backlog (physical-device validation, signing, notarization, stores, installers) **не береться**.

## Release checkpoint v0.10.0 — DONE (02.10.2026)

- Версія **0.10.0+22**; release PR #142 → `933a7bd27e0f4babe47f44a32f8bf9214b4b18a4`.
- Release run **#116 — SUCCESS** (264 tests, Windows/macOS exact packaged smoke з capabilities, Android, iOS unsigned, START/source, SHA256SUMS, legal, publish).
- Main verify **#561 — SUCCESS**. GitHub prerelease `v0.10.0` опубліковано 02.10.2026.
- Інтегровано: S1 #138, S2 #139, S3 #140, S4 #141, S5 + B.1 + B.2 + B.1b + release metadata #142.
- Docs-sync: README ×7, PROJECT_STATE, roadmap, START_HERE, user guides ×7 — PR `docs/v0-10-0-sync`.

## NEXT

Активного slice немає. Наступний scope визначає власник; кандидати — B.3 симулятор реінвестування, B.4 імпорт виписок, B.5 аналітика аукціонів, B.6 річний звіт (`docs/roadmap.md`).

## Планування аудиту 02.10.2026

За дорученням власника F1–F10 додано до майбутньої роботи: [backlog](docs/maintenance/AUDIT_BACKLOG_2026_10_02.md), [Issue #147](https://github.com/RomanZavadaM/ovdp-hub/issues/147). P1: цілісність міграції/workspace, приватний Planner після lock, перевірка KDF race; P2: notes/export/inactivity, partial NBU, packaged докази, docs.

Статус пунктів **PLANNED**, виправлення не почато. F4 — гіпотеза для контрольованого тесту, F9 — межа доказу. Документаційна гілка `docs/audit-planned-work-2026-10-02`, база `31c2004298f1b804439692e8bfb7562d3952c8ba`. Наступна продуктова дія — визначення scope власником. v0.10.0, B.3–B.6 та deferred physical-device/signing backlog без змін.

## Попередній checkpoint (історія)


**v0.9.4 / 0.9.4+21** — release PR #135, commit `1185ad7f94339cd8865f3123570b9ad14a935114`, release run #113, main verify #518. Деталі — `PROJECT_STATE.md`, `docs/PROJECT_CLOSURE_v0_9_4.md`.

## Deferred backlog — НЕ NEXT

- Android physical SAF persistence/revoke/provider-loss test;
- iOS development signing і physical iPhone runtime validation;
- Windows code signing;
- macOS notarization;
- Android/iOS store signing/distribution;
- installers / auto-update.

## Recovery rule

1. `START_HERE.md`;
2. `PROJECT_RULES.md`;
3. `PROJECT_STATE.md`;
4. цей `WORKLOG.md`;
5. фактичний GitHub `main`, відкриті PR, latest release;
6. останні записи Issue #18.

Не повторювати вже merged роботу; продовжувати з першої незавершеної дії активного slice.
