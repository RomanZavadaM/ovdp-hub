# Private portfolio encrypted payload — schema v3

Статус: **IMPLEMENTATION CONTRACT — PR #94**  
Storage boundary: payload bytes live **inside** the existing encrypted vault envelope.  
Backward compatibility: **schema v1 and schema v2 remain decode-supported**; new encode output is schema v3.

This document defines the factual private-portfolio domain before migration or UI.

## 1. Source-of-truth rule

Private factual records are source data. Holdings are never stored as a second editable list.

Schema v3 stores:
- acquisition lots;
- factual coupon/redemption cash events;
- factual sale/disposal records with explicit allocation to acquisition lots;
- encrypted legacy collection records for non-destructive migration of user-authored SavedSet metadata/scenario without converting those records into portfolio facts.

Derived holdings are:

**acquired units − represented disposal units − represented redemption units**

Only recorded facts affect the balance.

## 2. Public vs private boundary

Private payload contains user-specific facts only.

It does not copy:
- NBU instrument catalog;
- MinFin auction/calendar data;
- seller observations;
- public payment schedules.

Public instruments are referenced by ISIN.

## 3. Encrypted legacy collection records

Schema v3 adds `legacyCollections` for non-destructive migration of legacy `sets/*.json`.

A legacy collection record contains only:
- immutable source-file id;
- user-authored collection name;
- user-authored note;
- savedAt;
- sorted unique selected ISIN references;
- raw Planner scenario when present, recursively canonicalized by sorted object keys.

Full public Bond snapshots are deliberately not copied into the private payload. Public NBU/MinFin/seller data remains outside the private payload.

A migrated legacy collection is **not** an acquisition lot, holding, cash event or disposal. Migration creates zero portfolio facts.

Detailed idempotence, conflict, verification and plaintext-retention rules are defined in `docs/private-legacy-migration.md`.

## 4. Acquisition lot

Each lot has:
- stable local `id`;
- `isin`;
- integer `units`;
- factual `acquiredOn` date;
- `currency`;
- factual whole-lot `tradeAmount`;
- explicit fee state;
- optional private broker/account label.

### tradeAmount semantics

`tradeAmount` is the factual cash consideration for the bond trade itself for the whole lot, excluding a separately recorded broker/transaction fee.

It is not:
- a public quote;
- a yield;
- a percentage-of-nominal field;
- an inferred price.

If accrued interest was included in the broker's factual trade settlement amount, it stays in that factual trade amount rather than being silently reconstructed from public data.

### acquisition fee semantics

`feeStatus`:
- `unknown` → `feeTotal` absent;
- `known` → `feeTotal` required and may be exactly zero.

Known zero is never collapsed into unknown.

## 5. Factual coupon / redemption events

Supported cash event kinds:
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

The payload never replaces the factual amount with an amount reconstructed from a public NBU schedule.

## 6. Factual disposal / sale

Each disposal has:
- stable local `id`;
- `isin`;
- factual `disposedOn` date;
- positive integer disposed `units`;
- currency;
- factual whole-disposal gross `proceedsAmount`;
- explicit disposal fee state;
- one or more explicit acquisition-lot allocations;
- optional private note.

### proceeds / fee semantics

`proceedsAmount` is the factual gross trade consideration for the whole disposal before the separately recorded disposal fee.

Disposal `feeStatus`:
- `unknown` → `feeTotal` absent and net proceeds remain unknown;
- `known` → `feeTotal` required and may be exactly zero.

When fee is known:

`knownNetProceeds = proceedsAmount - feeTotal`

Unknown fee is never silently treated as zero.

## 7. Explicit lot allocation — no invented FIFO/LIFO

A disposal contains allocation rows:
- `lotId`;
- allocated integer `units`.

Rules:
- allocation-unit sum must equal disposal units exactly;
- the same lot cannot appear twice inside one disposal;
- referenced lot must exist;
- referenced lot ISIN must match disposal ISIN;
- referenced lot acquisition date must be on/before disposal date;
- cumulative allocation of a lot across all disposals cannot exceed its acquired units.

