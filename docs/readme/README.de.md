# OVDP Hub

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · [🇫🇷 Français](README.fr.md) · **🇩🇪 Deutsch** · [🇪🇸 Español](README.es.md) · [🇰🇷 한국어](README.ko.md) · [🇯🇵 日本語](README.ja.md)

> **Aktuelles Test-Release: [OVDP Hub v0.10.1](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.10.1) — 0.10.1+23**
>
> **Status: ACTIVE — Release-Checkpoint v0.10.1 wird am 20.10.2026 vorbereitet.**
>
> [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-START.zip) · [SHA-256](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/SHA256SUMS.txt)

## Produkt

OVDP Hub ist eine Local-first-Flutter/Dart-Anwendung für ukrainische Staatsanleihen: Marktquellen, Szenarioplanung, neutraler Vergleich und ein faktisches verschlüsseltes persönliches Portfolio.

## Neu in v0.10.1

- sicherere Migration privater Planner-Szenarien: Klartext wird erst nach erneuter Prüfung der verschlüsselten Kopie und der aktuellen Quelle gelöscht;
- Sperren leert den privaten Planner und beendet Dialoge, Datumsauswahl und veraltete asynchrone Ergebnisse;
- Lock/Background/Dispose brechen unvollständige Recovery-, Create-, Restore- und Migration-Vorgänge ab und entfernen verspätete Schlüssel;
- privater CSV/ICS-Export verlangt eine ausdrückliche Klartext-Zustimmung und zeigt das genaue Ziel;
- Kryptografie, KDF-Parameter und Payload-Schema bleiben unverändert; Schema v4.

## Produktumfang

- NBU / MinFin / Verkäuferdaten mit Provenance/Freshness;
- Planner mit Gebühren, Steuern, FX, wiederkehrenden Bedürfnissen, Reserve Floor und Early Exit je Position;
- A/B/C-Vergleich ohne automatischen Gewinner;
- deterministische CSV/ICS-Exporte und Economic Pulse;
- verschlüsseltes faktisches Portfolio mit Kauf, Verkauf, Coupon, Tilgung, expliziter Lot-Zuordnung und ISIN-Ledger;
- Recovery-Bestätigung/Rotation und portables verschlüsseltes Windows-Backup/Restore;
- macOS-Keychain-Portfolio mit realem Packaged-Lifecycle-Smoke;
- Android SAF / iOS security-scoped External-Storage-Grundlage;
- externer Mobile-Workspace, verschlüsselter Backup-Transport und fail-closed Berechtigungen;
- zweiphasiger Mobile-Self-Test über terminate/relaunch;
- Classic / Workbench / Light Dashboard und UK/EN/FR/DE/ES/KO/JA mit persistenter Sprache/Appearance.

Die Cash-Zusammenfassung enthält nicht den aktuellen Marktwert offener Positionen und ist keine Performance-Kennzahl. Unbekannte Gebühren bleiben unbekannt.

## Installation

Windows: gesamtes ZIP entpacken und `ovdp_hub.exe` starten. macOS: `ovdp_hub.app` öffnen; dieser Checkpoint ist nicht notarisiert. Android: `OVDP-Hub.apk` installieren. Das iOS-Paket ist unsigned und benötigt separates Apple Signing/Provisioning.

Vollständiges Handbuch: **[Deutsches Benutzerhandbuch](../user-guide/USER_GUIDE.de.md)**.

## Verifikation und Grenzen

Release-Run #116 von v0.10.1 (Commit `933a7bd`) bestand Analyze, **264 Tests**, Windows/macOS Exact-ZIP-Smoke inklusive Capability-Liste, Android Release Packaging, unsigned iOS Packaging, START/source, Checksums und Legal Notices.

Zurückgestellt: physische Android-SAF- und signierte iOS-Validierung, Produktionssignierung, Notarisierung, Store-Vertrieb, Installer und Auto-Update. Stückzinsen und Renditen sind Richtwerte, keine Anlageberatung.

## Datenschutz und Recht

Private Portfoliodaten bleiben lokal und verschlüsselt. Legacy-Workspace-JSON kann Klartext bleiben; Migration löscht Quell-JSON nie automatisch.

Copyright © 2026 Roman Zavada. Alle Rechte vorbehalten. Proprietäre Software; das öffentliche Repository gewährt keine Open-Source-Lizenz. Siehe [LICENSE.md](../../LICENSE.md).
