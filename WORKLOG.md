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

Мета: **tax assumptions → official effective-date audit → calculation → persistence → 7-language UI → tests**.

- baseline `main`: `847b0b1684dc2c6ca4e13435d03adf4356376276`
- active branch: `feat/planner-tax-assumptions`
- published checkpoint: **v0.8.7 / 0.8.7+15**
- audit completed 23.09.2026 against official sources:
  - PIT interest: current Tax Code section IV, p.p. 165.1.2 — government-bond interest excluded from taxable income;
  - PIT investment profit: p.p. 165.1.52 + current 2026 DPS explanation — OVDP investment profit excluded;
  - military levy: current 2026 DPS guidance states OVDP income is not subject to levy;
  - stale pre-23.05.2020 wording that excluded 165.1.2/165.1.52 from the levy exemption must not be used; DPS documents the 2020 amendment removing that wording.
- verified 2026 preset remains four explicit **0%** rules for Ukraine-resident individual / OVDP.
- safety rule: unknown taxes are never zero; non-zero tax rules stay fail-closed until a tax-base model is explicitly implemented.

### Поточна наступна дія

**DOING — wire only the verified 2026 Ukraine-resident OVDP preset.**

1. refresh preset source/date metadata;
2. retain `TaxScenario` in PlannerState/load/save;
3. add a tax impact evaluator that distinguishes unknown vs verified zero and fails closed on unsupported non-zero bases;
4. add unknown / verified-2026 UI and post-fee/post-tax result semantics;
5. localize tax controls/status/errors for UK/EN/FR/DE/ES/KO/JA;
6. add domain/cubit/persistence/widget tests;
7. green verify → PR → integrate into `main`.

FX and exit remain out of this slice.

## Черга робіт

1. **DONE** — multiple `PriceObservation` + explicit user source priority.
2. **DONE** — purchase fee assumptions → calculation + UI.
3. **DOING** — tax assumptions → official effective-date audit → calculation + UI.
4. **TODO** — FX assumptions calculation/UI.
5. **TODO** — exit assumptions redesign/wiring for multi-position scenarios.
6. **TODO** — A/B/C comparison.
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
