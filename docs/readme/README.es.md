# OVDP Hub

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · [🇫🇷 Français](README.fr.md) · [🇩🇪 Deutsch](README.de.md) · **🇪🇸 Español** · [🇰🇷 한국어](README.ko.md) · [🇯🇵 日本語](README.ja.md)

> **Release candidate / Кандидат prerelease: OVDP Hub v0.9.0 (0.9.0+17). Current published / Поточний опублікований: [v0.8.8](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.8.8)**
>
> Expected after successful gated publish / Очікується після успішного pipeline: [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.0/OVDP-Hub-0.9.0-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.0/OVDP-Hub-0.9.0-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.0/OVDP-Hub-0.9.0-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.0/OVDP-Hub-0.9.0-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.0/OVDP-Hub-0.9.0-START.zip) · [SHA-256](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.0/SHA256SUMS.txt)

---

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
- un perfil fiscal OVDP 2026 verificado para una persona física residente en Ucrania, distinguiendo claramente **desconocido** de **cero verificado**;
- comparación FX explícita con tipo, fecha y URL de fuente introducidos manualmente, sin mezclar monedas en el flujo de caja base;
- venta anticipada por posición con fecha y precio de salida BID/manual propios;
- necesidad futura principal recurrente guardada como regla tipada; las necesidades adicionales siguen siendo elementos únicos;
- comparación neutral **A/B/C** de 2–3 escenarios guardados con comparabilidad estricta y sin ganador automático;
- el texto generado del planificador / etiquetas predefinidas se guarda como IDs estables y se localiza al mostrarlo; los nombres del usuario permanecen literales;
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
5. **DONE** — supuestos de salida;
6. **DONE** — comparación neutral A/B/C;
7. **DONE** — localización del texto generado / etiquetas predefinidas + regresión;
8. **READY** — evaluación formal de preparación 0.9.0: GO para preparar el checkpoint prerelease.

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

Consulte [LICENSE.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/LICENSE.md), [COPYRIGHT.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/COPYRIGHT.md), [THIRD_PARTY_NOTICES.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/THIRD_PARTY_NOTICES.md), [LEGAL_AND_COPYRIGHT.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/docs/LEGAL_AND_COPYRIGHT.md).

### Desarrollo

```sh
cd apps/native
flutter pub get
flutter analyze
flutter test
flutter build windows --release
```

Otros destinos: `flutter build macos --release`, `flutter build apk --release`, `flutter build ipa --release`.

Estado del proyecto: [START_HERE.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/START_HERE.md), [PROJECT_STATE.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/PROJECT_STATE.md), [PROJECT_RULES.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/PROJECT_RULES.md), [WORKLOG.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/WORKLOG.md), [CHANGELOG.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/CHANGELOG.md).

---

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · [🇫🇷 Français](README.fr.md) · [🇩🇪 Deutsch](README.de.md) · **🇪🇸 Español** · [🇰🇷 한국어](README.ko.md) · [🇯🇵 日本語](README.ja.md)
