# WORKLOG — OVDP Hub

Оновлено: **23.09.2026**

Цей файл — оперативна точка відновлення активної розробки.

Точка входу для нової сесії: `START_HERE.md`  
Постійні правила: `PROJECT_RULES.md`  
Стабільний стан `main`: `PROJECT_STATE.md`  
Append-only журнал: GitHub Issue **#18 — OVDP Hub — live development ledger**

## Статуси

- `NEXT` — наступна конкретна дія.
- `DOING` — робота реально триває.
- `VERIFIED` — перевірено, але ще не merged.
- `BLOCKED` — є конкретна перешкода.
- `DONE` — тільки після merge у `main`.

## Активна ціль

**0.9.0 «Ринок»**.

Поточний опублікований checkpoint: **v0.8.7 / 0.8.7+15**.

## Поточний slice

Статус: **DOING**

Мета: **A/B/C scenario comparison → strict comparability → explanatory metrics → 7-language UI → tests**.

- baseline `main`: `d0d1a50e6d28267398b1d400a3503a2ba12bf566`
- active branch: `feat/planner-abc-comparison`
- published checkpoint: **v0.8.7 / 0.8.7+15**
- audit:
  - `PlannerScenario` already contains `groupId` and `variantLabel`, but current UI does not use them;
  - saved planner scenarios already live in `CollectionsView`, so comparison should reuse those immutable SavedSet records;
  - hard comparability boundary: currency, budget, reserve, start/horizon, settlement delay and economic needs must match;
  - strategy, positions, selected prices, fees, tax status, FX and exits may differ and are explanatory comparison dimensions;
  - two or three scenarios only;
  - no automatic winner/ranking in this slice; A/B/C are neutral display labels;
  - scenarios with unsupported recurring/reserveFloor needs fail closed until those need types are wired through active planner calculations.

### Поточна наступна дія

**DOING — comparison in “Мій план”.**

1. strict pure evaluator for 2–3 SavedSet planner scenarios;
2. reconstruct positions and reuse the same exit-aware fee → tax → FX → expense calculations as Planner;
3. select up to 3 saved scenarios in Collections;
4. table/cards: composition, strategy, initial cost, purchase fee status, tax status, reserve, profit basis/value, FX comparison, exits and expense shortfall;
5. clearly show shared baseline assumptions and why variants differ;
6. no best/worst label without explicit user criterion;
7. UK/EN/FR/DE/ES/KO/JA localization + domain/cubit/widget tests.

Generated planner copy/localization polish remains after this slice.

## Черга робіт

1. **DONE** — multiple `PriceObservation` + explicit user source priority.
2. **DONE** — purchase fee assumptions → calculation + UI.
3. **DONE** — tax assumptions → official effective-date audit → calculation + UI.
4. **DONE** — FX assumptions calculation/UI.
5. **DONE** — exit assumptions redesign/wiring for multi-position scenarios.
6. **DOING** — A/B/C comparison.
7. **TODO** — generated planner copy / preset labels localization + UX regression.
8. **TODO** — оцінка готовності formal prerelease 0.9.0.

## Продуктова логіка цієї черги

Не розширювати продукт новими ізольованими джерелами, доки не замкнений базовий шлях користувача:

**ринковий факт → freshness/provenance → вибір ціни → припущення витрат/податків/FX/exit → план → A/B/C comparison**.

Поточний MinFin results parser є першим кроком цього ланцюжка, а не окремою технічною ціллю.

## Ритм `main` і тестування

Термінологія власника:

- **«інтегрувати PR у `main`»** = звичайний технічний merge після green checks;
- **«злити у `main`»** = повний test-release checkpoint: нова version/build + Windows/macOS/Android/iOS + START/source + checksums/legal + новий GitHub prerelease.

Робочий ритм:

- кожен завершений self-contained slice: PR → green checks → **інтеграція PR у `main`**;
- не накопичувати кілька готових незлитих функціональних гілок;
- проміжно після user-visible integration можна тестувати START artifact з актуального `main`;
- регулярно, орієнтовно після 2–3 user-visible integrated slices, робити повне **«злиття у `main`»** з релізами всіх систем;
- робити такий checkpoint раніше після ризикової зміни parser/calculation/schema або одразу за прямою командою власника;
- поточний опублікований v0.8.7 не переписувати; кожен наступний повний checkpoint отримує нову версію/build.

## Нещодавно завершено

- **DONE — per-position exit assumptions**: PR #51 squash-merged у `main` як `296fb9e0b53093685ced9e801196616a401582f4`; final run #161 success. Multi-ISIN exit model, sale cashflow/profit/coverage, safe legacy compatibility, BID/manual provenance, persistence and 7-language UI integrated.


- **DONE — explicit FX comparison assumptions**: PR #48 squash-merged у `main` як `755c328e0d1b15d2d4843f434eaf774d80ff5494`; final run #152 success (88/88 tests). Explicit rate/date/source comparison, single-currency cashflow invariant, persistence, deferred advanced rules and 7-language UI integrated.


