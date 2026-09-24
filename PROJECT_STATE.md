# PROJECT_STATE — OVDP Hub

Оновлено: 24.09.2026

## Поточний checkpoint

- Активна версія: **0.9.2+19**
- Опублікований GitHub tag: **v0.9.2**
- Активний продукт: **Flutter/Dart, `apps/native`**
- Цільові платформи: Windows, macOS, Android, iOS
- Репозиторій: `RomanZavadaM/ovdp-hub`
- Основна гілка: `main`
- Статус продукту: **test / prerelease**
- Release commit: **`696fd4a07e5e23c4a44d9aeb8bd745671acfb52a`**
- Post-merge Flutter checks: **run #381 — success**
- Publish native prerelease: **run #102 — success**
- GitHub Release: **v0.9.2**, published 24.09.2026

### Що входить у 0.9.2

- постійний **«Економічний пульс»** у shell: NBU USD/UAH, EUR/UAH, остання UAH OVDP auction yield та найближчий MinFin auction із source/date;
- **«Мій портфель»** як окремий user-facing розділ у Classic / «Робочому кабінеті» / «Світлій панелі»;
- перший encrypted factual portfolio flow: create/open/lock, factual acquisition, derived holdings;
- portfolio використовує existing encrypted vault/private payload schema; паралельного plaintext portfolio store немає;
- inactivity/background lock синхронізований із user-facing portfolio state;
- version/build у UI походить з build metadata;
- appearance regression реально перемикає всі 3 дизайни;
- Windows/macOS release gate перевіряє **exact packaged ZIP**: extract → launch packaged executable → verify product/version/build + `classic/studio/dashboard`;
- правила exact-artifact release verification зафіксовані в `PROJECT_RULES.md`;
- UI локалізовано UK/EN/FR/DE/ES/KO/JA.

### Межі 0.9.2

- legacy `sets/*.json` не шифруються автоматично;
- explicit migration/cleanup wizard — наступний user-facing gate;
- macOS portfolio unlock лишається обмеженим до Data Protection Keychain runtime/provisioning validation;
- Android SAF / iOS security-scoped external-folder access відкладено до mobile storage slice;
- production signing лишається deferred.

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

PR **#51 — Planner: per-position exit assumptions** squash-merged у `main` як `296fb9e0b53093685ced9e801196616a401582f4`.

Інтегровано, але ще не видано окремим GitHub release:
- additive `positionExits` keyed by ISIN поверх schema 3;
- legacy global `exit` збережений лише для compatibility та приймається тільки коли однозначно відповідає одній позиції;
- multi-position legacy early-sale fail closed;
- sale date має бути після start, до maturity і не може збігатися з датою контрактної виплати;
- cashflow включає контрактні виплати до продажу + sale proceeds, а пізніші coupon/redemption відсікаються;
- settlement delay застосовується до sale proceeds у expense coverage;
- exit-aware profit проходить далі через purchase fees → tax → FX;
- optimizer не переоптимізує портфель під exit у цьому slice;
- BID exit вимагає source URL; manual assumption може бути локальним;
- per-position UI/status/errors локалізовано UK/EN/FR/DE/ES/KO/JA.

Final PR verification: **Flutter checks and START run #161 — success**.

PR **#54 — Planner: implement recurring needs block** squash-merged у `main` як `e2a48d7017fe578295e631054d84fce52cbc2b55`.

Інтегровано, але ще не видано окремим GitHub release:
- основна потреба винесена в окремий блок із назвою, датою та сумою;
- основну потребу можна зробити recurring із кроком у місяцях і загальною кількістю платежів;
- recurring need зберігається як typed `PlannerNeedType.recurring` у schema 3 без schema bump;
- cashflow/coverage розгортає recurring need детерміновано з month-end clamping;
- сценарій із recurring primary need коректно завантажується назад у UI;
- додаткові потреби лишаються явними one-off записами add/remove;
- hard-coded кнопка, що дублювала ще 5 місяців, видалена;
- legacy one-off scenarios лишаються сумісними;
- UI/errors локалізовано UK/EN/FR/DE/ES/KO/JA.

