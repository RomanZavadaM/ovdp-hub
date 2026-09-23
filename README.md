# OVDP Hub

**Українська · English · Français · Deutsch · Español · 한국어 · 日本語**

[Українська](#українська) · [English](#english) · [Français](#français) · [Deutsch](#deutsch) · [Español](#español) · [한국어](#한국어) · [日本語](#日本語)

> **Current published prerelease / Поточний опублікований prerelease: [OVDP Hub v0.8.7](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.8.7)**
>
> [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.8.7/OVDP-Hub-0.8.7-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.8.7/OVDP-Hub-0.8.7-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.8.7/OVDP-Hub-0.8.7-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.8.7/OVDP-Hub-0.8.7-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.8.7/OVDP-Hub-0.8.7-START.zip) · [SHA-256](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.8.7/SHA256SUMS.txt)

---

## Українська

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
5. **NEXT** — exit assumptions; далі A/B/C comparison і UX/localization polish.

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

## English

### What it is

**OVDP Hub** is an installable Flutter/Dart application for exploring Ukrainian government bonds (OVDP), market sources, and personal investment scenarios. Target platforms are **Windows, macOS, Android, and iOS**. Web/PWA is not part of the active product.

Active code: `apps/native`. The current major target is **0.9.0 “Market”**.

### What already works

- local OVDP catalog based on public NBU data;
- search, filters, payment schedules, and issue comparison;
- separate **NBU / Ministry of Finance / seller** data layers with provenance, source date, retrieval time, and freshness/status;
- structured Ministry of Finance auction calendars and detailed placement/switch auction results;
- multiple price sources with explicit user-controlled priority;
- planner for budget, reserve, maturity horizon, and future expenses;
- explicit purchase-fee assumptions: an unknown fee is never treated as zero;
- after v0.8.7, `main` also contains a verified 2026 Ukraine-resident OVDP tax profile with explicit **unknown** versus **verified zero** semantics;
- portable JSON workspace persistence;
- active UI and main user-facing errors localized for **UK / EN / FR / DE / ES / KO / JA**.

A nominal coupon is not treated as market yield, yield-only observations never become a price automatically, and unknown fees, taxes, or FX are never silently replaced with zero.

### Planner

The planner remains single-currency by design and supports maturity allocation, calculated-profit mode, and future-expense coverage. Quantity and full price can be edited manually. Additional expenses, reserve, settlement delay, and saved scenarios are supported.

Road to 0.9.0:

1. **DONE** — explicit price-source priority;
2. **DONE** — purchase-fee assumptions;
3. **DONE** — verified tax assumptions;
4. **DONE** — FX assumptions;
5. **NEXT** — exit assumptions; then A/B/C comparison and UX/localization polish.

OVDP Hub does not execute trades and does not confirm seller availability.

### Data and privacy

Catalogs and scenarios are stored on the device. Desktop users can open or copy a workspace folder. OVDP Hub does not operate a server for private portfolio data.

The current JSON workspace is **not encrypted**, so it is not intended for signing keys, KYC documents, or secrets. An encrypted vault and platform secure storage are planned as a separate stage.

### Quick testing

Normal changes run `flutter analyze`, `flutter test`, and START packaging. On Windows use `START.bat`; on macOS use `START.command`. The first local START run requires Flutter 3.47.5 and platform build tools.

A formal prerelease builds Windows/macOS/Android/iOS plus START/source, `SHA256SUMS.txt`, legal notices, an immutable tag, and a GitHub Release.

### Copyright and license

**Copyright © 2026 Roman Zavada. All rights reserved.**

OVDP Hub is **proprietary software**. Public repository visibility does not grant an open-source license or permission to copy, modify, republish, sell, redistribute, or create derivative versions.

See [LICENSE.md](LICENSE.md), [COPYRIGHT.md](COPYRIGHT.md), [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md), and [LEGAL_AND_COPYRIGHT.md](docs/LEGAL_AND_COPYRIGHT.md).

### Developer

```sh
cd apps/native
flutter pub get
flutter analyze
flutter test
flutter build windows --release
```

Other targets: `flutter build macos --release`, `flutter build apk --release`, `flutter build ipa --release`.

Project state entry points: [START_HERE.md](START_HERE.md), [PROJECT_STATE.md](PROJECT_STATE.md), [PROJECT_RULES.md](PROJECT_RULES.md), [WORKLOG.md](WORKLOG.md), [CHANGELOG.md](CHANGELOG.md).

---

## Français

### Présentation

**OVDP Hub** est une application Flutter/Dart installable pour consulter les obligations d’État ukrainiennes (OVDP), leurs sources de marché et créer des scénarios d’investissement personnels. Plateformes cibles : **Windows, macOS, Android et iOS**. Web/PWA ne fait pas partie du produit actif.

Code actif : `apps/native`. Objectif principal actuel : **0.9.0 « Marché »**.

### Fonctions disponibles

- catalogue local OVDP basé sur les données publiques de la NBU;
- recherche, filtres, calendriers de paiements et comparaison des émissions;
- couches distinctes **NBU / ministère des Finances / vendeurs** avec provenance, date de source, heure de récupération et état de fraîcheur;
- calendriers structurés des adjudications et résultats détaillés placement/switch;
- plusieurs sources de prix avec priorité explicite définie par l’utilisateur;
- planificateur de budget, réserve, échéances et dépenses futures;
- hypothèses explicites de frais d’achat : un frais inconnu n’est jamais considéré comme nul;
- après v0.8.7, `main` contient aussi un profil fiscal OVDP 2026 vérifié pour une personne physique résidente d’Ukraine, avec distinction explicite **inconnu / zéro vérifié**;
- sauvegarde portable des scénarios au format JSON;
- interface active et principales erreurs utilisateur localisées en **UK / EN / FR / DE / ES / KO / JA**.

Le coupon nominal n’est pas assimilé au rendement de marché, une observation « yield-only » ne devient jamais automatiquement un prix, et les frais, impôts ou FX inconnus ne sont jamais remplacés silencieusement par zéro.

### Planificateur

Le planificateur reste volontairement mono-devise. Il prend en charge la répartition par échéance, le mode de profit calculé et la couverture des dépenses futures. Quantité et prix total peuvent être modifiés manuellement.

Route vers 0.9.0 :

1. **DONE** — priorité explicite des sources de prix;
2. **DONE** — hypothèses de frais d’achat;
3. **DONE** — hypothèses fiscales vérifiées;
4. **DONE** — hypothèses FX;
5. **NEXT** — hypothèses de sortie; ensuite comparaison A/B/C et finition UX/localisation.

OVDP Hub n’exécute aucune transaction et ne confirme pas la disponibilité d’un instrument chez un vendeur.

### Données et confidentialité

Les catalogues et scénarios sont stockés sur l’appareil. Sur desktop, l’utilisateur peut ouvrir ou copier un dossier de travail. OVDP Hub ne dispose pas d’un serveur central de données privées de portefeuille.

Le stockage JSON actuel **n’est pas chiffré**. Il n’est donc pas destiné aux clés de signature, documents KYC ou secrets. Un coffre chiffré et le stockage sécurisé des plateformes constituent une étape ultérieure séparée.

### Test rapide

Les changements ordinaires exécutent `flutter analyze`, `flutter test` et génèrent un paquet START. Sous Windows : `START.bat`; sous macOS : `START.command`. Le premier lancement local nécessite Flutter 3.47.5 et les outils de compilation de la plateforme.

Un prerelease formel produit Windows/macOS/Android/iOS, START/source, `SHA256SUMS.txt`, les notices légales, un tag immuable et une GitHub Release.

### Droits d’auteur

**Copyright © 2026 Roman Zavada. Tous droits réservés.**

OVDP Hub est un **logiciel propriétaire**. La visibilité publique du dépôt n’accorde aucune licence open source ni autorisation de copier, modifier, republier, vendre, redistribuer ou créer des versions dérivées.

Voir [LICENSE.md](LICENSE.md), [COPYRIGHT.md](COPYRIGHT.md), [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md), [LEGAL_AND_COPYRIGHT.md](docs/LEGAL_AND_COPYRIGHT.md).

### Développement

```sh
cd apps/native
flutter pub get
flutter analyze
flutter test
flutter build windows --release
```

Autres cibles : `flutter build macos --release`, `flutter build apk --release`, `flutter build ipa --release`.

État du projet : [START_HERE.md](START_HERE.md), [PROJECT_STATE.md](PROJECT_STATE.md), [PROJECT_RULES.md](PROJECT_RULES.md), [WORKLOG.md](WORKLOG.md), [CHANGELOG.md](CHANGELOG.md).

---

## Deutsch

### Überblick

**OVDP Hub** ist eine installierbare Flutter/Dart-Anwendung zur Analyse ukrainischer Staatsanleihen (OVDP), ihrer Marktquellen und eigener Anlageszenarien. Zielplattformen: **Windows, macOS, Android und iOS**. Web/PWA gehört nicht zum aktiven Produkt.

Aktiver Code: `apps/native`. Das aktuelle Hauptziel ist **0.9.0 „Markt“**.

### Bereits verfügbar

- lokaler OVDP-Katalog auf Basis öffentlicher NBU-Daten;
- Suche, Filter, Zahlungspläne und Vergleich von Emissionen;
- getrennte Datenebenen **NBU / Finanzministerium / Verkäufer** mit Provenienz, Quelldatum, Abrufzeit und Aktualitätsstatus;
- strukturierte Auktionskalender des Finanzministeriums und detaillierte Placement-/Switch-Ergebnisse;
- mehrere Preisquellen mit expliziter Benutzerpriorität;
- Planer für Budget, Reserve, Laufzeiten und künftige Ausgaben;
- explizite Kaufgebühren-Annahmen: unbekannte Gebühren werden nie als null behandelt;
- nach v0.8.7 enthält `main` außerdem ein geprüftes OVDP-Steuerprofil 2026 für in der Ukraine ansässige Privatpersonen mit klarer Trennung zwischen **unbekannt** und **verifiziert null**;
- portable JSON-Workspaces für gespeicherte Szenarien;
- aktive UI und wichtigste benutzerseitige Fehler in **UK / EN / FR / DE / ES / KO / JA** lokalisiert.

Nominalkupon ist nicht gleich Marktrendite, reine Renditeangaben werden nicht automatisch zu Preisen, und unbekannte Gebühren, Steuern oder FX werden nie stillschweigend als null eingesetzt.

### Planer

Der Planer bleibt bewusst einwährungsbasiert. Er unterstützt Laufzeitverteilung, berechneten Ertrag und Deckung künftiger Ausgaben. Stückzahl und Gesamtpreis können manuell geändert werden.

Weg zu 0.9.0:

1. **DONE** — explizite Preisquellen-Priorität;
2. **DONE** — Kaufgebühren-Annahmen;
3. **DONE** — geprüfte Steuerannahmen;
4. **DONE** — FX-Annahmen;
5. **NEXT** — Exit-Annahmen; danach A/B/C-Vergleich und UX-/Lokalisierungs-Polish.

OVDP Hub führt keine Käufe oder Verkäufe aus und bestätigt keine Verfügbarkeit bei Verkäufern.

### Daten und Datenschutz

Kataloge und Szenarien werden auf dem Gerät gespeichert. Auf Desktop-Systemen kann ein Workspace-Ordner geöffnet oder kopiert werden. OVDP Hub betreibt keinen Server für private Portfoliodaten.

Der aktuelle JSON-Workspace ist **nicht verschlüsselt** und ist daher nicht für Signaturschlüssel, KYC-Dokumente oder Geheimnisse vorgesehen. Ein verschlüsselter Vault und Platform Secure Storage sind als separater späterer Schritt geplant.

### Schnelles Testen

Normale Änderungen führen `flutter analyze`, `flutter test` und START-Packaging aus. Unter Windows wird `START.bat`, unter macOS `START.command` verwendet. Der erste lokale Start benötigt Flutter 3.47.5 und die Build-Werkzeuge der Plattform.

Ein formaler Prerelease erstellt Windows/macOS/Android/iOS, START/source, `SHA256SUMS.txt`, rechtliche Hinweise, einen unveränderlichen Tag und ein GitHub Release.

### Urheberrecht

**Copyright © 2026 Roman Zavada. Alle Rechte vorbehalten.**

OVDP Hub ist **proprietäre Software**. Die öffentliche Sichtbarkeit des Repositorys gewährt keine Open-Source-Lizenz und keine Erlaubnis zum Kopieren, Ändern, Wiederveröffentlichen, Verkaufen, Verteilen oder Erstellen abgeleiteter Versionen.

Siehe [LICENSE.md](LICENSE.md), [COPYRIGHT.md](COPYRIGHT.md), [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md), [LEGAL_AND_COPYRIGHT.md](docs/LEGAL_AND_COPYRIGHT.md).

### Entwicklung

```sh
cd apps/native
flutter pub get
flutter analyze
flutter test
flutter build windows --release
```

Weitere Ziele: `flutter build macos --release`, `flutter build apk --release`, `flutter build ipa --release`.

Projektstatus: [START_HERE.md](START_HERE.md), [PROJECT_STATE.md](PROJECT_STATE.md), [PROJECT_RULES.md](PROJECT_RULES.md), [WORKLOG.md](WORKLOG.md), [CHANGELOG.md](CHANGELOG.md).

---

## Español

### Qué es

**OVDP Hub** es una aplicación instalable en Flutter/Dart para consultar bonos soberanos ucranianos (OVDP), fuentes de mercado y escenarios personales de inversión. Plataformas objetivo: **Windows, macOS, Android e iOS**. Web/PWA no forma parte del producto activo.

Código activo: `apps/native`. El objetivo principal actual es **0.9.0 «Mercado»**.

### Funciones disponibles

- catálogo local de OVDP basado en datos públicos del NBU;
- búsqueda, filtros, calendarios de pagos y comparación de emisiones;
- capas separadas **NBU / Ministerio de Finanzas / vendedores** con procedencia, fecha de fuente, hora de recuperación y estado de vigencia;
- calendarios estructurados de subastas y resultados detallados placement/switch;
- varias fuentes de precio con prioridad explícita controlada por el usuario;
- planificador de presupuesto, reserva, vencimientos y gastos futuros;
- supuestos explícitos de comisiones de compra: una comisión desconocida nunca se considera cero;
- después de v0.8.7, `main` también incluye un perfil fiscal OVDP 2026 verificado para una persona física residente en Ucrania, distinguiendo claramente **desconocido** de **cero verificado**;
- persistencia portable de escenarios en JSON;
- interfaz activa y principales errores para el usuario localizados en **UK / EN / FR / DE / ES / KO / JA**.

El cupón nominal no se trata como rentabilidad de mercado, una observación solo de rentabilidad no se convierte automáticamente en precio y las comisiones, impuestos o FX desconocidos nunca se sustituyen silenciosamente por cero.

### Planificador

El planificador sigue siendo de una sola moneda por diseño. Permite distribución por vencimientos, modo de beneficio calculado y cobertura de gastos futuros. La cantidad y el precio total pueden editarse manualmente.

Camino a 0.9.0:

1. **DONE** — prioridad explícita de fuentes de precio;
2. **DONE** — supuestos de comisión de compra;
3. **DONE** — supuestos fiscales verificados;
4. **DONE** — supuestos FX;
5. **NEXT** — supuestos de salida; después comparación A/B/C y mejora UX/localización.

OVDP Hub no ejecuta operaciones ni confirma disponibilidad con un vendedor.

### Datos y privacidad

Los catálogos y escenarios se guardan en el dispositivo. En desktop se puede abrir o copiar una carpeta de trabajo. OVDP Hub no mantiene un servidor central para datos privados de cartera.

El workspace JSON actual **no está cifrado**, por lo que no debe usarse para claves de firma, documentos KYC o secretos. Un vault cifrado y secure storage de plataforma están previstos como una fase separada.

### Pruebas rápidas

Los cambios normales ejecutan `flutter analyze`, `flutter test` y generan un paquete START. En Windows use `START.bat`; en macOS, `START.command`. La primera ejecución local requiere Flutter 3.47.5 y las herramientas de compilación de la plataforma.

Un prerelease formal crea Windows/macOS/Android/iOS, START/source, `SHA256SUMS.txt`, avisos legales, un tag inmutable y una GitHub Release.

### Derechos de autor

**Copyright © 2026 Roman Zavada. Todos los derechos reservados.**

OVDP Hub es **software propietario**. La visibilidad pública del repositorio no concede una licencia open source ni permiso para copiar, modificar, republicar, vender, redistribuir o crear versiones derivadas.

Consulte [LICENSE.md](LICENSE.md), [COPYRIGHT.md](COPYRIGHT.md), [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md), [LEGAL_AND_COPYRIGHT.md](docs/LEGAL_AND_COPYRIGHT.md).

### Desarrollo

```sh
cd apps/native
flutter pub get
flutter analyze
flutter test
flutter build windows --release
```

Otros destinos: `flutter build macos --release`, `flutter build apk --release`, `flutter build ipa --release`.

Estado del proyecto: [START_HERE.md](START_HERE.md), [PROJECT_STATE.md](PROJECT_STATE.md), [PROJECT_RULES.md](PROJECT_RULES.md), [WORKLOG.md](WORKLOG.md), [CHANGELOG.md](CHANGELOG.md).

---

## 한국어

### 소개

**OVDP Hub**는 우크라이나 국채(OVDP), 시장 정보 출처, 개인 투자 시나리오를 살펴보기 위한 설치형 Flutter/Dart 애플리케이션입니다. 대상 플랫폼은 **Windows, macOS, Android, iOS**이며 Web/PWA는 현재 제품 범위에 포함되지 않습니다.

활성 코드는 `apps/native`에 있습니다. 현재 주요 목표는 **0.9.0 “시장”**입니다.

### 현재 기능

- NBU 공개 데이터를 기반으로 한 로컬 OVDP 카탈로그;
- 검색, 필터, 지급 일정, 발행물 비교;
- 출처, source date, retrieved time, freshness/status를 분리해 보여 주는 **NBU / 재무부 / 판매자** 데이터 계층;
- 구조화된 재무부 경매 일정과 placement/switch 상세 결과;
- 사용자가 명시적으로 우선순위를 정하는 여러 가격 출처;
- 예산, 준비금, 만기 범위, 미래 지출을 위한 플래너;
- 명시적인 매수 수수료 가정: 알 수 없는 수수료를 0으로 처리하지 않음;
- v0.8.7 이후 `main`에는 2026년 우크라이나 거주 개인의 OVDP에 대한 검증된 세금 프로필도 통합되어 **미확인**과 **검증된 0**을 명확히 구분;
- 휴대 가능한 JSON 작업 폴더에 시나리오 저장;
- 활성 UI와 주요 사용자 오류가 **UK / EN / FR / DE / ES / KO / JA**로 현지화됨.

명목 쿠폰을 시장 수익률로 간주하지 않으며, yield-only 관측값을 자동으로 가격으로 사용하지 않습니다. 알 수 없는 수수료, 세금, FX도 자동으로 0으로 대체하지 않습니다.

### 플래너

플래너는 의도적으로 단일 통화 시나리오를 유지합니다. 만기 분배, 계산 수익 모드, 미래 지출 충당을 지원하며 수량과 총가격을 수동으로 수정할 수 있습니다.

0.9.0까지의 순서:

1. **DONE** — 가격 출처 우선순위;
2. **DONE** — 매수 수수료 가정;
3. **DONE** — 검증된 세금 가정;
4. **DONE** — FX 가정;
5. **NEXT** — exit 가정; 이후 A/B/C 비교, UX/현지화 마무리.

OVDP Hub는 실제 매매를 실행하지 않으며 판매자의 실제 재고를 확인하지 않습니다.

### 데이터와 개인정보

카탈로그와 시나리오는 사용자 기기에 저장됩니다. 데스크톱에서는 작업 폴더를 열거나 복사할 수 있습니다. OVDP Hub는 개인 포트폴리오 데이터를 위한 중앙 서버를 운영하지 않습니다.

현재 JSON 저장소는 **암호화되지 않았으므로** 서명 키, KYC 문서, 비밀정보 저장용이 아닙니다. 암호화 vault와 플랫폼 secure storage는 별도 단계로 계획되어 있습니다.

### 빠른 테스트

일반 변경에서는 `flutter analyze`, `flutter test`, START 패키징을 수행합니다. Windows에서는 `START.bat`, macOS에서는 `START.command`를 사용합니다. 첫 로컬 실행에는 Flutter 3.47.5와 해당 플랫폼 빌드 도구가 필요합니다.

정식 prerelease는 Windows/macOS/Android/iOS, START/source, `SHA256SUMS.txt`, 법적 고지, 변경되지 않는 tag, GitHub Release를 생성합니다.

### 저작권

**Copyright © 2026 Roman Zavada. All rights reserved.**

OVDP Hub는 **독점 소프트웨어(proprietary software)**입니다. 공개 저장소라고 해서 오픈소스 라이선스가 부여되는 것은 아니며 복사, 수정, 재게시, 판매, 재배포 또는 파생 버전 제작 권한을 의미하지 않습니다.

[LICENSE.md](LICENSE.md), [COPYRIGHT.md](COPYRIGHT.md), [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md), [LEGAL_AND_COPYRIGHT.md](docs/LEGAL_AND_COPYRIGHT.md)를 참고하세요.

### 개발

```sh
cd apps/native
flutter pub get
flutter analyze
flutter test
flutter build windows --release
```

다른 대상: `flutter build macos --release`, `flutter build apk --release`, `flutter build ipa --release`.

프로젝트 상태: [START_HERE.md](START_HERE.md), [PROJECT_STATE.md](PROJECT_STATE.md), [PROJECT_RULES.md](PROJECT_RULES.md), [WORKLOG.md](WORKLOG.md), [CHANGELOG.md](CHANGELOG.md).

---

## 日本語

### 概要

**OVDP Hub** は、ウクライナ国債（OVDP）、市場データの情報源、個人向け投資シナリオを確認するためのインストール型 Flutter/Dart アプリです。対象プラットフォームは **Windows、macOS、Android、iOS** です。Web/PWA は現在の製品範囲には含まれません。

アクティブなコードは `apps/native` です。現在の主要目標は **0.9.0「市場」** です。

### 現在利用できる機能

- NBU 公開データを基にしたローカル OVDP カタログ;
- 検索、フィルター、支払スケジュール、発行比較;
- provenance、source date、retrieved time、freshness/status を分離して表示する **NBU / 財務省 / 販売者** データ層;
- 財務省入札カレンダーと placement/switch の詳細結果;
- ユーザーが明示的に優先順位を決める複数の価格ソース;
- 予算、準備金、償還期間、将来支出を扱うプランナー;
- 明示的な購入手数料前提。不明な手数料を 0 とみなさない;
- v0.8.7 以降の `main` には、2026 年のウクライナ居住個人による OVDP 向け検証済み税務プロファイルも統合され、**不明** と **検証済み 0** を明確に区別;
- ポータブルな JSON ワークスペースへのシナリオ保存;
- アクティブ UI と主要なユーザー向けエラーを **UK / EN / FR / DE / ES / KO / JA** にローカライズ.

名目クーポンを市場利回りとはみなしません。yield-only の観測値を自動的に価格として使用せず、不明な手数料、税金、FX を暗黙に 0 に置き換えません。

### プランナー

プランナーは意図的に単一通貨シナリオを維持します。償還期間配分、計算利益モード、将来支出の充足を扱い、数量と総額価格は手動で変更できます。

0.9.0 までの順序:

1. **DONE** — 明示的な価格ソース優先順位;
2. **DONE** — 購入手数料前提;
3. **DONE** — 検証済み税務前提;
4. **DONE** — FX 前提;
5. **NEXT** — exit 前提; その後 A/B/C 比較、UX/ローカライズ調整.

OVDP Hub は実際の売買を実行せず、販売者の在庫を確認しません。

### データとプライバシー

カタログとシナリオはユーザー端末に保存されます。デスクトップではワークスペースフォルダーを開く、またはコピーできます。OVDP Hub は個人ポートフォリオデータ用の中央サーバーを運用しません。

現在の JSON ワークスペースは **暗号化されていない**ため、署名鍵、KYC 文書、秘密情報の保存には使用しないでください。暗号化 vault と platform secure storage は別の将来段階として計画されています。

### クイックテスト

通常の変更では `flutter analyze`、`flutter test`、START パッケージ作成を実行します。Windows では `START.bat`、macOS では `START.command` を使用します。初回のローカル実行には Flutter 3.47.5 と各 OS のビルドツールが必要です。

正式な prerelease は Windows/macOS/Android/iOS、START/source、`SHA256SUMS.txt`、法的通知、不変 tag、GitHub Release を生成します。

### 著作権

**Copyright © 2026 Roman Zavada. All rights reserved.**

OVDP Hub は **プロプライエタリソフトウェア**です。公開リポジトリであることは、オープンソースライセンスや、コピー、変更、再公開、販売、再配布、派生版作成の許可を意味しません。

[LICENSE.md](LICENSE.md)、[COPYRIGHT.md](COPYRIGHT.md)、[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)、[LEGAL_AND_COPYRIGHT.md](docs/LEGAL_AND_COPYRIGHT.md) を参照してください。

### 開発

```sh
cd apps/native
flutter pub get
flutter analyze
flutter test
flutter build windows --release
```

その他の対象: `flutter build macos --release`、`flutter build apk --release`、`flutter build ipa --release`.

プロジェクト状態: [START_HERE.md](START_HERE.md)、[PROJECT_STATE.md](PROJECT_STATE.md)、[PROJECT_RULES.md](PROJECT_RULES.md)、[WORKLOG.md](WORKLOG.md)、[CHANGELOG.md](CHANGELOG.md).

---

## Release and source notes

- Current published prerelease: **v0.8.7 / 0.8.7+15**.
- Published tags are immutable.
- The latest integrated `main` can contain work completed after the latest published prerelease.
- The repository is public for development and testing visibility, but the project license remains proprietary.
- Public source data remain subject to the rights and terms of their respective providers.

NBU catalog source: https://bank.gov.ua/ua/markets/ovdp
