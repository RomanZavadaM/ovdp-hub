# Encrypted vault — approved threat model and implementation contract

Статус: **APPROVED DESIGN CHECKPOINT — 24.09.2026**  
Scope: дизайн і security contract до реалізації. **Цей документ не означає, що encrypted vault уже реалізований.**

## 1. Мета і межа обіцянки

Vault захищає приватні локальні дані OVDP Hub **at rest** від читання після копіювання файлів, втрати/крадіжки заблокованого пристрою, випадкового потрапляння encrypted backup/vault file у сторонню папку та від непомітної модифікації ciphertext.

Vault **не** може захистити від:
- повністю скомпрометованої вже розблокованої ОС;
- шкідливо модифікованого застосунку;
- screen capture / clipboard / keylogger після unlock;
- користувацького plaintext export, який уже покинув vault;
- гарантованого secure erase на SSD, APFS snapshots, cloud/provider history або чужих backup;
- rollback на стару, але автентичну копію на новому пристрої без локальної історії revision.

OVDP Hub не показує статус «зашифровано», якщо приватні записи, які належать до цієї межі, зберігаються plaintext поза vault.

## 2. Private-data boundary

### 2.1. Може лишатися plaintext

Ці дані не вважаються приватним портфелем користувача і можуть зберігатися у звичайному workspace:

- `ovdp-workspace.json` з версією формату й application id, **без приватних полів**;
- публічні NBU/MinFin каталоги, календарі, результати аукціонів та їх provenance;
- публічні seller observations / market-reference cache;
- UI preferences: мова, appearance, layout;
- технічний locator активного workspace/vault, якщо він не містить ключового матеріалу;
- START/source та інші публічні application artifacts.

### 2.2. Обов'язково всередині vault

Після ввімкнення приватного режиму **не можна** зберігати plaintext поза vault:

- фактичний портфель;
- acquisition lots: ISIN, кількість, ціна/вартість придбання, дата, комісії;
- broker/account labels, приватні теги та нотатки;
- imported statements/documents або їх приватний зміст;
- user-authored collection notes;
- saved PlannerScenario / A-B-C variants, якщо вони містять бюджет, резерв, потреби, кількості, ручні ціни, fees/taxes/FX/exit assumptions або інші персональні фінансові параметри;
- приватні metadata, достатні для відновлення структури портфеля;
- майбутні персональні reminders / annotations, якщо вони походять із приватного портфеля.

Поточні `sets/*.json` містять user-authored note та можуть містити повний PlannerScenario. Тому вони є **legacy plaintext planning data**, а не encrypted-vault storage.

### 2.3. Exports

CSV/ICS/PDF або інший файл, який користувач **явно експортує** з приватних даних, є окремим plaintext artifact за межами vault, якщо формат сам не визначений як encrypted export.

Правила:
- export ніколи не створюється автоматично;
- UI перед plaintext export з vault явно попереджає, що файл більше не захищений vault;
- export path не повинен містити ключі/recovery material;
- app не заявляє, що exported file «зашифрований».

## 3. Threats

Враховуємо:

1. крадіжку копії vault file або encrypted backup;
2. втрачений/вкрадений пристрій у заблокованому стані;
3. випадкову синхронізацію encrypted vault у стороннього provider;
4. corruption, partial write, sync conflict;
5. tampering;
6. rollback на старішу валідну копію;
7. витік secret/key/recovery material у log, crash report, CI, release package, source repository або debug UI;
8. downgrade/migration помилку між версіями envelope;
9. втрату device-bound key після перевстановлення/скидання ОС;
10. підміну plaintext legacy data за «already encrypted».

## 4. Vault v1: file/envelope contract

Фізичний формат має бути **versioned envelope**, а не «зашифрований JSON без метаданих».

Зовнішній envelope може містити лише мінімальні несекретні поля, потрібні для відкриття та міграції:

- magic/application id;
- envelope version;
- vault instance id;
- algorithm identifiers;
- KDF/wrapping identifiers та параметри;
- nonce/salt;
- один або кілька wrapped data-key slots;
- ciphertext;
- мінімальний technical revision marker, якщо він потрібний до decrypt.

Усе, що описує портфель/сценарії/нотатки, має бути **всередині authenticated ciphertext**.

### Security properties

- тільки authenticated encryption (AEAD) з бібліотеки, яка пройшла окремий dependency/security review;
- **ніякої власної реалізації** crypto primitives;
- не використовувати ECB/CBC без окремої автентифікації, XOR, «шифрування паролем» або homemade formats;
- nonce/IV не може повторюватися для одного data key;
- envelope/version/algorithm identifiers, необхідні для коректної інтерпретації ciphertext, повинні бути authenticated як AAD або бути всередині authenticated payload;
- decryption/authentication failure = hard failure; не відкривати часткові/«майже валідні» дані;
- невідомий version/algorithm/KDF = fail closed;
- payload має власний schemaVersion незалежно від envelopeVersion.

Точний AEAD algorithm і concrete Dart/native library **не фіксуються цим slice**. Вони обираються наступним dependency review, але мусять відповідати цим властивостям та мати не менше 128-bit security level.

