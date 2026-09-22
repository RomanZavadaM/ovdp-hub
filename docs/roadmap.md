# Roadmap OVDP Hub

Оновлено: 22.09.2026. Цей roadmap стосується лише активного Flutter-продукту.

## 0.8.2 — стабілізація

- [x] Формальний proprietary release 0.8.1.
- [x] Захист `main`: PR + `verify` + squash + up-to-date.
- [ ] Прибрати завершені Web/Expo/Tauri/TypeScript прототипи з активного дерева.
- [ ] Переписати архітектуру й product docs під Flutter.
- [ ] Dart tool для оновлення початкового snapshot НБУ.
- [ ] Retention старих публічних каталогів у workspace.
- [ ] Єдина модель provenance/freshness для джерел.
- [ ] Threat model для encrypted vault і backup/recovery.
- [ ] Основа локалізації: UK за замовчуванням; EN/FR/DE/ES/KO/JA selectable.

## 0.9.0 — Ринок

- [ ] Єдина картка ISIN.
- [ ] НБУ: інструмент і графік контрактних виплат.
- [ ] Мінфін: календар, оголошення, результати аукціонів і корекції.
- [ ] Продавці: типізовані вторинні observations без вигаданої ціни.
- [ ] sourceDate / retrievedAt / validUntil / freshness / evidence URL.
- [ ] Передача лише явної/введеної ціни у планувальник.

## Планувальник наступного покоління

- [ ] Типізований PlannerScenario замість `Map<String,String>`.
- [ ] Комісії: разові/періодичні/невідомі з явним статусом.
- [ ] Effective-dated податкові сценарії.
- [ ] Кілька джерел цін і пріоритет користувача.
- [ ] Порівняння альтернативних сценаріїв A/B/C.
- [ ] Продаж до погашення як окреме припущення з BID/ціною.
- [ ] FX-модель з явним курсом, датою та джерелом.
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
