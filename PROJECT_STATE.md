# PROJECT_STATE — OVDP Hub

Оновлено: 23.09.2026

## Поточний checkpoint

- Активна версія в release candidate: **0.8.6+14**
- Поточний опублікований GitHub tag: **v0.8.5**
- Release candidate target: **v0.8.6**
- Активний продукт: **Flutter/Dart, `apps/native`**
- Цільові платформи: Windows, macOS, Android, iOS
- Репозиторій: `RomanZavadaM/ovdp-hub`
- Основна гілка: `main`
- Статус продукту: **test / prerelease**
- Release commit: **6e8ce5c7ccfd4217330e59fe96fd6a83ac531d59**
- Release workflow: **Publish native prerelease run #32 — success**
- GitHub Release: **v0.8.5**, опублікований 22.09.2026

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

## Що входить до release candidate v0.8.6 поверх v0.8.5

- нормалізований freshness/status UX у картці ISIN;
- typed `officialPublished` status для офіційних NBU/MinFin observations;
- seller public quotes лишаються `publicIndicative`;
- однаковий provenance/status block для NBU / MinFin / seller: source, sourceDate, retrievedAt, freshness, data status, evidence URL;
- textual status — не лише колір;
- локалізація UK/EN/FR/DE/ES/KO/JA;
- unit/widget/full-card wiring tests.

Ці зміни формують release candidate **v0.8.6 / 0.8.6+14**. Опублікований `v0.8.5` не переписується.

## Інваріанти

- приватні сценарії не передаються на сервер OVDP Hub;
- продукт не виконує купівлю/продаж;
- НБУ, Мінфін і продавці — різні шари даних і не підміняють одне одного;
- yield-only не перетворюється на вигадану ринкову ціну;
- невідома комісія або податок не означають 0;
- workspace і старі сценарії не переписуються мовчки під час читання;
- реальний портфель — лише після encrypted vault, platform secure storage і backup/recovery;
- copyright original project materials: Roman Zavada (Роман Завада).

## Чому 0.8.5, а не 0.9.0

0.8.5 фіксує завершені MinFin parser-slice, але **ще не завершені**:
- multiple price sources з explicit user priority;
- повне підключення typed fee/tax/FX/exit assumptions до calculations + UI;
- A/B/C comparison;
- generated planner copy / preset labels localization.

Тому 0.9.0 «Ринок» лишається активною ціллю.

## Наступний етап — 0.9.0 «Ринок»

1. multiple `PriceObservation` + explicit user source priority;
2. typed fee/tax/FX/exit assumptions → calculations + UI;
3. A/B/C comparison;
4. generated planner copy / preset labels localization.

Перед використанням податкових правил обов'язкова перевірка офіційних джерел на відповідну дату.
