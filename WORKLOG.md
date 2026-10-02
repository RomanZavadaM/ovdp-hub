# WORKLOG — OVDP Hub

Оновлено: **02.10.2026** (S1–S4 інтегровано, release v0.10.0 у роботі)

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

## Release checkpoint v0.10.0 (команда власника «злити у main», 02.10.2026)

Версія: **0.10.0+22** (функціональний етап: нові користувацькі можливості B.1/B.2 → minor).

| # | Slice | Статус |
|---|-------|--------|
| S1 | CSV/ICS export escaping; desktop focus-loss не блокує портфель | DONE — PR #138 → `a339ecfc` |
| S2 | Пароль відновлення при відкритті портфеля (A.1) | DONE — PR #139 → `4ea48cf4` |
| S3 | Сценарії Planner у vault + перенесення plaintext-сценаріїв (A.2) | DONE — PR #140 → `cc697691` |
| S4 | Видалення локального портфеля; вихід із конфліктів; підтверджений restore старішої копії (A.3) | DONE — PR #141 → `b19d485f` |
| S5 | Argon2 у фоновому ізоляті; толерантний парсер НБУ; Android SAF I/O | Release PR #142 |
| B.1 | Калькулятор облігації з каталогу (НКД, YTM) + річна дохідність плану | Release PR #142 (раніше #143, #145) |
| B.2 | Очікувані надходження портфеля + підказки «можливо, не записано» | Release PR #142 (раніше #144) |

## Поточна дія — release PR #142

- Гілка: `fix/v095-runtime-hardening` (S5 + B.1 + B.2 + B.1b + release metadata).
- Release metadata: `pubspec` 0.10.0+22, `CHANGELOG.md`, `docs/releases/RELEASE_NOTES_v0_10_0.md`, release contract `capabilities` + `privatePortfolioSchemaVersion` і їх перевірка в `scripts/verify-desktop-release.ps1`.
- Готово, коли: зелені checks на exact head (verify, Windows/macOS packaged smoke, Android, iOS, release preflight); merge → release workflow публікує prerelease `v0.10.0`.
- Наступна дія після публікації: docs-sync PR (README ×7, PROJECT_STATE, roadmap, START_HERE: release SHA/run, assets, SHA-256) + запис в Issue #18.

## Попередній checkpoint

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
