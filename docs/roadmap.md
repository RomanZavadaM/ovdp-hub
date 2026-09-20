# Roadmap

## 0.1 — initial baseline
- [x] Repository documentation and local-first ADR.
- [x] Static web comparison prototype with synthetic fixtures.
- [x] Decimal pricing, conventional cashflow XIRR and tests.
- [x] Build/typecheck/test CI definition.

## 0.2 — public information
- [x] Validate NBU instrument and payment data API.
- [x] NBU source adapter and provenance-aware public snapshot schema.
- [x] Initial Ministry calendar view with source document and planned-status warning.
- [ ] Ministry auction calendar/results ingestion with corrections.
- [x] NBU retrieval freshness, quarantine and stale-source UX.
- [x] Tests against versioned public fixtures; no network in unit tests.

## 0.3 — comparison quality
- [ ] Authorized public bank/broker quotes and versioned tariffs.
- [ ] ISIN, currency, maturity, source and quote-age filters.
- [ ] Day-count-aware accrued interest and coupon schedules.
- [ ] Effective-dated tax scenarios, recurring fees and deposit comparison.
- [ ] Bid/Ask early-sale simulation, FX and budget-level return.

## 0.4 — local portfolio
- [ ] Threat model, encrypted local vault and user-controlled backup/recovery.
- [ ] Holdings import, coupon calendar, local ICS export.
- [ ] Local maturity ladder and scenario calculator.
- [ ] Offline asset caching and installable PWA after security review.

## Later, separately scoped
- [ ] React Native iOS/Android with platform secure storage.
- [ ] Direct provider-authorized handoff; no private-data relay server.
- [ ] Assess each partner's native/public-client authorization independently.

Server-side identity, documents, signatures and order execution are excluded from the current architecture. Real-data integrations and automated recommendations are not implemented in 0.1.
