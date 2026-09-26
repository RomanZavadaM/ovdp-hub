# OVDP Hub

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · [🇫🇷 Français](README.fr.md) · [🇩🇪 Deutsch](README.de.md) · **🇪🇸 Español** · [🇰🇷 한국어](README.ko.md) · [🇯🇵 日本語](README.ja.md)

> **Checkpoint final del alcance actual: [OVDP Hub v0.9.4](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.9.4) — 0.9.4+21**
>
> **Estado de desarrollo: PARKED / completado en el alcance actual. Sin desarrollo activo.**
>
> [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-START.zip) · [SHA-256](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/SHA256SUMS.txt)

## Producto

OVDP Hub es una aplicación Flutter/Dart local-first para bonos estatales ucranianos OVDP: fuentes de mercado, planificación de escenarios, comparación neutral y cartera personal cifrada basada en hechos reales.

## v0.9.4

- capas NBU / MinFin / vendedores con procedencia/freshness;
- Planner con comisiones, impuestos, FX, necesidades recurrentes, reserve floor y salida anticipada por posición;
- comparación A/B/C sin ganador automático;
- exportaciones CSV/ICS deterministas y Economic Pulse;
- Portfolio cifrado con compra, venta, cupón, amortización, asignación explícita a lotes y ledger por ISIN;
- confirmación/rotación de recovery secret y backup/restore cifrado portable en Windows;
- Portfolio macOS respaldado por Keychain con smoke real del ciclo de vida empaquetado;
- base Android SAF e iOS security-scoped para almacenamiento externo;
- workspace móvil externo, transporte de backup cifrado y permisos fail-closed;
- self-test móvil en dos fases mediante terminate/relaunch;
- Classic / Workbench / Light Dashboard y UI UK/EN/FR/DE/ES/KO/JA con idioma/apariencia persistentes.

El resumen de caja no incorpora el valor de mercado actual de posiciones abiertas y no es una métrica de rentabilidad. Las comisiones desconocidas siguen siendo desconocidas.

## Instalación

Windows: extraiga todo el ZIP y ejecute `ovdp_hub.exe`. macOS: abra `ovdp_hub.app`; este checkpoint no está notarizado. Android: instale `OVDP-Hub.apk`. El paquete iOS es unsigned y necesita Apple signing/provisioning separado.

Guía completa: **[Guía de usuario en español](../user-guide/USER_GUIDE.es.md)**.

## Verificación y límites PARKED

El release run #113 de v0.9.4 superó analyze, **218/218 tests**, smoke exacto de ZIP Windows/macOS, packaging Android release, packaging iOS unsigned, START/source, checksums y avisos legales.

Aplazado y no activo: validación física Android SAF, build iOS development firmado + validación en iPhone, production signing/notarization/store distribution, instaladores y auto-update. Estos casos físicos no se declaran `RUNTIME VALIDATED`.

## Privacidad y licencia

Los datos privados de cartera permanecen locales y cifrados. Los JSON legacy del workspace pueden seguir en texto plano; la migración nunca elimina automáticamente el JSON fuente.

Copyright © 2026 Roman Zavada. Todos los derechos reservados. Software propietario; el repositorio público no concede una licencia open-source. Consulte [LICENSE.md](../../LICENSE.md).
