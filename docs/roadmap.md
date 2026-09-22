# Roadmap OVDP Hub

Оновлено: 22.09.2026. Цей roadmap стосується лише активного Flutter-продукту.

## 0.8.2 — стабілізація

- [x] Формальний proprietary release 0.8.1.
- [x] Захист `main`: PR + `verify` + squash + up-to-date.
- [x] Прибрати завершені Web/Expo/Tauri/TypeScript прототипи з активного дерева.
- [x] Переписати архітектуру й product docs під Flutter.
- [x] Dart tool для оновлення початкового snapshot НБУ.
- [x] Retention старих публічних каталогів у workspace.
- [x] Єдина модель provenance/freshness для джерел.
- [x] Threat model для encrypted vault і backup/recovery.
- [x] Основа локалізації: UK за замовчуванням; EN/FR/DE/ES/KO/JA selectable.

## 0.9.0 — Ринок

- [ ] Єдина картка ISIN.
- [x] НБУ: інструмент і графік контрактних виплат.
- [ ] Мінфін: календар, оголошення, результати аукціонів і корекції.
- [x] Продавці: типізовані вторинні observations без вигаданої ціни.
- [x] sourceDate / retrievedAt / validUntil / freshness / evidence URL у базовій source-моделі.
- [ ] Передача лише явної/введеної ціни у планувальник.

## Планувальник наступного покоління

- [x] Типізований PlannerScenario / schema 3 з adapter schema 1/2.
- [x] Домен комісій: разові/періодичні/невідомі з явним статусом.
- [x] Домен effective-dated податкових сценаріїв.
- [ ] Кілька джерел цін і пріоритет користувача.
- [ ] Порівняння альтернативних сценаріїв A/B/C.
- [x] Домен продажу до погашення як окремого припущення з BID/ручною ціною.
- [x] Домен FX з явним курсом, датою та джерелом.
- [ ] Типи потреб: разова, регулярна, резервна, мінімальний залишок.
- [ ] CSV/ICS; PDF лише після стабілізації структури звіту.

## Encrypted vault / фактичний портфель

- [ ] Threat model затверджений до коду шифрування.
- [ ] Аудитована криптографічна бібліотека; не власна криптографія.
- [ ] Platform secure storage: Windows/macOS/Android/iOS.
- [ ] Lock/unlock, auto-lock, deletion, recovery.
- [ ] Зашифрований backup з користувацьким recovery material.
- [ ] Holdings, acquisition lots, фактичні купони/погашення після vault.
- [ ] Android SAF / iOS security-scoped access для зовнішніх папок.

## Distribution readiness

- [ ] Windows code signing.
- [ ] macOS Developer ID + notarization.
- [ ] Android production keystore.
- [ ] iOS signing/distribution.
- [ ] Інсталятори й автооновлення — окреме рішення.

## Незмінні межі

Без окремого рішення власника не додаються централізовані портфелі, KYC, приватний relay, вбудовані partner secrets або виконання угод.


## Локалізація 0.9

- [x] Shell / navigation / shared dialogs — UK/EN/FR/DE/ES/KO/JA.
- [x] Каталог — UK/EN/FR/DE/ES/KO/JA.
- [x] Калькулятор — UK/EN/FR/DE/ES/KO/JA.
- [x] Продавці — UK/EN/FR/DE/ES/KO/JA.
- [ ] Сховище — повна функціональна локалізація.
- [ ] Добірки — повна функціональна локалізація.
- [ ] Планування — повна функціональна локалізація.
- Неповний модуль не видається за повністю локалізований: для неукраїнської мови показується попередження.
