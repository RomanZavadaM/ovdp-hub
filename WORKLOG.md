# WORKLOG — OVDP Hub

Оновлено: **24.09.2026**

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

**0.9.x — розвиток після завершеного 0.9.0 «Ринок»**.

Поточний опублікований checkpoint: **v0.9.0 / 0.9.0+17**.

## Поточний slice

Статус: **VERIFIED**

Мета: **deterministic local Planner exports: CSV + ICS; PDF deferred**.

- base `main`: **`b1507a0caac416d4f4b275f7508c46ccea1fbdeb`**;
- branch: **`feat/planner-exports`**;
- export model first: stable machine-readable CSV schema + calendar ICS semantics;
- source: current generated/saved Planner scenario, positions, typed needs and derived coverage/cashflow;
- file handling: local `exports/` inside the active workspace with validated deterministic filenames and atomic text writes;
- CSV: UTF-8, stable English machine headers, Decimal dot, RFC4180 escaping, explicit record types;
- ICS: all-day events for needs/reserve-floor and expected cash-availability dates for coupon/redemption/sale events; deterministic UID/DTSTAMP; no network;
- PDF remains deferred until report structure stabilizes;
- UI labels/messages: UK/EN/FR/DE/ES/KO/JA;
- regression: identical input → identical bytes; save path; CSV escaping; ICS escaping/dates; desktop/phone Planner buttons;
- draft PR: **#73** `Planner: add deterministic CSV and ICS exports`;
- verified code head: **`55a0b0c043ea656fcd5612be2d8906c4f6209b41`**;
- **Flutter checks and START run #229 — success (117/117 tests)**.

### Поточна наступна дія

**VERIFIED — code head passed run #229. Run exact latest-head CI after this docs-only checkpoint, then integrate PR #73 into `main` if green. PDF remains deferred.**

## Черга робіт

1. **DONE** — multiple `PriceObservation` + explicit user source priority.
2. **DONE** — purchase fee assumptions → calculation + UI.
3. **DONE** — tax assumptions → official effective-date audit → calculation + UI.
4. **DONE** — FX assumptions calculation/UI.
5. **DONE** — exit assumptions redesign/wiring for multi-position scenarios.
6. **DONE** — A/B/C comparison — PR #58, final run #183, merge `25123ceb…`.
7. **DONE** — Planner needs/future-expenses block requested by owner.
8. **DONE** — full test checkpoint v0.8.8 from current main.
9. **DONE** — generated planner copy / preset labels localization + UX regression — PR #61, run #189 (110/110), final run #190, merge `1e6849f7…`.
10. **DONE** — formal prerelease readiness assessment 0.9.0 — PR #63, run #193, merge `f80c7d8e…`; GO to release preparation.
11. **DONE** — v0.9.0 full cross-platform checkpoint: PR #65 → merge `21698ae3…`; release run #45 success; tag/release `v0.9.0` published.
12. **DONE** — optional third appearance «Світла панель» integrated via PR #67; final run #206; merge `90bea96f…`.
13. **DONE** — Planner reserve-floor / minimum-balance needs; PR #69 → merge `37b8120d…`; final branch run #210 and main run #211 green.
14. **VERIFIED** — deterministic local CSV + ICS Planner exports; PR #73, code run #229 green; awaiting latest-head docs-only verification.

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
- поточний опублікований v0.8.8 не переписувати; кожен наступний повний checkpoint отримує нову версію/build.

## Нещодавно завершено

- **DONE — Planner reserve-floor / minimum-balance**: PR #69 final head `0cf2f513…` passed run #210; squash-merged у `main` as `37b8120db0dd64fa81dc4f06e3e2a44a2ec21206`; post-merge run #211 success. Floor is a non-consuming minimum-liquid-cash constraint, schema 3 compatible, included in coverage/generator/A-B-C/UI and 7 languages.


- **DONE — Light Dashboard appearance**: PR #67 final latest-head run #206 success; squash-merged у `main` як `90bea96f5be1b28d980a3846341dbfe90b32e8e8`. Classic + Studio preserved, third «Світла панель» mode added with 7-language selector and desktop/phone regression coverage.


- **DONE — v0.9.0 full cross-platform checkpoint**: PR #65 squash-merged у `main` як `21698ae34f9438f7c5ab49724e47dc13014b7daa`; Publish native prerelease run #45 success. Опубліковано Windows/macOS/Android/iOS/START + SHA256SUMS + legal notices під tag `v0.9.0`.


- **DONE — formal 0.9.0 prerelease readiness assessment**: PR #63 squash-merged у `main` як `f80c7d8e87b4fb494cf37712627bc12277a2fa73`; final run #193 success. Evidence in `docs/READINESS_0_9_0.md`; no product blocker found; decision = GO to release-prep, while exact-current platform builds remain enforced release gates.

- **DONE — generated Planner copy / preset labels localization**: PR #61 squash-merged у `main` як `1e6849f78134d9654b0bf08b54ceebda4100ba4d`; code run #189 success (110/110 tests), final latest-head run #190 success. Generated plan/need/expense copy and scenario note are language-neutral in storage, displayed through `HubStrings` in UK/EN/FR/DE/ES/KO/JA; user-authored names remain literal; existing phone/desktop Planner regressions green.

- **DONE — strict neutral A/B/C comparison**: PR #58 squash-merged у `main` як `25123ceb049534c67b9d284ee0f79e5cc8694e28`; final run #183 success, 108/108 tests. Порівнюються 2–3 saved scenarios з однаковими baseline assumptions; recurring needs supported, reserve-floor fail closed, no automatic winner; UK/EN/FR/DE/ES/KO/JA UI + domain/Cubit/widget regressions green. Старий PR #53 закрито без merge.


- **DONE — v0.8.8 full cross-platform checkpoint**: PR #56 squash-merged у `main` як `acacf53b903e876e7bacae45ebc6f895e799cd75`; `Publish native prerelease` run #40 success. Опубліковано Windows/macOS/Android/iOS/START + SHA256SUMS + legal notices під tag `v0.8.8`; release description містить UK/EN/FR/DE/ES/KO/JA.


- **DONE — typed recurring Planner needs block**: PR #54 squash-merged у `main` як `e2a48d7017fe578295e631054d84fce52cbc2b55`; final run #168 success. Primary recurring need, month-end-safe expansion, schema-3 persistence/reload, one-off additions and 7-language UI integrated.


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
