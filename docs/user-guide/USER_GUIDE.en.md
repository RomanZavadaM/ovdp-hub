# OVDP Hub v0.9.3 — User Guide

## Purpose
OVDP Hub is a local-first application for Ukrainian government bonds (OVDP): market-source review, scenario planning, comparison, and a factual encrypted personal portfolio. It does not execute trades.

## Installation
**Windows:** extract the complete release ZIP and run `ovdp_hub.exe`. Keep DLLs/resources together. The test build is not production-signed, so SmartScreen may appear.

**macOS:** extract the ZIP and open `ovdp_hub.app`. The prerelease is not notarized. After a blocked first launch, macOS may offer **Open Anyway** under System Settings → Privacy & Security.

**Android:** extract the Android ZIP and install `OVDP-Hub.apk`. This is a development-signed test build.

**iOS:** the published package is unsigned and requires separate Apple signing/provisioning.

## Language and appearance
UI languages: Ukrainian, English, French, German, Spanish, Korean, Japanese. Appearance: Classic, Workbench, Light Dashboard. The selected language and appearance are stored locally on this device and restored on the next launch.

## Market and ISIN
Use the catalog to search/filter bonds. The ISIN card keeps NBU, MinFin, and seller observations separate and shows source date, retrieval time, and freshness/status. Yield-only or nominal data is never silently treated as a tradable market price.

## Planner
A scenario uses one base currency. Configure budget, reserve, horizon, needs, positions, fees, tax, FX, optional early exit, reserve floor, and one-off/recurring needs. Unknown values must remain unknown rather than being replaced with zero.

A/B/C compares 2–3 compatible saved scenarios. The letters are order labels only; the app does not choose a winner.

CSV and ICS exports are written locally to the active workspace `exports/` folder.

## My Portfolio
The portfolio is an encrypted local flow with create/open/lock and session/background locking.

**Purchase:** record factual ISIN/date/units/amount and fee state.

**Sale:** explicitly allocate the sale to acquisition lots; the app does not invent FIFO/LIFO.

**Coupon / redemption:** record actual received amounts. Coupon events do not change units.

**ISIN ledger:** purchase/sale/coupon/redemption history stays inspectable. Closed zero-unit positions remain visible.

**Factual cash summary:** shows purchase amounts, sale proceeds, coupons, redemptions, and known fees per currency. If any relevant acquisition/disposal fee is unknown, the exact net cash result is withheld.

This summary is **not market valuation or investment performance** because current market value of open positions is not added.

## Legacy migration
The migration wizard copies supported user-specific legacy data into the encrypted payload and verifies the encrypted copy. It is non-destructive: source JSON is never auto-deleted.

## Backup and updates
Before major updates, lock the portfolio, back up the workspace, create/verify an encrypted portable backup, and keep recovery material separately. For desktop updates, extract the new release into a new program folder and keep the workspace until the new version is verified.

On Windows, **My portfolio** can create a portable encrypted backup and restore an empty local portfolio from it. The recovery secret is entered twice at creation and can be changed later. Android/iOS external-file flows remain deferred to the separate SAF/security-scoped access stage.

## Checksums
Use `SHA256SUMS.txt` from the GitHub Release to verify downloaded archives when needed.

## Common issues
- SmartScreen / macOS launch warnings: expected for the unsigned test prerelease; only trust files from the official release page.
- “Unknown fee”: intentional state, not an error.
- No market net result: the factual summary deliberately excludes current market value of open holdings.
- iOS package will not install directly: it is unsigned.

## Responsibility
OVDP Hub is not a broker and does not guarantee instrument availability. Verify prices, fees, taxes, dates, and conditions with primary sources and your broker/bank before financial action.
