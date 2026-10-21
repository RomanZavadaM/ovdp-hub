# Архітектура OVDP Hub — Flutter native

Оновлено: **21.10.2026**

Єдиний активний продукт — `apps/native` для Windows, macOS, Android та iOS. OVDP Hub є local-first інформаційним, планувальним і factual-portfolio застосунком. Немає власного сервера приватного портфеля, KYC, broker credentials, виконання угод або tracking.

## Шари

```text
Flutter UI
  → Cubit / immutable state
  → feature repository / HubRepository / PortfolioGateway
  → public adapters + local workspace + encrypted vault
```

Widgets показують state і передають події. Cubit координують сценарії та stale-completion guards. Repository/gateway відповідають за I/O. Financial models і Decimal calculations не залежать від UI.

## Дані продукту

- Catalog/market: NBU, MinFin, provenance, freshness, status, ISIN card.
- Sellers: public PrivatBank/Inzhur/UNIVER observations. Price, yield, quantity, source time та retrieval time — окремі поля; ISIN/currency/maturity перевіряються.
- Planner: budget/reserve/horizon, fees/tax/FX, needs, early exit, neutral A/B/C, CSV/ICS.
- Portfolio: factual purchase/sale/coupon/redemption, explicit lot allocation, ledger і per-currency cash summary.
- Collections: public annotation-free lists у workspace; private named/noted collections у vault.

## Encrypted vault

Payload schema v5 читає v1–v4. V5 додає private collections поряд із private Planner scenarios та factual portfolio. Cryptography, KDF і recovery slots не змінені. Private UI state прив’язаний до session epoch: lock/background/dispose очищують state, а старі async completions не можуть його відновити.

Legacy private collection move є explicit verified full-copy migration. Source видаляється лише після canonical encrypted-copy verification, повторного читання незміненого source і чинної vault authorization. Unknown fields або conflicts блокують видалення.

## Публічні джерела продавців

Adapters читають лише загальнодоступні сторінки. Normalization не змішує quoted price, listed yield, available quantity, source timestamp і retrievedAt. Provider failure ізольований; retained observation позначається помилкою без підміни часу. Немає login/OTP/private endpoints/execution.

## Storage і платформи

Desktop використовує локальний workspace; macOS device state — Keychain. Android SAF та iOS security-scoped access мають реалізований external-file transport і fail-closed permission handling. Physical-device validation, production signing, notarization, stores, installers та auto-update лишаються deferred.
