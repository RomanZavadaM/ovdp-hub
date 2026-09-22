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

**0.9.0 «Ринок»** лишається великим функціональним етапом.

Перед наступним MinFin PDF parser slice формується окремий завершений тестовий checkpoint **0.8.4+12**.

## Поточний slice

Статус: **DOING**

Мета: **формальний prerelease checkpoint v0.8.4 для тестування**.

- базовий `main`: `5a189a3b127ac80ed3a6faa2c0eff4ef342b540a`
- активна гілка: `release/v0.8.4`
- target version: `0.8.4+12`
- release tag після merge/pipeline: `v0.8.4`
- попередній опублікований checkpoint: `v0.8.3`

### Що входить у 0.8.4

- [x] functional UI localization UK/EN/FR/DE/ES/KO/JA;
- [x] typed domain/repository/parser error localization;
- [x] three-layer ISIN card: NBU / MinFin / seller;
- [x] MinFin latest-auction adapter + ISIN join;
- [x] typed MinFin auction event index: placement / switch;
- [x] typed MinFin calendar document index: monthly / quarterly / switch PDFs;
- [x] provenance / evidence URL / fail-closed behavior;
- [x] START_HERE / WORKLOG / Issue #18 recovery protocol;
- [ ] structured future auction schedule із PDF — **не входить**;
- [ ] detailed auction results parser — **не входить**;
- [ ] full typed fee/tax/FX/exit UI/calculation integration — **не входить**.

### Критерій готовності release slice

1. Version/build = `0.8.4+12`.
2. `docs/releases/RELEASE_NOTES_v0_8_4.md` існує.
3. README/CHANGELOG узгоджені.
4. PR має зелений verify.
5. PR squash-merged у `main`.
6. Publish native prerelease успішно завершує verify + build Windows/macOS/Android/iOS/START.
7. GitHub Release `v0.8.4` існує з `SHA256SUMS.txt` і legal notices.
8. `PROJECT_STATE.md` після публікації оновлений фактичним release SHA/assets.
9. Issue #18 містить release result і наступну конкретну дію.

## Черга робіт

1. **DOING** — release PR 0.8.4 → verify → squash merge.
2. **NEXT** — перевірити Publish native prerelease та опубліковані assets v0.8.4.
3. **NEXT після релізу** — structured future auction schedule з офіційних календарних PDF; перед parser-ом візуально перевірити актуальні PDF-макети.
4. **TODO** — detailed MinFin auction results parser.
5. **TODO** — freshness/status UX у картці ISIN.
6. **TODO** — typed fee/tax/FX/exit assumptions → calculations + UI.
7. **TODO** — multiple `PriceObservation` + explicit user source priority.
8. **TODO** — A/B/C comparison.

## Нещодавно завершено

- **DONE — PR #20**: typed MinFin calendar document index; merge `5a189a3b127ac80ed3a6faa2c0eff4ef342b540a`; verify run #56; 56/56 tests passed.
- **DONE — PR #17**: typed placement/switch auction event index + recovery protocol; merge `2f3360d0d8f6d72fabff1489a8cb0d3bc5885c82`.
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