## 5. Key ownership and wrapping

### 5.1. Data Encryption Key

- кожен vault отримує випадковий **256-bit Data Encryption Key (DEK)** з CSPRNG;
- DEK **не** походить напряму з PIN, короткого пароля, імені, device id або workspace path;
- DEK не записується plaintext у workspace, log, preferences, crash data, source або backup;
- vault payload шифрується DEK.

### 5.2. Device key slot

Для звичайного локального unlock DEK зберігається лише у **wrapped/protected form**.

Device key slot:
- використовує OS-backed secret/key protection;
- device-local / non-synchronizing, якщо платформа це підтримує;
- не покладається на machine-wide protection, якщо доступний current-user/app-scoped варіант;
- biometric / OS user-presence може бути додатковим gate, але не замінює cryptographic key ownership;
- app PIN не є root encryption key.

### 5.3. Recovery key slot

Portable recovery є окремою моделлю, а не копією device key.

Якщо користувач вмикає recovery:
- той самий DEK отримує окремий recovery-wrapped slot;
- recovery secret має бути достатньо сильним для offline attack resistance;
- user-entered recovery secret проходить salted **memory-hard KDF**;
- KDF algorithm, salt і параметри versioned у envelope;
- exact KDF/parameters затверджуються dependency review і benchmark на всіх target platforms;
- recovery secret ніколи не зберігається поруч із backup автоматично.

Короткий 4–6 digit PIN **не допускається** як portable recovery secret.

## 6. Backup / recovery model

Розрізняємо:

### Local encrypted snapshot
Копія vault file, яка може бути корисною на тому самому пристрої, якщо device key slot збережений.

### Portable recovery backup
Encrypted vault + recovery-wrapped DEK. Такий backup може зберігатися поза пристроєм, але для restore потрібний recovery secret.

Правила:
- provider sync ≠ backup;
- перед destructive format migration створюється known-good encrypted backup/snapshot;
- backup/restore перевіряє authenticated decrypt **до** заміни активного vault;
- restore ніколи не переписує єдину відому робочу копію до повної validation;
- UI показує vault id, revision/backup timestamp і джерело restore до підтвердження;
- якщо recovery не налаштовано, UI прямо повідомляє: втрата OS key/device може означати незворотну втрату vault;
- recovery material не можна включати в diagnostics, clipboard history автоматично або crash report.

## 7. Rollback, corruption and atomic writes

AEAD захищає від tampering, але старий валідний ciphertext теж пройде authentication. Тому:

- payload містить monotonically increasing logical `revision`;
- device secure storage пам'ятає last-seen vault id + highest accepted revision/hash marker;
- нижча revision на тому самому пристрої → explicit rollback warning; автоматично не приймати як current;
- на новому/recovered device абсолютну «найновішу» копію довести неможливо без зовнішнього trusted state; UI показує revision/time і вимагає явного restore;
- write flow: new temp file → flush → authenticated read-back/validation → atomic replace/rename where platform semantics allow;
- попередня known-good encrypted copy зберігається до завершення нового write/migration;
- sync conflict не auto-mergиться на рівні ciphertext;
- дві divergent valid revisions = conflict, який потребує явного вибору/майбутнього record-level merge design.

## 8. Lock / auto-lock / memory behavior

Vault має стани **locked / unlocking / unlocked / locking / error**.

Обов'язково:
- manual Lock;
- lock при sign-out/disable private mode;
- auto-lock після configurable inactivity;
- auto-lock при app background/suspend після короткого configurable grace period;
- при поверненні з background приватний UI не рендериться до unlock;
- clipboard/export/preview не повинні переживати lock автоматично;
- після lock застосунок втрачає посилання на decrypted model та DEK/wrapping material якнайшвидше.

Dart/Flutter GC не дає гарантії фізичного zeroization усіх копій у пам'яті. Тому UI/documentation **не обіцяє guaranteed memory wiping**; реалізація мінімізує lifetime секретів і не кешує plaintext без потреби.

## 9. Delete semantics

«Видалити локальний vault» означає:
- закрити/lock vault;
- видалити local active encrypted file, де це можливо;
- видалити device key slot / wrapped-key references;
- видалити локальні app-owned metadata, потрібні для unlock;
- не видаляти external backups без окремої явної дії.

Не можна обіцяти secure erase фізичних блоків SSD/flash, cloud version history або provider snapshots.

## 10. Legacy plaintext migration

Migration з поточних `sets/*.json` виконується лише після реалізації й тестів vault.

Contract:
1. знайти legacy private-capable records;
2. показати, що вони зараз plaintext;
3. **copy/import** у vault;
4. read-back + schema validation + authenticated decrypt;
5. порівняти semantic record count/ids;
6. лише після успіху запропонувати користувачу окремо видалити legacy plaintext;
7. оригінал автоматично не видаляти й не переписувати;
8. crash/cancel посеред migration не повинен залишити «напівмігрований» стан, який UI назве завершеним.

