# Планована робота за аудитом 02.10.2026

За дорученням власника знахідки F1–F10 додано до майбутньої роботи. **Статус: PLANNED; реалізація не почата; активного продуктового NEXT немає.** Наступний slice і його scope визначає власник.

База статичного аудиту: `31c2004298f1b804439692e8bfb7562d3952c8ba` (v0.10.0 / 0.10.0+22). P1 — ризики приватності/цілісності даних; P2 — прозорість, UX, докази та документація. Пріоритет не є підтвердженням runtime-відтворення: F4 — гіпотеза для контрольованої перевірки, F9 — межа наявного доказу. Поточні зелені release gates не спростовують сценарії, які вони не перевіряють.

Рекомендований порядок: F1/F2 → F3/F4 → F5/F6/F7 → F8/F9/F10. Кожний майбутній slice: branch/PR, релевантний regression test, green exact-head checks, docs/ledger sync. Реліз — лише окремою командою власника. Deferred physical-device/signing/store backlog не активується.

## F1 — P1: Перенесення сценаріїв: перевіряти вміст перед видаленням plaintext

- Статус: **PLANNED**.
- [Код/документ на базі аудиту](https://github.com/RomanZavadaM/ovdp-hub/blob/31c2004298f1b804439692e8bfb7562d3952c8ba/apps/native/lib/features/portfolio/portfolio_cubit.dart).
- Знахідка: Збіг ID не доводить збіг даних. Повторна міграція після невдалого видалення або інший workspace можуть мати той самий ID.
- Критерії завершення: Порівняти канонічний вміст/ digest і походження workspace+record перед видаленням. Конфлікт зберігає оригінал. Тести: однаковий ID з різними сумами; правильний ID з неправильним вмістом.

## F2 — P1: Закріпити workspace на весь цикл міграції

- Статус: **PLANNED**.
- [Код/документ на базі аудиту](https://github.com/RomanZavadaM/ovdp-hub/blob/31c2004298f1b804439692e8bfb7562d3952c8ba/apps/native/lib/features/portfolio/portfolio_cubit.dart).
- Знахідка: Між читанням джерела та видаленням є await; користувач може перемкнути workspace. Черга окремих операцій не забезпечує транзакцію.
- Критерії завершення: Увесь read/save/verify/delete прив’язати до початкового workspace або generation. Тест із паузою та перемиканням A→B: B не змінюється, хибного успіху для A немає.

## F3 — P1: При блокуванні vault прибирати приватний сценарій із Planner

- Статус: **PLANNED**.
- [Код/документ на базі аудиту](https://github.com/RomanZavadaM/ovdp-hub/blob/31c2004298f1b804439692e8bfb7562d3952c8ba/apps/native/lib/features/planner/planner_cubit.dart).
- Знахідка: Завантажений сценарій копіюється у стан Planner; очищення списку Portfolio не очищує приватний draft.
- Критерії завершення: Позначати приватне походження. Manual/inactivity/background lock приховує або очищує приватні дані, діалоги й preview та блокує export. Перевірити також звичайні нові/public drafts.

## F4 — P1: Перевірити race між recovery/KDF та блокуванням

- Статус: **PLANNED**.
- [Код/документ на базі аудиту](https://github.com/RomanZavadaM/ovdp-hub/blob/31c2004298f1b804439692e8bfb7562d3952c8ba/apps/native/lib/features/portfolio/portfolio_gateway.dart).
- Знахідка: Гіпотеза статичного аудиту: операція, яка почалась до lock, після await може знову кешувати DEK. Обхід блокування у runtime не доведено.
- Критерії завершення: Спочатку контрольований тест із paused KDF → lock → completion. Після завершення session лишається locked, DEK відсутній, наступне відкриття вимагає secret. Generation/cancellation/cleanup охоплює всю операцію gateway.

## F5 — P2: Узгодити приватність нотаток звичайних collections

- Статус: **PLANNED**.
- [Код/документ на базі аудиту](https://github.com/RomanZavadaM/ovdp-hub/blob/31c2004298f1b804439692e8bfb7562d3952c8ba/apps/native/lib/features/collections/editor_cubit.dart).
- Знахідка: Назва і note звичайної collection зберігаються plaintext; security design відносить user notes до приватних даних.
- Критерії завершення: Визначити public/private межу: приватні нотатки у vault, для plaintext — зрозуміле повідомлення й відповідна документація. Перевірити фактичні файли workspace.

## F6 — P2: Попереджати про plaintext export приватного сценарію

- Статус: **PLANNED**.
- [Код/документ на базі аудиту](https://github.com/RomanZavadaM/ovdp-hub/blob/31c2004298f1b804439692e8bfb7562d3952c8ba/apps/native/lib/features/planner/planner_view.dart).
- Знахідка: CSV/ICS приватного сценарію виходять за межі vault у workspace, який може синхронізуватись.
- Критерії завершення: Перед export приватного draft пояснювати, що файл не захищений vault, і показувати призначення. Відміна не створює файл; public export працює.

## F7 — P2: Враховувати взаємодію у приватному UI для inactivity timer

- Статус: **PLANNED**.
- [Код/документ на базі аудиту](https://github.com/RomanZavadaM/ovdp-hub/blob/31c2004298f1b804439692e8bfb7562d3952c8ba/apps/native/lib/security/vault_session.dart).
- Знахідка: Поточний recordActivity враховує storage/foreground, але звичайне читання, введення та прокрутку не підключено.
- Критерії завершення: Throttled activity без збирання вмісту вводу. Активна робота не виглядає idle; справжня бездіяльність блокує vault. Узгодити поведінку draft із F3.

## F8 — P2: Показувати часткове оновлення каталогу НБУ

- Статус: **PLANNED**.
- [Код/документ на базі аудиту](https://github.com/RomanZavadaM/ovdp-hub/blob/31c2004298f1b804439692e8bfb7562d3952c8ba/apps/native/lib/models.dart).
- Знахідка: Толерантний parser може відкинути до 50% рядків; rejectedRows не показано користувачу.
- Критерії завершення: Показати valid/rejected counts, partial status і діагностику. Повна невдача зберігає попередній snapshot; перевірити змішані valid/invalid дані.

## F9 — P2: Розширити докази поведінки packaged builds

- Статус: **PLANNED**.
- [Код/документ на базі аудиту](https://github.com/RomanZavadaM/ovdp-hub/blob/31c2004298f1b804439692e8bfb7562d3952c8ba/apps/native/lib/release_contract.dart).
- Знахідка: Release-contract smoke перевіряє metadata/capability declarations, а не виконання всіх заявлених UI/domain сценаріїв. Це межа доказу, не твердження про зламаний реліз.
- Критерії завершення: Додати поведінкові packaged probes критичних migration/recovery/private-scenario/calculator flows; зберегти exact ZIP smoke. Compile mobile не називати physical runtime validation. Перевірити version/build dart-defines проміжних Android/iOS CI збірок.

## F10 — P2: Синхронізувати живу технічну документацію

- Статус: **PLANNED**.
- [Код/документ на базі аудиту](https://github.com/RomanZavadaM/ovdp-hub/blob/31c2004298f1b804439692e8bfb7562d3952c8ba/docs/architecture.md).
- Знахідка: Частина живих документів описує старі v0.9.x межі, payload v3 та попередній NEXT.
- Критерії завершення: Узгодити architecture/platforms/private-portfolio-payload/product/native README/START privacy/MinFin calendar/roadmap із v0.10.0, payload v4, PDF/DOCX parsing та чесними mobile runtime межами. Розрізняти legacy migration і explicit move/delete. Історичні release notes не переписувати.

## Відстеження

[GitHub Issue #147](https://github.com/RomanZavadaM/ovdp-hub/issues/147) — checklist майбутнього виконання. Запис у roadmap означає планування, а не початок реалізації.
