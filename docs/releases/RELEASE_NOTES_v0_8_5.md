# OVDP Hub 0.8.5

**Дата релізу:** 22.09.2026  
**Статус:** prerelease / test checkpoint  
**Версія застосунку:** 0.8.5+13  
**Правовласник:** © 2026 Roman Zavada (Роман Завада). All rights reserved.

## Навіщо цей реліз

0.8.5 — повний тестовий checkpoint після двох великих market-slice, інтегрованих поверх 0.8.4. Він не оголошує етап 0.9.0 «Ринок» завершеним, але фіксує вже перевірені structured MinFin data flows для календарів та результатів аукціонів.

## Що нового після 0.8.4

### Структурований майбутній розклад Мінфіну

- Додано structured future auction schedule з офіційних календарних PDF Мінфіну.
- Monthly / quarterly / switch документи розбираються окремими parser-ами відповідно до фактичних layout.
- Зберігаються provenance конкретного PDF, publication/source date та retrievedAt.
- Невідомий або змінений layout не вгадується: parser працює fail closed.
- Тести deterministic і не залежать від live network.
- Parser errors локалізовані для UK/EN/FR/DE/ES/KO/JA.

### Детальні результати аукціонів Мінфіну

- Фактичний формат 2026 перевірено на офіційних джерелах: result documents публікуються як DOCX.
- Звичайне розміщення: typed parser для observed layout **21 rows × N випусків**.
- Аукціон з обміну: typed parser для observed layout **26 fields × 1 result**.
- Нормалізується лише технічна Word-run fragmentation:
  - пробіли всередині дат;
  - пробіли всередині чисел;
  - пробіли всередині ISIN.
- Відсутні або невідомі поля не домислюються.
- Зберігаються official result URL, auction sourceDate, retrievedAt та тип observation.
- Parser fail closed на:
  - invalid DOCX;
  - неофіційний URL;
  - зміну набору/кількості полів;
  - дублікати;
  - невідповідність дати документа даті аукціону.
- Додано deterministic tests без live-network залежності.
- Додано direct MIT dependency `archive` для ZIP/DOCX container parsing і оновлено legal notices.

## Що навмисно ще НЕ завершено

- Нормалізований freshness/status UX у картці ISIN.
- Кілька `PriceObservation` з явним пріоритетом джерела користувачем.
- Повне підключення typed fee/tax/FX/exit assumptions до calculations + UI.
- A/B/C comparison.
- Generated planner copy / preset labels localization.
- Реальний портфель не додається до незашифрованого workspace.

Тому реліз — **0.8.5**, а не 0.9.0.

## Перевірки

Release pipeline повторно виконує:
- `flutter pub get --enforce-lockfile`;
- `flutter analyze`;
- `flutter test`;
- Windows release build;
- macOS release build;
- Android release APK;
- iOS unsigned release build;
- START/source packaging;
- SHA-256 manifest;
- publication as immutable GitHub prerelease.

## Пакети

Після успішного workflow публікуються:
- `OVDP-Hub-0.8.5-Windows-x64.zip`;
- `OVDP-Hub-0.8.5-macOS.zip`;
- `OVDP-Hub-0.8.5-Android-test.zip`;
- `OVDP-Hub-0.8.5-iOS-unsigned.zip`;
- `OVDP-Hub-0.8.5-START.zip`;
- `SHA256SUMS.txt`;
- legal notices.

Windows/macOS checkpoint не мають production code signing. Android використовує test/development signing configuration. iOS package — unsigned.

Це prerelease для тестування. Ринкові дані, тарифи, податки й розрахунки перед практичним використанням потрібно звіряти з первинними джерелами.
