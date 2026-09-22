# PROJECT_STATE — OVDP Hub

Оновлено: 22.09.2026

## Поточний checkpoint

- Активна версія: **0.8.1+9**
- Опублікований GitHub tag: **v0.8.1**
- Активний продукт: **Flutter/Dart, `apps/native`**
- Цільові платформи: Windows, macOS, Android, iOS
- Репозиторій: `RomanZavadaM/ovdp-hub`
- Основна гілка: `main`
- Статус продукту: **test / prerelease**
- Release commit: **a76c1d8ef49462d9401438624dc276f98eec952e**
- GitHub Release: **v0.8.1**, опублікований 22.09.2026

## Що вже реалізовано

- локальний каталог ОВДП на базі публічних даних;
- пошук, фільтри, графіки виплат та порівняння випусків;
- локальні добірки й робочі папки;
- навчальний калькулятор;
- планування бюджету, строків, резерву та майбутніх витрат;
- сценарії з кількома потребами й календарем надходжень;
- пряме завантаження публічних котирувань ПриватБанку;
- два варіанти інтерфейсу без втрати поточного стану;
- START-пакування та CI-перевірки;
- proprietary copyright/licensing на Roman Zavada;
- legal metadata для Windows/macOS/iOS;
- legal notices у пакетах.

## Інваріанти

- приватні сценарії не передаються на сервер OVDP Hub;
- продукт не виконує купівлю/продаж;
- публічні дані та індикативні котирування не видаються за гарантовану ринкову пропозицію;
- локальні робочі дані відокремлені від програмних пакетів;
- copyright original project materials: Roman Zavada (Роман Завада).

## Поточний релізний стан

**v0.8.1 опублікований.** Release pipeline успішно пройшов dependency resolution, `flutter analyze`, `flutter test` і platform release builds.

Опубліковані assets:

- `OVDP-Hub-0.8.1-Windows-x64.zip`;
- `OVDP-Hub-0.8.1-macOS.zip`;
- `OVDP-Hub-0.8.1-Android-test.zip`;
- `OVDP-Hub-0.8.1-iOS-unsigned.zip`;
- `OVDP-Hub-0.8.1-START.zip`;
- `SHA256SUMS.txt`;
- `LICENSE.md`, `COPYRIGHT.md`, `THIRD_PARTY_NOTICES.md`, `LEGAL_AND_COPYRIGHT.md`.

Tag/release вважається immutable checkpoint і не повинен пересуватися чи переписуватися.

## Після v0.8.1

Наступний функціональний етап не повинен автоматично називатися 0.9.0 до визначення його змісту. Перед новою роботою спочатку оновити цей файл із конкретною ціллю наступного checkpoint.
