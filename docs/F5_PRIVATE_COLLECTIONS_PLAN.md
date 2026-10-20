# F5 — приватні назви й нотатки collections

Статус: підготовлений наступний slice, **код F5 ще не реалізовано**. Основа — F1–F4 та F6, tracker #147. Точний main/branch/run див. WORKLOG і останній запис Issue #18.

## Проблема й межа даних

Зараз CollectionEditorCubit записує довільні name/note разом із публічними bond snapshots у JSON workspace. Водночас security design відносить приватні нотатки до даних vault. Саме попередження про plaintext не виправляє зберігання приватної нотатки.

Робоче рішення: власні назви й нотатки нової collection зберігати у vault за замовчуванням. Публічний список ISIN може залишатися у workspace без довільних приватних annotations; для нього використовувати generated display name. Не вводити виняток «приватні нотатки дозволено зберігати plaintext». Наявні legacy JSON не видаляти й не переписувати мовчки.

## Послідовність реалізації

1. **Окремий encrypted record.** Додати PrivateCollectionRecord для SavedSet без Planner scenario; зберігати повний набір name/note/bonds. Не послаблювати PrivateScenarioRecord і не маскувати нові записи як legacy migration metadata.
2. **Сумісність.** Payload schema v5 з окремим privateCollections; читання v1–v4 зберегти. Перевірити strict field validation, ліміти, round-trip, existing scenarios/factual records. Старі файли не перетворювати до явного save. Криптографію, KDF і recovery slots не змінювати.
3. **Editor і save.** Підключити PortfolioCubit; private title/note доступні після unlock, save йде лише через vault. Public ISIN list не приймає довільні name/note. Невдалий save зберігає доступний draft. Після lock private draft і transient UI очищуються; публічний draft не зникає. Не починати асинхронне збереження, якщо потрібний vault уже locked.
4. **Collections і reopen.** Об’єднати public workspace lists і private vault collections з чітким походженням. Private collection відкривається в editor, а Planner scenario — у Planner. Variant не повинен перетворювати private note на plaintext. Перевірити всі дії з назвою/нотаткою, clipboard/export/import і transient detail views.
5. **Legacy move.** Дати явну дію перенесення повної collection. Перед видаленням source JSON — canonical content comparison повної decrypted copy та перевірка початкового workspace/record, за правилами F1/F2. Конфлікт, lock, switch workspace або помилка лишають source недоторканим. Metadata-only legacy migration не вважати підтвердженням повної копії.
6. **Пояснення.** Позначити наявні plaintext annotations як legacy; показувати їх фактичне розташування й доступну дію перенесення. Український текст і переклади EN/FR/DE/ES/KO/JA. Узгодити security/payload/architecture docs і release contract, не переписувати історичні release notes.

## Докази завершення

- Real filesystem test: private name/note відсутні в усіх workspace JSON; після lock не залишаються у станах і доступному UI; після unlock/reopen відновлюються з vault.
- v1–v4 compatibility та v5 round-trip; factual portfolio і private Planner scenarios зберігаються без втрат.
- Public ISIN list не містить довільних annotations; public flow працює без vault.
- Save failure/retry, manual/background/inactivity lock, stale completion і private variant не створюють plaintext копії.
- Explicit move: правильна encrypted copy, конфлікт того самого ID з іншим вмістом, workspace A→B, locked vault, невдале source delete. Перевіряти фактичні файли.
- Реальні UI controls, narrow/desktop layout; analyze + усі tests; Windows/macOS exact ZIP smoke та Android/iOS build gates. Physical-device runtime не підміняти CI compile evidence.

Окрема branch/PR; DONE лише після зелених exact-head gates і merge. Публікація релізу — за PROJECT_RULES.
