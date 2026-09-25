# WORKLOG — OVDP Hub

Оновлено: **25.09.2026**

Цей файл — оперативна точка відновлення активної розробки.

Точка входу для нової сесії: `START_HERE.md`  
Постійні правила: `PROJECT_RULES.md`  
Стабільний стан `main`: `PROJECT_STATE.md`  
Append-only журнал: GitHub Issue **#18 — OVDP Hub — live development ledger**

## Статуси

- `NEXT` — наступна конкретна дія.
- `DOING` — робота реально триває.
- `VERIFIED` — перевірено, але ще не merged.
- `BLOCKED` — є конкретна перешкода.
- `DONE` — тільки після merge у `main`.

## Активна ціль

**0.9.x — розвиток після завершеного 0.9.0 «Ринок»**.

Поточний опублікований checkpoint: **v0.9.2 / 0.9.2+19**.

## Поточний slice

Статус: **DOING**

Мета: **v0.9.3+20 full cross-platform prerelease checkpoint**.

- base `main`: **`97695e360ba118814ab71978e65a96eb3b407df8`**;
- branch: **`release/v0.9.3`**;
- target version/build: **0.9.3+20**;
- PR: ще не відкрито;
- release scope: три user-visible portfolio slices після v0.9.2 — sale/redemption/history + migration wizard; factual coupon + per-ISIN ledger; factual cash summary + closed positions;
- private payload schema не змінюється;
- legacy migration лишається explicit + non-destructive; source JSON не видаляються автоматично;
- exact packaged Windows/macOS ZIP smoke є обов'язковим release gate;
- final publication має включати Windows/macOS/Android/iOS + START/source + SHA256 + legal notices;
- Android SAF / iOS security-scoped external-folder access лишається **DEFERRED**;
- production signing/notarization лишається **DEFERRED**.

Критерії готовності:
1. `apps/native/pubspec.yaml` = **0.9.3+20**.
2. Release notes у `docs/releases/RELEASE_NOTES_v0_9_3.md` містять UK/EN/FR/DE/ES/KO/JA.
3. README/CHANGELOG/PROJECT_STATE/START_HERE синхронізовані з candidate scope без хибної заяви про автоматичну legacy migration.
4. Exact release PR head проходить `flutter analyze`, full `flutter test`, Windows build/package/smoke і macOS build/package/smoke.
5. Release PR інтегрується exact-head у `main`.
6. Main release pipeline збирає й публікує Windows/macOS/Android/iOS + START/source + checksums/legal.
7. Tag `v0.9.3` незмінно вказує на release commit; assets і published release перевірені.
8. Лише після успішної публікації checkpoint стає DONE.

### Поточна наступна дія

**DOING — finish v0.9.3+20 metadata/docs, open release PR, pass exact packaged-artifact gates, then merge and verify the full Publish native prerelease pipeline.**

## Черга робіт