Final PR verification: **Flutter checks and START run #168 — success**.

PR **#58 — Planner: strict A/B/C scenario comparison v2** squash-merged у `main` як `25123ceb049534c67b9d284ee0f79e5cc8694e28`.

Інтегровано після опублікованого v0.8.8:
- порівняння рівно 2–3 збережених PlannerScenario у «Добірки»;
- A/B/C — нейтральні мітки за порядком вибору користувача, без автоматичного winner/best/worst;
- hard comparability: однакові currency, budget, reserve, start/horizon, settlement delay та економічні потреби;
- strategy, position composition, selected prices, purchase fees, tax state, FX та per-position exits можуть відрізнятися й пояснюються в таблиці;
- показуються position cost, fee/tax state, reserve, profit basis/value, coverage shortfall, exit count та FX comparison;
- typed recurring needs підтримуються, якщо їхній графік однаковий між сценаріями;
- reserve-floor need лишається explicit fail-closed до окремої реалізації;
- selection state відновлюється коректно після помилки/зняття вибору;
- UI/errors локалізовано UK/EN/FR/DE/ES/KO/JA;
- domain/Cubit/widget/localization regression coverage пройдено.

Старий diverged draft PR #53 закрито без merge й не використано як кодове джерело.

Final latest-head verification: **Flutter checks and START run #183 — success (108/108 tests)**.

PR **#61 — Planner: localize generated copy and preset labels** squash-merged у `main` як `1e6849f78134d9654b0bf08b54ceebda4100ba4d`.

Інтегровано після опублікованого v0.8.8:
- generated default plan / primary need / additional expense names зберігаються як stable generated-copy identifiers, а не як текст конкретної мови;
- generated scenario note зберігається language-neutral marker і локалізується під час відображення;
- aggregate purchase-fee та tax preset labels відокремлені від UI-мови в persisted scenario data;
- user-authored plan/need/expense names лишаються literal і не перекладаються автоматично;
- Planner і Collections відображають generated copy через `HubStrings` для UK/EN/FR/DE/ES/KO/JA;
- Planner → save → Collections → A/B/C → reopen та phone/desktop regression coverage лишаються зеленими.

Final code verification: **Flutter checks and START run #189 — success (110/110 tests)**.  
Final latest-head verification після WORKLOG-only commit: **run #190 — success**.

## Перехід від v0.8.8 до v0.9.0

Після v0.8.8 у `main` інтегровано A/B/C comparison і generated Planner copy / preset-label localization з наскрізними regression tests. Formal readiness gate пройдено, після чого checkpoint **v0.9.0 / 0.9.0+17** опубліковано повним cross-platform pipeline.

## Formal prerelease readiness assessment 0.9.0

Assessment від 24.09.2026 зафіксовано в `docs/READINESS_0_9_0.md`.

Висновок: **READY TO PREPARE 0.9.0 PRERELEASE CHECKPOINT**.

- product blockers перед release-prep не знайдено;
- latest functional main run #191: analyze + **110/110 tests** + START artifact — success;
- schema 3 + adapters 1/2, 7-language localization, legal/package metadata і release workflow перевірені;
- exact-current-main Windows/macOS/Android/iOS compile лишається обов'язковим release gate і має пройти в повному release workflow до publication;
- reserve-floor, exports, encrypted vault і production signing лишаються explicit deferred/non-blocking roadmap work.

## Інтегровано після v0.9.0

PR **#67 — UI: add optional Light Dashboard appearance** squash-merged у `main` як `90bea96f5be1b28d980a3846341dbfe90b32e8e8`.

