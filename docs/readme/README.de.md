# OVDP Hub

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · [🇫🇷 Français](README.fr.md) · **🇩🇪 Deutsch** · [🇪🇸 Español](README.es.md) · [🇰🇷 한국어](README.ko.md) · [🇯🇵 日本語](README.ja.md)

> **Aktueller Test-Prerelease: [OVDP Hub v0.9.3](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.9.3) — 0.9.3+20**
>
> [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-START.zip)

## Produkt
OVDP Hub ist eine Local-first-Flutter/Dart-Anwendung für ukrainische Staatsanleihen: Marktquellen, Szenarioplanung, neutraler Vergleich und ein faktisches verschlüsseltes persönliches Portfolio.

## v0.9.3
- NBU / MinFin / Verkäuferdaten mit Provenance und Freshness;
- Planner mit Gebühren, Steuern, FX, Early Exit, Reserve Floor und wiederkehrenden Bedürfnissen;
- A/B/C-Vergleich ohne automatischen Gewinner;
- deterministische CSV/ICS-Exporte;
- permanenter Economic Pulse;
- verschlüsseltes Portfolio mit Kauf, Verkauf, Coupon und Tilgung;
- explizite Erwerbslot-Zuordnung statt erfundenem FIFO/LIFO;
- ISIN-Ledger und geschlossene Positionen;
- faktische Cash-Zusammenfassung, unbekannte Gebühren bleiben unbekannt;
- nicht-destruktiver Legacy-Migrationsassistent;
- drei Oberflächen und UK/EN/FR/DE/ES/KO/JA.

Die Cash-Zusammenfassung enthält nicht den aktuellen Marktwert offener Positionen und ist keine Performance-Kennzahl.

## Installation
Windows: gesamtes ZIP entpacken und `ovdp_hub.exe` starten. macOS: `ovdp_hub.app` öffnen; Prerelease ist nicht notarisiert. Android: `OVDP-Hub.apk` installieren. iOS-Paket ist unsigned.

Vollständiges Handbuch: **[Deutsches Benutzerhandbuch](../user-guide/USER_GUIDE.de.md)**.

## Datenschutz
Private Portfoliodaten bleiben lokal und verschlüsselt. Legacy-Workspace-JSON kann Klartext bleiben; die Migration löscht Quell-JSON nie automatisch.

## Verifikation und Recht
v0.9.3 bestand Analyze/Tests, Windows/macOS-Packaging mit Smoke des tatsächlich gepackten Executables, Android, unsigned iOS, START/source, Checksums und Legal Notices.

Copyright © 2026 Roman Zavada. Alle Rechte vorbehalten. Proprietäre Software; siehe [LICENSE.md](../../LICENSE.md).
