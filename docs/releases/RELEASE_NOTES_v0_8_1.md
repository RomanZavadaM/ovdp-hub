# OVDP Hub 0.8.1

**Release date:** 22 September 2026  
**Status:** prerelease / test checkpoint  
**Copyright:** © 2026 Roman Zavada (Роман Завада). All rights reserved.

OVDP Hub 0.8.1 is the first formally packaged GitHub prerelease of the current Flutter/Dart product line.

## What is included

- native Flutter application for Windows, macOS, Android and iOS;
- local OVDP catalog and payment schedules;
- local collections and portable workspace scenarios;
- budget, maturity and cashflow planning;
- multiple future-expense scenarios and reserve logic;
- direct public quote loading from PrivatBank where available;
- classic interface and the alternative “Робочий кабінет” design;
- START/source package for local testing;
- proprietary license, copyright and third-party notices.

## Legal status

The original OVDP Hub project materials are proprietary works owned by **Roman Zavada (Роман Завада)**.

Public visibility of the repository does not grant an open-source license. See:

- `LICENSE.md`
- `COPYRIGHT.md`
- `THIRD_PARTY_NOTICES.md`
- `docs/LEGAL_AND_COPYRIGHT.md`

Public financial data and third-party software retain their own rights, licenses and terms.

## Data and privacy

OVDP Hub does not require a central account for local planning. Private scenarios and workspaces are stored on the user's device or in a user-selected local/network/cloud-synced folder.

The application does not execute purchases or sales and does not provide KYC or broker custody.

## Important financial limitation

Market data, yields, calendars and quotes may be delayed, indicative, incomplete or subject to change. Synthetic/demo calculations are marked separately. The user must independently verify information before making a financial, tax or investment decision.

## Package status

This release is a **test/prerelease checkpoint**.

- Windows package: unsigned test build.
- macOS package: unsigned/not notarized test build.
- Android package: test build using the current development signing configuration.
- iOS package: unsigned build; installation requires appropriate Apple signing.
- START package: source-based test package requiring Flutter 3.47.5 and platform build tools.

Legal notices are included in packaged distributions. SHA-256 hashes are published as `SHA256SUMS.txt`.

## Verification

Release workflow runs:

- `flutter pub get --enforce-lockfile`;
- `flutter analyze`;
- `flutter test`;
- platform release builds used for the published test packages.

The GitHub tag and release are immutable checkpoints and must not be moved or overwritten after publication.
