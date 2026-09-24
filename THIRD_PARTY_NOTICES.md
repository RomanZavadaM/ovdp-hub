# Third-Party Notices

OVDP Hub / ОВДП Hub includes or can be distributed with third-party software and uses public information from external sources. Those components and materials remain the property of their respective copyright holders or providers and are governed by their own licenses, terms and rights.

The OVDP Hub proprietary license does **not** replace, restrict, or relicense third-party components or public data.

Direct Flutter/Dart dependencies currently declared by the active native application include:

- Flutter and Dart SDK components
- file_selector
- path
- path_provider
- decimal
- http
- flutter_bloc
- archive — MIT, ZIP/DOCX container decoding for official MinFin auction-result documents
- pdf_document — Apache-2.0, pure-Dart PDF document model used by the calendar PDF reader
- pdf_graphics — Apache-2.0, pure-Dart PDF text extraction used by the calendar PDF reader
- sodium 4.1.0+1 — BSD-3-Clause Dart bindings; bundles/uses libsodium 1.0.22 (ISC) for the encrypted-vault cryptographic foundation
- flutter_secure_storage 11.2.0 — BSD-3-Clause, OS-backed device-key storage adapter for Android/iOS/macOS
- win32 6.4.0 — BSD-3-Clause, Windows API bindings used by the app-owned current-user DPAPI device-key adapter
- flutter_lints (development dependency)

`libsodium` remains governed by its own ISC license and copyright notices; the `sodium` Dart wrapper remains governed by BSD-3-Clause. `flutter_secure_storage` and `win32` retain their BSD-3-Clause terms and upstream copyright notices.

Platform runtimes, operating-system libraries, build tools, transitive dependencies and packaging/signing tools may have separate copyright and licensing terms. The authoritative dependency versions for a source/build checkpoint are recorded in `apps/native/pubspec.yaml` and `apps/native/pubspec.lock`.

OVDP Hub also reads or embeds public information originating from sources such as:

- National Bank of Ukraine (NBU)
- Ministry of Finance of Ukraine
- public bank or broker quote endpoints when explicitly connected by the application

Such data, source names, trademarks and related materials are not transferred to Roman Zavada by inclusion or use in OVDP Hub. Applicable source terms, attribution requirements and public-data rules remain in force.

For executable or test distributions, applicable third-party notices must be preserved as required by those projects and data providers.

**OVDP Hub original materials:** Copyright © 2026 Roman Zavada (Роман Завада). All rights reserved.

See [LICENSE.md](LICENSE.md) for the OVDP Hub proprietary license.
