# Продукт OVDP Hub

Оновлено: **25.09.2026**  
Актуальний checkpoint: **v0.9.3 / 0.9.3+20**

## Мета

OVDP Hub допомагає користувачеві працювати з публічними даними про українські ОВДП, відокремлювати різні джерела ринку, будувати локальні сценарії коштів і вести власний фактичний encrypted portfolio без центрального сервера приватних даних.

Застосунок не виконує купівлю або продаж і не є брокером.

## Поточний шлях користувача

1. Відкрити каталог ОВДП та за потреби оновити публічні дані НБУ.
2. Відфільтрувати випуски й відкрити картку ISIN.
3. Окремо переглянути шари НБУ / Мінфіну / продавців із provenance, датами та freshness/status.
4. Вибрати явне price observation або ввести власне припущення; yield-only/nominal не стають ціною автоматично.
5. Побудувати Planner scenario: budget, reserve, horizon, needs, fees, tax, FX, early exit, reserve floor.
6. За потреби порівняти 2–3 compatible scenarios у нейтральному A/B/C без automatic winner.
7. Зберегти scenario локально або створити CSV/ICS export.
8. У «Мій портфель» відкрити encrypted vault і внести фактичні purchase / sale / coupon / redemption записи.
9. Переглянути per-ISIN ledger, closed positions і factual per-currency cash summary.
10. Для legacy user-specific data використати explicit non-destructive migration wizard із encrypted-copy verification.

## Фінансові правила продукту

- НБУ, Мінфін і продавці — окремі шари даних.
- Yield-only та nominal estimate не перетворюються на виконувану market price.
- Unknown fee / tax / FX не означає zero.
- Продаж має explicit acquisition-lot allocation; OVDP Hub не вигадує FIFO/LIFO.
- Factual cash summary не включає current market value відкритих позицій і не є performance metric.
- A/B/C не ранжує сценарії та не вибирає «кращий» варіант.

## Дані та приватність

Public catalog/market data і user scenarios зберігаються local-first. Private portfolio працює через encrypted vault із platform device keys, recovery/portable backup, rollback/crash controls і session locking.

Legacy workspace JSON може залишатися plaintext. Migration wizard не видаляє source JSON автоматично.

Не зберігати у legacy plaintext workspace паролі, signing keys, KYC-документи чи інші секрети.

## Платформи

Поточні test targets: Windows, macOS, Android, iOS. Окремо публікується START/source package.

Production signing/notarization/store distribution ще не завершені; див. `docs/platforms.md`.

## Мови

Українська — основна й еталонна. User-facing UI та документація підтримують English, Français, Deutsch, Español, 한국어 та 日本語.

## Подальший розвиток

Після v0.9.3 канонічний NEXT визначається у `WORKLOG.md`. Станом на цей checkpoint: **post-v0.9.3 usability/product audit** з актуального `main`. Старі feature/release branches не відновлюються як джерела коду.
