# Нативний клієнт ОВДП Hub

Flutter 3.47.5 / Dart 3.13.4. Деталі продукту, сховища, ліцензії та актуального checkpoint — у кореневих `README.md`, `PROJECT_RULES.md` і `PROJECT_STATE.md`.

```sh
flutter pub get --enforce-lockfile
flutter analyze
flutter test
flutter build windows --release
```

Користувач запускає готовий застосунок без SDK та сервера. Windows-поширення повинно містити весь release-каталог із DLL і ресурсами, а не лише exe.

Поточний GitHub prerelease pipeline формує START, Windows, macOS, Android та unsigned iOS packages, додає legal notices і SHA-256 manifest.

macOS наразі орієнтований на пряме тестове поширення поза Mac App Store (без sandbox/signing/notarization). Android використовує development signing configuration. iOS-пакет непідписаний. Для store/production distribution потрібен окремий signing setup.

**Copyright © 2026 Roman Zavada (Роман Завада). All rights reserved.** OVDP Hub є proprietary software; див. кореневий `LICENSE.md`.


## Оновлення початкового каталогу НБУ

З каталогу `apps/native` виконайте `dart run tool/refresh_nbu.dart`, перегляньте diff `assets/nbu-snapshot.json` і лише після перевірки комітьте snapshot.

## Мови

Основна мова — українська. Оболонка має вибір Українська / English / Français / Deutsch / Español / 한국어 / 日本語. Повний переклад функціональних модулів розширюється поетапно; український текст є еталоном змісту.

## Приватність і encrypted-vault foundation у 0.9.1

У кодовій базі є перевірена encrypted-vault foundation: XChaCha20-Poly1305 envelope, Argon2id recovery, platform device-key adapters, atomic local vault store, encrypted backup/restore, rollback detection, session locking, recovery lifecycle та private payload schema v3.

Non-destructive migration core для legacy `sets/*.json` також інтегрований, але **user-facing migration/vault UI ще не підключено**. Поточні legacy workspace JSON не стають автоматично зашифрованими після оновлення. Migration core не видаляє source JSON і не синтезує acquisition/holding facts із SavedSet.

Наступний platform slice після v0.9.1 — Android SAF / iOS security-scoped access для зовнішніх папок; production signing та user-facing vault unlock/migration залишаються окремими gates.
