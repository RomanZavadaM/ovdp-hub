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

## Останній завершений slice

Статус: **DONE**

Мета: **v0.9.3 user documentation + GitHub cleanup**.

Завершено:
- root GitHub README оновлено під v0.9.3;
- localized GitHub README: UK / EN / FR / DE / ES / KO / JA;
- user guides: UK / EN / FR / DE / ES / KO / JA;
- native README актуалізовано;
- PROJECT_STATE / WORKLOG / START_HERE ущільнено;
- roadmap/changelog синхронізовано;
- stale duplicate PR #103 і #108 закрито;
- documentation PR #110 merged як `df505e9f…`;
- one-time branch cleanup workflow — success;
- **109 старих branches видалено, failed = 0**;
- tags/releases/commit history збережено;
- після фінального видалення sync branch live development branch = **`main` only**.

## Поточна наступна дія

**NEXT — post-v0.9.3 usability/product audit на актуальному `main`: пройти реальні user-visible navigation / portfolio / planner flows як цілісний продукт, знайти UX/logic gaps і сформувати один наступний self-contained slice.**

Не відновлювати старі feature/docs/release branches як джерела коду.

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
