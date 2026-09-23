# Changelog

Усі помітні зміни OVDP Hub фіксуються тут. Опубліковані GitHub Releases додатково мають незмінні release notes у `docs/releases/`.

## [Unreleased] — 0.9.0 «Ринок» development

- Наступний slice: tax assumptions → official effective-date audit → calculation + UI.
- Далі: FX assumptions, exit redesign/wiring, A/B/C comparison та generated planner copy localization.

## [0.8.7] — 2026-09-23

### Explicit price-source priority
- Додано кілька `PriceObservation` на ISIN і явний порядок пріоритету джерел, керований користувачем.
- Доступні add/select/reorder controls та явне повернення до nominal estimate.
- Yield-only і nominal estimate не можуть неявно стати market price.
- Duplicate eligible observations одного source fail closed.
- Збережено сумісність зі старим selected `price`.

### Explicit purchase-fee assumptions
- Typed `FeeAssumptions` тепер проходять через PlannerState/load/save.
- `unknown` відрізняється від підтвердженого нуля.
- Явна aggregate purchase fee зменшує доступний planning budget, reserve та calculated profit.
- Якщо комісія невідома, результат явно показується як gross/pre-fee, а не net.
- Детальні typed fee rules не переписуються спрощеним UI без явної дії користувача.
- UI та fee-related errors локалізовано UK/EN/FR/DE/ES/KO/JA.

### Release checkpoint
- Версія застосунку: `0.8.7+15`.
- Повний prerelease checkpoint для Windows, macOS, Android, iOS і START/source.
- Release description на GitHub підготовлений усіма сімома мовами інтерфейсу.

## [0.8.6] — 2026-09-23

### ISIN freshness/status UX
- Додано typed `officialPublished` status для офіційних NBU/MinFin observations.
- Seller public quotes лишаються `publicIndicative`; офіційні дані не змішуються з індикативними котируваннями.
- Для шарів NBU / MinFin / seller уніфіковано source, sourceDate, retrievedAt, freshness, textual data status та evidence URL.
- Fresh/stale/future/unknown status показується текстом, а не лише кольором.
- NBU catalog provenance передається безпосередньо в ISIN card.
- UI/status labels локалізовані UK/EN/FR/DE/ES/KO/JA.
- Додано unit/widget/full-card wiring tests.

### Release checkpoint
- Версія застосунку: `0.8.6+14`.
- Повний prerelease checkpoint для Windows, macOS, Android, iOS і START/source.
- Multiple price sources та explicit user priority навмисно лишаються наступним окремим slice.

## [0.8.5] — 2026-09-22

### MinFin structured future auction schedule
- Додано typed structured future auction schedule з офіційних календарних PDF Мінфіну.
- Monthly / quarterly / switch документи розбираються окремими parser-ами відповідно до фактичних layout.
- Збережено provenance конкретного PDF, publication/source date та retrievedAt.
- Parser fail closed при невідомій або зміненій структурі й покритий deterministic tests без live-network залежності.
- Додано pure-Dart PDF stack `pdf_document` + `pdf_graphics`, localized parser errors UK/EN/FR/DE/ES/KO/JA та legal notices.
- Додано окремі monthly / quarterly / switch parser-и з provenance та fail-closed validation.

### MinFin detailed auction results
- Підтверджено фактичний формат 2026: результати Мінфіну публікуються як офіційні DOCX.
- Додано typed parser для звичайного розміщення: observed layout 21 rows × N instruments.
- Додано typed parser для аукціону з обміну: observed layout 26 fields × 1 result.
- Нормалізується лише Word-run fragmentation у датах, числах та ISIN; відсутні поля не домислюються.
- Збережено official result URL, sourceDate, retrievedAt і primary-auction classification.
- Parser fail closed на invalid DOCX, неофіційний URL, зміну layout, дублікати/відсутні поля та невідповідність дат.
- Додано deterministic tests без live-network залежності та локалізовані result-DOCX errors UK/EN/FR/DE/ES/KO/JA.
- Додано direct MIT dependency `archive` для ZIP/DOCX контейнера та оновлено legal notices.