1. **DONE** — multiple `PriceObservation` + explicit user source priority.
2. **DONE** — purchase fee assumptions → calculation + UI.
3. **DONE** — tax assumptions → official effective-date audit → calculation + UI.
4. **DONE** — FX assumptions calculation/UI.
5. **DONE** — exit assumptions redesign/wiring for multi-position scenarios.
6. **DONE** — A/B/C comparison — PR #58, final run #183, merge `25123ceb…`.
7. **DONE** — Planner needs/future-expenses block requested by owner.
8. **DONE** — full test checkpoint v0.8.8 from current main.
9. **DONE** — generated planner copy / preset labels localization + UX regression — PR #61, run #189 (110/110), final run #190, merge `1e6849f7…`.
10. **DONE** — formal prerelease readiness assessment 0.9.0 — PR #63, run #193, merge `f80c7d8e…`; GO to release preparation.
11. **DONE** — v0.9.0 full cross-platform checkpoint: PR #65 → merge `21698ae3…`; release run #45 success; tag/release `v0.9.0` published.
12. **DONE** — optional third appearance «Світла панель» integrated via PR #67; final run #206; merge `90bea96f…`.
13. **DONE** — Planner reserve-floor / minimum-balance needs; PR #69 → merge `37b8120d…`; final branch run #210 and main run #211 green.
14. **DONE** — deterministic local CSV + ICS Planner exports; PR #73 → merge `3e8e7fbc…`; branch runs #229/#231 and main run #232 green.
15. **DONE** — Encrypted vault threat-model review/approval; PR #75 → merge `8403bec3…`; final exact-head run #236 green.
16. **DONE** — Encrypted vault dependency/security review and implementation-stack decision; PR #77 → merge `3e4171e7…`; final exact-head run #239 green.
17. **DONE** — Encrypted vault foundation; PR #79 → merge `d61a1245…`; final exact-head run #260 and post-merge run #261 green.
18. **DONE** — Encrypted vault local store/lifecycle; PR #81 → merge `16cd6f33…`; final run #274 and post-merge run #275 green.
19. **DONE** — Encrypted vault session/locking foundation; replacement PR #84 → merge `51fb9286…`; hardened run #285, final run #286 and post-merge run #287 green.
20. **DONE** — Encrypted vault lifecycle controls; PR #86 → merge `3dc1f53d…`; final run #301 and post-merge run #302 green.
21. **DONE** — Private portfolio/encrypted payload foundation; replacement PR #89 → merge `a516310f…`; final replacement run #311 and post-merge run #312 green.
22. **DONE** — Private portfolio factual sale/disposal + explicit lot-allocation foundation; replacement PR #92 → merge `d8de5c9f…`; exact-head run #317 and post-merge run #318 green.
23. **DONE** — Non-destructive legacy plaintext migration; PR #95 → merge `36191546…`; exact-head run #329 and post-merge run #331 green.
24. **DONE** — v0.9.1+18 full prerelease checkpoint; PR #97 → `bf9b358b…`; run #337, main run #338 and release run #72 green; immutable `v0.9.1` published with all platform assets.
25. **DONE** — v0.9.2+19: user-visible «Мій портфель» + persistent «Економічний пульс» + exact packaged-artifact release gate; main `696fd4a…`, run #381, release run #102.
26. **DONE** — User-facing factual acquisition flow + holdings summary on encrypted vault.
27. **DONE** — User-facing factual sale/redemption/history + legacy migration wizard; PR #101 → `c255c937…`; exact-head run #390 and post-merge run #391 green.
28. **DONE** — User-facing factual coupon entry + per-ISIN portfolio detail/ledger; PR #104 → `c8d26862…`; exact-head run #395 and post-merge run #396 green.
29. **DONE** — Factual portfolio cash/result summary + access to closed ISIN positions; PR #106 → `310afcc2…`; exact-head run #399 and post-merge run #400 green.
30. **DOING** — v0.9.3+20 full cross-platform prerelease checkpoint after three post-v0.9.2 user-visible portfolio slices.
31. **DEFERRED** — Android SAF / iOS security-scoped external-folder access; return before mobile vault/external-workspace UX claim.

## Продуктова логіка цієї черги

Не розширювати продукт новими ізольованими джерелами, доки не замкнений базовий шлях користувача:

**ринковий факт → freshness/provenance → вибір ціни → припущення витрат/податків/FX/exit → план → A/B/C comparison**.

Поточний MinFin results parser є першим кроком цього ланцюжка, а не окремою технічною ціллю.

## Ритм `main` і тестування

Термінологія власника:

- **«інтегрувати PR у `main`»** = звичайний технічний merge після green checks;
- **«злити у `main`»** = повний test-release checkpoint: нова version/build + Windows/macOS/Android/iOS + START/source + checksums/legal + новий GitHub prerelease.

Робочий ритм:

