# OVDP Hub

**🇺🇦 Українська** · [🇬🇧 English](docs/readme/README.en.md) · [🇫🇷 Français](docs/readme/README.fr.md) · [🇩🇪 Deutsch](docs/readme/README.de.md) · [🇪🇸 Español](docs/readme/README.es.md) · [🇰🇷 한국어](docs/readme/README.ko.md) · [🇯🇵 日本語](docs/readme/README.ja.md)

> **Current published prerelease / Поточний опублікований prerelease: [OVDP Hub v0.9.2](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.9.2) (0.9.2+19)**
>
> Downloads / Завантаження: [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.2/OVDP-Hub-0.9.2-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.2/OVDP-Hub-0.9.2-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.2/OVDP-Hub-0.9.2-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.2/OVDP-Hub-0.9.2-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.2/OVDP-Hub-0.9.2-START.zip) · [SHA-256](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.2/SHA256SUMS.txt)

---

### Що це

**OVDP Hub** — встановлюваний Flutter/Dart-застосунок для огляду українських ОВДП, ринкових джерел та власних інвестиційних сценаріїв. Цільові платформи: **Windows, macOS, Android, iOS**. Web/PWA не входить до активного продукту.

Активний код: `apps/native`. Поточний опублікований checkpoint — **0.9.2+19**. Він включає «Світлу панель», Planner reserve floor, deterministic CSV/ICS exports, encrypted-vault/private-portfolio foundation, а також нові user-facing **«Економічний пульс»** і **«Мій портфель»** з першою фактичною encrypted purchase/holdings flow. Legacy migration wizard ще не підключено.

### Що вже працює

- локальний каталог ОВДП на базі публічних даних НБУ;
- пошук, фільтри, графіки виплат і порівняння випусків;
- окремі шари даних **НБУ / Мінфін / продавці** з provenance, source date, retrieved time та freshness/status;
- структурований календар аукціонів Мінфіну та детальні результати placement/switch аукціонів;
- кілька джерел ціни з явним пріоритетом користувача;
- планувальник бюджету, резерву, строків і майбутніх витрат;
- явні purchase-fee assumptions: невідома комісія не прирівнюється до нуля;
- перевірений податковий профіль для фізособи-резидента України / ОВДП / 2026 з чітким розрізненням **unknown** та **verified zero**;
- явне FX-порівняння з ручним курсом, датою та URL джерела без змішування валют у базовому cashflow;
- достроковий продаж по кожній позиції з власною датою та BID/ручною exit-ціною;
- основна майбутня потреба може бути регулярною; повторення зберігається як typed правило, додаткові потреби — як окремі one-off записи;
- нейтральне порівняння **A/B/C** для 2–3 збережених сценаріїв із strict comparability та без автоматичного «кращого» варіанта;
- reserve floor / мінімальний залишок як typed правило: з указаної дати сума має лишатися ліквідною й не вважається витратою;
- локальні deterministic CSV/ICS exports із Planner scenario/needs/coverage/cashflow у папку `exports/` активного workspace; PDF відкладено до стабілізації звіту;
- generated Planner copy / preset labels зберігаються як stable IDs і локалізуються при показі; власні назви користувача лишаються literal;
- постійний **«Економічний пульс»** з NBU FX і MinFin auction indicators, source/date та fail-closed unavailable state;
- **«Мій портфель»**: локальний encrypted portfolio, create/open/lock, factual purchase та derived holdings;
- збереження сценаріїв у переносній робочій папці JSON;
- активний UI та основні user-facing помилки локалізовані **UK / EN / FR / DE / ES / KO / JA**.

Номінальна ставка не вважається ринковою дохідністю, yield-only не стає ціною автоматично, а невідомі комісії, податки чи FX не підміняються нулем.

### Планувальник

Планувальник працює в одній валюті сценарію та підтримує режими розподілу за строками, максимізації розрахункового прибутку й покриття майбутніх витрат. Повну ціну та кількість можна редагувати вручну. Підтримуються додаткові витрати, резерв, затримка зарахування і збереження сценарію.

Розвиток після опублікованого 0.9.0:

1. **DONE** — явний пріоритет джерел ціни;
2. **DONE** — purchase-fee assumptions;
3. **DONE** — verified tax assumptions;
4. **DONE** — FX assumptions;
5. **DONE** — exit assumptions;
6. **DONE** — neutral A/B/C comparison;
7. **DONE** — generated Planner copy / preset-label localization + regression;
8. **DONE** — v0.9.0 prerelease checkpoint;
9. **DONE** — reserve floor / мінімальний залишок;
10. **DONE** — локальні deterministic CSV/ICS exports; PDF deferred;
11. **DONE** — encrypted-vault threat model + audited crypto/device-key stack;
12. **DONE** — atomic encrypted local vault, recovery/backup, rollback detection і session locking;
13. **DONE** — recovery lifecycle + non-destructive local delete controls;
14. **DONE** — private portfolio factual domain: acquisitions/cash events/disposals + explicit lot allocation;
15. **DONE** — non-destructive legacy plaintext migration core / private payload schema v3;
16. **DONE** — v0.9.1+18 full prerelease checkpoint;
17. **DONE** — persistent «Економічний пульс» + first encrypted «Мій портфель» flow у v0.9.2+19;
18. **NEXT** — factual sale/redemption/history + explicit legacy migration wizard; mobile external-folder permissions deferred.

OVDP Hub не виконує купівлю чи продаж і не підтверджує доступність інструмента у продавця.

### Дані та приватність

Каталоги й сценарії зберігаються на пристрої. На desktop можна відкрити або скопіювати робочу папку. OVDP Hub не має сервера приватних портфельних даних.

У v0.9.2 уже є перевірена внутрішня encrypted-vault foundation (authenticated encryption, platform device keys, recovery/backup, rollback/session lifecycle) і non-destructive migration core. **Але поточні legacy `sets/*.json` у звичайному workspace все ще plaintext, доки user-facing migration/vault flow не буде окремо підключено.** Migration core не має delete API й не видаляє source JSON автоматично. Не використовуйте legacy workspace для ключів підпису, KYC-документів чи інших секретів.

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
