# AUDIT_POST_0_9_3 — usability / product audit

Дата: **25.09.2026**  
Base `main`: **`63227a8951f02acf426f1064e0f115c73a22fa80`**  
Checkpoint: **v0.9.3 / 0.9.3+20**

## Мета

Перевірити OVDP Hub не як набір уже реалізованих функцій, а як один продукт очима користувача:

**відкрити → знайти потрібний розділ → ввести дані → зрозуміти наслідки → зберегти/відновити → повернутися до роботи без неочікуваної втрати стану.**

Аудит спирається на актуальний `main`, visible-control widget regressions, platform/release contracts і фактичне wiring UI → Cubit/Gateway/Store. Старі branches не використовуються.

## Підсумок

Критичного дефекту розрахункової математики, який вимагав би rollback v0.9.3, під час цього проходу не виявлено.

Натомість є **три високопріоритетні продуктові прогалини**:

1. recovery/backup можливості vault існують нижче UI, але користувач не може ними керувати;
2. Planner може очищати сформовану composition під час ручного редагування ключових критеріїв;
3. macOS release існує, але encrypted portfolio на macOS свідомо вимкнений до runtime Keychain validation.

Також підтверджено кілька medium UX/localization/test gaps.

---

## HIGH-1 — encrypted portfolio backup/recovery не завершений як user flow

### Факт

Vault core уже має:
- recovery enable / rotate / remove;
- encrypted portable backup creation;
- encrypted backup restore;
- verification через recovery material;
- atomic recovery/rollback lifecycle.

Але `PortfolioGateway` не експонує ці операції, а `PortfolioView` не має user-facing:
- **створити encrypted backup**;
- **відновити encrypted backup**;
- **змінити recovery secret**;
- явного стану recovery/backup readiness.

### Додатковий ризик

Під час створення портфеля recovery secret вводиться **один раз**. UI попереджає, що OVDP Hub не зможе показати його пізніше, але немає повторного введення для confirmation.

Помилка набору може залишитися непоміченою до моменту реального recovery.

### Невідповідність документації

User guide уже радить:
- створити/перевірити encrypted portable backup;
- зберігати recovery material окремо.

Тобто документація описує user action, якої current UI не надає.

### Рішення

**Перший recommended fix slice: `portfolio-recovery-backup-ux`.**

Scope:
1. confirmation recovery secret при створенні;
2. user-facing backup state/action;
3. portable encrypted backup export на платформах із підтриманим file flow;
4. restore flow з recovery secret та explicit destructive/replace confirmation;
5. rotate recovery secret;
6. локалізація UK/EN/FR/DE/ES/KO/JA;
7. real-control widget tests;
8. fail-closed: mobile external-folder permission architecture не домислювати.

Android SAF / iOS security-scoped folders залишаються окремим deferred gate. Перший slice не повинен приховано розширювати mobile storage contract.

---

## HIGH-2 — Planner очищає composition під час редагування дат

### Факт

`PlannerCubit.edit()` вважає зміни:
- `currency`;
- `start`;
- `minDate`;
- `maxDate`

такими, що скидають:
- `inputs`;
- `positionExits`.

У `PlannerView` поля дат викликають `cubit.edit(...)` через `onChanged`.

### Наслідок

Користувач із уже сформованим планом починає вручну редагувати дату. Перший символ нового значення може одразу очистити composition / early exits — без explicit confirmation і до завершення валідного вводу.

Це не втрата durable saved scenario, але це несподівана втрата поточного робочого результату.

### Рішення

Окремий наступний slice після data-safety:
- date controls із commit-on-valid-selection замість destructive per-keystroke edit;
- explicit confirmation, якщо зміна критерію справді інвалідовує generated composition;
- regression: composition не зникає від проміжного невалідного тексту;
- state reset відбувається лише після підтвердженої валідної зміни.

---

## HIGH-3 — macOS release має вимкнений encrypted Portfolio

### Факт

`LocalEncryptedPortfolioGateway.supported` зараз дозволяє:
- Windows;
- Android;
- iOS.

**macOS не включено.**

Водночас lower secure-storage adapter уже має `MacOsOptions` з Data Protection Keychain і тестами конфігурації.

Release pipeline збирає й smoke-тестує macOS package, але desktop release smoke перевіряє release contract/version/appearance, а не реальний vault unlock через Keychain.

### Висновок

Це **runtime/release-validation gap**, а не причина просто додати `Platform.isMacOS`.

### Рішення

Окремий platform slice:
1. реальний macOS Keychain create/open/lock/reopen smoke;
2. backup/recovery lifecycle smoke;
3. packaged app runtime validation;
4. лише після green — включити macOS у `PortfolioGateway.supported`;
5. виправити docs/platform capability matrix.

---

## MEDIUM-1 — неповна локалізація Catalog

`CatalogView` містить hardcoded Ukrainian user-facing copy:
- offline catalog message;
- nominal-rate disclaimer;
- ISIN search label;
- horizon labels;
- empty-result message.

При цьому відповідні localized keys **вже існують** у `HubStrings`:
`catalogOffline`, `nominalNotYield`, `searchIsin`, `allTerms`, `upTo12`, `from24`, `noIssues`.

Це wiring defect, не відсутній переклад.

### Рішення
Замінити literals на existing keys і додати regression, що після перемикання мови Catalog не містить українського fallback copy.

