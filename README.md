# OVDP Hub

**🇺🇦 Українська** · [🇬🇧 English](docs/readme/README.en.md) · [🇫🇷 Français](docs/readme/README.fr.md) · [🇩🇪 Deutsch](docs/readme/README.de.md) · [🇪🇸 Español](docs/readme/README.es.md) · [🇰🇷 한국어](docs/readme/README.ko.md) · [🇯🇵 日本語](docs/readme/README.ja.md)

> **Фінальний checkpoint поточного етапу: [OVDP Hub v0.9.4](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.9.4) — 0.9.4+21**
>
> **Статус розвитку: PARKED / завершено на поточному рівні. Активної розробки немає.**
>
> **Завантаження:** [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-START.zip) · [SHA-256](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/SHA256SUMS.txt)

## Про продукт

**OVDP Hub** — local-first Flutter/Dart-застосунок для роботи з українськими ОВДП: каталог і джерела ринку, сценарне планування, порівняння варіантів та власний зашифрований фактичний портфель.

Підтримувані test/checkpoint платформи: **Windows, macOS, Android та iOS unsigned**. Активний продукт знаходиться в `apps/native`.

## Що входить у v0.9.4

- каталог ОВДП на базі публічних даних НБУ;
- картка ISIN з окремими шарами **НБУ / Мінфін / продавці**, provenance і freshness;
- календар і результати аукціонів Мінфіну;
- кілька спостережень ціни та явний пріоритет джерел;
- Planner: budget/reserve/horizon, fees, tax, FX, recurring/one-off needs, reserve floor, per-position early exit;
- нейтральне порівняння **A/B/C** без automatic winner;
- deterministic CSV/ICS exports;
- **Економічний пульс**;
- **Мій портфель**: local encrypted vault, factual purchase/sale/coupon/redemption, explicit lot allocation, per-ISIN ledger і closed positions;
- factual per-currency cash summary, де unknown fees не підміняються нулем;
- non-destructive legacy migration;
- recovery secret confirmation/rotation;
- Windows portable encrypted backup/restore;
- macOS Keychain-backed encrypted Portfolio з real packaged lifecycle smoke;
- Android SAF + iOS security-scoped external-storage foundation;
- mobile external workspace / encrypted backup transport з fail-closed semantics;
- двоетапна mobile storage self-test панель через terminate/relaunch;
- UI UK / EN / FR / DE / ES / KO / JA;
- Classic / Workbench / Light Dashboard;
- persistence мови та appearance.

## Важливо про розрахунки

OVDP Hub не виконує операції купівлі/продажу і не є брокером. Номінал, yield, котирування та припущення не підміняють фактичну ціну угоди.

Фактичний cash summary портфеля **не включає поточну ринкову вартість відкритих позицій** і тому не є market valuation або performance metric. Якщо релевантна комісія невідома, exact net-result не показується.

## Встановлення

### Windows
1. Завантажте `OVDP-Hub-0.9.4-Windows-x64.zip`.
2. Розпакуйте весь ZIP.
3. Запустіть `ovdp_hub.exe` з розпакованої папки.
4. Checkpoint не має production code signing, тому Windows може показати SmartScreen.

### macOS
1. Завантажте й розпакуйте `OVDP-Hub-0.9.4-macOS.zip`.
2. Відкрийте `ovdp_hub.app`.
3. Checkpoint не notarized; macOS може вимагати підтвердження запуску через **System Settings → Privacy & Security → Open Anyway**.

### Android
Розпакуйте Android ZIP і встановіть `OVDP-Hub.apk`. Це test-build із development signing, не Play Store release.

### iOS
Пакет **unsigned**. Він є compile/checkpoint artifact і потребує окремого Apple signing/provisioning для встановлення на iPhone. Підписана development-збірка на цьому етапі свідомо відкладена.

### START/source
Потрібен Flutter **3.47.5** та build tools відповідної ОС. Windows: `START.bat`; macOS: `START.command`.

## Перевірка v0.9.4

Release pipeline #113 пройшов:
- `flutter analyze`;
- **218/218 tests**;
- Windows/macOS release build + exact packaged ZIP smoke;
- Android release test APK package;
- unsigned iOS release package;
- START/source;
- `SHA256SUMS.txt` та legal notices;
- publish GitHub prerelease/tag `v0.9.4`.

## Межі parked checkpoint

Свідомо відкладено й **не є активним NEXT**:
- Android physical-device SAF persistence/revoke/provider-loss validation;
- iOS development signing + physical-device runtime validation;
- Windows production signing;
- macOS notarization;
- Android/iOS store distribution;
- installers / auto-update.

Це означає: mobile foundation реалізований і пройшов regression/compile gates, але невиконані physical-device сценарії не називаються `RUNTIME VALIDATED`.

## Керівництво і документація

- [Українське керівництво](docs/user-guide/USER_GUIDE.uk.md)
- [Release notes v0.9.4](docs/releases/RELEASE_NOTES_v0_9_4.md)
- [Changelog](CHANGELOG.md)
- [Roadmap / parked scope](docs/roadmap.md)
- [START_HERE](START_HERE.md)
- [PROJECT_STATE](PROJECT_STATE.md)
- [WORKLOG](WORKLOG.md)

## Дані та приватність

OVDP Hub працює local-first: приватний портфель не надсилається на центральний сервер OVDP Hub. Legacy workspace-файли можуть залишатися plaintext; migration wizard не видаляє source JSON автоматично.

Перед перенесенням або перевстановленням робіть резервні копії workspace та encrypted Portfolio backup, якщо відповідний backup-flow доступний на вашій платформі.

## Авторські права

**Copyright © 2026 Roman Zavada (Роман Завада). All rights reserved.**

OVDP Hub — **proprietary software**. Публічний репозиторій не надає open-source ліцензії чи дозволу на копіювання, модифікацію, перепублікацію, продаж або створення похідних продуктів без письмового дозволу правовласника.

Див. [LICENSE.md](LICENSE.md), [COPYRIGHT.md](COPYRIGHT.md), [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md), [LEGAL_AND_COPYRIGHT.md](docs/LEGAL_AND_COPYRIGHT.md).
