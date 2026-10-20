# OVDP Hub

[🇺🇦 Українська](../../README.md) · **🇬🇧 English** · [🇫🇷 Français](README.fr.md) · [🇩🇪 Deutsch](README.de.md) · [🇪🇸 Español](README.es.md) · [🇰🇷 한국어](README.ko.md) · [🇯🇵 日本語](README.ja.md)

> **Current test release: [OVDP Hub v0.10.1](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.10.1) — 0.10.1+23**
>
> **Development status: ACTIVE — v0.10.1 release checkpoint is being prepared on 20.10.2026.**
>
> [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-START.zip) · [SHA-256](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/SHA256SUMS.txt)

## What it is

OVDP Hub is a local-first Flutter/Dart app for Ukrainian government bonds: market-source review, scenario planning, neutral comparison, and a factual encrypted personal portfolio.

## v0.10.1 highlights

- safer private Planner migration: plaintext is deleted only after rechecking the encrypted copy and current source;
- locking clears the private Planner and cancels dialogs, date pickers, and stale async completions;
- lock/background/dispose cancel unfinished recovery, create, restore, and migration work and remove late keys;
- private CSV/ICS export requires explicit plaintext consent and shows the exact destination;
- cryptography, KDF parameters, and payload schema are unchanged; schema remains v4.

## Product scope

- NBU / MinFin / seller layers with provenance and freshness;
- Planner with fees, tax, FX, recurring needs, reserve floor and per-position early exit;
- neutral A/B/C comparison without an automatic winner;
- deterministic CSV/ICS exports and Economic Pulse;
- encrypted factual Portfolio with purchase/sale/coupon/redemption, explicit lot allocation and per-ISIN ledger;
- recovery confirmation/rotation and Windows portable encrypted backup/restore;
- macOS Keychain-backed Portfolio with packaged runtime lifecycle smoke;
- Android SAF and iOS security-scoped external-storage foundation;
- mobile external workspace and encrypted backup transport with fail-closed permission semantics;
- integrated two-phase terminate/relaunch mobile-storage self-test;
- Classic / Workbench / Light Dashboard;
- UI in UK/EN/FR/DE/ES/KO/JA with persisted language and appearance.

The factual cash summary excludes current market value of open holdings, so it is not market valuation or investment-performance reporting. Unknown fees remain unknown.

## Install

Windows: extract the complete ZIP and run `ovdp_hub.exe`. macOS: extract and open `ovdp_hub.app`; this checkpoint is not notarized. Android: extract and install `OVDP-Hub.apk`. The iOS package is unsigned and requires separate Apple signing/provisioning for installation.

Full guide: **[English User Guide](../user-guide/USER_GUIDE.en.md)**.

## Verification and boundaries

The completed feature head passed Flutter analyze, **314 tests**, exact packaged Windows/macOS smoke, Android release packaging, and unsigned iOS packaging. The v0.10.1 release workflow must reproduce these gates and publish START/source, checksums, and legal notices.

Deferred: Android physical SAF persistence/revoke testing, signed iOS/device runtime validation, production signing/notarization/store distribution, installers and auto-update. These physical-device cases are not claimed as `RUNTIME VALIDATED`. Accrued interest and yields are indicative, not quotes or investment advice.

## Privacy and legal

Private portfolio data stays local and encrypted. Legacy workspace JSON may remain plaintext; migration never auto-deletes source JSON.

Copyright © 2026 Roman Zavada. All rights reserved. OVDP Hub is proprietary software; the public repository does not grant an open-source license. See [LICENSE.md](../../LICENSE.md) and [legal notices](../LEGAL_AND_COPYRIGHT.md).
