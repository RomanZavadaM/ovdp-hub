# Private portfolio encrypted payload — schema v1

Статус: **IMPLEMENTATION CONTRACT — PR #88**  
Storage boundary: payload bytes live **inside** the existing encrypted vault envelope.

This document defines the first factual private-portfolio schema. It is intentionally not a migration or UI contract.

## 1. Source-of-truth rule

Private factual records are source data. Holdings are not stored as a second editable list.

Schema v1 stores:
- acquisition lots;
- factual coupon/redemption cash events.

A derived balance is calculated from those records:
- acquired units
- minus represented redemption units.

This derived balance must **not** yet be shown as a complete real-world holding if the user has unrecorded sale/disposal activity. Factual sale/disposal is deliberately deferred to the next private-domain slice before migration or portfolio UI.

## 2. Public vs private boundary

Private payload contains user-specific facts only.

It does not copy:
- NBU instrument catalog;
- MinFin auction/calendar data;
- seller observations;
- public payment schedules.

Public instruments are referenced by ISIN.

## 3. Acquisition lot

Each lot has:
- stable local `id`;
- `isin`;
- integer `units`;
- factual `acquiredOn` date;
- `currency`;
- factual `tradeAmount`;
- explicit fee state;
- optional private broker/account label.

### tradeAmount semantics

`tradeAmount` is the factual cash consideration for the bond trade itself for the whole lot, **excluding separately recorded broker/transaction fee**.

It is not:
- a public quote;
- a yield;
- a percentage-of-nominal field;
- an inferred price.

If accrued interest was paid as part of the broker's trade settlement amount, it belongs in this factual trade amount rather than being silently reconstructed from public data.

### fee semantics

`feeStatus` is explicit:
- `unknown` → `feeTotal` must be absent;
- `known` → `feeTotal` is required and may be exactly zero.

Therefore known zero is never collapsed into unknown.

When fee is known:
`knownCashOutflow = tradeAmount + feeTotal`.

## 4. Factual cash events

Schema v1 supports:
- `coupon`;
- `redemption`.

Each event has:
- stable local `id`;
- `isin`;
- factual event date;
- currency;
- positive factual cash `amount`;
- optional private note.

Redemption additionally requires positive integer `units`.

Event amount is the factual cash amount recorded by the user/import source. The payload does not derive or replace it from NBU payment schedules.

## 5. Semantic validation

Fail closed when:
- record/portfolio ID format is invalid;
- record IDs duplicate across lots/events;
- ISIN/date/currency/amount is invalid;
- one ISIN has conflicting lot currencies;
- cash event has no acquisition lot;
- cash-event currency differs from its acquisition currency;
- event predates the first acquisition;
- a redemption requires more cumulative units than have been acquired by that date;
- known/unknown fee state is inconsistent;
- coupon carries redemption units;
- unknown schema or unknown fields are encountered.

Same-day acquisition is applied before same-day redemption for non-negative-unit validation.

## 6. Deterministic representation

Canonical order:
- acquisition lots: date → ISIN → id;
- cash events: date → ISIN → kind → id.

JSON uses a fixed schema-v1 key order, UTF-8 encoding and canonical Decimal string values.

Both encode and decode enforce a 16 MiB payload limit.

Record-count limits:
- acquisition lots: 10,000;
- cash events: 50,000.

## 7. Encrypted-storage integration

The codec returns raw private payload bytes.

Those bytes are passed to the existing `LocalVaultStore` / session layer and therefore receive:
- XChaCha20-Poly1305 authenticated encryption;
- vault revision/rollback handling;
- atomic known-good write lifecycle;
- device-key/recovery handling.

The physical vault file must not contain plaintext private fields such as portfolio id, ISIN, account label or factual amounts.

## 8. Explicitly deferred

Before user-facing portfolio UI or legacy migration:
- factual sale/disposal records;
- disposal-to-acquisition-lot allocation / realized cost basis;
- imported broker statement adapters;
- actual portfolio UI;
- migration from legacy `sets/*.json`;
- any automatic reconstruction of missing historical cash events.

No missing historical fact is invented from public data.