- Classic збережено;
- «Робочий кабінет» / Studio збережено як default;
- додано третій режим **«Світла панель»**;
- three-mode appearance selector замінив двостановий toggle;
- light-blue desktop header/sidebar/status shell + OVDP-specific watermark;
- mobile bottom navigation збережена;
- appearance labels локалізовано UK/EN/FR/DE/ES/KO/JA;
- design regression перевіряє всі три режими та збереження Planner input;
- code verification run #205 — success; final latest-head run #206 — success.

## Інтегровано після v0.9.0 — Planner reserve floor та exports

Після Light Dashboard інтегровано ще два user-visible slice:

- **Planner reserve-floor / мінімальний залишок** — PR #69, merge `37b8120db0dd64fa81dc4f06e3e2a44a2ec21206`; floor є non-consuming liquid-cash constraint, підтримує persistence, coverage/generator, strict A/B/C і 7 мов; branch run #210 та main run #211 — success.
- **Deterministic local Planner CSV + ICS exports** — PR #73, merge `3e8e7fbc08f3d2a305e8eb6d92bfb9428a34dedc`; CSV schema v1, ICS needs/reserve-floor/receipt availability, local-only `<workspace>/exports/`, stable file stem/UID/DTSTAMP, UK/EN/FR/DE/ES/KO/JA; exact-head run #231 і post-merge run #232 — success.
- PDF export свідомо відкладено до стабілізації структури звіту.

## Encrypted vault — approved design checkpoint

PR **#75 — Security: approve encrypted vault threat model** squash-merged у `main` як **`8403bec33ec911a0f7c6a7a766fd585828f3a207`**.

Інтегровано як security contract до будь-якої crypto/plugin реалізації:
- поточні `sets/*.json` визнані legacy plaintext private-capable data, бо можуть містити user notes та повний PlannerScenario;
- публічні NBU/MinFin/seller reference caches можуть лишатися plaintext;
- зафіксовано random per-vault 256-bit DEK, versioned authenticated envelope, OS-backed device key slot і окремий optional recovery wrapper;
- recovery вимагає strong secret + memory-hard KDF; короткий PIN не є root/recovery key;
- затверджено rollback/corruption/atomic-write, lock/auto-lock, plaintext-export і non-destructive legacy migration semantics;
- зафіксовано Windows/macOS/iOS/Android secure-storage/file-access requirements;
- exact AEAD/KDF/library/plugin choices свідомо відкладено до окремого dependency/security review.

Final exact-head verification: **Flutter checks and START run #236 — success**.

**Crypto/plugin code у цьому checkpoint не інтегрувався.**

## Encrypted vault — approved dependency/security checkpoint

PR **#77 — Security: choose encrypted vault crypto and key-storage stack** squash-merged у `main` як **`3e4171e7bc700f6f844e4b27f89222e49feb40cb`**.

Final exact-head verification: **Flutter checks and START run #239 — success**.

Approved implementation inputs:
- **`sodium 4.1.0+1` / libsodium 1.0.22** — XChaCha20-Poly1305-IETF, explicit Argon2id13, libsodium CSPRNG;
- **`flutter_secure_storage 11.2.0`** — тільки Android / iOS / macOS, із hardened explicit options;
- **`win32 6.4.0` + app-owned Windows DPAPI adapter** — current-user scope, non-destructive failure handling;
- generic `flutter_secure_storage_windows` не використовується для vault DEK через destructive decrypt/parse error path у reviewed implementation;
- implementation має підняти Dart floor з >=3.9 до **>=3.13**; поточний CI Flutter 3.47.5 уже працює на сумісному Dart;
- active vault v1 — app-managed local encrypted storage; live provider-backed mutable vault лишається deferred.

Повний review: `docs/security-vault-dependency-review.md`.

**У PR #77 не додавались dependencies або feature code.**

## Encrypted vault — foundation integrated

PR **#79 — Vault: add encrypted storage foundation** squash-merged у `main` як **`d61a1245d0cded27187d06186fcba0df0921dd05`**.

