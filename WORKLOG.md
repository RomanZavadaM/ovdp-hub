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

Мета: **detailed MinFin auction results parser**.

- функціональний baseline після завершеного PDF schedule slice: `1313339ac0241dc2ea50db3ea14494ea07871f3c`
- post-merge documentation checkpoint: `d38189e24f1bec12c70991bb6c6df15957b1d8fe`
- попередній slice: structured future auction schedule from official calendar PDFs
- merged PR: **#24** `Parse structured MinFin auction schedules from official PDFs`
- merge SHA: `1313339ac0241dc2ea50db3ea14494ea07871f3c`
- stale source PR #21 закрито без merge
- final functional verify before merge: **Flutter checks and START run #75 — success**
- post-merge documentation verify: **Flutter checks and START run #77 — success** (`flutter pub get --enforce-lockfile`, `flutter analyze`, `flutter test`)
- версія/checkpoint лишається **v0.8.4 / 0.8.4+12**

### Поточна наступна дія

Почати окремий slice для **detailed MinFin auction results parser**: спочатку перевірити фактичні офіційні сторінки/документи результатів аукціонів і зафіксувати реальні поля та layout до написання parser-а.

## Черга робіт

1. **NEXT** — detailed MinFin auction results parser.
2. **TODO** — freshness/status UX у картці ISIN.
3. **TODO** — typed fee/tax/FX/exit assumptions → calculations + UI.
4. **TODO** — multiple `PriceObservation` + explicit user source priority.
5. **TODO** — A/B/C comparison.
6. **TODO** — оцінка готовності formal prerelease 0.9.0.

## Нещодавно завершено

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
