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
- PR #19 **закритий без merge** через розсинхронізацію GitHub PR head (PR залишився на `f0918ac…`, тоді як гілка вже була на `29be2c…`)
- replacement branch: `feat/minfin-calendar-documents-r2`; replacement PR створюється з актуального checkpoint
- офіційне джерело перевірено 22.09.2026: `https://mof.gov.ua/uk/kalendar-aukcioniv`; сторінка публікує monthly / quarterly / switch PDF-документи та дати їх публікації
- останній завершений slice: PR #17, merge `2f3360d0d8f6d72fabff1489a8cb0d3bc5885c82`
- verify PR #17: run #53 — success

### Що вже зроблено в цьому slice

- [x] актуальну офіційну структуру Мінфіну перевірено у web до написання parser-а;
- [x] окрема typed-модель: monthly placement / quarterly placement / monthly switch;
- [x] source date / retrievedAt / evidence URL;
- [x] лише офіційні PDF URL `mof.gov.ua/storage/files`;
- [x] fail closed при зміні структури, невідомому типі, відсутній даті або дублікаті;
- [x] detailed auction results у цьому slice не парсяться;
- [x] deterministic tests без live-network залежності;
- [x] нові user-facing error codes локалізовані UK/EN/FR/DE/ES/KO/JA;
- [x] `PROJECT_STATE.md` / `docs/roadmap.md` уточнюють межу: PDF-документи індексуються, але їх таблиці ще не є структурованим future schedule;
- [ ] актуальний head PR #19 має пройти GitHub `verify`.

### Критерій готовності slice

1. Офіційна структура джерела перевірена й зафіксована в коді/тестах без припущень.
2. Typed calendar/documents model і fail-closed parser реалізовані.
3. `flutter analyze` + `flutter test` проходять через GitHub verify.
4. PR squash-merged у `main`.
5. WORKLOG та Issue #18 містять merge SHA і наступну конкретну дію.

## Черга робіт

1. **DOING** — створити replacement PR з `feat/minfin-calendar-documents-r2` від актуального checkpoint `29be2c199b3c2dd5ccf5773a44d1535b28e02373`; verify → squash merge.
2. **NEXT** — окремий slice: структурований розклад майбутніх аукціонів із офіційних календарних PDF; перед parser-ом візуально перевірити актуальні PDF-макети, не вгадувати дані.
3. **TODO** — детальний parser результатів аукціонів Мінфіну, з fail-closed поведінкою та provenance.
4. **TODO** — нормалізований freshness/status UX у картці ISIN.
5. **TODO** — підключити typed fee/tax/FX/exit assumptions до реальних розрахунків і UI; локалізувати generated planner copy/preset labels.
6. **TODO** — кілька `PriceObservation` на ISIN + явний user-selected source priority.
7. **TODO** — повне порівняння сценаріїв A/B/C.
8. **TODO** — лише після цього оцінювати готовність формального prerelease checkpoint 0.9.0.

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
