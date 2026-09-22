# WORKLOG — OVDP Hub

Оновлено: **22.09.2026**

Цей файл — оперативна точка відновлення активної розробки. Він навмисно дублює лише те, що потрібно для продовження роботи без історії чату.

Точка входу для нової сесії: `START_HERE.md`  
Постійні правила: `PROJECT_RULES.md`  
Стабільний стан `main`: `PROJECT_STATE.md`  
Append-only журнал: GitHub Issue **#18 — OVDP Hub — live development ledger**

## Статуси

- `NEXT` — наступна конкретна дія.
- `DOING` — робота реально триває у вказаній гілці/PR.
- `VERIFIED` — код/зміна перевірені, але ще не merged у `main`.
- `BLOCKED` — є конкретна перешкода; причина повинна бути записана.
- `DONE` — тільки після merge у `main`.

## Активна ціль

**0.9.0 «Ринок»** — довести ринковий шар Мінфіну, картку ISIN і typed planner assumptions до цілісного тестованого етапу без публікації 0.9.0 раніше готовності всього заявленого scope.

Поточна опублікована контрольна точка лишається **v0.8.3 / 0.8.3+11**.

## Поточний slice

Статус: **DOING**

Мета: **MinFin structured future auction schedule from official calendar PDFs**.

- базовий `main`: `5a189a3b127ac80ed3a6faa2c0eff4ef342b540a`
- активна гілка: `feat/minfin-calendar-pdf-schedule`
- PR: ще не відкритий
- останній завершений slice: PR #20, merge `5a189a3b127ac80ed3a6faa2c0eff4ef342b540a`
- verify PR #20: run #56 — success, **56/56 tests**

### Що треба зробити в цьому slice

- візуально перевірити актуальні офіційні PDF календаря Мінфіну через screenshots, не лише текстове витягування;
- визначити реальну структуру таблиць: дата аукціону, валюта, строк/тип, ISIN або інші поля — тільки якщо вони реально є в PDF;
- окремо перевірити monthly placement, quarterly placement і switch PDF, бо макети можуть відрізнятися;
- створити typed future-auction schedule model без змішування з historical auction results;
- provenance має містити URL конкретного PDF, publication date та retrievedAt;
- parser має fail closed при невідомому/зміненому layout;
- не вигадувати ISIN, ставку, обсяг або інші поля, яких немає в календарному документі;
- deterministic tests будувати на зафіксованих структурах, без live-network залежності;
- нові user-facing errors локалізувати UK/EN/FR/DE/ES/KO/JA;
- після коду: PR → verify → squash merge.

### Критерій готовності slice

1. Актуальні PDF-макети перевірені візуально.
2. Typed schedule model відповідає лише полям, які реально публікує Мінфін.
3. Parser fail closed і має deterministic coverage.
4. GitHub verify проходить analyze + tests.
5. PR squash-merged у `main`.
6. WORKLOG та Issue #18 оновлені merge SHA і наступною дією.

## Черга робіт

1. **DOING** — structured future auction schedule з офіційних календарних PDF.
2. **NEXT** — детальний parser результатів аукціонів Мінфіну, fail closed + provenance.
3. **TODO** — нормалізований freshness/status UX у картці ISIN.
4. **TODO** — підключити typed fee/tax/FX/exit assumptions до реальних розрахунків і UI; локалізувати generated planner copy/preset labels.
5. **TODO** — кілька `PriceObservation` на ISIN + явний user-selected source priority.
6. **TODO** — повне порівняння сценаріїв A/B/C.
7. **TODO** — лише після цього оцінювати готовність формального prerelease checkpoint 0.9.0.

## Нещодавно завершено

- **DONE — PR #20**: typed MinFin calendar document index (monthly / quarterly / switch PDF metadata + publication date + provenance + fail-closed parser); merge `5a189a3b127ac80ed3a6faa2c0eff4ef342b540a`, verify run #56, 56/56 tests.

- **DONE — PR #17**: typed placement/switch auction event index + `START_HERE.md`/`WORKLOG.md`/Issue #18 recovery protocol; merge `2f3360d0d8f6d72fabff1489a8cb0d3bc5885c82`.
- **DONE — PR #15**: typed `AppError`, стабільні codes + parameters, локалізований error rendering UK/EN/FR/DE/ES/KO/JA.
- **DONE — PR #16**: завершено domain/parser error localization; прибрані залишкові hard-coded user-facing validation/error strings з активних flows.
- `main` після PR #16: `9abab51af155fc7c482b9bbe9c74fd4efa0b242b`.

## Якщо роботу перервано

Наступний чат/сесія НЕ повинні відновлювати стан з пам'яті.

Послідовність:

1. прочитати `START_HERE.md`;
2. прочитати `PROJECT_RULES.md`;
3. прочитати `PROJECT_STATE.md`;
4. прочитати цей `WORKLOG.md` з активної гілки/PR, якщо вона існує;
5. прочитати останні коментарі Issue #18;
6. перевірити фактичний `main`, активні PR і їх head SHA;
7. якщо SHA відрізняються від цього файла — GitHub має пріоритет, файл одразу синхронізувати;
8. продовжити з першого пункту `DOING/NEXT`, не повторюючи вже merged роботу.

## Правило для чату

Чат — інтерфейс керування роботою, **не сховище стану**. Усе, що змінює напрямок, scope, статус або наступну дію, повинно бути відображене в GitHub через `WORKLOG.md` та/або Issue #18 у цій же робочій сесії.
