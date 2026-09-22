# PROJECT_STATE — OVDP Hub

Оновлено: 22.09.2026

## Поточний checkpoint

- Активна версія: **0.8.4+12**
- Опублікований GitHub tag: **v0.8.4**
- Активний продукт: **Flutter/Dart, `apps/native`**
- Цільові платформи: Windows, macOS, Android, iOS
- Репозиторій: `RomanZavadaM/ovdp-hub`
- Основна гілка: `main`
- Статус продукту: **test / prerelease**
- Release commit: **1cb857e2ac3850a830c4bdde4e78559e50f03985**
- GitHub Release: **v0.8.4**, опублікований 22.09.2026

## Що реалізовано й входить до 0.8.4

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
- typed MinFin auction event index: placement / switch + announcement/result URLs;
- typed MinFin auction calendar document index: monthly / quarterly / switch PDF + publication date + provenance;
- функціональна локалізація активного UI для UK/EN/FR/DE/ES/KO/JA;
- typed `AppError` / domain/repository/parser error localization;
- START_HERE / WORKLOG / Issue #18 recovery protocol;
- proprietary copyright/licensing на Roman Zavada.

## Інваріанти

- приватні сценарії не передаються на сервер OVDP Hub;
- продукт не виконує купівлю/продаж;
- НБУ, Мінфін і продавці — різні шари даних і не підміняють одне одного;
- yield-only не перетворюється на вигадану ринкову ціну;
- невідома комісія або податок не означають 0;
- workspace і старі сценарії не переписуються мовчки під час читання;
- реальний портфель — лише після encrypted vault, platform secure storage і backup/recovery;
- copyright original project materials: Roman Zavada (Роман Завада).

## Реліз v0.8.4

Release pipeline **Publish native prerelease run #21** успішно завершив:
- `flutter pub get --enforce-lockfile`;
- `flutter analyze` — **No issues found**;
- `flutter test` — **56/56 tests passed**;
- Windows release build + packaging;
- macOS release build + packaging;
- Android release APK + packaging;
- iOS unsigned release build + packaging;
- START package;
- SHA-256 manifest;
- prerelease publication.

Опубліковані assets:
- `OVDP-Hub-0.8.4-Windows-x64.zip`;
- `OVDP-Hub-0.8.4-macOS.zip`;
- `OVDP-Hub-0.8.4-Android-test.zip`;
- `OVDP-Hub-0.8.4-iOS-unsigned.zip`;
- `OVDP-Hub-0.8.4-START.zip`;
- `SHA256SUMS.txt`;
- `LICENSE.md`;
- `COPYRIGHT.md`;
- `LEGAL_AND_COPYRIGHT.md`;
- `THIRD_PARTY_NOTICES.md`.

Tag/release не пересуваємо й не переписуємо.

## Чому 0.8.4, а не 0.9.0

0.8.4 уже містить значну частину етапу «Ринок», але **ще не завершені**:
- структурований future auction schedule із вмісту PDF Мінфіну;
- detailed auction results parser;
- повне підключення typed fee/tax/FX/exit assumptions до всіх розрахунків та UI;
- multiple price sources з explicit user priority;
- повне A/B/C comparison.

Тому 0.8.4 — завершений тестовий checkpoint, а 0.9.0 лишається активною ціллю.

## Наступний етап — 0.9.0 «Ринок»

1. structured future auction schedule з офіційних календарних PDF Мінфіну; перед parser-ом візуально перевірити актуальні PDF-макети;
2. detailed parser результатів аукціонів Мінфіну;
3. нормалізований freshness/status UX у картці ISIN;
4. typed fee/tax/FX/exit assumptions → calculations + UI;
5. multiple `PriceObservation` + explicit user source priority;
6. A/B/C comparison;
7. generated planner copy / preset labels localization під час відповідного UI slice.

Перед використанням податкових правил обов'язкова перевірка офіційних джерел на відповідну дату.
