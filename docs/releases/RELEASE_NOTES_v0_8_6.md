# OVDP Hub 0.8.6

**Дата релізу:** 23.09.2026  
**Статус:** prerelease / test checkpoint  
**Версія застосунку:** 0.8.6+14  
**Правовласник:** © 2026 Roman Zavada (Роман Завада). All rights reserved.

## Навіщо цей реліз

0.8.6 — повний тестовий checkpoint після завершення freshness/status UX у трирівневій картці ISIN. Реліз не завершує етап 0.9.0 «Ринок», але робить provenance та актуальність ринкових шарів зрозумілішими для ручного тестування.

## Що нового після 0.8.5

### Нормалізований freshness/status UX

- Додано typed `officialPublished` для офіційних observation НБУ та Мінфіну.
- Публічні котирування продавців лишаються `publicIndicative`.
- НБУ / Мінфін / продавець відображаються як окремі шари й не підміняють один одного.
- Для кожного шару уніфіковано:
  - джерело;
  - `sourceDate`;
  - `retrievedAt`;
  - freshness;
  - textual data status/confidence;
  - evidence/source URL.
- Fresh/stale/future/unknown status відображається текстом, а не лише кольором.
- NBU catalog provenance передається безпосередньо у картку ISIN.
- Додано локалізацію UK/EN/FR/DE/ES/KO/JA.
- Додано unit/widget/full-card tests.

## Що навмисно ще НЕ завершено

- Multiple `PriceObservation` на ISIN з явним вибором/пріоритетом джерела користувачем.
- Підключення typed fee/tax/FX/exit assumptions до calculations + UI.
- A/B/C comparison.
- Generated planner copy / preset labels localization.
- Реальний портфель до encrypted vault не додається.

Тому реліз — **0.8.6**, а не 0.9.0.

## Інваріанти

- Yield-only не може неявно стати ринковою ціною.
- Nominal estimate не може тихо замінити вибране market observation.
- Офіційно опубліковані дані та індикативні seller quotes мають різні typed status.
- Невідома комісія/податок не означає 0.

## Перевірки і пакування

Release pipeline повинен повторно виконати:
- `flutter pub get --enforce-lockfile`;
- `flutter analyze`;
- `flutter test`;
- Windows release build;
- macOS release build;
- Android release APK;
- iOS unsigned release build;
- START/source packaging;
- SHA-256 manifest;
- publication as GitHub prerelease.

Очікувані пакети:
- `OVDP-Hub-0.8.6-Windows-x64.zip`;
- `OVDP-Hub-0.8.6-macOS.zip`;
- `OVDP-Hub-0.8.6-Android-test.zip`;
- `OVDP-Hub-0.8.6-iOS-unsigned.zip`;
- `OVDP-Hub-0.8.6-START.zip`;
- `SHA256SUMS.txt`;
- legal notices.

Windows/macOS checkpoint не мають production code signing. Android — test/development signing configuration. iOS package — unsigned.
