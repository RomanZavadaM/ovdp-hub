# Architecture 0.1 — public data, local calculations

```mermaid
flowchart LR
  N[НБУ / Мінфін / дозволені публічні джерела] --> P[Майбутній public-only importer]
  P --> S[Версіоновані публічні snapshots]
  S --> C[Пристрій користувача]
  H[Static hosting: JS / CSS / HTML] --> C
  subgraph Device[Межа пристрою]
    C --> Q[Порівняння та фільтри]
    Q --> M[Decimal pricing / XIRR]
    V[Майбутнє локальне зашифроване сховище] --> Q
  end
  C -. майбутній прямий handoff .-> B[Банк / брокер / Дія]
```

Implemented: static Next.js application, in-memory inputs, three synthetic quotes, local pricing package. Dashed/future elements are not implemented.

## Logical data model

Public: Asset(id, isin?, currency, nominal, issueDate, maturityDate, dayCount, termsVersion); Payment(assetId, date, coupon, principal); Quote(id, assetId, sourceId, bid/ask, clean/dirty, price, accruedInterest, min/max/stepQuantity, settlementDate, observedAt, validUntil, indicative/executable); FeeSchedule(sourceId, version, effectiveFrom/To, rules, evidence); Source(id, URL, redistributionPolicy, fetchedAt).

Private future local model: LocalPortfolio(id, name, baseCurrency); LocalHolding(portfolioId, assetId, quantity, acquisitionCost); LocalSettings(id, preferences); VaultMetadata(version, cryptoParameters). No Users table or server-side portfolio FK. Partner credentials and signing keys are not ordinary portfolio records.

```mermaid
erDiagram
 ASSET ||--o{ PAYMENT : schedules
 ASSET ||--o{ QUOTE : quoted
 SOURCE ||--o{ QUOTE : publishes
 SOURCE ||--o{ FEE_SCHEDULE : documents
 LOCAL_PORTFOLIO ||--o{ LOCAL_HOLDING : contains
 ASSET ||--o{ LOCAL_HOLDING : references
```

## Local calculation contract

`calculateBond({ quantity, cleanPrice, accruedInterest, upfrontFee, settlementDate, payments })` returns costs, net receipts, profit, cashflows, netXirr, methodology and engineVersion. Money values are decimal strings. Prices are currency units per bond, not percent of nominal. Payments are net per-unit cashflows; callers must explicitly apply applicable tax/fee policy. No generic tax engine is implemented.

`compareDemo(budget)` returns SYNTHETIC, executable=false, fixed settlement/maturity dates, assumptions and ranked results. This is a local function, not a private POST API.

## Financial invariants

- Dirty price = clean price + supplied accrued interest, once.
- Initial outflow = rounded quantity × dirty price + rounded upfront fee.
- Net XIRR uses ACT/365F and actual dates, one negative initial flow and positive/non-negative future flows.
- Invalid dates, invalid decimal strings, fractional quantities and unsupported flow shapes are rejected.
- Compare integer lots within liquidity and budget; show idle cash independently.
- All demo amounts are UAH, exemption is a scenario assumption, no recurring fees or reinvestment.

## Public feed contract (planned)

Versioned JSON snapshots: schemaVersion, generatedAt, sourceURL, sourceObservedAt, qualityStatus, assets, quotes and feeVersions. Imported quotations are indicative unless a source explicitly supports execution; phase one never executes them. A published yield is not a executable offer.

## Security boundary

No server API, cookies, account identity, analytics, document upload or signing code. Static delivery is still a supply-chain trust boundary. Production hosting headers, CSP, dependency audits and source provenance are launch gates, not claims fulfilled by this prototype.
