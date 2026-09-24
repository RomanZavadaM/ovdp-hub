# OVDP Hub — formal 0.9.0 prerelease readiness assessment

Дата: **24.09.2026**  
Base `main`: `1ae98503c48776ebfd790b837e9a30d889eeb54e`  
Поточний опублікований checkpoint: **v0.8.8 / 0.8.8+16**  
Статус висновку: **READY TO PREPARE 0.9.0 PRERELEASE CHECKPOINT**

Цей документ є decision gate. Він не створює tag/release і не змінює опублікований v0.8.8.

## Підсумок

Під час аудиту **не знайдено продуктового blocker**, який вимагав би нового feature/fix slice перед підготовкою 0.9.0 prerelease.

Поточний `main` замкнув запланований шлях 0.9 «Ринок»:

**ринковий факт → provenance/freshness → explicit price selection → fee/tax/FX/exit assumptions → needs/cashflow plan → neutral A/B/C comparison**.

Generated Planner copy / preset labels також відокремлено від persisted UI-language text через PR #61.

Рекомендований наступний крок: **підготувати окремий release-checkpoint PR для 0.9.0**, не переписуючи v0.8.8.

## 1. Scope / roadmap

### READY

Завершено:
- NBU / MinFin / seller data layers з provenance і fail-closed parsers;
- freshness/status UX;
- explicit price observations + user priority;
- explicit purchase-fee assumptions;
- verified effective-dated OVDP tax preset;
- explicit FX comparison;
- per-position early-sale assumptions;
- recurring primary need + additional one-off needs;
- neutral A/B/C comparison;
- generated Planner copy / preset-label localization UK/EN/FR/DE/ES/KO/JA.

### DEFERRED / NON-BLOCKING

Свідомо не входять до поточного prerelease gate:
- reserve-floor / minimum-balance need;
- CSV/ICS та майбутня PDF report structure;
- encrypted vault і фактичний portfolio/holdings;
- production signing / notarization / store distribution;
- installers / auto-update.

Ці пункти залишаються roadmap work і не підміняються готовими можливостями.

## 2. Scenario schema / backward compatibility

### READY

- Поточний PlannerScenario лишається **schema 3**.
- Нові поля після schema 3 додавалися additive.
- Legacy schema 1/2 читаються через explicit adapter.
- Невідомі schema versions fail closed.
- Per-position exits зберігають safe legacy hold field для старих schema-3 readers.
- Ambiguous multi-position legacy early sale fail closed.
- Price source priority перевіряється на відповідність фактично вибраній observation.
- Workspace / saved scenarios не переписуються мовчки під час читання.
- Generated-copy localization не потребувала schema bump: stable IDs є string values у вже існуючих полях.
- Regression tests покривають legacy schema 2, additive schema-3 observations/priority та per-position exits.

## 3. Localization / UX regression

### READY

Підтримувані мови:
- UK
- EN
- FR
- DE
- ES
- KO
- JA

Evidence:
- `AppLanguage` містить рівно ці 7 мов;
- localization tests ітерують `AppLanguage.values` для domain/error/generated-copy groups;
- generated plan / primary need / expense / scenario-description copy локалізується під час display;
- user-authored names лишаються literal;
- phone/desktop widget regressions лишаються green.

Остання функціональна перевірка після PR #61:
- **Flutter checks and START run #191 — success** на `1e6849f78134d9654b0bf08b54ceebda4100ba4d`;
- `flutter analyze` — success;
- `flutter test` — **110/110 passed**;
- START artifact: `OVDP-Hub-0.8.8-test-191-1-START`.

## 4. Legal / package metadata

### READY

- Proprietary owner: **Roman Zavada (Роман Завада)**.
- Root package має `LICENSE.md`, `COPYRIGHT.md`, `THIRD_PARTY_NOTICES.md`, `docs/LEGAL_AND_COPYRIGHT.md`.
- Third-party notices перелічують direct active dependencies; `flutter_localizations` є SDK-компонентом і покривається записом Flutter/Dart SDK components.
- START package явно вимагає та копіює всі legal notices.
- Windows/macOS desktop packaging копіює legal notices.
- Android/iOS prerelease packaging копіює legal notices.
- Windows metadata використовує Flutter version macros і має owner/copyright.
- iOS/macOS version metadata використовує `FLUTTER_BUILD_NAME` / `FLUTTER_BUILD_NUMBER`.
- iOS має explicit `NSHumanReadableCopyright`.

## 5. Release workflow / artifact safety

### READY

`.github/workflows/release.yml`:
- читає version/build тільки з валідного `X.Y.Z+N`;
- вимагає відповідний `docs/releases/RELEASE_NOTES_vX_Y_Z.md`;
- перевіряє, чи release/tag уже існує, і не запускає повторну публікацію існуючого tag;
- перед packaging запускає `flutter pub get --enforce-lockfile`, `flutter analyze`, `flutter test`;
- окремо збирає START, Windows, macOS, Android та unsigned iOS;
- `publish` залежить від **усіх** build jobs;
- перед publish додає legal notices і `SHA256SUMS.txt`;
- створює immutable GitHub prerelease через `gh release create --target "$GITHUB_SHA"`.

Останній повний release workflow:
- **Publish native prerelease run #40 — success** для v0.8.8;
- jobs `preflight / verify / start / windows / macos / android / ios / publish` — success.

## 6. Current-main cross-platform compile status

### NON-BLOCKING RELEASE GATE

Після v0.8.8 інтегровано A/B/C comparison та generated-copy localization. Для exact current `main` є green analyze/tests/START (run #191), але окремий manual `native.yml workflow_dispatch packages=all` після цих Dart-only змін не запускався.

Це **не вважається приховано пройденою перевіркою**.

Водночас publish pipeline технічно не може перейти до `publish`, доки Windows/macOS/Android/iOS/START jobs не завершаться успішно. Тому current-main platform compile лишається обов'язковим release gate самого 0.9.0 checkpoint.

## 7. Repository hygiene

### READY

На момент assessment:
- open product PR: **0**;
- open technical/product issues: **0**;
- open service ledger: **Issue #18**;
- latest functional main push після PR #61: run #191 — green.

## 8. Release-prep actions — required, but not product blockers

Перед 0.9.0 checkpoint треба окремим release PR:
1. змінити `apps/native/pubspec.yaml` з `0.8.8+16` на **`0.9.0+17`**;
2. створити `docs/releases/RELEASE_NOTES_v0_9_0.md`;
3. release notes оформити всіма 7 мовами інтерфейсу;
4. звірити changelog/project state з фактичним 0.9.0 scope;
5. пройти PR checks;
6. merge release PR має бути свідомою дією checkpoint-публікації: push у `main` запустить повний release workflow;
7. вважати 0.9.0 опублікованим лише після success усіх platform jobs, checksum/legal stage і GitHub prerelease publication.

## Рішення

**GO: OVDP Hub ready to prepare formal v0.9.0 prerelease checkpoint.**

Це рішення означає готовність **до release-prep PR**, а не твердження, що v0.9.0 вже опубліковано.

Якщо platform build або release workflow під час checkpoint знайде проблему, вона стає blocker і tag/release не повинен вважатися завершеним.
