# PROJECT_STATE — OVDP Hub

Оновлено: 23.09.2026

## Поточний checkpoint

- Активна версія: **0.8.7+15**
- Опублікований GitHub tag: **v0.8.7**
- Активний продукт: **Flutter/Dart, `apps/native`**
- Цільові платформи: Windows, macOS, Android, iOS
- Репозиторій: `RomanZavadaM/ovdp-hub`
- Основна гілка: `main`
- Статус продукту: **test / prerelease**
- Release commit: **6ab844fd3063fbfa9fcf54ab875539241c459845**
- Release workflow: **Publish native prerelease run #37 — success**
- GitHub Release: **v0.8.7**, опублікований 23.09.2026

## Що входить до опублікованого 0.8.5

База 0.8.4 зберігається повністю:
- локальний каталог ОВДП на базі публічних даних НБУ;
- пошук, фільтри, графіки виплат та порівняння випусків;
- локальні добірки й робочі папки;
- навчальний калькулятор;
- планування бюджету, строків, резерву й майбутніх витрат;
- scenario schema 3 + adapter schema 1/2 без тихого переписування;
- typed price observations: full price, clean price + НКД, yield-only, nominal estimate;
- fee/tax/FX/exit domain models;
- трирівнева картка ISIN: НБУ / Мінфін / продавець;
- MinFin latest-auction adapter + ISIN join;
- typed MinFin auction event index;
- typed MinFin calendar document index;
- локалізація активного UI та user-facing error flows для UK/EN/FR/DE/ES/KO/JA;
- START_HERE / WORKLOG / Issue #18 recovery protocol;
- proprietary copyright/licensing на Roman Zavada.

Додано в 0.8.5:
- structured future auction schedule parser з офіційних calendar PDF Мінфіну;
- окремі monthly / quarterly / switch parsers;
- provenance конкретного PDF, publication/source date і retrievedAt;
- fail-closed validation для невідомої/зміненої PDF-структури;
- detailed MinFin auction-result parser з офіційних DOCX;
- typed placement results: **21-row observed layout × N випусків**;
- typed switch-auction results: **26-field observed layout**;
- нормалізація Word-run fragmentation у датах, числах та ISIN без домислювання відсутніх полів;
- fail-closed DOCX/URL/layout/date validation;
- deterministic tests без live-network залежності;
- локалізовані parser errors UK/EN/FR/DE/ES/KO/JA;
- audited pure-Dart PDF stack та direct MIT `archive` dependency з оновленими legal notices.

## Реліз v0.8.5

Release pipeline **Publish native prerelease run #32** успішно завершив:
- `flutter pub get --enforce-lockfile`;
- `flutter analyze`;
- `flutter test`;
- Windows release build + packaging;
- macOS release build + packaging;
- Android release APK + packaging;
- iOS unsigned release build + packaging;
- START/source package;
- SHA-256 manifest;
- prerelease publication.

Опубліковані assets:
- `OVDP-Hub-0.8.5-Windows-x64.zip`;
- `OVDP-Hub-0.8.5-macOS.zip`;
- `OVDP-Hub-0.8.5-Android-test.zip`;
- `OVDP-Hub-0.8.5-iOS-unsigned.zip`;
- `OVDP-Hub-0.8.5-START.zip`;
- `SHA256SUMS.txt`;
- `LICENSE.md`;
- `COPYRIGHT.md`;
- `LEGAL_AND_COPYRIGHT.md`;
- `THIRD_PARTY_NOTICES.md`.

Tag/release не пересуваємо й не переписуємо.

## Що додано в опублікованому 0.8.6 поверх v0.8.5

- нормалізований freshness/status UX у картці ISIN;
- typed `officialPublished` status для офіційних NBU/MinFin observations;
- seller public quotes лишаються `publicIndicative`;
- однаковий provenance/status block для NBU / MinFin / seller: source, sourceDate, retrievedAt, freshness, data status, evidence URL;
- textual status — не лише колір;
- локалізація UK/EN/FR/DE/ES/KO/JA;
- unit/widget/full-card wiring tests.

Ці зміни опубліковані як **v0.8.6 / 0.8.6+14**. Попередній `v0.8.5` не переписувався.

## Реліз v0.8.6

Release pipeline **Publish native prerelease run #34** успішно завершив:
- `flutter pub get --enforce-lockfile`;
- `flutter analyze`;
- `flutter test`;
- Windows release build + packaging;
- macOS release build + packaging;
- Android release APK + packaging;
- iOS unsigned release build + packaging;
- START/source package;
- SHA-256 manifest;
- prerelease publication.

Опубліковані assets:
- `OVDP-Hub-0.8.6-Windows-x64.zip`;
- `OVDP-Hub-0.8.6-macOS.zip`;
- `OVDP-Hub-0.8.6-Android-test.zip`;
- `OVDP-Hub-0.8.6-iOS-unsigned.zip`;
- `OVDP-Hub-0.8.6-START.zip`;
- `SHA256SUMS.txt`;
- legal notices.

Tag/release не пересуваємо й не переписуємо.

## Інваріанти

- приватні сценарії не передаються на сервер OVDP Hub;
- продукт не виконує купівлю/продаж;
- НБУ, Мінфін і продавці — різні шари даних і не підміняють одне одного;
- yield-only і nominal estimate не можуть автоматично ставати вибраною ринковою ціною;
- невідома комісія або податок не означають 0;
- workspace і старі сценарії не переписуються мовчки під час читання;
- реальний портфель — лише після encrypted vault, platform secure storage і backup/recovery;
- copyright original project materials: Roman Zavada (Роман Завада).