The domain does **not** automatically choose FIFO, LIFO, average-cost or any other allocation method. Such a choice would create a private historical fact that the user/import source did not provide.

## 8. Realized cost-basis foundation without hidden rounding

For each disposal allocation the domain exposes exact factual inputs:
- disposal id;
- acquisition lot id;
- allocated units;
- total lot units;
- factual whole-lot trade amount;
- acquisition fee known/unknown state;
- factual whole-lot fee when known.

This is sufficient provenance for a later reporting/tax layer to derive realized acquisition cost under an explicit rounding/accounting rule.

This slice deliberately **does not** divide a whole-lot Decimal amount into an arbitrarily rounded per-unit Decimal. Financial rounding is not invented at domain-storage level.

## 9. Redemption / disposal boundary

Schema v1/v2/v3 redemption records do not contain acquisition-lot allocation.

Therefore, if a redemption for an ISIN is already represented on or before a later disposal date, schema v2/v3 rejects that disposal with a fail-closed semantic error. Otherwise the program could falsely claim which acquisition lots remained after redemption.

This restriction can be relaxed only by a later explicit redemption-allocation model.

## 10. Semantic validation

Fail closed when:
- record/portfolio ID format is invalid;
- record IDs duplicate across lots/events/disposals;
- ISIN/date/currency/amount is invalid;
- one ISIN has conflicting acquisition currencies;
- cash event or disposal has no acquisition lot;
- event/disposal currency differs from acquisition currency;
- event/disposal predates acquisition;
- disposal allocation sum differs from disposed units;
- allocation references missing/wrong-ISIN/future lot;
- cumulative disposal allocation overuses an acquisition lot;
- represented disposal/redemption makes chronological units negative;
- disposal occurs on/after a represented redemption without redemption allocation;
- known/unknown fee state is inconsistent;
- coupon carries redemption units;
- unknown schema or unknown fields are encountered.

Same-day acquisition is applied before same-day disposal. Disposal on the same day as a represented redemption is conservatively rejected by the redemption-allocation rule.

## 11. Deterministic representation

Canonical order:
- acquisition lots: date → ISIN → id;
- cash events: date → ISIN → kind → id;
- disposals: date → ISIN → id;
- each disposal's allocations: lotId.

JSON uses fixed schema-v3 key order, UTF-8 and canonical Decimal string values. Legacy collection scenario maps are recursively key-sorted before encoding.

Both encode and decode enforce a 16 MiB payload limit.

Record-count limits:
- acquisition lots: 10,000;
- cash events: 50,000;
- disposals: 50,000;
- encrypted legacy collection records: 10,000.

## 12. Schema v1/v2 compatibility

Decoder accepts:
- schema v1: `portfolioId + acquisitionLots + cashEvents`;
- schema v2: the same fields plus required `disposals`;
- schema v3: schema v2 plus required `legacyCollections`.

Decoded v1 has empty disposal and legacy-collection lists. Decoded v2 has an empty legacy-collection list. Re-encoding always produces canonical schema v3.

Unknown future fields or schema versions still fail closed.

## 13. Encrypted-storage integration

The codec returns raw private payload bytes.

Those bytes are passed to the existing `LocalVaultStore` / session layer and receive:
- XChaCha20-Poly1305 authenticated encryption;
- vault revision/rollback handling;
- atomic known-good write lifecycle;
- device-key/recovery handling.

Regression coverage requires the physical vault file not to expose plaintext portfolio id, ISIN, broker label, disposal id, lot-allocation provenance, migrated note or migrated Planner scenario values.

## 14. Explicitly deferred

Before user-facing portfolio UI:
- migration UI/status and explicit cleanup action;
- user-facing disposal/allocation editor;
- imported broker statement adapters;
- automatic lot-allocation policy;
- reporting/tax realized-gain rounding policy;
- redemption-to-lot allocation;
- any automatic reconstruction of missing historical facts.

No missing historical fact is invented from public data.