До завершення цього процесу status має бути на кшталт **«Vault увімкнено; legacy plaintext data ще існують»**, а не просто «Encrypted».

## 11. Platform secure-storage matrix

| Platform | Device-key requirement | External-file access | Gate for implementation |
|---|---|---|---|
| Windows | current-user OS-protected secret/key storage; DPAPI-compatible design. Не використовувати machine-wide scope для user vault і не залежати від deprecated prompt flow | normal user-selected filesystem path | verify exact Flutter/native bridge, uninstall/profile-loss semantics, test locked-user behavior |
| macOS | Keychain, non-synchronizing device/app-local item; access control reviewed separately | App Sandbox user-selected access + persistent security-scoped bookmark when needed | verify entitlements, Keychain accessibility, bookmark stale/renew flow |
| iOS | Keychain, non-synchronizing device-local item; user-presence policy reviewed separately | document picker / security-scoped URL where applicable | verify accessibility class, reinstall/key loss, background lock and file-provider behavior |
| Android | Android Keystore-backed non-exportable key/wrapping key | Storage Access Framework (persisted URI permission) for external/provider files | verify API-level support, auth invalidation, backup flags, SAF persistable permissions |

### Official platform evidence used by this review

- Microsoft DPAPI / `CryptProtectData`: https://learn.microsoft.com/en-us/windows/win32/api/dpapi/nf-dpapi-cryptprotectdata
- Microsoft Windows data protection: https://learn.microsoft.com/windows/uwp/security/data-protection
- Apple Keychain Services: https://developer.apple.com/documentation/security/keychain-services
- Apple storing keys in Keychain: https://developer.apple.com/documentation/security/storing-keys-in-the-keychain
- Apple security-scoped file access: https://developer.apple.com/documentation/security/accessing-files-from-the-macos-app-sandbox
- Android Keystore: https://developer.android.com/privacy-and-security/keystore
- Android Storage Access Framework: https://developer.android.com/training/data-storage/shared/documents-files

Ці джерела підтверджують platform primitive/capability. Вони **не** затверджують конкретний Flutter plugin.

## 12. Logging, telemetry and diagnostics

Заборонено:
- log DEK/KEK/recovery secret;
- log decrypted payload/notes/holdings;
- додавати private vault file у CI fixture/release/source artifact;
- crash report з plaintext private state;
- analytics/session replay для vault UI.

Допустимі diagnostics повинні містити лише redacted technical error code, envelope version, platform і non-secret state.

## 13. Dependency/security review gate

Після цього design checkpoint наступний slice **не починає одразу feature UI**.

Спочатку окремо перевіряються candidate dependencies:
- maintenance/release cadence;
- license compatibility;
- known security advisories;
- audited/standard primitive use;
- Windows implementation (не «fallback plaintext»);
- Keychain/Keystore semantics;
- biometric/auth invalidation behavior;
- backup/synchronization flags;
- Flutter desktop/mobile support;
- testability без live secrets.

Якщо один plugin не забезпечує однакові security properties на всіх 4 платформах, допускається platform-specific adapter. **Не допускається** weakest-common-denominator fallback, який робить одну платформу plaintext.

## 14. Acceptance tests required before feature is called encrypted

Мінімальний security regression suite:

- wrong/corrupted ciphertext fails closed;
- modified envelope/AAD fails authentication;
- unknown envelope version/algorithm fails closed;
- no duplicate nonce in deterministic stress fixture / writer contract;
- device key missing → clear locked/recovery state, not reset;
- recovery restore on fresh profile/device fixture;
- rollback warning on lower known revision;
- interrupted write keeps previous known-good vault;
- legacy migration copies + verifies before any delete offer;
- lock/background removes private UI state;
- plaintext export requires explicit action/warning;
- repository/release artifact scan contains no test keys/recovery secrets/private fixtures;
- Windows/macOS/iOS/Android platform adapter tests for key create/read/delete/invalidation.

## 15. Approved decisions vs deferred implementation choices

### Approved / frozen by this checkpoint

- precise private-data boundary above;
- legacy `sets/*.json` are not encrypted;
- random per-vault 256-bit DEK;
- authenticated versioned envelope;
- device OS-backed key protection;
- optional separate recovery-wrapped DEK;
- memory-hard KDF requirement for portable recovery;
- no short PIN as root/recovery key;
- explicit plaintext-export boundary;
- rollback warning model;
- non-destructive legacy migration;
- manual + inactivity/background lock;
- no secure-erase or perfect-memory-zeroization claims;
- fail closed for unknown/corrupt crypto format.

### Deferred to the next dependency/security review

- exact AEAD algorithm/library;
- exact recovery KDF and parameters;
- exact Flutter secure-storage/plugin stack;
- biometric/user-presence defaults;
- default inactivity/grace durations;
- vault payload record schema beyond the boundary/invariants above;
- record-level conflict merge across synced devices.

No crypto/plugin implementation is approved until that dependency review is recorded.

Dependency/security review proposal: `docs/security-vault-dependency-review.md`. It must pass the normal PR/exact-head verification and be merged before its package/algorithm choices are treated as approved implementation inputs.
