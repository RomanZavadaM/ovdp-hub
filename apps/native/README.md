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

## Приватність і encrypted portfolio у 0.9.3

У кодовій базі є перевірена encrypted-vault foundation: XChaCha20-Poly1305 envelope, Argon2id recovery, platform device-key adapters, atomic local vault store, encrypted backup/restore, rollback detection, session locking, recovery lifecycle та private payload schema v3.

У v0.9.3 user-facing encrypted portfolio охоплює factual purchase/sale/redemption/coupon, per-ISIN ledger, closed positions, factual cash summary та explicit non-destructive migration wizard. Legacy `sets/*.json` не переписуються і не видаляються автоматично; migration запускається лише явною дією користувача.

Desktop release gate перевіряє exact packaged Windows/macOS ZIP: розпаковує його, запускає packaged executable і звіряє version/build та три appearance. Android SAF / iOS security-scoped external-folder access відкладено до mobile storage gate.
