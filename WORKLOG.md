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

Статус: **DOING**

Мета: **structured future auction schedule з офіційних календарних PDF Мінфіну**.

- базовий `main`: `719e6bfe005c85e2ea6d6c868da22bbfe5f77d12`
- активна гілка: `feat/minfin-calendar-pdf-schedule-r2`
- source PR: #21, head `1853d2a90fd136fa11376285901f81aa02da8227`
- source verify: **Flutter checks and START run #70 — success**
- причина replacement: після v0.8.4 `main` просунувся вперед, а PR #21 став non-mergeable; релізний стан не переписуємо
- актуальна опублікована контрольна точка: **v0.8.4 / 0.8.4+12**
- фактичні макети перевірені до переносу коду: monthly placement і switch — офіційні PDF 2026 візуально; quarterly — офіційна таблична структура з окремими currency/tenor cells підтверджена візуальним PDF reference і поточним 2026 document content
- офіційна сторінка джерела: `https://mof.gov.ua/uk/kalendar-aukcioniv`

### Що переносимо з перевіреного PR #21

- typed future-auction schedule model, окремий від historical auction results;
- pure-Dart PDF text extraction через `pdf_document` + `pdf_graphics`;
- monthly / quarterly / switch parsers за різними фактичними layout;
- provenance: URL конкретного PDF, publication/source date, retrievedAt;
- fail-closed behavior на unknown/changed layout;
- deterministic tests без live-network залежності;
- локалізовані parser errors UK/EN/FR/DE/ES/KO/JA;
- dependency/legal notices без регресії версії `0.8.4+12`.

### Критерій готовності slice

1. PDF-макети перевірені й структура parser-а не базується на припущеннях.
2. Typed schedule model відповідає лише полям, які реально публікує Мінфін.
3. Parser fail closed і має deterministic normal/changed-shape coverage.
4. `flutter pub get --enforce-lockfile`, `flutter analyze`, `flutter test` проходять у GitHub verify.
5. Replacement PR squash-merged у `main`.
6. `PROJECT_STATE.md`, `WORKLOG.md` та Issue #18 синхронізовані з merge SHA і рівно однією наступною дією.

### Поточна наступна дія

Перенести тільки перевірені зміни PR #21 на цю гілку поверх v0.8.4 state, відкрити replacement PR і повторно прогнати verify.

## Черга робіт

1. **DOING** — MinFin structured future auction schedule from official calendar PDFs.
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