- **DONE — verified OVDP tax assumptions**: PR #45 squash-merged у `main` як `b47fd1360432a8336ca38666064eb46eebbd04f7`; final run #145 success. Official-source-audited 2026 zero-tax preset, unknown/verified-zero semantics, fail-closed non-zero tax base, persistence, post-fee/post-tax result UI and 7-language coverage integrated.


- **DONE — v0.8.7 full cross-platform checkpoint**: PR #42 squash-merged у `main` як `6ab844fd3063fbfa9fcf54ab875539241c459845`; `Publish native prerelease` run #37 success. Опубліковано Windows/macOS/Android/iOS/START + SHA256SUMS + legal notices під tag `v0.8.7`; GitHub Release description містить UK/EN/FR/DE/ES/KO/JA.


- **DONE — explicit purchase fee assumptions**: PR #41 squash-merged у `main` як `fbe8028ae1f68fcbb9c4c7a7057134c6793c00ae`; final run #135 success (80/80 tests). Planner зберігає typed fees, відрізняє unknown від confirmed zero, враховує явну aggregate purchase fee у budget/reserve/profit, показує gross caveat при unknown fees, не перезаписує richer typed rules і має 7-language UI/error coverage.


- **DONE — explicit price-source priority**: PR #39 squash-merged у `main` як `255d15294105e8d5ae6dfe216f1e900fe0490192`; final run #123 success. Planner зберігає кілька observations, explicit source priority, UI add/select/reorder + nominal fallback; yield-only/nominal не стають market price автоматично; UI локалізовано 7 мовами, regression/widget coverage зелені.

- **DONE — v0.8.6 full cross-platform checkpoint**: PR #37 squash-merged у `main` як `7b19670a2ff621a65685db714022d8819ecff7d4`; `Publish native prerelease` run #34 success; опубліковано Windows/macOS/Android/iOS/START + SHA256SUMS + legal notices під tag `v0.8.6`.

- **DONE — ISIN freshness/status UX**: PR #35 squash-merged у `main` як `e4f6d1cfe0544a28cc1afff81084e5dd898910ba`; final run #104 success. Official NBU/MinFin observations відокремлено від seller indicative quotes; для трьох шарів уніфіковано sourceDate/retrievedAt/freshness/status/evidence UI та 7 мов.

- **DONE — v0.8.5 full cross-platform checkpoint**: PR #33 squash-merged у `main` як `6e8ce5c7ccfd4217330e59fe96fd6a83ac531d59`; `Publish native prerelease` run #32 success; опубліковано Windows/macOS/Android/iOS/START + SHA256SUMS + legal notices під незмінним tag `v0.8.5`.

- **DONE — detailed MinFin auction results**: PR #31 squash-merged у `main` як `3f8ff04d1bddb221b5180384b547c6bd544a22d8`; final clean run #95 success. Реальні 2026 result DOCX перевірено; placement parser покриває 21-row × N layout, switch parser — 26-field layout; provenance, fail-closed validation, deterministic tests і локалізовані errors інтегровані.

- **DONE — owner command semantics**: PR #29 squash-merged у `main` як `75c62456e29a1882bbcf59d4a04e739966781da2`; run #81 success. «Злити у main» тепер канонічно означає повний cross-platform test release, а звичайний merge називається «інтегрувати PR у main».

- **DONE — product direction + regular test cadence**: PR #27 squash-merged у `main` як `531f33649da30eb9ec191632f11c418e33b7ddf7`; run #79 success. Зафіксовано vertical-slice порядок до 0.9.0, merge кожного завершеного slice у `main`, START-тест після user-visible merge та cross-platform checkpoint після 2–3 user-visible slices або раніше для ризикових core-змін.

- **DONE — MinFin structured future auction schedule**: PR #24 squash-merged у `main` як `1313339ac0241dc2ea50db3ea14494ea07871f3c`; stale PR #21 закрито без merge; final verify run #75 success; parser підтримує окремі monthly / quarterly / switch layouts, provenance, deterministic tests і fail-closed behavior.

- **DONE — v0.8.4**: prerelease published from commit `1cb857e2ac3850a830c4bdde4e78559e50f03985`; release workflow run #21 success; 56/56 tests passed; Windows/macOS/Android/iOS/START published with SHA256SUMS + legal notices.
- **DONE — PR #22**: release checkpoint 0.8.4.
- **DONE — PR #20**: typed MinFin calendar document index; merge `5a189a3b127ac80ed3a6faa2c0eff4ef342b540a`.
- **DONE — PR #17**: typed placement/switch auction event index + recovery protocol.
- **DONE — PR #15/#16**: typed AppError + domain/parser error localization.

## Якщо роботу перервано

1. прочитати `START_HERE.md`;
2. прочитати `PROJECT_RULES.md`;
3. прочитати `PROJECT_STATE.md`;
4. прочитати `WORKLOG.md`;
5. прочитати останні коментарі Issue #18;
6. перевірити фактичний `main`, активні PR і CI;
7. GitHub має пріоритет над застарілим текстом;
8. продовжити з першого `DOING/NEXT`.

## Правило для чату

Чат — інтерфейс керування роботою, **не сховище стану**. Усе, що змінює напрямок, scope, статус або наступну дію, повинно бути відображене в GitHub у цій же робочій сесії.
