# Roadmap OVDP Hub

Оновлено: 24.09.2026. Цей roadmap стосується лише активного Flutter-продукту.

## Продуктовий напрямок до 0.9.0

Ціль — довести OVDP Hub від набору корисних модулів до цілісного сценарію **«перевірені ринкові факти → зрозуміла актуальність → явний вибір ціни/припущень → план → порівняння»**.

Порядок розвитку:

1. **Довіра до ринкових даних — DONE**: detailed MinFin auction results parser інтегрований з provenance, fail-closed поведінкою та deterministic tests.
2. **Зрозуміла актуальність — DONE**: freshness/status UX у картці ISIN уніфіковано для NBU / MinFin / seller observations.
3. **Явний вибір ринкової ціни — DONE**: кілька `PriceObservation`, explicit user priority, add/select/reorder controls і nominal fallback інтегровані без прихованої підміни yield/nominal ціною.
4. **Повна економіка сценарію — DONE**: purchase-fee, verified-tax, explicit-FX та per-position exit vertical інтегровані. Невідомі значення не вважати нулем.
5. **Порівняння рішень — DONE**: neutral A/B/C comparison для 2–3 saved scenarios із strict baseline comparability, recurring-needs support, explanatory metrics і no-winner semantics — PR #58, final run #183.
6. **Готовність 0.9.0 — NEXT**: generated-copy localization і regression review завершені; провести formal prerelease readiness assessment, потім вирішити щодо cross-platform prerelease.

Принцип пріоритезації: спочатку завершувати вертикальний користувацький шлях, а не додавати нові ізольовані джерела чи екрани.

## Опублікований checkpoint v0.8.8

**v0.8.8 / 0.8.8+16** опубліковано 23.09.2026 з verified-tax, explicit-FX, per-position exit та typed recurring-needs verticals. Повний release pipeline run #40 успішний для Windows/macOS/Android/iOS/START. Після v0.8.8 у `main` інтегровано A/B/C comparison через PR #58 і generated Planner copy / preset-label localization через PR #61. Наступний продуктовий крок — formal 0.9.0 prerelease readiness assessment.

## Ритм інтеграції та тестових checkpoint

- Кожен завершений і перевірений vertical slice **інтегруємо PR у `main`** перед початком наступного.
- Проміжно після user-visible integration тестуємо актуальний `main` через START artifact.
- Команда власника **«злити у `main`»** означає повний багатоплатформний test-release checkpoint: нова version/build, Windows/macOS/Android/iOS, START/source, checksums/legal, Git tag і GitHub prerelease.
- Такий повний checkpoint плануємо регулярно — орієнтовно після кожних 2–3 user-visible integrated slices або раніше після ризикових змін parser/calculation/schema.
- Опубліковані теги не переписуються; кожне повне «злиття у `main`» отримує нову версію/build.

## 0.8.2 — стабілізація

- [x] Формальний proprietary release 0.8.1.
- [x] Захист `main`: PR + `verify` + squash + up-to-date.
- [x] Прибрати завершені Web/Expo/Tauri/TypeScript прототипи з активного дерева.
- [x] Переписати архітектуру й product docs під Flutter.
- [x] Dart tool для оновлення початкового snapshot НБУ.
- [x] Retention старих публічних каталогів у workspace.
- [x] Єдина модель provenance/freshness для джерел.
- [x] Threat model для encrypted vault і backup/recovery.
- [x] Основа локалізації: UK за замовчуванням; EN/FR/DE/ES/KO/JA selectable.

## 0.9.0 — Ринок

- [x] Єдина картка ISIN з окремими NBU / MinFin / seller шарами.
- [x] НБУ: інструмент і графік контрактних виплат.
- [x] Мінфін: календар, оголошення та структуровані результати аукціонів.
  - [x] Typed index оголошень/результатів з розрізненням placement/switch та fail-closed parser.
  - [x] Typed index календарних документів Мінфіну: monthly / quarterly / switch PDF + publication date + provenance.
  - [x] Структурований розклад майбутніх аукціонів із календарних PDF: окремі monthly / quarterly / switch parser-и, provenance, deterministic tests і fail-closed validation.
  - [x] Детальний parser результатів аукціонів з офіційних DOCX: placement 21-row × N, switch 26-field, provenance + fail-closed + deterministic tests.
