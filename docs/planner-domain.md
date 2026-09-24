# Типізована модель планувальника 0.9

Статус: перший сумісний етап міграції.

## Чому змінюємо модель

Planner 0.7/0.8 виріс із швидкої карти `Map<String,String>`. Вона лишається UI-adapter на перехідний період, але новий persisted domain має schema 3 і окремі типи для фінансових припущень.

## Schema 3

`PlannerScenario` містить:

- бюджет, резерв, валюту й горизонт;
- typed needs;
- позиції з typed price observation;
- fee assumptions;
- tax scenario;
- FX assumptions;
- exit assumption;
- `groupId` + `variantLabel` для альтернатив A/B/C;
- provenance кожної зовнішньої ціни.

### Потреби

Типи:

- `oneOff` — разова потреба;
- `recurring` — регулярна потреба з кроком у місяцях і кількістю повторень;
- `reserveFloor` — мінімальний залишок/резерв.

Поточний UI редагує:
- основну `oneOff` потребу;
- основну `recurring` потребу з `everyMonths` + `occurrences`;
- додаткові `oneOff` потреби.

Recurring primary need зберігається як typed `PlannerNeed` у schema 3 і детерміновано розгортається в cashflow/coverage з month-end clamping.

### Семантика reserve floor

`reserveFloor` — **не витрата** і не зовнішнє поповнення. Це мінімальний ліквідний залишок, який має бути доступним починаючи з указанної дати.

- у дату активації перевіряється, що ліквідний cash не нижчий за floor;
- floor не віднімається з cash і не збільшує cumulative spent;
- для кожної наступної one-off/recurring потреби shortfall рахується від залишку **після** витрати відносно активного floor;
- генератор варіанта використовує жорсткішу межу між базовим scenario `reserve` та активним `reserveFloor`;
- current UI підтримує один reserve-floor rule; typed schema 3 не змінюється;
- A/B/C сценарії порівнюються лише за однакових reserve-floor type/date/amount, так само як для інших економічних needs.

Це не можна тихо спрощувати до one-off expense, бо тоді floor був би помилково «витрачений».

### Ціни

`PriceObservation` розрізняє:

- full price;
- clean price + НКД;
- yield-only;
- nominal estimate.

Yield-only **не має effectiveUnitCost** і не може бути позицією планувальника без окремого явного ціноутворення. Ручна ціна має confidence `userAssumption`, а не маскується під ринкове котирування.

### Комісії

`FeeAssumptions.unknown()` і `FeeAssumptions.confirmed([])` — різні стани:

- unknown = ми не знаємо комісії;
- known + empty = підтверджено нульові комісії.

Підтримувані типи моделі: flat, per-unit, percent-of-trade, recurring. Формули застосування підключаються окремим етапом після UI і тестів.

### Податки

Податкова модель effective-dated: tax kind, income kind, ставка, scopeFrom/scopeTo, verifiedOn, sourceUrl.

У коді є інформаційний preset `TaxScenario.ukraineResidentOvdp2026()` для фізособи-резидента України, перевірений 23.09.2026 за офіційними джерелами ДПС. Він **не підставляється автоматично** в існуючий план: legacy і новий UI без явного вибору мають status unknown.

### FX

FX assumption містить валютну пару, Decimal rate, дату та optional provenance. Валюти не змішуються автоматично.

### Достроковий продаж

Exit mode — hold-to-maturity або early-sale. Early-sale вимагає дату та BID/ручну ціну. ASK або yield-only не приймаються як ціна продажу.

## Сумісність

- scenario schema 1/2 читаються через adapter у typed in-memory модель;
- вихідний старий JSON при читанні не переписується;
- нові save у гілці 0.9 пишуть schema 3;
- outer SavedSet schema поки лишається 2;
- Git tag v0.8.2 лишається незмінним і читає лише старі сценарії за своїми правилами.

До формального релізу 0.9.0 schema 3 вважається prerelease-format.