## Що додано в опублікованому v0.8.7 поверх v0.8.6

PR **#39 — Planner: multiple price observations with explicit source priority** squash-merged у `main` як `255d15294105e8d5ae6dfe216f1e900fe0490192`.

Увійшло до v0.8.7:
- additive schema-3 `priceObservations` + `priceSourcePriority`;
- кілька explicit price observations на ISIN;
- явний user-controlled priority джерел;
- add/select/reorder source controls у planner UI;
- explicit nominal-estimate fallback;
- legacy selected `price` збережений для сумісності зі старими readers;
- yield-only і nominal estimate виключені з market-price candidates;
- duplicate eligible observations одного source fail closed;
- persistence/load/save для observations + source priority;
- 9 нових price-source UI keys у UK/EN/FR/DE/ES/KO/JA;
- regression tests для simultaneous quantity+price edit;
- widget regression для lifecycle price-source dialog.

Final PR verification: **Flutter checks and START run #123 — success**.

Цей slice виданий у **v0.8.7 / 0.8.7+15**; попередній v0.8.6 не переписувався.

PR **#41 — Planner: explicit purchase fee assumptions** squash-merged у `main` як `fbe8028ae1f68fcbb9c4c7a7057134c6793c00ae`.

Увійшло до v0.8.7:
- typed `FeeAssumptions` зберігаються в PlannerState та проходять load/save;
- `unknown` чітко відрізняється від підтвердженого нуля;
- підтримано явну aggregate purchase fee у валюті сценарію;
- відома комісія резервується з planning budget і враховується в initial cost, reserve та calculated profit;
- при невідомій комісії UI явно показує gross/pre-fee результат, а не net;
- детальні typed fee rules зберігаються й не переписуються спрощеним UI без явної дії користувача;
- UI та fee-related errors локалізовано UK/EN/FR/DE/ES/KO/JA;
- domain/cubit/persistence/widget regression coverage проходить повністю.

Final PR verification: **Flutter checks and START run #135 — success (80/80 tests)**.

## Інтегровано в `main` після опублікованого v0.8.7

PR **#45 — Planner: verified OVDP tax assumptions** squash-merged у `main` як `b47fd1360432a8336ca38666064eb46eebbd04f7`.

Інтегровано, але ще не видано окремим GitHub release:
- official-source-audited preset для фізособи-резидента України / ОВДП / 2026;
- чотири explicit 0% правила: PIT + military levy × interest + investment profit;
- `TaxScenario` проходить PlannerState/load/save;
- unknown tax не підміняється нулем;
- incomplete / out-of-scope / non-zero rules fail closed до появи explicit tax-base model;
- post-fee/post-tax result semantics: verified-zero показується явно, unknown tax лишає pre-tax caveat;
- tax UI/status/errors локалізовано UK/EN/FR/DE/ES/KO/JA;
- domain/cubit/persistence/widget tests зелені.

Final PR verification: **Flutter checks and START run #145 — success**.

Опублікований checkpoint лишається **v0.8.7 / 0.8.7+15**; tag/release не переписуємо.

PR **#48 — Planner: explicit FX comparison assumptions** squash-merged у `main` як `755c328e0d1b15d2d4843f434eaf774d80ff5494`.

Інтегровано, але ще не видано окремим GitHub release:
- typed `FxAssumption` проходить PlannerState/load/save;
- planner лишається single-currency: FX не дозволяє змішувати позиції чи потреби різних валют;
- explicit comparison semantics: **1 одиниця валюти сценарію = введений курс у валюті порівняння**;
- користувач задає target currency, rate, as-of date та source URL;
- 0 FX rules = конвертацію не просили;
- 1 matching rule = показуються converted invested/reserve/profit;
- multiple/non-standard rules зберігаються й defer-яться без здогадок або тихого переписування;
- base-currency cashflow лишається authoritative;
- FX UI/status/errors локалізовано UK/EN/FR/DE/ES/KO/JA.

Final PR verification: **Flutter checks and START run #152 — success (88/88 tests)**.

## Чому 0.8.7, а не 0.9.0

Після v0.8.7 у `main` уже інтегровано verified tax assumptions та explicit FX comparison assumptions, але **ще не завершені**:
- exit assumptions → redesign/wiring для multi-position scenarios;
- A/B/C comparison;
- generated planner copy / preset labels localization.

Тому 0.9.0 «Ринок» лишається активною ціллю.

## Наступний етап — 0.9.0 «Ринок»

1. exit assumptions → multi-position redesign/wiring;
2. A/B/C comparison;
3. generated planner copy / preset labels localization.

Перед використанням податкових правил обов'язкова перевірка офіційних джерел і періоду дії кожного правила.


## Реліз v0.8.7

Повний checkpoint 0.8.7 опубліковано з двома user-visible slice після v0.8.6:
- explicit price-source priority;
- explicit purchase-fee assumptions.

Release notes опубліковано сімома мовами інтерфейсу: UK / EN / FR / DE / ES / KO / JA.

Release pipeline **Publish native prerelease run #37** успішно завершив verify, Windows, macOS, Android, iOS, START і publish.

Опубліковані assets:
- `OVDP-Hub-0.8.7-Windows-x64.zip`;
- `OVDP-Hub-0.8.7-macOS.zip`;
- `OVDP-Hub-0.8.7-Android-test.zip`;
- `OVDP-Hub-0.8.7-iOS-unsigned.zip`;
- `OVDP-Hub-0.8.7-START.zip`;
- `SHA256SUMS.txt`;
- legal notices.
