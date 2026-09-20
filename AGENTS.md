# Development rules

- Current scope: public-information aggregator; no execution, KYC, user accounts or financial advice.
- Personal inputs, holdings, documents and signing keys must never traverse OVDP Hub servers.
- Keep calculations on-device. No analytics, session replay, remote fonts or third-party scripts.
- Public ingestion may process public market data only; never attach user identifiers or portfolios.
- Demo quotes must be clearly marked SYNTHETIC and never executable.
- Money uses decimal arithmetic. Number is acceptable only for UI formatting and final yield sorting.
- Use pnpm. Run pnpm test, pnpm typecheck and pnpm build before committing functional changes.
- Do not claim a broker API is available without verified documentation and permission to use it.
- Never store signing keys in browser localStorage; do not implement crypto primitives yourself.
- Discuss any change to these trust boundaries with the user before implementing it.
