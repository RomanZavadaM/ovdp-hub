# Development rules

- Before any project work, read `PROJECT_RULES.md` and `PROJECT_STATE.md`; they are the canonical persistent rules and current checkpoint.

- Current scope: public-information aggregator; no execution, KYC, user accounts or financial advice.
- Personal inputs, holdings, documents and signing keys must never traverse OVDP Hub servers.
- Keep calculations on-device. No analytics, session replay, remote fonts or third-party scripts.
- Public ingestion may process public market data only; never attach user identifiers or portfolios.
- Demo quotes must be clearly marked SYNTHETIC and never executable.
- Money uses decimal arithmetic. Floating point is restricted to presentation and the separately tested numerical yield solver; never use it for stored monetary values.
- The active and only product line is apps/native (Flutter/Dart), targeting Windows, macOS, Android and iOS. Run flutter analyze, flutter test and the target release build for native changes. Retired web/Expo/Tauri history remains available through Git, not the active tree.
- User-selected network or cloud-synced workspaces are authorized. Explain that the selected provider stores/syncs those files. Never place signing keys in portable workspaces.
- Monetary arithmetic uses Decimal. Double is permitted only inside the bounded numerical XIRR solver and presentation; test reference tolerances explicitly.
- Do not claim a broker API is available without verified documentation and permission to use it.
- Never store signing keys in browser localStorage; do not implement crypto primitives yourself.
- Discuss any change to these trust boundaries with the user before implementing it.

- Original OVDP Hub project materials are proprietary and owned by Roman Zavada (Роман Завада). Public repository visibility is not an open-source license.
- Preserve LICENSE.md, COPYRIGHT.md, THIRD_PARTY_NOTICES.md, visible copyright notices and platform metadata. Do not relicense the project or change the named copyright owner without the owner's explicit instruction.
- Third-party software and public market data retain their own licenses, terms, attribution and rights; never claim them as original OVDP Hub property.

- Product language rule: Ukrainian is canonical/default. Design user-visible strings for localization to English, French, German, Spanish, Korean and Japanese; translations must preserve financial/legal meaning.
