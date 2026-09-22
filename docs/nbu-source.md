# NBU public securities adapter

Implemented 2026-09-20. Source: https://bank.gov.ua/depo_securities?json
Reference page: https://bank.gov.ua/ua/markets/ovdp
Official API listing: https://bank.gov.ua/ua/open-data/api-dev
Technical specification: https://bank.gov.ua/admin_uploads/article/Instr_API_depo_securities.pdf
Reuse/attribution: https://bank.gov.ua/ua/open-data

Verified HTTP 200 and Access-Control-Allow-Origin: * with an Origin header on 2026-09-20. Availability and CORS can change; the UI retains its prior snapshot on failure. No proxy is used.

## Mapping
- cptype DCP + emit_okpo 00013480: domestic government bond. OZDP and OMP excluded. Unknown types quarantined.
- cpcode: ISIN; val_code: currency; nominal: nominal value.
- auk_proc: nominal interest rate, explicitly NOT a purchase YTM.
- razm_date / pgs_date: issue / maturity date.
- pay_period: coupon period in days, absent/zero means unknown (not guessed).
- payments.pay_type: 1 coupon, 2 redemption, 3 early redemption, per official PDF.
- pay_val: payment amount per security, in issue currency. Preserve coupon and principal separately.

JSON numbers are normalized to decimal strings. Unknown amounts are rejected rather than defaulted to zero. Invalid individual rows are quarantined with index/reason; a wholly invalid or empty feed and duplicate ISINs reject the entire refresh. CLI publication fails on any quarantined row and preserves the previous file.

retrievedAt records successful retrieval, not the underlying dataset's effective date. sourceAsOf is null because the feed does not supply a trustworthy dataset timestamp. RECENT describes retrieval under 24h; it is not a guarantee of current financial terms. Issue dates, maturity and schedules are retained as supplied; no payment is fabricated from coupon frequency. The UI shows future scheduled payments, never confirms receipt.

## Updating

From `apps/native`, run `dart run tool/refresh_nbu.dart`. Only public data is requested. The validated output atomically replaces `apps/native/assets/nbu-snapshot.json`; review the diff before committing. Builds and tests use the committed snapshot and never depend on source uptime.

The UI loads this public snapshot initially and refreshes only on explicit click, directly device → NBU, credentials omitted and referrer suppressed. No ISIN filter, budget, account, document or portfolio is sent. There is no automatic background polling or private storage. Public endpoint sees ordinary connection metadata. Static hosting is still a code-delivery trust boundary.

Fixture nbu-sample.json contains one actual DCP and one OZDP record retrieved on 2026-09-20; tests are offline. Ministry auction ingestion remains a separate upcoming task.