- кожен завершений self-contained slice: PR → green checks → **інтеграція PR у `main`**;
- не накопичувати кілька готових незлитих функціональних гілок;
- проміжно після user-visible integration можна тестувати START artifact з актуального `main`;
- регулярно, орієнтовно після 2–3 user-visible integrated slices, робити повне **«злиття у `main`»** з релізами всіх систем;
- робити такий checkpoint раніше після ризикової зміни parser/calculation/schema або одразу за прямою командою власника;
- поточний опублікований v0.8.8 не переписувати; кожен наступний повний checkpoint отримує нову версію/build.

## Нещодавно завершено

- **DONE — factual cash summary + closed positions**: PR #106 exact head `40ea1175…` passed run #399 and was squash-merged into `main` as `310afcc26728597e01d31c896d39b860bf4f20b5`; post-merge run #400 green with START/source. Summary uses only persisted cash facts, exact net result is withheld when fees are unknown, and closed ISINs remain inspectable through factual ledger.

- **DONE — factual coupon + per-ISIN ledger**: PR #104 exact head `ce86507c…` passed run #395 and was squash-merged into `main` as `c8d26862430ac14dc25ad63da71bd016824ce91a`; post-merge run #396 green with START/source. Coupon uses existing encrypted cash-event schema, never changes holdings or invents units; current positions expose per-ISIN factual ledger with persisted notes.

- **DONE — factual sale/redemption/history + explicit legacy migration wizard**: PR #101 exact head `961d41a0…` passed run #390 and was squash-merged into `main` as `c255c937500d17b41cf0ac8542698139539fa047`; post-merge run #391 green with START/source. Sale requires explicit acquisition-lot allocation; redemption/history are factual; migration reports migrated/already/conflict/invalid + encrypted-copy verification and never auto-deletes source JSON. Migration session plaintext is always discarded after an attempt to prevent stale overwrite.

- **DONE — v0.9.2+19 full prerelease checkpoint**: main `696fd4a07e5e23c4a44d9aeb8bd745671acfb52a`; post-merge run #381 success; Publish native prerelease run #102 success; tag/release `v0.9.2` published with Windows/macOS/Android/iOS/START, SHA256SUMS and legal notices. Real packaged desktop ZIP smoke verifies build metadata and Classic/Studio/Light Dashboard contract before publish.

- **DONE — v0.9.1+18 full prerelease checkpoint**: PR #97 merged as `bf9b358b73ce84ea333a09978a4607c0505d30fb`; exact-head run #337 and post-merge run #338 green; Publish native prerelease run #72 built/published Windows, macOS, Android test, unsigned iOS, START/source, SHA256 and legal notices; immutable tag `v0.9.1` points to the release commit.

- **DONE — non-destructive legacy plaintext migration core**: PR #95 merged as `36191546229ad3146fce84a1846a24a0529de3b7`; final branch run #329 and post-merge main run #331 green. Private payload schema v3 preserves user-specific legacy collection metadata/scenario without inventing portfolio facts; source JSON remains untouched and no delete API exists.

- **DONE — private portfolio factual disposals / lot allocation**: replacement PR #92 exact head `c3e63967…` passed run #317 and was squash-merged into `main` as `d8de5c9f1d144c8f816a65877b86bcd79058b432`; post-merge run #318 green. Schema v2 adds explicit factual disposals, explicit acquisition-lot allocation, realized factual cost/proceeds and holdings net of represented disposals; legacy migration/UI remain absent.

- **DONE — private portfolio/encrypted payload foundation**: replacement PR #89 exact head `af6153b0…` passed run #311 and was squash-merged into `main` as `a516310f71c6414018d3f398c42ba88f553f5244`; post-merge run #312 green with START/source artifact. Schema v1 stores factual acquisition lots plus coupon/redemption events, deterministic encrypted payload bytes and derived holdings; sale/disposal, legacy migration and portfolio UI remain deferred.

