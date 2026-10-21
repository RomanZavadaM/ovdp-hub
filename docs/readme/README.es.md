# OVDP Hub

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · [🇫🇷 Français](README.fr.md) · [🇩🇪 Deutsch](README.de.md) · **🇪🇸 Español** · [🇰🇷 한국어](README.ko.md) · [🇯🇵 日本語](README.ja.md)

> **Versión de prueba actual: [OVDP Hub v0.10.1](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.10.1) — 0.10.1+23**
>
ACTIVE — v0.10.1 is published; the next checkpoint is under verification.
>
> [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-START.zip) · [SHA-256](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/SHA256SUMS.txt)

## Producto

OVDP Hub es una aplicación Flutter/Dart local-first para bonos estatales ucranianos OVDP: fuentes de mercado, planificación de escenarios, comparación neutral y cartera personal cifrada basada en hechos reales.

## Novedades v0.10.1

- migración más segura de escenarios privados del Planner: el texto plano solo se elimina tras volver a verificar la copia cifrada y la fuente actual;
- el bloqueo limpia el Planner privado y cancela diálogos, selectores de fecha y resultados asíncronos obsoletos;
- lock/background/dispose cancelan recovery/create/restore/migration incompletos y eliminan claves tardías;
- la exportación CSV/ICS privada exige consentimiento explícito para texto plano y muestra el destino exacto;
- criptografía, parámetros KDF y esquema payload sin cambios; se mantiene schema v5.


## Después de v0.10.1 — candidato al próximo checkpoint

- F5 está integrado en `main`: las colecciones privadas con nombre y nota se guardan cifradas en la cartera, pueden editarse y reabrirse, y el bloqueo borra el borrador.
- Las listas ISIN públicas funcionan sin cartera y no contienen anotaciones privadas.
- Mover una colección antigua en texto plano es una acción explícita. La fuente se elimina solo tras verificar la copia cifrada completa y que no cambió; un conflicto, campo desconocido, bloqueo o error conserva el original.
- El esquema payload v5 lee v1–v4; criptografía y KDF no cambian.
- La PR #157 prepara una comparación de solo lectura de ofertas públicas de Inzhur, UNIVER y PrivatBank por ISIN, moneda y vencimiento. Precio, rendimiento, cantidad y hora de fuente siguen separados; no se inventan valores desconocidos.
- Todavía no es una versión publicada; v0.10.1 sigue siendo la descarga actual.

## Alcance del producto

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

## Verificación y límites

El release run #116 de v0.10.1 (commit `933a7bd`) superó analyze, **314 tests**, smoke exacto de ZIP Windows/macOS con la lista de capacidades, packaging Android release, packaging iOS unsigned, START/source, checksums y avisos legales.

Aplazado: validación física de Android SAF e iOS firmado, firma de producción, notarización, distribución en tiendas, instaladores y auto-update. Intereses devengados y rendimientos orientativos; no es asesoramiento de inversión.

## Privacidad y licencia

Los datos privados de cartera permanecen locales y cifrados. Los JSON legacy del workspace pueden seguir en texto plano; la migración nunca elimina automáticamente el JSON fuente.

Copyright © 2026 Roman Zavada. Todos los derechos reservados. Software propietario; el repositorio público no concede una licencia open-source. Consulte [LICENSE.md](../../LICENSE.md).
