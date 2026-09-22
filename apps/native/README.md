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
