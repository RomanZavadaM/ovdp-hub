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

## Поточний slice

Статус: **DOING**

Мета: **post-v0.9.3 usability/product audit** на фактичному `main`.

- base main: `63227a8951f02acf426f1064e0f115c73a22fa80`;
- branch: `audit/post-v0.9.3-usability`;
- перевіряються реальні user-visible navigation / Catalog / Planner / Portfolio / appearance / localization / platform flows;
- аудит відділений від implementation: спочатку підтверджуємо хиби й пріоритет, потім один self-contained fix slice;
- старі branches не використовуються як джерела коду.

### Уже підтверджені findings

1. **HIGH · data safety:** vault core має recovery lifecycle та encrypted backup/restore primitives, але `PortfolioGateway`/UI не дають користувачу portable encrypted backup/restore/rotate recovery; user guide вже радить створювати encrypted portable backup.
2. **HIGH · recovery UX:** recovery secret при створенні портфеля вводиться один раз без confirmation, хоча потім не показується.
3. **HIGH · macOS product gap:** v0.9.3 macOS build публікується, але `LocalEncryptedPortfolioGateway.supported` не включає macOS; lower secure-storage adapter для macOS уже існує, тому потрібен окремий runtime/provisioning validation gate, а не сліпе ввімкнення.
4. **HIGH · Planner UX/state:** редагування `currency/start/minDate/maxDate` очищає generated positions; start/min/max TextFormField викликають `edit()` onChanged, тому ручне редагування дати може очистити composition/early exits без explicit confirmation.
5. **MEDIUM · date UX:** Planner використовує ручний `YYYY-MM-DD`, Portfolio — ручний `DD.MM.YYYY`; календарного picker немає.
6. **MEDIUM · localization:** CatalogView містить hardcoded Ukrainian user-facing text, попри наявні localized keys.
7. **MEDIUM · persisted copy:** створення варіанта добірки зберігає hardcoded suffix `— варіант`, незалежно від UI language.
8. **MEDIUM · preferences:** selected language та appearance не persist між запусками.
9. **MEDIUM · mobile confidence:** full Portfolio real-control regression є для desktop, але немає еквівалентного phone-flow regression.
10. **MEDIUM · portfolio/domain UX:** після partial redemption позитивний holding лишається, але sale intentionally fail-closed через відсутність redemption lot allocation; UI prefilter/disabled action погано пояснює причину.

### Поточна наступна дія

**DOING — оформити `docs/AUDIT_POST_0_9_3.md`, звірити findings із тестами/кодом, визначити один перший fix slice та відкрити audit PR.**

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