Інтегровано:
- Dart SDK floor >=3.13;
- exact direct dependencies + lockfile: `sodium 4.1.0+1`, `flutter_secure_storage 11.2.0`, `win32 6.4.0`, `ffi 2.2.0`;
- app-owned `VaultCrypto` із XChaCha20-Poly1305-IETF envelope primitives, random DEK/nonce та explicit Argon2id13 recovery derivation;
- `VaultDeviceKeyStore` contract;
- hardened Android/iOS/macOS secure-storage options;
- app-owned current-user Windows DPAPI protector/store з non-destructive failure/rollback behavior;
- security regression tests for wrong key/ciphertext/AAD, KDF parameters, device-store invariants and Windows known-good preservation;
- third-party notices;
- four-platform release compile gate (Windows/macOS/Android/iOS) + real Windows DPAPI smoke.

Verification evidence:
- functional head `0631b7ef…` — Flutter checks and START run #256 success;
- platform gate head `57749cc1…` — Vault foundation platform compile run #2 success on Windows/macOS/Android/iOS + Windows DPAPI smoke;
- exact latest PR head `684c374ac5a4aff48f89365fe5da30f5defe565e` — Flutter checks and START run #260 success;
- post-merge `main` run **#261 — success**;
- Publish native prerelease preflight #66 — success/skipped publication because the immutable v0.9.0 checkpoint already exists.

macOS Data Protection Keychain runtime/provisioning remains an explicit gate before user-facing vault unlock. Compile success is not treated as runtime proof.

**No legacy plaintext migration, portfolio/private-data UI, backup UX or product claim that user data is encrypted was added in PR #79.**

## Encrypted vault — local store/lifecycle integrated

PR **#81 — Vault: add local encrypted store and recovery lifecycle** squash-merged у `main` як **`16cd6f33496104d630a8bf05582dcf8514c4f1b1`**.

Інтегровано:
- versioned recovery-wrapped DEK slot на Argon2id13 + XChaCha20-Poly1305;
- recovery-slot presence/content прив'язано до payload AEAD AAD, тому strip/replace fail closed;
- app-managed encrypted vault file create/open/save;
- pending → flush → authenticated read-back → known-good replace;
- restart recovery з незалежною автентифікацією backup;
- highest-accepted revision / rollback detection;
- portable encrypted backup + recovery restore на fresh device-key store;
- regression coverage для wrong secret, corruption, rollback, interrupted replace, revision-state failure і slot tampering.

Verification:
- exact reviewed head `cd2651c2…` — run #273 success;
- final exact latest head `d6abeb862…` — run #274 success;
- post-merge `main` run **#275 — success**.

Lifecycle contract: `docs/security-vault-local-store.md`.

**Legacy `sets/*.json` migration/deletion та private-data UI ще не реалізовані.**

## Encrypted vault — session/locking foundation integrated

Replacement PR **#84 — Vault: add session locking state machine** squash-merged у `main` як **`51fb92862f3afae71915fa6bc6cce97204ad7037`**. PR #83 закрито без merge через завислий GitHub Actions concurrency run і не є джерелом коду.

Інтегровано:
- app-owned states: locked / unlocking / unlocked / locking / error;
- explicit unlock через `VaultContentStore` та manual lock;
- injected inactivity timeout і background grace без прихованих product defaults;
- elapsed wall-clock foreground enforcement на випадок OS timer suspension;
- generation-token invalidation для stale async unlock/save completion;
- session-owned plaintext copy очищується при lock/error/dispose; guaranteed heap zeroization не обіцяється;
- окремо знайдено й закрито pending-unlock/background race: background grace застосовується також під час `unlocking`, а stale completion не може повторно відкрити session;
- deterministic session regressions + contract `docs/security-vault-session.md`.

