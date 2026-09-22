# PROJECT_STATE — OVDP Hub

Оновлено: 22.09.2026

## Поточний checkpoint

- Активна версія: **0.8.2+10**
- Опублікований GitHub tag: **v0.8.2**
- Активний продукт: **Flutter/Dart, `apps/native`**
- Цільові платформи: Windows, macOS, Android, iOS
- Репозиторій: `RomanZavadaM/ovdp-hub`
- Основна гілка: `main`
- Статус продукту: **test / prerelease**
- Release commit: **5c44a129545d2d697d9fb65c6d9548823b6288fd**
- GitHub Release: **v0.8.2**, опублікований 22.09.2026

## Що реалізовано

- локальний каталог ОВДП на базі публічних даних НБУ;
- пошук, фільтри, графіки виплат та порівняння випусків;
- локальні добірки й робочі папки;
- навчальний калькулятор;
- планування бюджету, строків, резерву та майбутніх витрат;
- сценарії з кількома потребами й календарем надходжень;
- пряме завантаження публічних котирувань ПриватБанку;
- типізована базова модель provenance/freshness для зовнішніх observations;
- два варіанти інтерфейсу без втрати поточного стану;
- основа багатомовності: українська default/canonical; EN/FR/DE/ES/KO/JA selectable у оболонці;
- retention публічних каталогів без зміни збережених сценаріїв;
- Dart tool для оновлення bootstrap snapshot НБУ;
- threat model майбутнього encrypted vault;
- START-пакування, CI та формальний multi-platform prerelease pipeline;
- proprietary copyright/licensing на Roman Zavada;
- legal metadata та legal notices у пакетах.

## Архітектурний стан після 0.8.2

- активна продуктова лінія одна: Flutter/Dart;
- завершені Next.js/Expo/Tauri/TypeScript прототипи вилучені з активного дерева; історія доступна в Git;
- `docs/architecture.md`, `docs/product.md` і `docs/roadmap.md` описують фактичний Flutter-продукт;
- workspace marker і формати існуючих добірок/сценаріїв у 0.8.2 не змінювались;
- приватні сценарії не передаються на сервер OVDP Hub;
- продукт не виконує купівлю/продаж;
- публічні дані та індикативні котирування не видаються за гарантовану ринкову пропозицію;
- copyright original project materials: Roman Zavada (Роман Завада).

## Реліз v0.8.2

Release pipeline успішно пройшов dependency resolution, `flutter analyze`, **41 тести** та release builds усіх цільових платформ.

Опубліковані assets:

- `OVDP-Hub-0.8.2-Windows-x64.zip`;
- `OVDP-Hub-0.8.2-macOS.zip`;
- `OVDP-Hub-0.8.2-Android-test.zip`;
- `OVDP-Hub-0.8.2-iOS-unsigned.zip`;
- `OVDP-Hub-0.8.2-START.zip`;
- `SHA256SUMS.txt`;
- `LICENSE.md`, `COPYRIGHT.md`, `THIRD_PARTY_NOTICES.md`, `LEGAL_AND_COPYRIGHT.md`.

За політикою проєкту опублікований tag/release є незмінним checkpoint: його не пересуваємо і не переписуємо. GitHub API не позначає цей release системним прапорцем immutable.

## Наступний етап — 0.9.0 «Ринок»

Перший крок 0.9.0 має бути сумісним і неруйнівним:

1. типізована доменна модель планувальника замість поступового розростання `Map<String,String>`;
2. parser/adapter старих scenario schema 1/2 у нову in-memory модель без тихого переписування файлів;
3. типізовані price observations і джерела;
4. моделі комісій, effective-dated податкових сценаріїв, FX, раннього продажу та різних типів потреб;
5. єдина картка ISIN: НБУ → Мінфін → вторинний ринок → користувацькі припущення.

Перед встановленням будь-яких податкових ставок або правил обов'язкова перевірка актуальних офіційних джерел на відповідну дату.

Повноцінний фактичний портфель реалізовується лише після encrypted vault, platform secure storage і backup/recovery.