- **DONE — encrypted vault lifecycle controls**: PR #86 final head `fa0b42ce…` passed run #301 and was squash-merged into `main` as `3dc1f53dc87e741730115f786798fa5e409007ff`; post-merge run #302 green. Recovery enable/rotate/remove, non-destructive local delete/crash recovery, external-backup preservation and session-level store serialization are integrated; no legacy migration/private UI.

- **DONE — encrypted vault session/locking foundation**: replacement PR #84 final head `5c6e8e3c…` passed run #286 and was squash-merged into `main` as `51fb92862f3afae71915fa6bc6cce97204ad7037`; post-merge run #287 green. Manual/inactivity/background locking, generation guards, plaintext-buffer disposal and pending-unlock/background race coverage are integrated. PR #83 closed without merge.

- **DONE — encrypted vault local store/lifecycle**: PR #81 final head `d6abeb86…` passed run #274 and was squash-merged into `main` as `16cd6f33496104d630a8bf05582dcf8514c4f1b1`; post-merge run #275 green. Recovery slot binding, encrypted local file, atomic known-good recovery, rollback detection and portable encrypted backup/restore are integrated; no legacy migration/private UI.

- **DONE — encrypted vault foundation**: PR #79 exact latest head `684c374a…` passed run #260 and was squash-merged into `main` as `d61a1245d0cded27187d06186fcba0df0921dd05`; post-merge run #261 green. Added Dart >=3.13, pinned sodium/flutter_secure_storage/win32/ffi, XChaCha20-Poly1305 + Argon2id primitives, hardened Android/Apple key storage, non-destructive Windows DPAPI, four-platform compile gate and Windows DPAPI smoke. No legacy migration/private-data UI.

- **DONE — encrypted vault dependency/security review**: PR #77 exact latest head `dea8cc33…` passed run #239 and was squash-merged into `main` as `3e4171e7bc700f6f844e4b27f89222e49feb40cb`. Approved: sodium/libsodium for XChaCha20-Poly1305 + Argon2id, hardened flutter_secure_storage on Android/Apple, app-owned Windows DPAPI via win32; no dependency/feature code was added in the review.

- **DONE — encrypted vault threat-model checkpoint**: PR #75 final head `13b628e7…` passed run #236 and was squash-merged into `main` as `8403bec33ec911a0f7c6a7a766fd585828f3a207`. Private-data boundary, random DEK + authenticated envelope, device/recovery key ownership, rollback/lock/migration/export semantics and platform requirements are frozen; no crypto/plugin code was added.

- **DONE — deterministic Planner CSV + ICS exports**: PR #73 squash-merged у `main` як `3e8e7fbc08f3d2a305e8eb6d92bfb9428a34dedc`; exact-head run #231 і post-merge run #232 success; CSV/ICS local-only exports integrated, PDF deferred.


- **DONE — Planner reserve-floor / minimum-balance**: PR #69 final head `0cf2f513…` passed run #210; squash-merged у `main` as `37b8120db0dd64fa81dc4f06e3e2a44a2ec21206`; post-merge run #211 success. Floor is a non-consuming minimum-liquid-cash constraint, schema 3 compatible, included in coverage/generator/A-B-C/UI and 7 languages.


- **DONE — Light Dashboard appearance**: PR #67 final latest-head run #206 success; squash-merged у `main` як `90bea96f5be1b28d980a3846341dbfe90b32e8e8`. Classic + Studio preserved, third «Світла панель» mode added with 7-language selector and desktop/phone regression coverage.


- **DONE — v0.9.0 full cross-platform checkpoint**: PR #65 squash-merged у `main` як `21698ae34f9438f7c5ab49724e47dc13014b7daa`; Publish native prerelease run #45 success. Опубліковано Windows/macOS/Android/iOS/START + SHA256SUMS + legal notices під tag `v0.9.0`.


