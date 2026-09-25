# Roadmap OVDP Hub

Оновлено: 25.09.2026. Цей roadmap стосується лише активного Flutter-продукту.

## Продуктовий напрямок до 0.9.0

Ціль — довести OVDP Hub від набору корисних модулів до цілісного сценарію **«перевірені ринкові факти → зрозуміла актуальність → явний вибір ціни/припущень → план → порівняння»**.

Порядок розвитку:

1. **Довіра до ринкових даних — DONE**: detailed MinFin auction results parser інтегрований з provenance, fail-closed поведінкою та deterministic tests.
2. **Зрозуміла актуальність — DONE**: freshness/status UX у картці ISIN уніфіковано для NBU / MinFin / seller observations.
3. **Явний вибір ринкової ціни — DONE**: кілька `PriceObservation`, explicit user priority, add/select/reorder controls і nominal fallback інтегровані без прихованої підміни yield/nominal ціною.
4. **Повна економіка сценарію — DONE**: purchase-fee, verified-tax, explicit-FX та per-position exit vertical інтегровані. Невідомі значення не вважати нулем.
5. **Порівняння рішень — DONE**: neutral A/B/C comparison для 2–3 saved scenarios із strict baseline comparability, recurring-needs support, explanatory metrics і no-winner semantics — PR #58, final run #183.
6. **0.9.0 — RELEASED**: readiness assessment не знайшов product blocker; PR #65 інтегровано, а full cross-platform release workflow #45 успішно опублікував v0.9.0.

Принцип пріоритезації: спочатку завершувати вертикальний користувацький шлях, а не додавати нові ізольовані джерела чи екрани.

## Опублікований checkpoint v0.9.0

**v0.9.0 / 0.9.0+17** опубліковано 24.09.2026. До checkpoint увійшли всі 0.9 «Ринок» verticals, strict neutral A/B/C comparison і generated Planner copy/preset-label localization. PR #65 merged як `21698ae34f9438f7c5ab49724e47dc13014b7daa`; release pipeline run #45 успішний для Windows/macOS/Android/iOS/START і final publish.

## Ритм інтеграції та тестових checkpoint

- Кожен завершений і перевірений vertical slice **інтегруємо PR у `main`** перед початком наступного.
- Проміжно після user-visible integration тестуємо актуальний `main` через START artifact.
- Команда власника **«злити у `main`»** означає повний багатоплатформний test-release checkpoint: нова version/build, Windows/macOS/Android/iOS, START/source, checksums/legal, Git tag і GitHub prerelease.
- Такий повний checkpoint плануємо регулярно — орієнтовно після кожних 2–3 user-visible integrated slices або раніше після ризикових змін parser/calculation/schema.
- Опубліковані теги не переписуються; кожне повне «злиття у `main`» отримує нову версію/build.

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

- [x] Єдина картка ISIN з окремими NBU / MinFin / seller шарами.
- [x] НБУ: інструмент і графік контрактних виплат.
- [x] Мінфін: календар, оголошення та структуровані результати аукціонів.
  - [x] Typed index оголошень/результатів з розрізненням placement/switch та fail-closed parser.
  - [x] Typed index календарних документів Мінфіну: monthly / quarterly / switch PDF + publication date + provenance.
  - [x] Структурований розклад майбутніх аукціонів із календарних PDF: окремі monthly / quarterly / switch parser-и, provenance, deterministic tests і fail-closed validation.
  - [x] Детальний parser результатів аукціонів з офіційних DOCX: placement 21-row × N, switch 26-field, provenance + fail-closed + deterministic tests.
- [x] Продавці: типізовані вторинні observations без вигаданої ціни.
- [x] Базові sourceDate / retrievedAt / freshness / evidence URL; validUntil лишається source-specific.
- [x] Передача лише явної/введеної ціни у планувальник; yield-only/nominal не стають market price автоматично.

## UX після v0.9.0

- [x] Додатковий дизайн **«Світла панель»** за наданими власником desktop reference screenshots — PR #67, final run #206.
- [x] Classic та **«Робочий кабінет»** залишаються доступними; новий дизайн не замінює їх.
- [x] Appearance selector і новий shell локалізовано UK/EN/FR/DE/ES/KO/JA.
- [x] Desktop + phone regression coverage; функціональний стан Planner/Catalog не губиться при зміні оформлення.
- [x] UI slice завершено; подальші Planner reserve-floor та CSV/ICS export slice також інтегровані.

## Планувальник наступного покоління

- [x] Типізований PlannerScenario / schema 3 з adapter schema 1/2.
- [x] Домен комісій: разові/періодичні/невідомі з явним статусом.
- [x] Домен effective-dated податкових сценаріїв.
- [x] Кілька джерел цін і пріоритет користувача — PR #39, final run #123.
- [x] Purchase fee assumptions: unknown / confirmed zero / aggregate fee → persistence / calculation / UI — PR #41, final run #135.
- [x] Tax assumptions → official effective-date verification → calculation/UI — PR #45, final run #145.
- [x] FX assumptions → explicit comparison calculation/UI — PR #48, final run #152.
- [x] Exit assumptions → per-position multi-ISIN cashflow/profit/UI — PR #51, final run #161.
- [x] Порівняння альтернативних сценаріїв A/B/C — PR #58, final run #183; 2–3 scenarios, strict comparability, no automatic winner, recurring needs supported.
- [x] Домен продажу до погашення як окремого припущення з BID/ручною ціною.
- [x] Домен FX з явним курсом, датою та джерелом.
- [x] Типи потреб: разова + регулярна з typed persistence/cashflow/UI — PR #54, final run #168.
- [x] Потреби типу reserve floor / мінімальний залишок — PR #69, final run #210, merge `37b8120d…`, post-merge run #211.
- [x] CSV/ICS — deterministic local exports зі scenario/cashflow/needs — PR #73, exact-head run #231, merge `3e8e7fbc…`, post-merge run #232. PDF лишається deferred до стабілізації структури звіту.