### Release checkpoint
- Версія застосунку: `0.8.5+13`.
- Повний prerelease checkpoint для Windows, macOS, Android, iOS і START/source.
- `freshness/status UX` навмисно не включено: це наступний окремий slice.

## [0.8.4] — 2026-09-22

### Market checkpoint and localization
- Завершено функціональну локалізацію активного UI для UK/EN/FR/DE/ES/KO/JA, включно з Планувальником.
- Domain/repository/parser error flows переведені на typed stable codes + localized rendering.
- Додано трирівневу картку ISIN з окремими NBU / MinFin / seller шарами та provenance.
- Додано MinFin latest-auction adapter та typed auction event index для placement/switch.
- Додано typed index календарних PDF-документів Мінфіну: monthly / quarterly / switch + publication date + evidence URL.
- Усі MinFin parser-и fail closed при невідомій структурі/посиланні.
- Додано START_HERE / WORKLOG / GitHub Issue #18 recovery protocol для надійного продовження розробки між чатами.
- Structured future auction schedule із вмісту PDF та detailed results parser залишаються наступними окремими slice.

## [0.8.3] — 2026-09-22

### Completed intermediate checkpoint
- Зафіксовано типізований домен планувальника як сумісну основу наступного етапу без незавершеної картки ISIN.
- Додано schema 3 для нових сценаріїв із адаптером читання старих schema 1/2 без тихого переписування файлів.
- Додано типізовані price observations з provenance та чітким розділенням повної ціни, clean price + НКД, yield-only і nominal estimate.
- Додано моделі комісій, effective-dated податків, FX, дострокового продажу та різних типів потреб.
- Невідома комісія/податок не підміняються нулем; yield-only не може автоматично стати ціною планувальника.
- Розширено contract tests для нового домену та сумісності зі старими сценаріями.
- 0.9 market-card / Мінфін integration лишаються наступним окремим етапом.

## [0.8.2] — 2026-09-22

### Stabilization
- Активний репозиторій консолідовано навколо Flutter native product.
- Додано Dart refresh НБУ, retention публічних каталогів, provenance/freshness та threat model encrypted vault.
- Закладено локалізацію з українською мовою за замовчуванням і вибором EN/FR/DE/ES/KO/JA.

## [0.8.1] — 2026-09-22

### Legal and packaging
- Roman Zavada (Роман Завада) зафіксований як правовласник оригінальних матеріалів OVDP Hub.
- Додано proprietary `LICENSE.md`, `COPYRIGHT.md`, `THIRD_PARTY_NOTICES.md`.
- Додано copyright у «Про програму» та platform metadata.
- Legal notices включаються до START та платформних тестових пакетів.
- Формалізовано release workflow, checksums і release documentation.

## [0.8.0] — 2026-09-22

### UI and testing
- Додано альтернативний дизайн «Робочий кабінет» із перемиканням без втрати введених даних.
- Додано START-only test pipeline для швидких перевірок.
- Активний Flutter-клієнт закріплено як основний продукт.

## [0.7.0] — 2026-09-21

### Planning
- Додано режими розподілу строків, більшого прибутку та покриття витрат.
- Додано багаторазові майбутні витрати, резерв і затримку зарахування.
- Підключено публічні котирування ПриватБанку.
- Виправлено збереження вручну введених цін кандидатів.

## [0.6.0] — 2026-09-21

### Budget and cashflow
- Додано планування бюджету й cashflow.
- Додано версійні тестові пакети та локальні сценарії.

## Earlier checkpoints

Початкові checkpoint охоплюють локальний-first каталог ОВДП, NBU public-data adapter, календар Мінфіну, локальні експорти, кросплатформні клієнти та міграцію активного продукту на Flutter.
