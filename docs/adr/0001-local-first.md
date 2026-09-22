# ADR 0001: public aggregator and on-device private data

Status: local-first security boundary remains accepted; web-platform details are superseded by ADR 0002, 2026-09-22.

## Decision

Phase one is an aggregator of public OVDP information. It has no accounts, personal backend, KYC, trading or signature storage. Next.js exports static assets. Calculation executes in the browser. The current budget lives in React memory and is cleared on reload.

Future private portfolios and settings must remain on the end user's device. Local encrypted storage and user-controlled encrypted backups require a separate security design. Private documents, credentials and signature material must not pass through OVDP Hub infrastructure.

Future partner authorization must use a provider-supported native/public-client flow (for example authorization code with PKCE) and direct device-to-provider transmission. No partner client secret may be embedded in the application. If a provider mandates a confidential backend, the feature is unsupported under this architecture; use a provider-hosted handoff instead.

## Limits and threat model

Local-first removes a central private-data collection point, not all attack surfaces. An altered application bundle, XSS, malicious extension, compromised device or stolen unlocked session can still expose data. Partner systems necessarily process information received directly from the user. Static hosting sees ordinary network metadata such as IP addresses; that is distinct from a server-side financial profile.

Use no telemetry/session replay. Before persistent storage: audited cryptographic library, encrypted vault with user-held unlock material, explicit locking, deletion, recovery/export design, dependency review, CSP and no third-party runtime scripts. Non-exportable platform keys should be preferred on native devices. Never claim end-to-end safety solely because IndexedDB is used.

## Public aggregation

Public sources may be downloaded directly if allowed and CORS-compatible, or collected by an isolated public-data publishing job. Such a job receives no user budget, holdings, documents or identity. Do not expose a general-purpose URL proxy. Publish versioned source-attributed snapshots with observed/published timestamps and stale markers. No private-data relay may be introduced to solve CORS.

## Superseded proposal

The earlier conceptual microservice design with central Users/KYC/Documents/OMS storage is superseded for this product. These services are not implemented and are not the current roadmap. Local storage does not make server-based KYC or order routing acceptable.