Verification:
- pre-hardening run #279 — success;
- hardened exact head `0a69362b…` — run #285 success;
- final latest PR head `5c6e8e3c…` — run #286 success;
- post-merge `main` run **#287 — success**.

**No legacy plaintext migration, private portfolio schema or user-facing vault UI was added.**

## Encrypted vault — lifecycle controls integrated

PR **#86 — Vault: add recovery and local-delete lifecycle controls** squash-merged у `main` як **`3dc1f53dc87e741730115f786798fa5e409007ff`**.

Інтегровано:
- recovery enable для existing device-openable vault без зміни DEK;
- recovery secret/slot rotation з verify-before-commit;
- explicit recovery removal зі збереженням device-key access;
- local delete active file + app-owned lifecycle artifacts + device key/revision metadata;
- external encrypted backups не видаляються local delete;
- interrupted/failed delete rollback/crash recovery;
- reserved internal paths для backup/restore;
- session-level serialization store operations після manual race review: overlapping save/lifecycle/re-unlock → `vault.session_busy`;
- lifecycle contract: `docs/security-vault-lifecycle-controls.md`.

Verification:
- pre-hardening head `4fe7bf74…` — run #297 success;
- serialized mutation head `110c4d98…` — run #299 success;
- final exact head `fa0b42ceacadbed73926acb6ba065921c2ae1fee` — run #301 success;
- post-merge `main` run **#302 — success**.

No legacy plaintext migration, holdings schema or user-facing vault UI was added.

## Private portfolio — encrypted payload foundation integrated

Replacement PR **#89 — Portfolio: add encrypted private payload domain foundation** squash-merged у `main` як **`a516310f71c6414018d3f398c42ba88f553f5244`**. PR #88 закрито без merge лише через draft-state permission block і не є окремим джерелом коду.

Інтегровано:
- private payload schema v1, незалежна від outer vault envelope;
- factual acquisition lots зі stable id, ISIN, units, acquisition date, currency, factual whole-lot trade amount, explicit known/unknown fee state та optional private broker/account label;
- factual coupon/redemption cash events зі stable id, factual date/amount/currency; redemption additionally records units;
- holdings не зберігаються як друга mutable source of truth — вони derivеd з acquisition lots minus represented redemptions;
- deterministic canonical ordering + fixed-key JSON/UTF-8 codec;
- semantic fail-closed validation для duplicate record IDs, invalid fields, event-without-acquisition, currency mismatch, redemption-before-acquisition і negative derived units;
- public NBU/MinFin/seller reference data лишаються поза private payload, instruments referenced by ISIN;
- encrypted LocalVaultStore integration test підтверджує, що physical vault file не містить plaintext portfolio id / ISIN / broker label.

Verification:
- functional head `db291909…` — run #307 success;
- schema/docs head `8396eb5d…` — run #309 success;
- final exact branch head `af6153b0b559da8b184ebd843a3aea29221335bf` — run #310 success;
- replacement PR #89 exact-head run **#311 — success**;
- post-merge `main` run **#312 — success**, including START/source artifact.

Contract: `docs/private-portfolio-payload.md`.

**Schema v1 deliberately does not yet model factual sale/disposal. Therefore its derived holdings must not be presented as a complete real-world portfolio until disposal records are added. Legacy `sets/*.json` migration/import/delete and portfolio UI remain absent.**

## Private portfolio — factual disposals integrated

Replacement PR **#92 — Portfolio: add factual disposals and lot allocation** squash-merged у `main` як **`d8de5c9f1d144c8f816a65877b86bcd79058b432`**. Draft PR #91 closed without merge and is not a code source.

