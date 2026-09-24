# OVDP Hub

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · [🇫🇷 Français](README.fr.md) · **🇩🇪 Deutsch** · [🇪🇸 Español](README.es.md) · [🇰🇷 한국어](README.ko.md) · [🇯🇵 日本語](README.ja.md)

> **Current published prerelease / Поточний опублікований prerelease: [OVDP Hub v0.9.2](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.9.2) (0.9.2+19)**
>
> Downloads / Завантаження: [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.2/OVDP-Hub-0.9.1-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.2/OVDP-Hub-0.9.1-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.2/OVDP-Hub-0.9.1-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.2/OVDP-Hub-0.9.1-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.2/OVDP-Hub-0.9.1-START.zip) · [SHA-256](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.2/SHA256SUMS.txt)

---

### Checkpoint v0.9.2

**v0.9.2+19** bringt den permanenten **Wirtschaftspuls** und den ersten user-facing **Mein Portfolio**-Flow: lokales verschlüsseltes Portfolio erstellen/öffnen/sperren, faktischen OVDP-Kauf erfassen und abgeleitete Bestände anzeigen. Zusätzlich prüft ein Release-Gate das tatsächlich verteilte Windows/macOS-ZIP samt Executable.

**Datenschutzgrenze:** Legacy-`sets/*.json` werden weiterhin nicht automatisch verschlüsselt. Migration/Cleanup-Wizard bleibt ein separater nächster User-Flow; Android SAF / iOS security-scoped ist zurückgestellt.


### Überblick

**OVDP Hub** ist eine installierbare Flutter/Dart-Anwendung zur Analyse ukrainischer Staatsanleihen (OVDP), ihrer Marktquellen und eigener Anlageszenarien. Zielplattformen: **Windows, macOS, Android und iOS**. Web/PWA gehört nicht zum aktiven Produkt.

Aktiver Code: `apps/native`. Der aktuelle Checkpoint ist **0.9.2+19**. Er enthält die UI/Planner/Export-Erweiterungen nach 0.9.0 sowie die verifizierte interne Vault-/Private-Domain-/Migrationsgrundlage. User-facing Vault/Migration/Portfolio bleibt noch nicht angebunden.

### Bereits verfügbar

- lokaler OVDP-Katalog auf Basis öffentlicher NBU-Daten;
- Suche, Filter, Zahlungspläne und Vergleich von Emissionen;
- getrennte Datenebenen **NBU / Finanzministerium / Verkäufer** mit Provenienz, Quelldatum, Abrufzeit und Aktualitätsstatus;
- strukturierte Auktionskalender des Finanzministeriums und detaillierte Placement-/Switch-Ergebnisse;
- mehrere Preisquellen mit expliziter Benutzerpriorität;
- Planer für Budget, Reserve, Laufzeiten und künftige Ausgaben;
- explizite Kaufgebühren-Annahmen: unbekannte Gebühren werden nie als null behandelt;
- ein geprüftes OVDP-Steuerprofil 2026 für in der Ukraine ansässige Privatpersonen mit klarer Trennung zwischen **unbekannt** und **verifiziert null**;
- expliziter FX-Vergleich mit manuell eingegebenem Kurs, Datum und Quellen-URL, während der Basis-Cashflow einwährungsbasiert bleibt;
- vorzeitiger Verkauf je Position mit eigenem Verkaufsdatum und BID-/manuellem Exit-Preis;
- wiederkehrender Hauptbedarf als typisierte Regel; zusätzliche Bedarfe bleiben einmalige Einträge;
- neutraler **A/B/C**-Vergleich für 2–3 gespeicherte Szenarien mit strenger Vergleichbarkeit und ohne automatischen Gewinner;
- typisierte Mindestbestand-/Reserve-Floor-Regel: Ab dem Wirksamkeitsdatum muss der Betrag liquide bleiben und wird nicht als Ausgabe behandelt;
- deterministische lokale Planner-CSV/ICS-Exporte für Szenario/Bedarfe/Deckung/Cashflow in den `exports`-Ordner des aktiven Arbeitsbereichs; PDF bleibt bis zur Stabilisierung der Berichtsstruktur zurückgestellt;
- generierter Planner-Text / Preset-Labels werden als stabile IDs gespeichert und erst bei der Anzeige lokalisiert; benutzerdefinierte Namen bleiben unverändert;
- portable JSON-Workspaces für gespeicherte Szenarien;
- aktive UI und wichtigste benutzerseitige Fehler in **UK / EN / FR / DE / ES / KO / JA** lokalisiert.

Nominalkupon ist nicht gleich Marktrendite, reine Renditeangaben werden nicht automatisch zu Preisen, und unbekannte Gebühren, Steuern oder FX werden nie stillschweigend als null eingesetzt.

### Planer

Der Planer bleibt bewusst einwährungsbasiert. Er unterstützt Laufzeitverteilung, berechneten Ertrag und Deckung künftiger Ausgaben. Stückzahl und Gesamtpreis können manuell geändert werden.

Entwicklung nach dem veröffentlichten 0.9.0-Checkpoint:

1. **DONE** — explizite Preisquellen-Priorität;
2. **DONE** — Kaufgebühren-Annahmen;
3. **DONE** — geprüfte Steuerannahmen;
4. **DONE** — FX-Annahmen;
5. **DONE** — Exit-Annahmen;
6. **DONE** — neutraler A/B/C-Vergleich;
7. **DONE** — Lokalisierung von generated Planner copy / Preset-Labels + Regression;
8. **DONE** — v0.9.0-Prerelease-Checkpoint;
9. **DONE** — Reserve Floor / Mindestbestand;
10. **DONE** — deterministische lokale CSV/ICS-Exporte; PDF zurückgestellt;
11. **DONE** — Encrypted-Vault/Private-Domain/nicht-destruktive Migration; 12. **DONE** — v0.9.2+18 Checkpoint; 13. **NEXT** — Android SAF / iOS security-scoped Zugriff auf externe Ordner; user-facing Vault/Migration-UX bleibt ein separates Gate.

OVDP Hub führt keine Käufe oder Verkäufe aus und bestätigt keine Verfügbarkeit bei Verkäufern.

### Daten und Datenschutz

Kataloge und Szenarien werden auf dem Gerät gespeichert. Auf Desktop-Systemen kann ein Workspace-Ordner geöffnet oder kopiert werden. OVDP Hub betreibt keinen Server für private Portfoliodaten.

Die vom aktuellen user-facing Collections-Flow verwendeten Legacy-Workspace-JSON-Dateien bleiben **Klartext**, bis ein zukünftiger expliziter Vault/Migrations-Flow angebunden und erfolgreich ausgeführt wird. v0.9.2 enthält die verifizierte Vault-/Private-Payload-/Migrationsgrundlage, schreibt oder löscht bestehende `sets/*.json` aber nicht automatisch. Keine Signaturschlüssel, KYC-Dokumente oder andere Secrets im Legacy-Workspace speichern.

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
