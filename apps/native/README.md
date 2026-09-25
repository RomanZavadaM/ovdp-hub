# Нативний клієнт OVDP Hub

Flutter 3.47.5 / Dart 3.13.4. Активний тестовий checkpoint: **v0.9.3 / 0.9.3+20**.

Базові перевірки:

```sh
flutter pub get --enforce-lockfile
flutter analyze
flutter test
flutter build windows --release
```

Готовий desktop-застосунок не потребує SDK або сервера. Windows package повинен містити весь release-каталог із DLL і ресурсами, а не лише EXE.

Release pipeline формує:
- Windows x64 ZIP;
- macOS ZIP;
- Android test ZIP;
- unsigned iOS ZIP;
- START/source ZIP;
- legal notices та `SHA256SUMS.txt`.

Windows/macOS release jobs обов’язково розпаковують **саме створений release ZIP**, запускають packaged executable та звіряють product/version/build/appearance contract перед публікацією.

## Distribution status

- Windows: test prerelease без production code-signing.
- macOS: пряме тестове поширення, без production signing/notarization.
- Android: development signing configuration.
- iOS: unsigned package, потребує окремого Apple signing/provisioning.

## Дані та encrypted portfolio

v0.9.3 включає user-facing encrypted portfolio:
- create/open/lock;
- factual acquisition;
- explicit sale/disposal lot allocation;
- factual coupon/redemption;
- per-ISIN ledger;
- closed positions;
- factual per-currency cash summary;
- explicit unknown-fee semantics;
- non-destructive legacy migration wizard із encrypted-copy verification.

Поточна market value відкритих позицій не додається до factual cash summary. Unknown acquisition/disposal fee не перетворюється на zero.

Legacy workspace JSON може залишатися plaintext. Migration wizard не має автоматичного delete source JSON.

## Оновлення каталогу НБУ

З `apps/native` виконайте:

```sh
dart run tool/refresh_nbu.dart
```

Після цього перевірте diff `assets/nbu-snapshot.json` і лише тоді комітьте snapshot.

## Локалізація

Основна мова — українська. User-facing UI підтримує Українська / English / Français / Deutsch / Español / 한국어 / 日本語.

## Документація

- кореневий `README.md` — продуктова сторінка;
- `docs/user-guide/` — user manuals сімома мовами;
- `docs/releases/RELEASE_NOTES_v0_9_3.md` — release notes;
- `START_HERE.md`, `PROJECT_STATE.md`, `WORKLOG.md` — канонічний стан розробки.

**Copyright © 2026 Roman Zavada (Роман Завада). All rights reserved.** OVDP Hub є proprietary software; див. кореневий `LICENSE.md`.
