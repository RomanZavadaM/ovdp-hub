# WORKLOG — OVDP Hub

Оновлено: **22.09.2026**

Цей файл — оперативна точка відновлення активної розробки. Він навмисно дублює лише те, що потрібно для продовження роботи без історії чату.

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

Статус: **VERIFIED / очікує оновленого verify після додавання worklog-протоколу**

Мета: **MinFin typed auction event index**.

- базовий `main`: `9abab51af155fc7c482b9bbe9c74fd4efa0b242b`
- активна гілка: `feat/minfin-auction-events`
- PR: **#17 — Expand MinFin with typed auction event index**
- head до додавання цього журналу: `90d279225d8d8ea99236d21586e4c9932d5ecc66`
- останній підтверджений CI перед зміною журналу: **Flutter checks and START, run #48 — success**

### Що вже реалізовано в цьому slice

- typed `MinfinAuctionEvent`;
- `placement` і `switchAuction` як різні типи подій;
- auction date;
- official announcement URL;
- optional result URL;
- provenance/source metadata;
- перевірка, що source URL лишається на `https://mof.gov.ua`;
- fail-closed при зміні/невідомому форматі;
- duplicate event/link detection;
- локалізовані MinFin error codes для UK/EN/FR/DE/ES/KO/JA;
- deterministic parser tests;
- оновлення roadmap і `PROJECT_STATE.md` у PR.

### Критерій готовності slice

1. WORKLOG-протокол і правило в `PROJECT_RULES.md` зафіксовані в активній гілці.
2. PR #17 має актуальний зелений `verify` після останніх змін.
3. PR #17 squash-merged у `main`.
4. `WORKLOG.md` після merge вказує merge SHA і наступний slice.

## Черга робіт

1. **DOING** — зафіксувати persistent worklog/ledger protocol у PR #17.
2. **NEXT** — дочекатися/перевірити нового `verify` для PR #17 та squash-merge.
3. **TODO** — окремий slice: календар документів/подій Мінфіну.
4. **TODO** — окремий slice: детальний parser результатів аукціонів Мінфіну, з fail-closed поведінкою та provenance.
5. **TODO** — нормалізований freshness/status UX у картці ISIN.
6. **TODO** — підключити typed fee/tax/FX/exit assumptions до реальних розрахунків і UI; локалізувати generated planner copy/preset labels.
7. **TODO** — кілька `PriceObservation` на ISIN + явний user-selected source priority.
8. **TODO** — повне порівняння сценаріїв A/B/C.
9. **TODO** — лише після цього оцінювати готовність формального prerelease checkpoint 0.9.0.

## Нещодавно завершено

- **DONE — PR #15**: typed `AppError`, стабільні codes + parameters, локалізований error rendering UK/EN/FR/DE/ES/KO/JA.
- **DONE — PR #16**: завершено domain/parser error localization; прибрані залишкові hard-coded user-facing validation/error strings з активних flows.
- `main` після PR #16: `9abab51af155fc7c482b9bbe9c74fd4efa0b242b`.

## Якщо роботу перервано

Наступний чат/сесія НЕ повинні відновлювати стан з пам'яті.

Послідовність:

1. прочитати `PROJECT_RULES.md`;
2. прочитати `PROJECT_STATE.md`;
3. прочитати цей `WORKLOG.md` з активної гілки/PR, якщо вона існує;
4. прочитати останні коментарі Issue #18;
5. перевірити фактичний `main`, активні PR і їх head SHA;
6. якщо SHA відрізняються від цього файла — GitHub має пріоритет, файл одразу синхронізувати;
7. продовжити з першого пункту `DOING/NEXT`, не повторюючи вже merged роботу.

## Правило для чату

Чат — інтерфейс керування роботою, **не сховище стану**. Усе, що змінює напрямок, scope, статус або наступну дію, повинно бути відображене в GitHub через `WORKLOG.md` та/або Issue #18 у цій же робочій сесії.
