# OVDP Hub

**🇺🇦 Українська** · [🇬🇧 English](docs/readme/README.en.md) · [🇫🇷 Français](docs/readme/README.fr.md) · [🇩🇪 Deutsch](docs/readme/README.de.md) · [🇪🇸 Español](docs/readme/README.es.md) · [🇰🇷 한국어](docs/readme/README.ko.md) · [🇯🇵 日本語](docs/readme/README.ja.md)

> **Поточний тестовий prerelease: [OVDP Hub v0.9.3](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.9.3) — 0.9.3+20**
>
> **Завантаження:** [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-START.zip) · [SHA-256](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/SHA256SUMS.txt)

## Про продукт

**OVDP Hub** — локальний Flutter/Dart-застосунок для роботи з українськими ОВДП: каталог і джерела ринку, сценарне планування, порівняння варіантів та власний зашифрований фактичний портфель.

Підтримувані тестові платформи: **Windows, macOS, Android та iOS**. Активний продукт знаходиться в `apps/native`; старі web-прототипи не є актуальною продуктовою лінією.

## Основні можливості v0.9.3

- каталог ОВДП на базі публічних даних НБУ;
- картка ISIN з окремими шарами **НБУ / Мінфін / продавці**, датою, джерелом і freshness/status;
- календар і структуровані результати аукціонів Мінфіну;
- кілька спостережень ціни та явний пріоритет джерел;
- планувальник бюджету, резерву, строків, потреб і cashflow;
- явні припущення щодо комісій, податків, FX та дострокового продажу;
- нейтральне порівняння **A/B/C** без автоматичного «кращого» варіанта;
- reserve floor / мінімальний ліквідний залишок;
- deterministic CSV/ICS exports;
- постійний **«Економічний пульс»**;
- **«Мій портфель»**: локальне encrypted-сховище, purchase/sale/coupon/redemption, історія та ledger по ISIN;
- закриті позиції залишаються доступними в історії;
- фактичний грошовий підсумок по валюті з окремими купівлями, продажами, купонами, погашеннями та відомими комісіями;
- невідомі комісії не підміняються нулем;
- explicit non-destructive legacy migration wizard з перевіркою зашифрованої копії;
- UI та user-facing повідомлення: **UK / EN / FR / DE / ES / KO / JA**;
- три оформлення: Classic, «Робочий кабінет» і «Світла панель».

## Важливо про розрахунки

OVDP Hub не виконує операції купівлі/продажу і не є брокером. Номінал, yield, котирування та припущення не підміняють фактичну ціну угоди.

Фактичний грошовий підсумок портфеля **не включає поточну ринкову вартість відкритих позицій**, тому не є оцінкою портфеля чи показником інвестиційної дохідності. Якщо комісія невідома, точний net-result не показується.

## Встановлення

### Windows
1. Завантажте `OVDP-Hub-0.9.3-Windows-x64.zip`.
2. Розпакуйте **весь ZIP** у звичайну папку.
3. Запустіть `ovdp_hub.exe` із розпакованої папки. DLL і ресурси мають залишатися поруч.
4. Збірка тестова й поки без production code-signing, тому Windows може показати SmartScreen.

### macOS
1. Завантажте й розпакуйте `OVDP-Hub-0.9.3-macOS.zip`.
2. Відкрийте `ovdp_hub.app`.
3. Поточний prerelease не notarized/signing production-ready; macOS може вимагати підтвердження запуску через **System Settings → Privacy & Security → Open Anyway** після першої спроби.

### Android
Розпакуйте Android ZIP, встановіть `OVDP-Hub.apk` і, якщо система попросить, дозвольте встановлення застосунків із цього джерела. Це test-build із development signing, не Play Store release.

### iOS
Опублікований пакет **unsigned**. Він не є готовим App Store/Ad Hoc пакетом і потребує окремого Apple signing/provisioning для встановлення.

### START/source
START-пакет призначений для запуску з вихідного коду. Потрібні Flutter **3.47.5** та інструменти збірки відповідної ОС. У Windows використовуйте `START.bat`, у macOS — `START.command`.

## Керівництво користувача

Повне керівництво: **[Українською](docs/user-guide/USER_GUIDE.uk.md)**.

Інші мови: [English](docs/user-guide/USER_GUIDE.en.md) · [Français](docs/user-guide/USER_GUIDE.fr.md) · [Deutsch](docs/user-guide/USER_GUIDE.de.md) · [Español](docs/user-guide/USER_GUIDE.es.md) · [한국어](docs/user-guide/USER_GUIDE.ko.md) · [日本語](docs/user-guide/USER_GUIDE.ja.md).

## Дані, приватність і резервні копії

OVDP Hub працює local-first: приватний портфель не надсилається на центральний сервер OVDP Hub. Encrypted portfolio використовує локальне authenticated encryption, platform device keys, recovery/backup, rollback detection і session locking.

Legacy workspace-файли можуть залишатися plaintext. Migration wizard **не видаляє source JSON автоматично**. Після перевірки перенесення користувач сам вирішує, що робити зі старими файлами.

Перед оновленням або перенесенням на інший ПК/Mac зробіть резервну копію робочої папки й encrypted backup портфеля.

## Перевірка релізу

Release pipeline v0.9.3 пройшов:
- `flutter analyze` і повний `flutter test`;
- Windows/macOS release build;
- пакування ZIP;
- запуск executable **саме з розпакованого release ZIP** та перевірку version/build і contract;
- Android release test build;
- unsigned iOS build;
- START/source package;
- `SHA256SUMS.txt` та legal notices.

## Документація

- [Керівництва користувача](docs/user-guide/README.md)
- [Release notes v0.9.3](docs/releases/RELEASE_NOTES_v0_9_3.md)
- [Changelog](CHANGELOG.md)
- [Roadmap](docs/roadmap.md)
- [START_HERE — відновлення розробки](START_HERE.md)
- [PROJECT_STATE](PROJECT_STATE.md)
- [WORKLOG](WORKLOG.md)

## Авторські права

**Copyright © 2026 Roman Zavada (Роман Завада). All rights reserved.**

OVDP Hub — **proprietary software**. Публічний репозиторій не є open-source ліцензією й не надає дозволу на копіювання, модифікацію, перепублікацію, продаж або створення похідних продуктів без письмового дозволу правовласника.

Див. [LICENSE.md](LICENSE.md), [COPYRIGHT.md](COPYRIGHT.md), [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md), [LEGAL_AND_COPYRIGHT.md](docs/LEGAL_AND_COPYRIGHT.md).
