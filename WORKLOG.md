# WORKLOG — OVDP Hub

Оновлено: **25.09.2026**

Точка входу: `START_HERE.md`  
Постійні правила: `PROJECT_RULES.md`  
Підтверджений стан main: `PROJECT_STATE.md`  
Append-only ledger: GitHub Issue **#18**

## Поточний опублікований checkpoint

**v0.9.3 / 0.9.3+20**

- release commit: `e2ec96322a1acb953589eeeb45e8ec50cd5d198a`;
- post-merge run #405 — success;
- full release run #106 — success;
- Windows/macOS exact packaged ZIP smoke — success;
- Android / unsigned iOS / START/source — success;
- tag/release `v0.9.3` published with SHA256 and legal notices.

## Поточний slice

Статус: **DOING**

Мета: **v0.9.3 user documentation + GitHub cleanup**.

- branch: `docs/v0.9.3-user-guides`;
- PR: **#110 — draft**;
- root GitHub README: rewritten for v0.9.3;
- localized GitHub descriptions: UK / EN / FR / DE / ES / KO / JA;
- user guides: UK / EN / FR / DE / ES / KO / JA;
- native README: synchronized with actual v0.9.3 behavior and distribution state;
- stale duplicate PR #103 — closed;
- stale duplicate PR #108 — closed;
- historical state docs are being compacted so released history lives in CHANGELOG/releases rather than active recovery files;
- final repository cleanup will remove obsolete non-main branches while preserving `main`, tags/releases and commit history.

### Поточна наступна дія

**DOING — open documentation PR, verify exact head, integrate it into main, then run one-time branch cleanup and verify that only main remains as the live development branch.**

## Нещодавно завершено

1. **DONE — v0.9.3+20 full prerelease checkpoint**: PR #109 → `e2ec9632…`; PR release run #105 green; main #405 green; publish #106 green; all platform assets published.
2. **DONE — factual cash summary + closed positions**: PR #106 → `310afcc2…`; exact-head #399; post-merge #400.
3. **DONE — factual coupon + per-ISIN ledger**: PR #104 → `c8d26862…`; exact-head #395; post-merge #396.
4. **DONE — sale/redemption/history + migration wizard**: PR #101 → `c255c937…`; exact-head #390; post-merge #391.
5. **DONE — v0.9.2+19**: `696fd4a…`; post-merge #381; release #102.

## Після cleanup

**NEXT — post-v0.9.3 usability/product audit з актуального `main`: перевірити user-visible navigation/portfolio/planner як цілісний продукт і сформувати наступний self-contained slice.**

Не повертатися до старих feature/docs/release branches. Android SAF / iOS security-scoped external-folder access і production signing залишаються deferred gates.

## Термінологія власника

- **«інтегрувати PR у main»** = звичайний технічний merge після green checks.
- **«злити у main»** = повний cross-platform test-release checkpoint з новою version/build, платформними artifacts, START/source, checksums/legal, tag і GitHub prerelease.

## Правило recovery

Новий чат:
1. прочитати `START_HERE.md`;
2. `PROJECT_RULES.md`;
3. `PROJECT_STATE.md`;
4. `WORKLOG.md`;
5. фактичний GitHub main/open PR/CI;
6. останні записи Issue #18;
7. продовжити перший `DOING` або `NEXT`.
