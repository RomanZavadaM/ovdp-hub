# START_HERE — OVDP Hub

> **Перша точка входу для будь-якої нової робочої сесії, нового чату або відновлення після обриву.**

Цей файл існує, щоб робота над OVDP Hub не залежала від пам'яті конкретного чату.

## Обов'язковий startup protocol

Перед будь-якою зміною коду, документації, релізу або плану:

1. Прочитати цей файл.
2. Прочитати `PROJECT_RULES.md` — незмінні правила проєкту.
3. Прочитати `PROJECT_STATE.md` — що вже інтегровано в `main`, поточна версія/checkpoint і великий наступний етап.
4. Прочитати `WORKLOG.md` — активний slice, гілка/PR, перевірені SHA, блокери та точна наступна дія.
5. Перевірити фактичний стан GitHub:
   - актуальний `main` SHA;
   - відкриті PR;
   - head SHA активного PR;
   - останній CI/verify.
6. Прочитати останні записи GitHub Issue **#18 — OVDP Hub — live development ledger**.
7. Якщо GitHub суперечить тексту у файлах — GitHub має пріоритет; одразу синхронізувати `WORKLOG.md`.
8. Продовжити з першого незавершеного пункту `DOING` / `NEXT`. Не повторювати merged роботу.

## Джерела істини та їхня роль

### `PROJECT_RULES.md`
Постійні правила:
- архітектурні межі;
- версіювання;
- локалізація;
- фінансові інваріанти;
- privacy/security;
- git/release workflow;
- обов'язковий worklog protocol.

### `PROJECT_STATE.md`
Тільки підтверджений інтегрований стан `main`:
- поточний prerelease/checkpoint;
- що реально вже merged;
- що входить/не входить у поточну версію;
- наступний великий етап.

Не використовувати цей файл як журнал незлитої роботи.

### `WORKLOG.md`
Оперативний стан активної розробки:
- поточна ціль;
- активний slice;
- base SHA;
- branch;
- PR;
- current/head SHA;
- останній verify;
- критерії готовності;
- `DOING` / `NEXT` / `BLOCKED`;
- нещодавно завершені slice.

Це головний файл відновлення після обриву чату.

### GitHub Issue #18 — live development ledger
Append-only хронологія:
- початок slice;
- створення branch;
- важливі зміни;
- analyze/test;
- PR;
- CI success/failure;
- blocker;
- merge;
- новий наступний slice.

Issue не заміняє WORKLOG: він дає історію, WORKLOG — поточний знімок.

### `apps/native/pubspec.yaml`
Машинне джерело version/build активного Flutter-продукту.

### `docs/roadmap.md`
Середньостроковий план функціоналу. Не використовувати замість `WORKLOG.md` для визначення того, що робиться прямо зараз.

## Команда власника «злити у main»

У цьому проєкті фраза власника **«злити у `main`» / «зливай у `main`»** не означає лише merge PR.

Вона означає **повний тестовий релізний checkpoint**: нова version/build, інтеграція в `main`, збірки Windows/macOS/Android/iOS, START/source, checksums/legal notices, новий Git tag і GitHub prerelease.

Для звичайного merge без релізу використовувати формулювання **«інтегрувати PR у `main`»**.

## Правило завершення slice

Slice не є `DONE`, доки:

1. код/документація завершені;
2. обов'язкові перевірки пройдені;
3. PR має зелений verify;
4. PR merged у `main`;
5. `PROJECT_STATE.md` оновлений, якщо змінився підтверджений стан;
6. `WORKLOG.md` містить merge SHA і рівно одну наступну конкретну дію;
7. у Issue #18 записано факт merge і нову точку продовження.

## Правило для нового чату

Якщо користувач пише щось на кшталт:

> «Продовжуємо OVDP Hub»

робоча сесія повинна **спочатку відновити стан з GitHub за цим протоколом**, а не покладатися на пам'ять попередньої розмови.

Рекомендована мінімальна фраза для нового чату:

> **Продовжуємо OVDP Hub. Відкрий у GitHub `START_HERE.md` і віднови роботу строго за ним.**

Цього має бути достатньо для відновлення контексту без копіювання великого промпту.

## Поточний технічний контекст

- Репозиторій: `RomanZavadaM/ovdp-hub`
- Активний продукт: `apps/native` (Flutter/Dart)
- Основна мова: українська
- Додаткові мови: EN / FR / DE / ES / KO / JA
- Завершений великий етап: **0.9.0 «Ринок»**
- Поточний опублікований checkpoint: **v0.9.0 / 0.9.0+17**
- Інтегровано після v0.9.0: **додатковий дизайн «Світла панель»**, Classic та «Робочий кабінет» збережені
- Інтегровано після v0.9.0 також: **Planner reserve-floor / мінімальний залишок**
- Інтегровано після v0.9.0 також: **deterministic local Planner CSV + ICS exports**; PDF лишається deferred
- Інтегровано після v0.9.0 також: **approved encrypted-vault threat model** — private-data boundary, key/recovery/rollback/lock/platform contract; crypto/plugin implementation ще не починалась
- Наступний активний slice: **Encrypted vault dependency/security review — перевірити AEAD/KDF + secure-storage/platform adapter candidates проти `docs/security-vault.md`; feature implementation до завершення review не починати**
- Live ledger: GitHub Issue **#18**
