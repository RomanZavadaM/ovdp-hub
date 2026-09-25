# Архітектура OVDP Hub — Flutter native

Оновлено: **25.09.2026**  
Актуальний checkpoint: **v0.9.3 / 0.9.3+20**

## Межа продукту

Активний продукт один: `apps/native` на Flutter/Dart для Windows, macOS, Android та iOS. Web/PWA, Next.js, Expo і Tauri не є активними продуктовими лініями.

OVDP Hub — local-first інформаційний, планувальний і factual-portfolio застосунок. Немає серверних акаунтів OVDP Hub, централізованого приватного портфеля, KYC, виконання угод або приватного relay-сервера.

## Шари runtime

```text
Flutter UI
  ↓
Cubit / immutable feature State
  ↓
feature repositories / HubRepository / PortfolioGateway
  ↓
public adapters + local workspace + encrypted vault
```

Основні функціональні області:

- `catalog` — випуски НБУ, фільтри, графіки виплат;
- `market/isin` — NBU / MinFin / seller observations із provenance/freshness;
- `collections` — локальні добірки;
- `calculator` — локальні фінансові розрахунки;
- `workspace` — переносне локальне сховище public/scenario data;
- `planner` — typed scenarios, needs, fees, tax, FX, exits, reserve floor, A/B/C;
- `sellers` — дозволені публічні observations продавців;
- `portfolio` — encrypted factual purchase/sale/coupon/redemption, holdings, ledger, cash summary;
- `vault/security` — device keys, recovery, encrypted backup, locking, rollback/crash lifecycle;
- `navigation/appearance/l10n` — shell, три appearance та UK/EN/FR/DE/ES/KO/JA.

UI widgets не повинні напряму виконувати файлові/мережеві операції. Cubit/feature state керує flow; repositories/gateways відповідають за I/O. Грошова арифметика використовує Decimal; Double допускається лише у явно обмежених і протестованих чисельних задачах.

## Ринкова модель

Один ISIN може мати незалежні шари:

1. **Інструмент / контрактні платежі** — НБУ.
2. **Первинний ринок** — календар, оголошення та результати Мінфіну.
3. **Вторинний ринок** — публічні/дозволені seller observations.
4. **Користувацький scenario** — price, quantity, fee/tax/FX/exit assumptions.
5. **Фактичний private portfolio** — реальні user-recorded cash/position facts.

Шари не зливаються у «єдину правду». Кожне market observation має власне джерело, source date, retrieved time і data/freshness status.

## Planner

Поточний Planner використовує typed scenario model зі збереженням сумісності старих schema через adapters без тихого переписування.

Окремо моделюються:

- positions та selected price observations;
- purchase fee state, включно з unknown;
- effective-dated tax assumptions;
- FX assumptions;
- per-position early exit;
- one-off / recurring needs;
- reserve floor;
- settlement delay;
- A/B/C strict comparability;
- deterministic CSV/ICS exports.

## Private portfolio / encrypted vault

Private portfolio **вже user-facing у v0.9.3** і не зберігається як паралельний plaintext portfolio store.

Vault layer включає:

- authenticated encrypted envelope;
- platform device-key adapters;
- recovery material / wrapped key lifecycle;
- portable encrypted backup/restore;
- atomic local replace/recovery;
- rollback detection;
- manual/inactivity/background locking;
- serialized lifecycle controls.

Factual portfolio domain включає acquisition lots, explicit disposal allocations, coupon/redemption cash events, derived holdings, closed positions, per-ISIN ledger та per-currency factual cash summary.

Unknown acquisition/disposal fee не перетворюється на zero. Поточна market value відкритих позицій не входить у factual cash result.

## Legacy migration

Legacy user-specific workspace data може бути скопійоване у private encrypted payload explicit non-destructive wizard-ом. Після запису перевіряється encrypted copy. Source JSON автоматично не видаляється.

Public Bond snapshots не перетворюються на private factual records і factual portfolio facts не синтезуються з відсутніх даних.

## Platform storage boundary

Desktop workspace може бути локальним або у user-selected/synchronized filesystem location.

Mobile external-folder support через Android SAF / iOS security-scoped bookmarks **ще deferred**; до окремого storage gate mobile використовує підтримуваний app-local storage contract.

## Локалізація

Канонічна мова — українська. User-facing UI: Українська, English, Français, Deutsch, Español, 한국어, 日本語. Persisted business/domain identifiers не повинні залежати від перекладеного display text.

## Recovery / development protocol

Поточний стан відновлюється лише через `START_HERE.md` → `PROJECT_RULES.md` → `PROJECT_STATE.md` → `WORKLOG.md` → GitHub Issue #18. Старі branches не є джерелами коду.