- **DONE — formal 0.9.0 prerelease readiness assessment**: PR #63 squash-merged у `main` як `f80c7d8e87b4fb494cf37712627bc12277a2fa73`; final run #193 success. Evidence in `docs/READINESS_0_9_0.md`; no product blocker found; decision = GO to release-prep, while exact-current platform builds remain enforced release gates.

- **DONE — generated Planner copy / preset labels localization**: PR #61 squash-merged у `main` як `1e6849f78134d9654b0bf08b54ceebda4100ba4d`; code run #189 success (110/110 tests), final latest-head run #190 success. Generated plan/need/expense copy and scenario note are language-neutral in storage, displayed through `HubStrings` in UK/EN/FR/DE/ES/KO/JA; user-authored names remain literal; existing phone/desktop Planner regressions green.

- **DONE — strict neutral A/B/C comparison**: PR #58 squash-merged у `main` як `25123ceb049534c67b9d284ee0f79e5cc8694e28`; final run #183 success, 108/108 tests. Порівнюються 2–3 saved scenarios з однаковими baseline assumptions; recurring needs supported, reserve-floor fail closed, no automatic winner; UK/EN/FR/DE/ES/KO/JA UI + domain/Cubit/widget regressions green. Старий PR #53 закрито без merge.


- **DONE — v0.8.8 full cross-platform checkpoint**: PR #56 squash-merged у `main` як `acacf53b903e876e7bacae45ebc6f895e799cd75`; `Publish native prerelease` run #40 success. Опубліковано Windows/macOS/Android/iOS/START + SHA256SUMS + legal notices під tag `v0.8.8`; release description містить UK/EN/FR/DE/ES/KO/JA.


- **DONE — typed recurring Planner needs block**: PR #54 squash-merged у `main` як `e2a48d7017fe578295e631054d84fce52cbc2b55`; final run #168 success. Primary recurring need, month-end-safe expansion, schema-3 persistence/reload, one-off additions and 7-language UI integrated.


- **DONE — per-position exit assumptions**: PR #51 squash-merged у `main` як `296fb9e0b53093685ced9e801196616a401582f4`; final run #161 success. Multi-ISIN exit model, sale cashflow/profit/coverage, safe legacy compatibility, BID/manual provenance, persistence and 7-language UI integrated.


- **DONE — explicit FX comparison assumptions**: PR #48 squash-merged у `main` як `755c328e0d1b15d2d4843f434eaf774d80ff5494`; final run #152 success (88/88 tests). Explicit rate/date/source comparison, single-currency cashflow invariant, persistence, deferred advanced rules and 7-language UI integrated.


- **DONE — verified OVDP tax assumptions**: PR #45 squash-merged у `main` як `b47fd1360432a8336ca38666064eb46eebbd04f7`; final run #145 success. Official-source-audited 2026 zero-tax preset, unknown/verified-zero semantics, fail-closed non-zero tax base, persistence, post-fee/post-tax result UI and 7-language coverage integrated.


- **DONE — v0.8.7 full cross-platform checkpoint**: PR #42 squash-merged у `main` як `6ab844fd3063fbfa9fcf54ab875539241c459845`; `Publish native prerelease` run #37 success. Опубліковано Windows/macOS/Android/iOS/START + SHA256SUMS + legal notices під tag `v0.8.7`; GitHub Release description містить UK/EN/FR/DE/ES/KO/JA.


- **DONE — explicit purchase fee assumptions**: PR #41 squash-merged у `main` як `fbe8028ae1f68fcbb9c4c7a7057134c6793c00ae`; final run #135 success (80/80 tests). Planner зберігає typed fees, відрізняє unknown від confirmed zero, враховує явну aggregate purchase fee у budget/reserve/profit, показує gross caveat при unknown fees, не перезаписує richer typed rules і має 7-language UI/error coverage.


- **DONE — explicit price-source priority**: PR #39 squash-merged у `main` як `255d15294105e8d5ae6dfe216f1e900fe0490192`; final run #123 success. Planner зберігає кілька observations, explicit source priority, UI add/select/reorder + nominal fallback; yield-only/nominal не стають market price автоматично; UI локалізовано 7 мовами, regression/widget coverage зелені.

