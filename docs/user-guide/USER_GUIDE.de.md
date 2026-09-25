# OVDP Hub v0.9.3 — Benutzerhandbuch

## Zweck
OVDP Hub ist eine Local-first-Anwendung für ukrainische Staatsanleihen (OVDP): Marktdatenquellen, Szenarioplanung, Vergleich und ein faktisches verschlüsseltes persönliches Portfolio. Die App führt keine Trades aus.

## Installation
**Windows:** komplettes ZIP entpacken und `ovdp_hub.exe` starten. DLLs/Ressourcen zusammenlassen. Der Test-Build ist nicht produktiv signiert; SmartScreen kann erscheinen.

**macOS:** ZIP entpacken und `ovdp_hub.app` öffnen. Der Prerelease ist nicht notarisiert; nach einem blockierten Start kann **Open Anyway** unter System Settings → Privacy & Security verfügbar sein.

**Android:** Android-ZIP entpacken und `OVDP-Hub.apk` installieren. Development-signierter Test-Build.

**iOS:** das veröffentlichte Paket ist unsigned und benötigt separates Apple Signing/Provisioning.

## Sprache und Erscheinungsbild
Sprachen: Ukrainisch, Englisch, Französisch, Deutsch, Spanisch, Koreanisch und Japanisch. Ansichten: Classic, Workbench, Light Dashboard.

## Markt und ISIN
Im Katalog können Anleihen gesucht und gefiltert werden. Die ISIN-Karte trennt NBU-, MinFin- und Verkäuferdaten und zeigt Datum, Quelle und Freshness/Status. Yield-only oder Nominalwerte werden nicht stillschweigend als handelbarer Marktpreis verwendet.

## Planer
Ein Szenario hat eine Basiswährung. Konfigurieren Sie Budget, Reserve, Horizont, Bedürfnisse, Positionen, Gebühren, Steuern, FX, optionalen vorzeitigen Verkauf, Reserve Floor sowie einmalige/wiederkehrende Bedürfnisse. Unbekannte Werte bleiben unbekannt und werden nicht zu Null.

A/B/C vergleicht 2–3 kompatible gespeicherte Szenarien ohne automatischen Gewinner. CSV/ICS-Exporte werden lokal unter `exports/` gespeichert.

## Mein Portfolio
Das Portfolio ist ein verschlüsselter lokaler Ablauf mit Create/Open/Lock.

**Kauf:** ISIN/Datum/Einheiten/Betrag und Gebührenstatus faktisch erfassen.

**Verkauf:** Verkauf explizit Erwerbslots zuordnen; kein erfundenes FIFO/LIFO.

**Coupon / Tilgung:** nur tatsächlich erhaltene Beträge erfassen.

**ISIN-Ledger:** Kauf/Verkauf/Coupon/Tilgung bleibt nachvollziehbar; geschlossene Positionen bleiben sichtbar.

**Faktische Cash-Zusammenfassung:** Käufe, Verkaufserlöse, Coupons, Tilgungen und bekannte Gebühren je Währung. Bei unbekannter relevanter Gebühr wird kein exaktes Nettoergebnis angezeigt.

Dies ist **keine** Marktwert- oder Performance-Berechnung, da der aktuelle Marktwert offener Positionen nicht addiert wird.

## Legacy-Migration
Der Assistent kopiert unterstützte Legacy-Nutzerdaten in den verschlüsselten Payload und verifiziert die Kopie. Die Migration ist nicht destruktiv; Quell-JSON wird nie automatisch gelöscht.

## Backup und Update
Vor großen Updates Portfolio sperren, Workspace sichern, verschlüsseltes portables Backup prüfen und Recovery Material getrennt aufbewahren. Desktop-Updates in einen neuen Programmordner entpacken und Workspace behalten, bis die neue Version geprüft ist.

## Prüfung und typische Probleme
`SHA256SUMS.txt` dient zur Download-Prüfung. SmartScreen/macOS-Warnungen sind beim unsignierten Test-Prerelease möglich. „Unknown fee“ ist ein bewusster Zustand. Das iOS-Paket ist unsigned und nicht direkt installierbar.

## Grenzen
OVDP Hub ist kein Broker. Preise, Gebühren, Steuern, Daten und Bedingungen vor finanziellen Handlungen mit Primärquellen und Broker/Bank prüfen.