---

## MEDIUM-2 — hardcoded Ukrainian потрапляє у saved collection variant

`CollectionEditorCubit.variant()` формує:

```dart
name: '${saved.name} — варіант'
```

Цей текст може бути збережений у workspace незалежно від active UI language.

### Рішення
Не зберігати перекладений suffix як business data. Використати stable generated-copy semantics або вимагати explicit user-authored name.

---

## MEDIUM-3 — date UX непослідовний

Planner використовує manual **YYYY-MM-DD**.

Portfolio purchase/sale/coupon/redemption використовує manual **DD.MM.YYYY** через власний parser.

У product UI немає calendar/date picker.

### Наслідок
Користувач мусить пам’ятати два формати дат у межах одного застосунку; mobile keyboard UX слабкий; помилки виявляються лише після submit/recalculation.

### Рішення
Єдиний reusable date control:
- locale-friendly display;
- canonical ISO persistence;
- picker + keyboard fallback;
- explicit validation;
- не міняти persisted schema.

---

## MEDIUM-4 — language та appearance не persist

`LocaleCubit` стартує з Ukrainian.
`AppearanceCubit` стартує зі Studio/«Робочого кабінету».

Обидва selection живуть лише в memory і скидаються після restart.

### Рішення
Зберігати лише non-sensitive UI preferences у app support/preferences storage:
- language;
- appearance.

Не змішувати їх із workspace або private vault.

---

## MEDIUM-5 — Portfolio mobile confidence нижчий за Planner

Є повний real-control Portfolio regression для desktop:
- open;
- sale;
- coupon;
- redemption;
- details;
- closed position;
- migration.

Немає еквівалентного end-to-end phone-flow regression.

Planner має багато phone-sized visible-control tests, хоча вони покладаються на довге `ensureVisible` scrolling.

### Рішення
Додати phone regression для:
- navigation → Portfolio;
- create/open;
- purchase;
- details;
- lock;
- overflow/exception check;
- modal actions reachable without clipped buttons.

---

## MEDIUM-6 — partial redemption створює неочевидний sale dead-end

Domain навмисно fail-closed: після recorded redemption sale для того самого ISIN заборонений, доки немає exact redemption allocation по lots.

Це захищає фактичність, але partial redemption може залишити positive holding, який користувач бачить, а sale action для нього вже недоступний.

UI prefilter/disabled path погано пояснює причину; existing localized error часто не показується, бо користувача не допускають до submit.

### Рішення
Короткостроково:
- пояснювати disabled sale / affected ISIN;
- не створювати враження, що holding «зламаний».

Повне вирішення — окремий domain/schema slice для explicit redemption lot allocation. Не змішувати його з UX cleanup.

---

## MEDIUM-7 — довгі monolithic Planner / Portfolio flows

Орієнтири:
- `planner_view.dart` ≈ 1200 рядків UI;
- `portfolio_view.dart` ≈ 1700 рядків UI.

Planner mobile tests регулярно використовують `ensureVisible`, щоб дійти до далеких controls. Це підтверджує, що основний flow фізично довгий.

### Рішення
Не робити cosmetic rewrite одним великим PR.

Після data-safety/date fixes розбити presentation на логічні sections/components з progressive disclosure:
- Inputs;
- Needs;
- Assumptions;
- Composition;
- Result;
- Save/export.

State/domain залишити тим самим.

---

## LOW / спостереження

### 7 destinations у phone NavigationBar
Phone shell показує 7 destinations в одному bottom NavigationBar із label only for selected item. Це працює в current regression, але інформаційна архітектура перевантажена.

Не міняти навігацію лише за припущенням. Спочатку додати phone portfolio/navigation regression і вже за фактом overflow/discoverability вирішувати, чи потрібен grouped navigation / More.

### Economic Pulse
Persistent pulse добре працює як trust/status layer. На phone він горизонтально scrollable. Це не blocker; перевіряти разом із screen-height usability, а не видаляти.

---

## Що НЕ виявлено під час цього проходу

- немає підстав rollback v0.9.3;
- не знайдено доказу, що factual cash summary змішує current market value;
- unknown fees лишаються explicit;
- A/B/C не має automatic winner;
- three-appearance switch має desktop + phone regression;
- catalog/portfolio/planner core flows мають substantial automated coverage;
- release artifacts v0.9.3 пройшли заявлені packaged desktop smoke gates.

---

## Рекомендований порядок

1. **Portfolio data safety — backup/restore/recovery confirmation/rotation.**
2. **Planner non-destructive date editing + unified date-control foundation.**
3. **Localization/persisted-copy cleanup + language/appearance persistence.**
4. **macOS Portfolio runtime validation and enablement.**
5. **Portfolio phone regression + responsive UX cleanup.**
6. **Redemption allocation domain extension**, якщо потрібні sale-after-partial-redemption workflows.
7. Після кількох slices — наступний cross-platform release checkpoint за cadence.

## Acceptance для завершення аудиту

- findings зафіксовані в Git;
- severity відділяє data-safety/platform blockers від cosmetic UX;
- кожний HIGH finding має конкретний evidence path;
- визначено **рівно один** перший implementation slice;
- mobile storage deferred boundary не розмито;
- старі branches не використовуються як evidence/source.
