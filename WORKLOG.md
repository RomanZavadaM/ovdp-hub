# WORKLOG — OVDP Hub

Оновлено: **22.09.2026**

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

Поточний опублікований checkpoint: **v0.8.4 / 0.8.4+12**.

## Поточний slice

Статус: **NEXT**

Мета: **structured future auction schedule з офіційних календарних PDF Мінфіну**.

Перед написанням parser-а обов'язково:
- знайти актуальні PDF з офіційної сторінки Мінфіну;
- візуально перевірити їх фактичний layout;
- не вгадувати колонки/дати/типи з назви документа;
- зафіксувати observed structure у deterministic fixtures/tests;
- зберегти provenance і fail-closed behavior.

### Критерій готовності наступного slice

1. Актуальні PDF-макети перевірені візуально.
2. Typed schedule model визначена з фактичної структури документа.
3. Parser не домислює відсутні дані.
4. Deterministic tests покривають нормальний і changed-shape cases.
5. `flutter analyze` + `flutter test` зелені.
6. PR squash-merged у `main`.
7. WORKLOG + Issue #18 синхронізовані.

## Черга робіт

1. **NEXT** — MinFin structured future auction schedule from official calendar PDFs.
2. **TODO** — detailed MinFin auction results parser.
3. **TODO** — freshness/status UX у картці ISIN.
4. **TODO** — typed fee/tax/FX/exit assumptions → calculations + UI.
5. **TODO** — multiple `PriceObservation` + explicit user source priority.
6. **TODO** — A/B/C comparison.
7. **TODO** — оцінка готовності formal prerelease 0.9.0.

## Нещодавно завершено

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