Integrated:
- private payload schema v2 with schema-v1 decode compatibility;
- factual sale/disposal records with stable id, ISIN, date, disposed units, factual whole-disposal proceeds/currency, explicit known/unknown fee state and optional note;
- explicit acquisition-lot allocations per disposal; no automatic FIFO/LIFO and no invented cost basis;
- allocation validation: sum equals disposed units, referenced lot exists/matches ISIN, acquisition is not after disposal, cumulative lot allocation cannot exceed acquired units;
- holdings derive from acquisitions minus represented redemptions minus represented disposals;
- conservative fail-closed rule for disposal on/after already-recorded redemption until redemption-to-lot allocation exists;
- realized acquisition trade cost and known acquisition fees derive only from explicit allocations;
- unknown acquisition/disposal fee remains unknown, never silently zero;
- deterministic schema-v2 codec + encrypted LocalVaultStore round-trip regressions.

Verification:
- functional head `cabf0735…` — run #314 success;
- final draft head `e9b26461…` — run #316 success;
- replacement PR #92 exact head `c3e63967ee245a39a6e6ea044cf425aae66086dc` — run #317 success;
- post-merge `main` run **#318 — success**.

**No legacy `sets/*.json` migration/import/delete and no user-facing portfolio UI was added.**

## Non-destructive legacy plaintext migration integrated

PR **#95 — Portfolio: migrate legacy plaintext collections non-destructively** squash-merged у `main` як **`36191546229ad3146fce84a1846a24a0529de3b7`**.

Інтегровано:
- private payload schema v3 з backward decode schema v1/v2;
- encrypted `legacyCollections` records для immutable legacy `sets/*.json` source identity;
- mapping лише user-specific fields: name, note, savedAt, selected ISIN references та raw canonicalized Planner scenario;
- full public Bond snapshots навмисно не копіюються в private payload;
- SavedSet ніколи не перетворюється на acquisition/holding/disposal facts; migration створює **0 portfolio facts**;
- unknown legacy top-level fields fail closed, щоб майбутні/private fields не губилися мовчки;
- idempotent rerun: same source + same private mapped content → no write/revision bump;
- same source id + changed private content → conflict, never overwrite;
- valid files можуть мігрувати навіть при окремому corrupt/unsupported peer file;
- після encrypted save vault повторно відкривається, а весь canonical schema-v3 payload перевіряється;
- migration core не має delete API; legacy source JSON не змінюються і не видаляються.

Verification:
- hardened code/docs head `bcc79168…` — run #328 success;
- final exact branch head `093c3ada…` — run #329 success;
- PR #95 merge `36191546229ad3146fce84a1846a24a0529de3b7`;
- post-merge `main` run **#331 — success**.

Contracts:
- `docs/private-portfolio-payload.md` — schema v3;
- `docs/private-legacy-migration.md` — mapping/idempotence/verification/no-delete rules.

**Important boundary:** user-facing vault/migration/portfolio UI is still not wired. Existing legacy workspace `sets/*.json` remain plaintext until a future explicit migration flow is connected and successfully run.

## Release v0.9.1 published

Full prerelease checkpoint **v0.9.1 / 0.9.1+18** published from `main` commit **`bf9b358b73ce84ea333a09978a4607c0505d30fb`**.

Release evidence:
- release PR **#97 — Release: OVDP Hub v0.9.1+18**;
- exact PR head run **#337 — success**;
- post-merge `main` run **#338 — success**;
- **Publish native prerelease run #72 — success**;
- immutable tag **`v0.9.1`** → `bf9b358b73ce84ea333a09978a4607c0505d30fb`;
- GitHub prerelease **OVDP Hub 0.9.1** published 24.09.2026.

Published assets:
- `OVDP-Hub-0.9.1-Windows-x64.zip`;
- `OVDP-Hub-0.9.1-macOS.zip`;
- `OVDP-Hub-0.9.1-Android-test.zip`;
- `OVDP-Hub-0.9.1-iOS-unsigned.zip`;
- `OVDP-Hub-0.9.1-START.zip`;
- `SHA256SUMS.txt`;
- `LICENSE.md`, `COPYRIGHT.md`, `LEGAL_AND_COPYRIGHT.md`, `THIRD_PARTY_NOTICES.md`.

