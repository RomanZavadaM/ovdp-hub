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

Поточний опублікований checkpoint: **v0.8.6 / 0.8.6+14**.

## Поточний slice

Статус: **VERIFIED**

Мета: **multiple `PriceObservation` + explicit user source priority**.

- release baseline `main`: `2030dcfe01304dcd11e443c886ae9d2bc6f6c165`
- active branch: `feat/price-observation-source-priority`
- опублікований checkpoint: **v0.8.6 / 0.8.6+14**
- active draft PR: **#39** `Planner: multiple price observations with explicit source priority`
- verified functional head: `b6bfe1e47870e7a9ff3faf319035ad164cb8495c`
- final functional verify: **Flutter checks and START run #122 — success**
- `flutter pub get --enforce-lockfile` — success
- `flutter analyze` — success
- `flutter test` — success
- implemented and verified:
  - additive schema-3 `priceObservations` + `priceSourcePriority`;
  - legacy selected `price` retained for older readers;
  - resolver accepts only explicit purchase prices (full/clean ASK/manual);
  - yield-only and nominal estimate are excluded from market-price candidates;
  - duplicate eligible observations from one source fail closed;
  - PlannerCubit load/save preserves observations and source priority;
  - planner UI supports add/select/reorder source controls and explicit nominal fallback;
  - combined quantity + manual-price edit regression fixed: the already quantity-updated input is no longer overwritten from stale state;
  - price-source dialog no longer disposes controllers during route-exit animation;
  - 9 price-source UI keys localized in UK/EN/FR/DE/ES/KO/JA;
  - deterministic domain, cubit/persistence, localization and widget-flow tests added and passing.
- CI history:
  - run #112 — analyzer failure;
  - run #113/#114 — one planner regression;
  - run #115 — diagnostic confirmed `planner.reserve_spent` came from stale quantity `45`;
  - run #121 — domain/cubit/localization tests green, widget test exposed disposed-controller UI race;
  - run #122 — **success** after UI race fix.

### Поточна наступна дія

Перевести PR **#39** з draft у **ready**, дочекатися green checks на фінальному WORKLOG head і **інтегрувати PR у `main`** squash merge.

Після merge синхронізувати `PROJECT_STATE.md`, `WORKLOG.md`, roadmap та Issue #18. Єдиний наступний functional slice після синхронізації: **typed fee/tax/FX/exit assumptions → calculations + UI**.

Hard invariant: yield-only або nominal estimate **ніколи** не можуть автоматично стати вибраною ринковою ціною.

## Черга робіт

1. **NEXT** — multiple `PriceObservation` + explicit user source priority.
2. **TODO** — typed fee/tax/FX/exit assumptions → calculations + UI.
3. **TODO** — A/B/C comparison.
4. **TODO** — generated planner copy / preset labels localization + UX regression.
5. **TODO** — оцінка готовності formal prerelease 0.9.0.

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
- поточний опублікований v0.8.6 не переписувати; кожен наступний повний checkpoint отримує нову версію/build.

## Нещодавно завершено

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
