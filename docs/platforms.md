# Платформи

Єдиний активний продукт — Flutter/Dart у `apps/native`. Web/PWA виключено.

| Платформа | Поточний prerelease-пакет | Статус |
|---|---|---|
| Windows | `OVDP-Hub-<version>-Windows-x64.zip` | test build, без production code signing |
| macOS | `OVDP-Hub-<version>-macOS.zip` | test build, без signing/notarization |
| Android | `OVDP-Hub-<version>-Android-test.zip` | APK + notices, development signing |
| iOS | `OVDP-Hub-<version>-iOS-unsigned.zip` | unsigned app package |
| START | `OVDP-Hub-<version>-START.zip` | source-based test package |

Спільні модель даних, UI-компоненти, розрахунки та формат робочої папки. Платформні функції й поширення перевіряються окремо.

Desktop: робоча папка може бути на локальному/підключеному мережевому диску або у синхронізованій хмарним клієнтом папці. Mobile: внутрішня папка; постійний зовнішній доступ через SAF/bookmarks ще не реалізований.

## CI і prerelease

`.github/workflows/native.yml` виконує звичайні checks та START-пакування. На checkpoint можна вручну попросити Windows/macOS/Android/iOS builds.

`.github/workflows/release.yml` є формальним prerelease pipeline. Для поточної версії з `apps/native/pubspec.yaml` він:

1. перевіряє наявність `docs/releases/RELEASE_NOTES_vX_Y_Z.md`;
2. не перепубліковує вже існуючий GitHub Release;
3. виконує `flutter pub get --enforce-lockfile`, `flutter analyze`, `flutter test`;
4. збирає START, Windows, macOS, Android та iOS;
5. додає legal notices;
6. рахує SHA-256 для всіх release assets;
7. створює незмінний tag `vX.Y.Z` і GitHub prerelease.

Після публікації tag/release не пересуваються та не переписуються.

## Signing

Поточна лінія 0.x є тестовою:

- Windows — без production Authenticode signing;
- macOS — без Apple signing/notarization;
- Android — використовує поточну development signing configuration;
- iOS — збирається з `--no-codesign`.

Production/store distribution потребує окремого налаштування ключів, сертифікатів, notarization і store metadata. Ключі підпису не повинні зберігатися у Git.

Попередні Next.js/Expo/Tauri клієнти після завершення міграції вилучені з активного дерева; історія доступна через Git.