- [x] Продавці: типізовані вторинні observations без вигаданої ціни.
- [x] Базові sourceDate / retrievedAt / freshness / evidence URL; validUntil лишається source-specific.
- [x] Передача лише явної/введеної ціни у планувальник; yield-only/nominal не стають market price автоматично.

## Планувальник наступного покоління

- [x] Типізований PlannerScenario / schema 3 з adapter schema 1/2.
- [x] Домен комісій: разові/періодичні/невідомі з явним статусом.
- [x] Домен effective-dated податкових сценаріїв.
- [x] Кілька джерел цін і пріоритет користувача — PR #39, final run #123.
- [x] Purchase fee assumptions: unknown / confirmed zero / aggregate fee → persistence / calculation / UI — PR #41, final run #135.
- [x] Tax assumptions → official effective-date verification → calculation/UI — PR #45, final run #145.
- [x] FX assumptions → explicit comparison calculation/UI — PR #48, final run #152.
- [x] Exit assumptions → per-position multi-ISIN cashflow/profit/UI — PR #51, final run #161.
- [x] Порівняння альтернативних сценаріїв A/B/C — PR #58, final run #183; 2–3 scenarios, strict comparability, no automatic winner, recurring needs supported.
- [x] Домен продажу до погашення як окремого припущення з BID/ручною ціною.
- [x] Домен FX з явним курсом, датою та джерелом.
- [x] Типи потреб: разова + регулярна з typed persistence/cashflow/UI — PR #54, final run #168.
- [ ] Потреби типу reserve floor / мінімальний залишок.
- [ ] CSV/ICS; PDF лише після стабілізації структури звіту.

## Encrypted vault / фактичний портфель

- [ ] Threat model затверджений до коду шифрування.
- [ ] Аудитована криптографічна бібліотека; не власна криптографія.
- [ ] Platform secure storage: Windows/macOS/Android/iOS.
- [ ] Lock/unlock, auto-lock, deletion, recovery.
- [ ] Зашифрований backup з користувацьким recovery material.
- [ ] Holdings, acquisition lots, фактичні купони/погашення після vault.
- [ ] Android SAF / iOS security-scoped access для зовнішніх папок.

## Distribution readiness

- [ ] Windows code signing.
- [ ] macOS Developer ID + notarization.
- [ ] Android production keystore.
- [ ] iOS signing/distribution.
- [ ] Інсталятори й автооновлення — окреме рішення.

## Незмінні межі

Без окремого рішення власника не додаються централізовані портфелі, KYC, приватний relay, вбудовані partner secrets або виконання угод.


## Локалізація 0.9

- [x] Shell / navigation / shared dialogs — UK/EN/FR/DE/ES/KO/JA.
- [x] Каталог — UK/EN/FR/DE/ES/KO/JA.
- [x] Калькулятор — UK/EN/FR/DE/ES/KO/JA.
- [x] Продавці — UK/EN/FR/DE/ES/KO/JA.
- [x] Сховище — UK/EN/FR/DE/ES/KO/JA.
- [x] Добірки + редактор — UK/EN/FR/DE/ES/KO/JA.
- [x] Планувальник — статичний UI UK/EN/FR/DE/ES/KO/JA.
- [x] Domain/error повідомлення з Cubit/Repository/parser/domain validation переведені на typed коди й локалізоване відображення UK/EN/FR/DE/ES/KO/JA.
- [x] Generated planner copy / preset labels: stable persisted generated-copy IDs + display-time `HubStrings` для UK/EN/FR/DE/ES/KO/JA; user-authored text literal — PR #61, run #189 (110/110), final run #190.
