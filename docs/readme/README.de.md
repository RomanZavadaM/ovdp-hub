# OVDP Hub

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · [🇫🇷 Français](README.fr.md) · **🇩🇪 Deutsch** · [🇪🇸 Español](README.es.md) · [🇰🇷 한국어](README.ko.md) · [🇯🇵 日本語](README.ja.md)

> **Current published prerelease / Поточний опублікований prerelease: [OVDP Hub v0.8.7](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.8.7)**
>
> [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.8.7/OVDP-Hub-0.8.7-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.8.7/OVDP-Hub-0.8.7-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.8.7/OVDP-Hub-0.8.7-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.8.7/OVDP-Hub-0.8.7-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.8.7/OVDP-Hub-0.8.7-START.zip) · [SHA-256](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.8.7/SHA256SUMS.txt)

---

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

Siehe [LICENSE.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/LICENSE.md), [COPYRIGHT.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/COPYRIGHT.md), [THIRD_PARTY_NOTICES.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/THIRD_PARTY_NOTICES.md), [LEGAL_AND_COPYRIGHT.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/docs/LEGAL_AND_COPYRIGHT.md).

### Entwicklung

```sh
cd apps/native
flutter pub get
flutter analyze
flutter test
flutter build windows --release
```

Weitere Ziele: `flutter build macos --release`, `flutter build apk --release`, `flutter build ipa --release`.

Projektstatus: [START_HERE.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/START_HERE.md), [PROJECT_STATE.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/PROJECT_STATE.md), [PROJECT_RULES.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/PROJECT_RULES.md), [WORKLOG.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/WORKLOG.md), [CHANGELOG.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/CHANGELOG.md).

---

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · [🇫🇷 Français](README.fr.md) · **🇩🇪 Deutsch** · [🇪🇸 Español](README.es.md) · [🇰🇷 한국어](README.ko.md) · [🇯🇵 日本語](README.ja.md)
