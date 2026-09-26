# OVDP Hub

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · [🇫🇷 Français](README.fr.md) · **🇩🇪 Deutsch** · [🇪🇸 Español](README.es.md) · [🇰🇷 한국어](README.ko.md) · [🇯🇵 日本語](README.ja.md)

> **Finaler Checkpoint des aktuellen Umfangs: [OVDP Hub v0.9.4](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.9.4) — 0.9.4+21**
>
> **Entwicklungsstatus: PARKED / im aktuellen Umfang abgeschlossen. Keine aktive Entwicklung.**
>
> [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-START.zip) · [SHA-256](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/SHA256SUMS.txt)

## Produkt

OVDP Hub ist eine Local-first-Flutter/Dart-Anwendung für ukrainische Staatsanleihen: Marktquellen, Szenarioplanung, neutraler Vergleich und ein faktisches verschlüsseltes persönliches Portfolio.

## v0.9.4

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

## Verifikation und PARKED-Grenzen

Release-Run #113 von v0.9.4 bestand Analyze, **218/218 Tests**, Windows/macOS Exact-ZIP-Smoke, Android Release Packaging, unsigned iOS Packaging, START/source, Checksums und Legal Notices.

Zurückgestellt und nicht aktiv: physische Android-SAF-Validierung, signierter iOS-Development-Build + iPhone-Runtime-Test, Production Signing/Notarization/Store Distribution, Installer und Auto-Update. Diese Physical-Device-Fälle werden nicht als `RUNTIME VALIDATED` bezeichnet.

## Datenschutz und Recht

Private Portfoliodaten bleiben lokal und verschlüsselt. Legacy-Workspace-JSON kann Klartext bleiben; Migration löscht Quell-JSON nie automatisch.

Copyright © 2026 Roman Zavada. Alle Rechte vorbehalten. Proprietäre Software; das öffentliche Repository gewährt keine Open-Source-Lizenz. Siehe [LICENSE.md](../../LICENSE.md).
