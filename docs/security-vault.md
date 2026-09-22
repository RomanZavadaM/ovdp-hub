# Encrypted vault: threat model і вимоги

Статус: дизайн до реалізації.

## Навіщо окремий vault

Поточний workspace містить відкриті JSON добірок і сценаріїв. Для фактичного портфеля, acquisition lots, приватних нотаток або інших чутливих даних цього недостатньо.

## Загрози

- викрадення копії файлів або backup;
- втрачений/вкрадений пристрій у заблокованому стані;
- випадкове потрапляння workspace до чужої хмарної папки;
- пошкодження або часткова синхронізація;
- rollback на старішу копію;
- витік секретів у лог, CI, release package або репозиторій.

Vault не може захистити від повністю скомпрометованої розблокованої ОС або шкідливо модифікованого застосунку.

## Криптографічні правила

- не реалізовувати криптографічні примітиви самостійно;
- використовувати аудитовану бібліотеку та authenticated encryption;
- ключ даних генерується випадково і не походить напряму з PIN;
- platform secure storage захищає локальний ключовий матеріал;
- backup має окремий recovery design; синхронізація файлу не є backup strategy;
- формат файлу має version, algorithm identifiers, nonce/salt/KDF parameters і контроль цілісності;
- міграції формату не виконуються руйнівно без резервної копії.

## Платформи

Перед реалізацією перевіряються:

- Windows — OS-protected credential/key storage;
- macOS/iOS — Keychain;
- Android — Keystore-backed secure storage;
- Android зовнішні папки — SAF;
- iOS зовнішні файли — security-scoped access/bookmarks.

Конкретний Flutter plugin обирається після окремого dependency/security review.

## UX

Потрібні lock/unlock, auto-lock, recovery/export, видалення локального vault, явне попередження про втрату recovery material і статус останнього успішного backup. Не показувати «зашифровано», якщо частина приватних записів лишається plaintext поза vault.
