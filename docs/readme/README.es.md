# OVDP Hub

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · [🇫🇷 Français](README.fr.md) · [🇩🇪 Deutsch](README.de.md) · **🇪🇸 Español** · [🇰🇷 한국어](README.ko.md) · [🇯🇵 日本語](README.ja.md)

> **Prerelease de prueba actual: [OVDP Hub v0.9.3](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.9.3) — 0.9.3+20**
>
> [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-START.zip)

## Producto
OVDP Hub es una aplicación Flutter/Dart local-first para bonos estatales ucranianos OVDP: fuentes de mercado, planificación de escenarios, comparación neutral y cartera personal cifrada con hechos reales.

## Novedades v0.9.3
- capas NBU / MinFin / vendedores con procedencia y freshness;
- Planner con comisiones, impuestos, FX, salida anticipada, reserve floor y necesidades recurrentes;
- comparación A/B/C sin ganador automático;
- exportaciones CSV/ICS deterministas;
- Economic Pulse permanente;
- cartera cifrada con compra, venta, cupón y amortización factual;
- asignación explícita a lotes de adquisición, sin FIFO/LIFO inventado;
- ledger por ISIN y posiciones cerradas;
- resumen de caja factual con comisiones desconocidas conservadas como desconocidas;
- migración legacy no destructiva con verificación de copia cifrada;
- tres apariencias y UI en UK/EN/FR/DE/ES/KO/JA.

El resumen de caja no incorpora el valor de mercado actual de posiciones abiertas, por lo que no es una métrica de rentabilidad.

## Instalación
Windows: extraiga todo el ZIP y ejecute `ovdp_hub.exe`. macOS: abra `ovdp_hub.app`; el prerelease no está notarizado. Android: instale `OVDP-Hub.apk`. El paquete iOS es unsigned.

Guía completa: **[Guía de usuario en español](../user-guide/USER_GUIDE.es.md)**.

## Privacidad
Los datos privados de cartera permanecen locales y cifrados. Los JSON legacy del workspace pueden seguir en texto plano; la migración nunca elimina automáticamente el JSON fuente.

## Verificación y licencia
v0.9.3 superó analyze/tests, empaquetado Windows/macOS con smoke del ejecutable realmente distribuido, Android, iOS unsigned, START/source, checksums y avisos legales.

Copyright © 2026 Roman Zavada. Todos los derechos reservados. Software propietario; consulte [LICENSE.md](../../LICENSE.md).
