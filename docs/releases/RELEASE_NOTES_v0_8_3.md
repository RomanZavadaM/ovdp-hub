# OVDP Hub 0.8.3

**Дата релізу:** 22.09.2026  
**Статус:** prerelease / завершений проміжний checkpoint  
**Версія застосунку:** 0.8.3+11  
**Правовласник:** © 2026 Roman Zavada (Роман Завада). All rights reserved.

## Навіщо цей реліз

0.8.3 — свідома проміжна точка між стабілізацією 0.8.2 і великим етапом 0.9 «Ринок».

У реліз не включаються незавершена єдина картка ISIN, новий адаптер Мінфіну або напівготовий market UI. Натомість тут зафіксовано вже завершений і протестований домен, на якому ці функції будуються.

## Що завершено

- Flutter/Dart лишається єдиною активною продуктовою лінією.
- Українська — основна/канонічна мова; оболонка передбачає вибір EN/FR/DE/ES/KO/JA.
- Додано типізований PlannerScenario та scenario schema 3.
- Старі scenario schema 1/2 читаються через адаптер без автоматичного переписування файлів.
- Додано typed price observations з provenance/source metadata.
- Розрізняються full price, clean price + НКД, yield-only і nominal estimate.
- Yield-only observation не використовується як unit price без окремого явного ціноутворення.
- Додано моделі fee assumptions, effective-dated tax scenarios, FX assumptions і exit assumptions.
- Unknown fee/tax — окремий стан і не означає 0%.
- Достроковий продаж вимагає BID або явної ручної ціни; ASK не підміняє ціну продажу.
- Закладено варіанти сценаріїв A/B/C через groupId/variantLabel.
- Додано contract tests для нового домену та backward compatibility.
- Provenance/freshness і security gate encrypted vault з 0.8.2 залишаються інваріантами.

## Межі цього checkpoint

- Єдина картка ISIN ще не завершена.
- Інтеграція результатів/календаря Мінфіну як структурованого market layer ще попереду.
- Typed fee/tax/FX/exit domain уже зберігається і тестується, але весь відповідний UI та всі формули ще не оголошуються завершеними.
- Реальний портфель не вводиться до завершення encrypted vault + platform secure storage + backup/recovery.
- Продукт не виконує купівлю/продаж і не є інвестиційною рекомендацією.

## Дані та актуальність

НБУ використовується для параметрів випуску. Публічні котирування продавців є окремими observations і не вважаються виконуваною пропозицією без підтвердження. HTTP 200 не означає, що ринкова дата актуальна.

## Пакети

Release pipeline формує:
- Windows x64;
- macOS;
- Android test;
- iOS unsigned;
- START/source;
- SHA256SUMS;
- legal notices.

Windows/macOS checkpoint не мають production code signing, Android використовує поточну test/development signing configuration, iOS package — unsigned.

Це prerelease. Перед практичним використанням ринкові дані, тарифи, податки та розрахунки потрібно звіряти з первинним джерелом.
