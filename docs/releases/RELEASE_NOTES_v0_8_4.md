# OVDP Hub 0.8.4

**Дата релізу:** 22.09.2026  
**Статус:** prerelease / test checkpoint  
**Версія застосунку:** 0.8.4+12  
**Правовласник:** © 2026 Roman Zavada (Роман Завада). All rights reserved.

## Навіщо цей реліз

0.8.4 — наступна завершена тестова точка після 0.8.3. Вона фіксує вже інтегровану частину етапу **0.9 «Ринок»**, але не оголошує весь 0.9 завершеним.

Цей checkpoint зручний для тестування тому, що market/localization slices уже merged, а наступний parser структурованого розкладу з PDF Мінфіну ще не почато.

## Що нового після 0.8.3

### Локалізація
- Повна статична UI-локалізація основних активних модулів для:
  - Українська;
  - English;
  - Français;
  - Deutsch;
  - Español;
  - 한국어;
  - 日本語.
- Domain/repository/parser помилки переведені на typed `AppError` / stable error codes + parameters.
- Бізнес-логіка більше не повинна повертати готові українські user-facing error strings.
- Додано тестування English error flow і fallback families.

### Ринок / картка ISIN
- Додано трирівневу картку ISIN:
  1. НБУ — параметри випуску;
  2. Мінфін — primary-market observations;
  3. продавець — реально завантажені secondary-market observations.
- Шари NBU / MinFin / seller не підміняють один одного.
- Yield не називається price.
- Seller quote не вигадується, якщо дані не завантажені.

### Мінфін
- Додано latest-auction market adapter та ISIN join.
- Додано typed auction event index:
  - placement;
  - switch auction;
  - auction date;
  - official announcement URL;
  - optional results URL;
  - provenance;
  - fail-closed parsing.
- Додано typed index календарних документів Мінфіну:
  - monthly placement;
  - quarterly placement;
  - monthly switch;
  - publication date;
  - official PDF evidence URL;
  - provenance;
  - fail-closed parsing.
- URL джерел перевіряються як офіційні `mof.gov.ua`.

### Надійність розробки
- Додано `START_HERE.md` як канонічну точку входу для нової сесії/чату.
- Додано `WORKLOG.md` з активним slice, branch/PR/SHA/CI і точною наступною дією.
- GitHub Issue #18 використовується як append-only development ledger.
- Новий чат повинен відновлювати стан із GitHub, а не з пам'яті попередньої розмови.

## Що навмисно ще НЕ завершено

- Вміст календарних PDF Мінфіну ще не перетворюється на структурований future auction schedule.
- Детальний parser результатів аукціонів ще не завершений.
- Typed fee/tax/FX/exit assumptions ще не повністю підключені до всіх розрахунків та UI.
- Кілька джерел цін з явним user-selected priority ще не завершені.
- Повне A/B/C порівняння сценаріїв ще не завершене.
- Реальний портфель не додається до незашифрованого workspace.

Тому версія залишається **0.8.4**, а не 0.9.0.

## Перевірки

Release pipeline повторно виконує:
- `flutter pub get --enforce-lockfile`;
- `flutter analyze`;
- `flutter test`;
- release build для Windows;
- release build для macOS;
- release APK для Android;
- unsigned release build для iOS.

## Пакети

Після успішного release workflow публікуються:
- `OVDP-Hub-0.8.4-Windows-x64.zip`;
- `OVDP-Hub-0.8.4-macOS.zip`;
- `OVDP-Hub-0.8.4-Android-test.zip`;
- `OVDP-Hub-0.8.4-iOS-unsigned.zip`;
- `OVDP-Hub-0.8.4-START.zip`;
- `SHA256SUMS.txt`;
- legal notices.

Windows/macOS checkpoint не мають production code signing. Android використовує test/development signing configuration. iOS package — unsigned.

Це prerelease для тестування. Ринкові дані, тарифи, податки й розрахунки перед практичним використанням потрібно звіряти з первинними джерелами.