- **DONE — v0.8.6 full cross-platform checkpoint**: PR #37 squash-merged у `main` як `7b19670a2ff621a65685db714022d8819ecff7d4`; `Publish native prerelease` run #34 success; опубліковано Windows/macOS/Android/iOS/START + SHA256SUMS + legal notices під tag `v0.8.6`.

- **DONE — ISIN freshness/status UX**: PR #35 squash-merged у `main` як `e4f6d1cfe0544a28cc1afff81084e5dd898910ba`; final run #104 success. Official NBU/MinFin observations відокремлено від seller indicative quotes; для трьох шарів уніфіковано sourceDate/retrievedAt/freshness/status/evidence UI та 7 мов.

- **DONE — v0.8.5 full cross-platform checkpoint**: PR #33 squash-merged у `main` як `6e8ce5c7ccfd4217330e59fe96fd6a83ac531d59`; `Publish native prerelease` run #32 success; опубліковано Windows/macOS/Android/iOS/START + SHA256SUMS + legal notices під незмінним tag `v0.8.5`.

- **DONE — detailed MinFin auction results**: PR #31 squash-merged у `main` як `3f8ff04d1bddb221b5180384b547c6bd544a22d8`; final clean run #95 success. Реальні 2026 result DOCX перевірено; placement parser покриває 21-row × N layout, switch parser — 26-field layout; provenance, fail-closed validation, deterministic tests і локалізовані errors інтегровані.

- **DONE — owner command semantics**: PR #29 squash-merged у `main` як `75c62456e29a1882bbcf59d4a04e739966781da2`; run #81 success. «Злити у main» тепер канонічно означає повний cross-platform test release, а звичайний merge називається «інтегрувати PR у main».

- **DONE — product direction + regular test cadence**: PR #27 squash-merged у `main` як `531f33649da30eb9ec191632f11c418e33b7ddf7`; run #79 success. Зафіксовано vertical-slice порядок до 0.9.0, merge кожного завершеного slice у `main`, START-тест після user-visible merge та cross-platform checkpoint після 2–3 user-visible slices або раніше для ризикових core-змін.

- **DONE — MinFin structured future auction schedule**: PR #24 squash-merged у `main` як `1313339ac0241dc2ea50db3ea14494ea07871f3c`; stale PR #21 закрито без merge; final verify run #75 success; parser підтримує окремі monthly / quarterly / switch layouts, provenance, deterministic tests і fail-closed behavior.

- **DONE — v0.8.4**: prerelease published from commit `1cb857e2ac3850a830c4bdde4e78559e50f03985`; release workflow run #21 success; 56/56 tests passed; Windows/macOS/Android/iOS/START published with SHA256SUMS + legal notices.
- **DONE — PR #22**: release checkpoint 0.8.4.
- **DONE — PR #20**: typed MinFin calendar document index; merge `5a189a3b127ac80ed3a6faa2c0eff4ef342b540a`.
- **DONE — PR #17**: typed placement/switch auction event index + recovery protocol.
- **DONE — PR #15/#16**: typed AppError + domain/parser error localization.

## Якщо роботу перервано

1. прочитати `START_HERE.md`;
2. прочитати `PROJECT_RULES.md`;
3. прочитати `PROJECT_STATE.md`;
4. прочитати `WORKLOG.md`;
5. прочитати останні коментарі Issue #18;
6. перевірити фактичний `main`, активні PR і CI;
7. GitHub має пріоритет над застарілим текстом;
8. продовжити з першого `DOING/NEXT`.

## Правило для чату

Чат — інтерфейс керування роботою, **не сховище стану**. Усе, що змінює напрямок, scope, статус або наступну дію, повинно бути відображене в GitHub у цій же робочій сесії.
