# OVDP Hub

**🇺🇦 Українська** · [🇬🇧 English](docs/readme/README.en.md) · [🇫🇷 Français](docs/readme/README.fr.md) · [🇩🇪 Deutsch](docs/readme/README.de.md) · [🇪🇸 Español](docs/readme/README.es.md) · [🇰🇷 한국어](docs/readme/README.ko.md) · [🇯🇵 日本語](docs/readme/README.ja.md)

> **Current published prerelease / Поточний опублікований prerelease: [OVDP Hub v0.8.7](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.8.7)**
>
> [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.8.7/OVDP-Hub-0.8.7-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.8.7/OVDP-Hub-0.8.7-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.8.7/OVDP-Hub-0.8.7-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.8.7/OVDP-Hub-0.8.7-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.8.7/OVDP-Hub-0.8.7-START.zip) · [SHA-256](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.8.7/SHA256SUMS.txt)

---

### Що це

**OVDP Hub** — встановлюваний Flutter/Dart-застосунок для огляду українських ОВДП, ринкових джерел та власних інвестиційних сценаріїв. Цільові платформи: **Windows, macOS, Android, iOS**. Web/PWA не входить до активного продукту.

Активний код: `apps/native`. Поточна велика ціль — **0.9.0 «Ринок»**.

### Що вже працює

- локальний каталог ОВДП на базі публічних даних НБУ;
- пошук, фільтри, графіки виплат і порівняння випусків;
- окремі шари даних **НБУ / Мінфін / продавці** з provenance, source date, retrieved time та freshness/status;
- структурований календар аукціонів Мінфіну та детальні результати placement/switch аукціонів;
- кілька джерел ціни з явним пріоритетом користувача;
- планувальник бюджету, резерву, строків і майбутніх витрат;
- явні purchase-fee assumptions: невідома комісія не прирівнюється до нуля;
- після v0.8.7 у `main` уже інтегровано перевірений податковий профіль для фізособи-резидента України / ОВДП / 2026 з чітким розрізненням **unknown** та **verified zero**;
- збереження сценаріїв у переносній робочій папці JSON;
- активний UI та основні user-facing помилки локалізовані **UK / EN / FR / DE / ES / KO / JA**.

Номінальна ставка не вважається ринковою дохідністю, yield-only не стає ціною автоматично, а невідомі комісії, податки чи FX не підміняються нулем.

### Планувальник

Планувальник працює в одній валюті сценарію та підтримує режими розподілу за строками, максимізації розрахункового прибутку й покриття майбутніх витрат. Повну ціну та кількість можна редагувати вручну. Підтримуються додаткові витрати, резерв, затримка зарахування і збереження сценарію.

Поточний напрямок до 0.9.0:

1. **DONE** — явний пріоритет джерел ціни;
2. **DONE** — purchase-fee assumptions;
3. **DONE** — verified tax assumptions;
4. **DONE** — FX assumptions;
5. **DONE** — exit assumptions;
6. **NEXT** — A/B/C comparison; далі UX/localization polish.

OVDP Hub не виконує купівлю чи продаж і не підтверджує доступність інструмента у продавця.

### Дані та приватність

Каталоги й сценарії зберігаються на пристрої. На desktop можна відкрити або скопіювати робочу папку. OVDP Hub не має сервера приватних портфельних даних.

Поточне JSON-сховище **не зашифроване**, тому воно не призначене для ключів підпису, KYC-документів чи секретів. Encrypted vault та platform secure storage — окремий майбутній етап.

### Швидке тестування

Звичайні зміни запускають `flutter analyze`, `flutter test` і START-пакування. START запускається через `START.bat` у Windows або `START.command` у macOS. Для першого запуску потрібен Flutter 3.47.5 та інструменти збірки відповідної ОС.

Формальний prerelease збирає Windows/macOS/Android/iOS, START/source, `SHA256SUMS.txt`, legal notices, незмінний tag і GitHub Release.

### Авторські права

**Copyright © 2026 Roman Zavada (Роман Завада). All rights reserved.**

OVDP Hub — **proprietary software**. Публічний репозиторій не надає open-source ліцензії та не означає дозволу на копіювання, модифікацію, перепублікацію, продаж або створення похідних версій.

Див. [LICENSE.md](LICENSE.md), [COPYRIGHT.md](COPYRIGHT.md), [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md), [LEGAL_AND_COPYRIGHT.md](docs/LEGAL_AND_COPYRIGHT.md).

### Для розробника

```sh
cd apps/native
flutter pub get
flutter analyze
flutter test
flutter build windows --release
```

Також підтримуються `flutter build macos --release`, `flutter build apk --release`, `flutter build ipa --release`.

Ключові файли стану: [START_HERE.md](START_HERE.md), [PROJECT_STATE.md](PROJECT_STATE.md), [PROJECT_RULES.md](PROJECT_RULES.md), [WORKLOG.md](WORKLOG.md), [CHANGELOG.md](CHANGELOG.md).

---

### Мови / Languages

**🇺🇦 Українська** · [🇬🇧 English](docs/readme/README.en.md) · [🇫🇷 Français](docs/readme/README.fr.md) · [🇩🇪 Deutsch](docs/readme/README.de.md) · [🇪🇸 Español](docs/readme/README.es.md) · [🇰🇷 한국어](docs/readme/README.ko.md) · [🇯🇵 日本語](docs/readme/README.ja.md)

> Інші мови винесені в окремі README-файли, щоб GitHub не показував усі переклади однією довгою сторінкою.
