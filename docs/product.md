# Product scope and user journey

## Goal

Help users understand public OVDP information and compare net economics without collecting their investment budgets or portfolios centrally.

## Implemented catalog journey

Open committed NBU snapshot → filter locally → inspect source and retrieval time → expand future payments → compare up to three issues → build a short- or long-horizon scenario package → optionally refresh directly from NBU. Error retains prior snapshot. No purchase or accounts.

Scenario packages use transparent maturity windows (up to 12 months or from 24 months), allow up to five locally selected issues, and show currency composition with equal technical preview shares. These shares are a comparison aid, not a personalized recommendation.

## Separate demo journey

Open app → see SYNTHETIC label → enter UAH budget → calculate locally → compare quantity, price with fee, profit, annualized return and idle cash. No registration, recommendation, account opening or purchase.

## Planned aggregator journey

Load public snapshots → filter currency/ISIN/maturity/source → inspect freshness and tariff completeness → calculate locally → optionally save to encrypted local vault → open public source. A broker handoff is external and explicitly labeled.

## Sources to validate

- NBU OVDP reference: https://bank.gov.ua/ua/markets/ovdp
- NBU open-data terms: https://bank.gov.ua/ua/open-data
- Ministry auction calendar: https://www.mof.gov.ua/uk/kalendar-aukcioniv
- Ministry primary purchase explanation: https://www.mof.gov.ua/uk/domestic_government_bonds_for_population-360
- Tax reference: https://www.tax.gov.ua/deklaratsiyna-kampaniya-2026/stavki-podatku-na-dohodi-fizichnih-osib-ta-viyskovogo-zboru

The NBU securities adapter is implemented; other entries remain reference pages, not claims that a connector is implemented. Confirm payload/schema, CORS, attribution, terms and refresh frequency before each integration. No scraping of authenticated client accounts.

## Acceptance criteria

- Public data and demo fixtures are visually distinguishable.
- Entering/changing budgets makes no network request.
- All costs and assumptions visible; no unknown fee silently replaced with zero.
- No KYC, accounts or trading action in phase one.
- Dates and stale source status shown; no invented live prices.
- Budget never exceeded, quantities integral and within liquidity.
- Keyboard navigation, explicit labels and narrow-screen table scrolling.
- No personal data committed to fixtures, logs or CI artifacts.
