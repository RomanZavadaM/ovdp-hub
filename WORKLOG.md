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

Мета: **MinFin calendar/documents layer** — окремо типізувати офіційний календар/документи Мінфіну навколо аукціонів, не змішуючи їх із already-typed auction event index або detailed results parser.

- базовий `main`: `2f3360d0d8f6d72fabff1489a8cb0d3bc5885c82`
- активна гілка: `feat/minfin-calendar-documents`
- PR: ще не відкритий
- останній завершений slice: PR #17, merge `2f3360d0d8f6d72fabff1489a8cb0d3bc5885c82`
- verify PR #17: run #53 — success

### Що треба зробити в цьому slice

- перевірити актуальну офіційну структуру Мінфіну у web до написання parser-а;
- визначити окрему typed-модель для календарних/документних записів;
- зберігати source date / retrievedAt / evidence URL;
- використовувати лише офіційні URL Мінфіну;
- parser має fail closed при зміні структури або невідомому типі документа;
- не парсити detailed auction results у цьому slice;
- додати deterministic tests без live-network залежності;
- локалізувати нові user-facing error codes для UK/EN/FR/DE/ES/KO/JA;
- оновити `PROJECT_STATE.md` / `docs/roadmap.md`, якщо slice змінює підтверджений статус.

### Критерій готовності slice

1. Офіційна структура джерела перевірена й зафіксована в коді/тестах без припущень.
2. Typed calendar/documents model і fail-closed parser реалізовані.
3. `flutter analyze` + `flutter test` проходять через GitHub verify.
4. PR squash-merged у `main`.
5. WORKLOG та Issue #18 містять merge SHA і наступну конкретну дію.

## Черга робіт

1. **DOING** — окремий slice: календар документів/подій Мінфіну.
2. **NEXT** — детальний parser результатів аукціонів Мінфіну, з fail-closed поведінкою та provenance.
5. **TODO** — нормалізований freshness/status UX у картці ISIN.
6. **TODO** — підключити typed fee/tax/FX/exit assumptions до реальних розрахунків і UI; локалізувати generated planner copy/preset labels.
7. **TODO** — кілька `PriceObservation` на ISIN + явний user-selected source priority.
8. **TODO** — повне порівняння сценаріїв A/B/C.
9. **TODO** — лише після цього оцінювати готовність формального prerelease checkpoint 0.9.0.

## Нещодавно завершено

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
