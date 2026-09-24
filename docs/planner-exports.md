# Planner CSV / ICS export

Статус: активний slice після v0.9.0.

## Межі

Експорт локальний: OVDP Hub не завантажує сценарії на сервер і не виконує угод. Файли створюються у поточному workspace в окремій людсько читабельній папці `exports/`.

PDF не входить до цього slice. Його слід додавати лише після стабілізації структури звіту.

## CSV contract

Формат: UTF-8 with BOM, RFC-4180-compatible quoting, comma delimiter, LF line endings.

Columns are stable machine-readable identifiers:

`scenario_name,currency,budget,base_reserve,start_date,event_date,event_type,label,amount,isin,quantity,unit_cost,available,remaining,shortfall`

Rows are deterministically sorted by date, event type, ISIN and label.

Supported `event_type` values:
- `POSITION` — позиція сценарію; `amount` = initial position cost;
- `PURCHASE_FEE` — відома сукупна комісія придбання, якщо її можна розрахувати;
- `NEED_ONE_OFF` — разова потреба;
- `NEED_RECURRING` — розгорнутий платіж typed recurring need;
- `RESERVE_FLOOR` — активація minimum-balance rule; **не витрата**;
- `COUPON` — купон, доступний після settlement delay;
- `REDEMPTION` — погашення, доступне після settlement delay;
- `SALE` — надходження від explicit early sale після settlement delay.

Coverage rows carry `available`, `remaining` and `shortfall`. Для reserve floor `remaining == available`, бо floor не списується.

Conditional `EARLY_REDEMPTION` не експортується як гарантований receipt.

## ICS contract

Формат: iCalendar 2.0 / UTF-8 / CRLF.

All exported items are all-day `VEVENT` entries:
- one-off and expanded recurring needs;
- reserve-floor activation;
- expected COUPON / REDEMPTION / SALE cash-availability dates after settlement delay.

Positions and purchase fees are not calendar events and therefore are CSV-only.

UIDs and ordering are derived from scenario/event content; repeated generation from identical input creates the same ICS event identities.

## Local storage

A bundle is written to:

`<workspace>/exports/OVDP-Hub-<scenario>-YYYY-MM-DD_HHMMSS/`

with:
- `planner.csv`
- `planner.ics`

If the human-readable folder name already exists, a numeric suffix is added. Writes go to a new bundle directory; on failure the incomplete directory is removed.

## Invariants

- no currency conversion is invented;
- yield-only is not turned into a price;
- reserve floor is never turned into spending;
- unknown fees are not exported as zero;
- user-authored labels are preserved literally;
- export generation does not mutate or save the Planner scenario.
