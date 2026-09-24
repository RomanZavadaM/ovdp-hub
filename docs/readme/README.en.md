# OVDP Hub

[🇺🇦 Українська](../../README.md) · **🇬🇧 English** · [🇫🇷 Français](README.fr.md) · [🇩🇪 Deutsch](README.de.md) · [🇪🇸 Español](README.es.md) · [🇰🇷 한국어](README.ko.md) · [🇯🇵 日本語](README.ja.md)

> **Current published prerelease / Поточний опублікований prerelease: [OVDP Hub v0.9.0](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.9.1) (0.9.1+18)**
>
> Downloads / Завантаження: [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.1/OVDP-Hub-0.9.1-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.1/OVDP-Hub-0.9.1-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.1/OVDP-Hub-0.9.1-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.1/OVDP-Hub-0.9.1-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.1/OVDP-Hub-0.9.1-START.zip) · [SHA-256](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.0/SHA256SUMS.txt)

---

### v0.9.1 checkpoint

**v0.9.1+18** adds the post-0.9.0 Light Dashboard, Planner reserve floor, deterministic CSV/ICS exports, and the verified internal encrypted-vault/private-portfolio foundation: authenticated local vault storage, recovery/backup, rollback/session lifecycle, factual private portfolio schemas, explicit disposal lot allocation, and a non-destructive legacy migration core.

**Privacy boundary:** the user-facing vault/migration/portfolio flow is not wired yet. Existing legacy `sets/*.json` do **not** become encrypted automatically after updating. The migration core has no delete API and never converts a saved collection into factual holdings. Next after this checkpoint: Android SAF / iOS security-scoped external-folder access, with user-facing vault/migration UX as a separate gate.


### What it is

**OVDP Hub** is an installable Flutter/Dart application for exploring Ukrainian government bonds (OVDP), market sources, and personal investment scenarios. Target platforms are **Windows, macOS, Android, and iOS**. Web/PWA is not part of the active product.

Active code: `apps/native`. The current checkpoint is **0.9.1+18**. It includes the post-0.9.0 UI/Planner/export work plus the verified internal encrypted-vault/private-domain/migration foundation. User-facing vault/migration/portfolio wiring remains deferred.

### What already works

- local OVDP catalog based on public NBU data;
- search, filters, payment schedules, and issue comparison;
- separate **NBU / Ministry of Finance / seller** data layers with provenance, source date, retrieval time, and freshness/status;
- structured Ministry of Finance auction calendars and detailed placement/switch auction results;
- multiple price sources with explicit user-controlled priority;
- planner for budget, reserve, maturity horizon, and future expenses;
- explicit purchase-fee assumptions: an unknown fee is never treated as zero;
- a verified 2026 Ukraine-resident OVDP tax profile with explicit **unknown** versus **verified zero** semantics;
- explicit FX comparison with manual rate, date, and source URL while base cashflow stays single-currency;
- per-position early sale with an individual sale date and BID/manual exit price;
- a recurring primary future need stored as a typed rule, while additional needs remain one-off items;
- neutral **A/B/C** comparison for 2–3 saved scenarios with strict comparability and no automatic winner;
- typed reserve-floor / minimum-balance rule: from its effective date the amount must remain liquid and is not treated as an expense;
- deterministic local Planner CSV/ICS exports for scenario/needs/coverage/cashflow into the active workspace `exports/` folder; PDF remains deferred until the report structure stabilizes;
- generated Planner copy / preset labels are stored as stable IDs and localized at display time; user-authored names remain literal;
- portable JSON workspace persistence;
- active UI and main user-facing errors localized for **UK / EN / FR / DE / ES / KO / JA**.

A nominal coupon is not treated as market yield, yield-only observations never become a price automatically, and unknown fees, taxes, or FX are never silently replaced with zero.

### Planner

The planner remains single-currency by design and supports maturity allocation, calculated-profit mode, and future-expense coverage. Quantity and full price can be edited manually. Additional expenses, reserve, settlement delay, and saved scenarios are supported.

Development after the published 0.9.0 checkpoint:

1. **DONE** — explicit price-source priority;
2. **DONE** — purchase-fee assumptions;
3. **DONE** — verified tax assumptions;
4. **DONE** — FX assumptions;
5. **DONE** — exit assumptions;
6. **DONE** — neutral A/B/C comparison;
7. **DONE** — generated Planner copy / preset-label localization + regression;
8. **DONE** — v0.9.0 prerelease checkpoint;
9. **DONE** — reserve-floor / minimum-balance need;
10. **DONE** — deterministic local CSV/ICS exports; PDF deferred;
11. **NEXT** — review/approve the encrypted-vault threat model before crypto implementation.

OVDP Hub does not execute trades and does not confirm seller availability.

### Data and privacy

Catalogs and scenarios are stored on the device. Desktop users can open or copy a workspace folder. OVDP Hub does not operate a server for private portfolio data.

The current JSON workspace is **not encrypted**, so it is not intended for signing keys, KYC documents, or secrets. An encrypted vault and platform secure storage are planned as a separate stage.

### Quick testing

Normal changes run `flutter analyze`, `flutter test`, and START packaging. On Windows use `START.bat`; on macOS use `START.command`. The first local START run requires Flutter 3.47.5 and platform build tools.

A formal prerelease builds Windows/macOS/Android/iOS plus START/source, `SHA256SUMS.txt`, legal notices, an immutable tag, and a GitHub Release.

### Copyright and license

**Copyright © 2026 Roman Zavada. All rights reserved.**

OVDP Hub is **proprietary software**. Public repository visibility does not grant an open-source license or permission to copy, modify, republish, sell, redistribute, or create derivative versions.

See [LICENSE.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/LICENSE.md), [COPYRIGHT.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/COPYRIGHT.md), [THIRD_PARTY_NOTICES.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/THIRD_PARTY_NOTICES.md), and [LEGAL_AND_COPYRIGHT.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/docs/LEGAL_AND_COPYRIGHT.md).

### Developer

```sh
cd apps/native
flutter pub get
flutter analyze
flutter test
flutter build windows --release
```

Other targets: `flutter build macos --release`, `flutter build apk --release`, `flutter build ipa --release`.

Project state entry points: [START_HERE.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/START_HERE.md), [PROJECT_STATE.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/PROJECT_STATE.md), [PROJECT_RULES.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/PROJECT_RULES.md), [WORKLOG.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/WORKLOG.md), [CHANGELOG.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/CHANGELOG.md).

---

[🇺🇦 Українська](../../README.md) · **🇬🇧 English** · [🇫🇷 Français](README.fr.md) · [🇩🇪 Deutsch](README.de.md) · [🇪🇸 Español](README.es.md) · [🇰🇷 한국어](README.ko.md) · [🇯🇵 日本語](README.ja.md)