Checkpoint scope:
- Light Dashboard;
- Planner reserve floor;
- deterministic CSV/ICS exports;
- encrypted-vault/security foundation;
- recovery/backup/rollback/session/lifecycle controls;
- factual private portfolio schemas through v3;
- factual disposals + explicit lot allocation;
- non-destructive legacy migration core.

**Privacy boundary remains unchanged:** user-facing vault/migration/portfolio UI is not wired; existing legacy workspace `sets/*.json` do not become encrypted automatically merely by installing v0.9.1; migration core has no delete API.

**v0.9.1 tag/release/assets are immutable and must not be moved or rewritten.**

## Наступний етап після v0.9.1

**Android SAF / iOS security-scoped external-folder access**:

1. replace unrestricted path assumptions with platform-supported external-folder access on Android/iOS;
2. preserve workspace portability without copying private data to a server;
3. fail closed when provider permission/bookmark access is unavailable or revoked;
4. add deterministic persistence/reopen tests around platform access handles;
5. keep live provider-backed mutable vault deferred;
6. user-facing vault/migration UX remains a separate explicit gate before claiming legacy private data is encrypted/migrated.


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


## Реліз v0.8.8

Повний test checkpoint **0.8.8+16** опубліковано з актуального `main` після v0.8.7.

До checkpoint входять інтегровані після v0.8.7 user-visible verticals:
- verified tax assumptions для фізособи-резидента України / ОВДП / 2026;
- explicit FX comparison із rate/date/source provenance;
- per-position early-sale assumptions;
- typed recurring primary needs + additional one-off needs;
- multilingual README pages та документаційна синхронізація.

A/B/C comparison **не входить до незмінного v0.8.8**; його інтегровано пізніше через PR #58 у поточний `main`.

Release notes опубліковано сімома мовами: UK / EN / FR / DE / ES / KO / JA.

Release pipeline **Publish native prerelease run #40** успішно завершив verify, Windows, macOS, Android, iOS, START і publish.

Опубліковані assets:
- `OVDP-Hub-0.8.8-Windows-x64.zip`;
- `OVDP-Hub-0.8.8-macOS.zip`;
- `OVDP-Hub-0.8.8-Android-test.zip`;
- `OVDP-Hub-0.8.8-iOS-unsigned.zip`;
- `OVDP-Hub-0.8.8-START.zip`;
- `SHA256SUMS.txt`;
- legal notices.


## Реліз v0.9.0

Повний prerelease checkpoint **0.9.0+17** опубліковано з `main` після readiness gate.

До candidate входять зміни після v0.8.8:
- strict neutral A/B/C comparison для 2–3 saved Planner scenarios;
- hard baseline comparability без автоматичного winner/best/worst;
- generated Planner plan/need/expense copy як stable persisted IDs;
- generated scenario descriptions через display-time localization;
- user-authored names лишаються literal;
- UK/EN/FR/DE/ES/KO/JA coverage;
- readiness assessment `docs/READINESS_0_9_0.md`: GO до release preparation.

Release notes опубліковано сімома мовами інтерфейсу. PR **#65** squash-merged у `main` як `21698ae34f9438f7c5ab49724e47dc13014b7daa`; **Publish native prerelease run #45** успішно завершив verify, Windows, macOS, Android, iOS, START і final publish.

Опубліковані assets:
- `OVDP-Hub-0.9.0-Windows-x64.zip`;
- `OVDP-Hub-0.9.0-macOS.zip`;
- `OVDP-Hub-0.9.0-Android-test.zip`;
- `OVDP-Hub-0.9.0-iOS-unsigned.zip`;
- `OVDP-Hub-0.9.0-START.zip`;
- `SHA256SUMS.txt`;
- legal notices.

**v0.9.0 опубліковано як test/prerelease checkpoint; tag/release не пересувати й не переписувати.**
