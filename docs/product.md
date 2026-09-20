# Product scope and user journey

## Goal

Help users understand public OVDP information and compare net economics without collecting their investment budgets or portfolios centrally.

## Current journey

Open app → see SYNTHETIC label → enter UAH budget → calculate locally → compare quantity, price with fee, profit, annualized return and idle cash. No registration, recommendation, account opening or purchase.

## Planned aggregator journey

Load public snapshots → filter currency/ISIN/maturity/source → inspect freshness and tariff completeness → calculate locally → optionally save to encrypted local vault → open public source. A broker handoff is external and explicitly labeled.

## Sources to validate

- NBU OVDP reference: https://bank.gov.ua/ua/markets/ovdp
- NBU open-data terms: https://bank.gov.ua/ua/open-data
- Ministry auction calendar: https://www.mof.gov.ua/uk/kalendar-aukcioniv
- Ministry primary purchase explanation: https://www.mof.gov.ua/uk/domestic_government_bonds_for_population-360
- Tax reference: https://www.tax.gov.ua/deklaratsiyna-kampaniya-2026/stavki-podatku-na-dohodi-fizichnih-osib-ta-viyskovogo-zboru

These are reference pages, not claims that a connector is implemented. Confirm payload/schema, CORS, attribution, terms and refresh frequency before each integration. No scraping of authenticated client accounts.

## Acceptance criteria

- Public data and demo fixtures are visually distinguishable.
- Entering/changing budgets makes no network request.
- All costs and assumptions visible; no unknown fee silently replaced with zero.
- No KYC, accounts or trading action in phase one.
- Dates and stale source status shown; no invented live prices.
- Budget never exceeded, quantities integral and within liquidity.
- Keyboard navigation, explicit labels and narrow-screen table scrolling.
- No personal data committed to fixtures, logs or CI artifacts.
