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
- Поточний опублікований checkpoint: **v0.9.2 / 0.9.2+19** — prerelease, tag `v0.9.2` → `696fd4a07e5e23c4a44d9aeb8bd745671acfb52a`; release workflow #102 — success
- Інтегровано після v0.9.0: **додатковий дизайн «Світла панель»**, Classic та «Робочий кабінет» збережені
- Інтегровано після v0.9.0 також: **Planner reserve-floor / мінімальний залишок**
- Інтегровано після v0.9.0 також: **deterministic local Planner CSV + ICS exports**; PDF лишається deferred
- Інтегровано після v0.9.0 також: **approved encrypted-vault threat model** — private-data boundary, key/recovery/rollback/lock/platform contract
- Інтегровано після v0.9.0 також: **approved vault dependency/security stack** — `sodium 4.1.0+1` / libsodium 1.0.22, `flutter_secure_storage 11.2.0` для Android/Apple, app-owned Windows DPAPI через `win32 6.4.0`
- Інтегровано після v0.9.0 також: **encrypted vault foundation** — Dart >=3.13, exact security dependencies/lockfile, XChaCha20-Poly1305 envelope primitives, Argon2id recovery derivation, hardened device-key adapters, four-platform compile gate + Windows DPAPI smoke
- Інтегровано після v0.9.0 також: **encrypted vault local store/lifecycle** — recovery-wrapped DEK slot, authenticated slot binding, app-managed encrypted file, known-good atomic replace/restart recovery, rollback detection, portable encrypted backup/restore
- Інтегровано після v0.9.0 також: **encrypted vault session/locking foundation** — explicit locked/unlocking/unlocked/locking/error state, manual/inactivity/background lock, stale async completion guards and pending-unlock/background race coverage
- Інтегровано після v0.9.0 також: **encrypted vault lifecycle controls** — recovery enable/rotate/remove, non-destructive local delete/crash recovery, external-backup preservation and serialized session store operations
- Інтегровано після v0.9.0 також: **private encrypted payload/domain foundation** — schema v1, factual acquisition lots, explicit fee state, factual coupon/redemption events, deterministic encrypted codec and derived holdings
- Інтегровано після v0.9.0 також: **private factual disposals / lot allocation** — schema v2, explicit sale/disposal records, explicit acquisition-lot allocation, realized factual cost/proceeds and holdings net of represented disposals
- Інтегровано після v0.9.0 також: **non-destructive legacy plaintext migration core / private payload schema v3** — legacy collection metadata + selected ISINs + raw Planner scenario can be copied into encrypted payload; public Bond snapshots omitted; zero portfolio facts synthesized; source JSON never auto-deleted
- Release v0.9.1: **DONE** — PR #97 → `main` `bf9b358b…`; exact-head run #337, post-merge run #338, Publish native prerelease run #72 — success; Windows/macOS/Android/iOS + START/source + SHA256/legal опубліковано
- Інтегровано після v0.9.2: **factual sale/redemption/history + explicit non-destructive legacy migration wizard** — PR #101 → `main` `c255c937500d17b41cf0ac8542698139539fa047`; exact-head run #390 і post-merge run #391 — success
- Інтегровано після v0.9.2 також: **factual coupon entry + per-ISIN factual ledger** — PR #104 → `main` `c8d26862430ac14dc25ad63da71bd016824ce91a`; exact-head run #395 і post-merge run #396 — success
- Інтегровано після v0.9.2 також: **factual portfolio cash/result summary + closed ISIN access** — PR #106 → `main` `310afcc26728597e01d31c896d39b860bf4f20b5`; exact-head run #399 і post-merge run #400 — success; unknown fees remain explicit and market value is not presented as factual result
- Активний release candidate: **v0.9.3+20**, branch `release/v0.9.3`; scope — factual sale/redemption/history + migration wizard + factual coupon/per-ISIN ledger + factual cash summary/closed positions
- Поточна дія: пройти exact-head release PR gates, інтегрувати в `main`, потім перевірити повний Publish native prerelease для Windows/macOS/Android/iOS + START/source; Android SAF / iOS security-scoped access лишається deferred
- Live ledger: GitHub Issue **#18**