## Encrypted vault / фактичний портфель

- [x] Threat model review/approval — PR #75.
- [x] Audited crypto stack selected and reviewed: sodium/libsodium, Argon2id13, XChaCha20-Poly1305 — PR #77.
- [x] Platform device-key adapters: hardened Android/iOS/macOS secure storage + app-owned Windows DPAPI; four-platform compile gate + Windows DPAPI smoke — PR #79. macOS runtime/provisioning remains a release gate before user-facing unlock.
- [x] Local encrypted vault file lifecycle: recovery-wrapped DEK slot, authenticated slot binding, atomic known-good recovery, rollback detection — PR #81.
- [x] Encrypted portable backup/restore primitives with recovery material — PR #81.
- [x] Lock/unlock session state, inactivity/background auto-lock and stale async lifecycle guards — replacement PR #84; hardened run #285, final run #286, merge `51fb9286…`, post-merge run #287.
- [x] Recovery enable/rotate/remove + local vault deletion lifecycle — PR #86; non-destructive rollback/crash handling, external-backup preservation and serialized session store operations.
- [x] Private encrypted payload/domain foundation: acquisition lots, derived holdings, factual coupon/redemption events with stable IDs and deterministic validation — replacement PR #89, merge `a516310f…`, post-merge run #312.
- [x] Factual sale/disposal records + deterministic acquisition-lot allocation / realized-cost foundation — replacement PR #92, exact-head run #317, merge `d8de5c9f…`, post-merge run #318.
- [x] Non-destructive legacy plaintext migration core — private payload schema v3; strict/idempotent/conflict-aware mapping, full encrypted verification, zero synthesized portfolio facts and no delete API; PR #95, post-merge run #331.
- [x] **v0.9.2:** user-facing encrypted portfolio entrypoint: create/open/lock, factual acquisition, derived holdings + persistent Economic Pulse.
- [x] Release correctness gate: exact packaged Windows/macOS ZIP → extract → execute → verify version/build + Classic/Studio/Light Dashboard contract.
- [x] Factual sale/redemption/history UI + explicit non-destructive legacy migration wizard — PR #101, exact-head run #390, merge `c255c937…`, post-merge run #391.
- [x] User-facing factual coupon entry + per-ISIN portfolio detail/ledger — PR #104, exact-head run #395, merge `c8d26862…`, post-merge run #396.
- [x] Factual portfolio cash/result summary + access to closed ISIN positions — PR #106, exact-head run #399, merge `310afcc2…`, post-merge run #400; unknown fees remain explicit and market value is not presented as fact.
- [x] **v0.9.3+20 RELEASED:** full cross-platform prerelease after three post-v0.9.2 user-visible portfolio slices; PR #109 → `e2ec9632…`, main run #405 and publish run #106 — success.
- [ ] Android SAF / iOS security-scoped access для зовнішніх папок — deferred до mobile external-workspace/vault slice.

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
- [x] Сховище — UK/EN/FR/DE/ES/KO/JA.
- [x] Добірки + редактор — UK/EN/FR/DE/ES/KO/JA.
- [x] Планувальник — статичний UI UK/EN/FR/DE/ES/KO/JA.
- [x] Domain/error повідомлення з Cubit/Repository/parser/domain validation переведені на typed коди й локалізоване відображення UK/EN/FR/DE/ES/KO/JA.
- [x] Generated planner copy / preset labels: stable persisted generated-copy IDs + display-time `HubStrings` для UK/EN/FR/DE/ES/KO/JA; user-authored text literal — PR #61, run #189 (110/110), final run #190.


## Після v0.9.3

- [x] Post-v0.9.3 usability/product audit — PR #116; findings зафіксовано в `docs/AUDIT_POST_0_9_3.md`.
- [x] Portfolio recovery / backup UX — PR #117: recovery-secret confirmation, rotation, Windows portable encrypted backup/restore, UK/EN/FR/DE/ES/KO/JA; exact-head #417, merge `fc38177a…`, post-merge #418.
- [x] Planner safe criteria/date editing — PR #119, exact-head #420, merge `ad3a995a…`, post-merge #421.
- [ ] Unified date-control UX / picker для Planner + Portfolio — окремий slice після state-safety foundation.
- [x] Catalog localization literals + persisted collection variant copy cleanup — PR #120, final exact-head #428, merge `5638f56e…`, post-merge #429.
- [ ] **NEXT:** Persist language/appearance preferences as non-sensitive app preferences, separate from workspace/private vault.
- [ ] macOS Portfolio runtime Keychain validation + enablement — окремий platform gate.
- [ ] Android SAF / iOS security-scoped external-folder access — deferred до окремого mobile storage gate.
- [ ] Production signing/notarization/store distribution — окремий distribution-readiness gate.
