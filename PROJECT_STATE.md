# PROJECT_STATE — OVDP Hub

Оновлено: 22.09.2026

## Поточний checkpoint

- Активна версія: **0.8.3+11**
- Release target: **v0.8.3**
- Активний продукт: **Flutter/Dart, `apps/native`**
- Цільові платформи: Windows, macOS, Android, iOS
- Репозиторій: `RomanZavadaM/ovdp-hub`
- Основна гілка: `main`
- Статус продукту: **test / prerelease**
- Попередній опублікований checkpoint: **v0.8.2**

## Що реалізовано й входить до 0.8.3

- локальний каталог ОВДП на базі публічних даних НБУ;
- пошук, фільтри, графіки виплат та порівняння випусків;
- локальні добірки й робочі папки;
- навчальний калькулятор;
- планування бюджету, строків, резерву й майбутніх витрат;
- сценарії з кількома потребами та календарем надходжень;
- публічні котирування ПриватБанку як окремий secondary-market observation layer;
- provenance/freshness model для зовнішніх даних;
- типізований `PlannerScenario` і scenario schema 3;
- adapter старих scenario schema 1/2 без тихого переписування файлів;
- typed price observations: full price, clean price + НКД, yield-only, nominal estimate;
- моделі fee assumptions, effective-dated tax scenarios, FX assumptions, exit assumptions;
- unknown fee/tax не підміняються нулем;
- yield-only не підміняється unit price;
- основа альтернативних сценаріїв A/B/C;
- українська default/canonical; EN/FR/DE/ES/KO/JA передбачені для вибору;
- retention публічних каталогів;
- threat model і security gate майбутнього encrypted vault;
- START, CI та multi-platform prerelease pipeline;
- proprietary copyright/licensing на Roman Zavada.

## Інваріанти

- приватні сценарії не передаються на сервер OVDP Hub;
- продукт не виконує купівлю/продаж;
- НБУ, Мінфін і продавці — різні шари даних і не підміняють одне одного;
- індикативна дохідність без ціни не перетворюється на вигадану ринкову ціну;
- невідома комісія або податок не означають 0;
- workspace і старі сценарії не переписуються мовчки під час читання;
- реальний портфель — лише після encrypted vault, platform secure storage і backup/recovery;
- copyright original project materials: Roman Zavada (Роман Завада).

## Чому 0.8.3, а не 0.9.0

0.8.3 — завершена проміжна точка. У ній уже є стабільний типізований домен, але **ще немає завершеної** єдиної картки ISIN, структурованого адаптера Мінфіну та повного UI для fee/tax/FX/early-sale моделей.

Ці незавершені частини не включаються до заявленого функціонального обсягу checkpoint.

## Наступний етап — 0.9.0 «Ринок»

1. єдина картка ISIN;
2. НБУ — характеристики випуску;
3. Мінфін — календар і результати первинного ринку;
4. продавці — вторинні observations;
5. нормалізований freshness/status UX;
6. підключення typed fee/tax/FX/exit assumptions до розрахунків і UI;
7. порівняння альтернативних сценаріїв.

Перед використанням податкових правил обов'язкова перевірка офіційних джерел на відповідну дату.
