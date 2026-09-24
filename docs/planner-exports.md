# Planner exports — CSV + ICS

Статус: active implementation slice after v0.9.0.

## Мета

OVDP Hub експортує поточний згенерований або повторно відкритий Planner scenario локально без мережевої відправки даних.

Перший стабільний формат:
- CSV — машинно читаний знімок сценарію, позицій, typed needs, coverage та очікуваних cashflow events;
- ICS — календар потреб і очікуваної доступності грошових надходжень.

PDF навмисно відкладено, доки структура звіту не стабілізується.

## Детермінізм

За однакового domain input і однакової мови ICS:
- байти CSV однакові;
- байти ICS однакові;
- порядок рядків/подій стабільний;
- UID подій стабільні;
- export content не містить поточного часу запуску.

Файл отримує deterministic stem із дати початку сценарію та стабільного hash його економічних припущень.

## Локальне збереження

Експорт пишеться тільки в активний workspace:

`<workspace>/exports/`

Ім'я файлу проходить allow-list validation. Дозволені тільки `.csv` і `.ics`. Запис виконується через temporary file + rename; мережевих upload/action немає.

## CSV schema v1

Encoding: UTF-8 with BOM.  
Line endings: CRLF.  
Delimiter: comma.  
Decimal separator: dot.  
Escaping: RFC4180.

Stable machine headers:

`record_type,id,date,source_date,name,kind,currency,amount,available,remaining,shortfall,isin,quantity,unit_cost,price_source,every_months,occurrences,value`

### Record types

- `scenario` — baseline fields such as budget/reserve/start/horizon/strategy;
- `position` — ISIN, quantity, unit cost and selected price source;
- `need_rule` — persisted typed one-off/recurring/reserve-floor rule;
- `coverage` — expanded need/floor checkpoint with available/remaining/shortfall;
- `receipt` — coupon/redemption/sale event expected to become available after settlement delay.

Generated names may be rendered for human readability, but machine `kind` values remain stable domain identifiers.

## ICS schema v1

Calendar:
- `VERSION:2.0`
- `PRODID:-//OVDP Hub//Planner Export//EN`
- `CALSCALE:GREGORIAN`
- `METHOD:PUBLISH`

VEVENT is emitted for:
- one-off/expanded recurring needs;
- reserve-floor activation;
- coupon availability;
- redemption availability;
- explicit early-sale proceeds availability.

### Dates

Need/floor event date = rule/expanded need date.

Receipt event date = contractual/source date + scenario settlement delay.  
Original issuer/sale date is included in DESCRIPTION when different.

All events are DATE-valued all-day events.

### UID and DTSTAMP

UID is derived from stable event data and does not use randomness.

DTSTAMP is deterministic and derived from scenario start date at 00:00:00Z rather than export execution time.

## Safety / interpretation

- CSV/ICS are exports of the user's scenario assumptions and public instrument schedule data; they are not transaction instructions.
- Unknown fees/taxes stay unknown; export does not silently substitute zero.
- Reserve floor remains a non-consuming minimum-liquid-cash constraint, not an expense.
- Conditional early redemption is not promoted to guaranteed cashflow.
- Explicit early-sale event is included only when the scenario already contains a valid sale assumption.
