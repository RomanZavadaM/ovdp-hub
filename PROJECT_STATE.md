# PROJECT_STATE — OVDP Hub

Оновлено: 22.09.2026

## Поточний checkpoint

- Активна версія: **0.8.3+11**
- Опублікований GitHub tag: **v0.8.3**
- Активний продукт: **Flutter/Dart, `apps/native`**
- Цільові платформи: Windows, macOS, Android, iOS
- Репозиторій: `RomanZavadaM/ovdp-hub`
- Основна гілка: `main`
- Статус продукту: **test / prerelease**
- Release commit: **325b75b80f4e4ed76501142ec02031713c2e4e5d**
- GitHub Release: **v0.8.3**, опублікований 22.09.2026

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

## Реліз v0.8.3

Release pipeline успішно пройшов dependency resolution, `flutter analyze`, **47 тестів** та release builds усіх цільових платформ.

Опубліковані assets:
- `OVDP-Hub-0.8.3-Windows-x64.zip`;
- `OVDP-Hub-0.8.3-macOS.zip`;
- `OVDP-Hub-0.8.3-Android-test.zip`;
- `OVDP-Hub-0.8.3-iOS-unsigned.zip`;
- `OVDP-Hub-0.8.3-START.zip`;
- `SHA256SUMS.txt`;
- legal notices.

За політикою проєкту tag/release не пересуваємо й не переписуємо.

## Чому 0.8.3, а не 0.9.0

0.8.3 — завершена проміжна точка. У ній уже є стабільний типізований домен, але **ще немає завершеної** єдиної картки ISIN, структурованого адаптера Мінфіну та повного UI для fee/tax/FX/early-sale моделей.

Ці незавершені частини не включаються до заявленого функціонального обсягу checkpoint.

## Активна розробка — 0.9.0 «Ринок»

Перший development slice після v0.8.3:
- functional i18n для Каталогу, Калькулятора та Продавців: UK/EN/FR/DE/ES/KO/JA;
- untranslated modules при неукраїнській мові явно позначаються як incomplete;
- shell/studio/shared dialogs і картка деталей випуску переводяться через ті самі ключі;
- додано MinFin primary-market adapter для таблиці останніх аукціонних ставок;
- додано ISIN join model, яка зберігає NBU instrument / MinFin primary / seller secondary як окремі факти;
- parser Мінфіну fail-closed: зміна структури, дубль ISIN або некоректна дата не дають тихо використати дані.

## Наступні кроки 0.9.0 «Ринок»

1. єдина картка ISIN у UI поверх уже розділеної доменної моделі;
2. розширити Мінфін з latest-rates summary до календаря/оголошень/детальних результатів;
3. продавці — вторинні observations і freshness/status UX;
4. локалізувати Сховище, Добірки та Планування на UK/EN/FR/DE/ES/KO/JA;
5. підключити typed fee/tax/FX/exit assumptions до розрахунків і UI;
6. порівняння альтернативних сценаріїв A/B/C.

Перед використанням податкових правил обов'язкова перевірка офіційних джерел на відповідну дату.
