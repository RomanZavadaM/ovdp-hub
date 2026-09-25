# OVDP Hub

[🇺🇦 Українська](../../README.md) · **🇬🇧 English** · [🇫🇷 Français](README.fr.md) · [🇩🇪 Deutsch](README.de.md) · [🇪🇸 Español](README.es.md) · [🇰🇷 한국어](README.ko.md) · [🇯🇵 日本語](README.ja.md)

> **Current test prerelease: [OVDP Hub v0.9.3](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.9.3) — 0.9.3+20**
>
> [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-START.zip) · [SHA-256](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/SHA256SUMS.txt)

## What it is
OVDP Hub is a local-first Flutter/Dart app for Ukrainian government bonds: market-source review, scenario planning, neutral comparison, and a factual encrypted personal portfolio. Supported test targets: Windows, macOS, Android, iOS.

## v0.9.3 highlights
- NBU / MinFin / seller layers with provenance and freshness;
- Planner with fees, tax, FX, early exit, reserve floor and recurring needs;
- neutral A/B/C comparison without an automatic winner;
- deterministic CSV/ICS exports;
- persistent Economic Pulse;
- encrypted My Portfolio with factual purchase, sale, coupon and redemption;
- explicit acquisition-lot allocation instead of invented FIFO/LIFO;
- per-ISIN ledger and closed positions;
- factual cash summary with unknown fees preserved as unknown;
- non-destructive legacy migration wizard with encrypted-copy verification;
- Classic / Workbench / Light Dashboard;
- UI in UK/EN/FR/DE/ES/KO/JA.

The factual cash summary excludes current market value of open holdings, so it is not market valuation or investment-performance reporting.

## Install
Windows: extract the complete ZIP and run `ovdp_hub.exe`. macOS: extract and open `ovdp_hub.app`; the prerelease is not notarized. Android: extract and install `OVDP-Hub.apk`. iOS package is unsigned and needs separate Apple signing/provisioning.

Full guide: **[English User Guide](../user-guide/USER_GUIDE.en.md)**.

## Privacy
Private portfolio data is local and encrypted. Legacy workspace JSON may remain plaintext; migration never auto-deletes source JSON. Back up the workspace and encrypted portable backup before major updates.

## Verification
v0.9.3 passed full Flutter analyze/tests, Windows/macOS release packaging and exact packaged-executable smoke, Android test build, unsigned iOS build, START/source packaging, checksums and legal notices.

## Legal
Copyright © 2026 Roman Zavada. All rights reserved. OVDP Hub is proprietary software; the public repository does not grant an open-source license. See [LICENSE.md](../../LICENSE.md) and [legal notices](../LEGAL_AND_COPYRIGHT.md).
