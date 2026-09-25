# OVDP Hub

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · [🇫🇷 Français](README.fr.md) · [🇩🇪 Deutsch](README.de.md) · **🇪🇸 Español** · [🇰🇷 한국어](README.ko.md) · [🇯🇵 日本語](README.ja.md)

> **Current published prerelease / Поточний опублікований prerelease: [OVDP Hub v0.9.3](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.9.3) (0.9.3+20)**
>
> Downloads / Завантаження: [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-START.zip) · [SHA-256](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/SHA256SUMS.txt)

---

### Checkpoint v0.9.3

**v0.9.3+20** completa el ciclo factual visible de la cartera: ventas con asignación explícita a lotes, amortizaciones y cupones factuales, historial, ledger por ISIN, posiciones cerradas, resumen de caja factual por divisa y un asistente explícito de migración legacy no destructiva. Las comisiones desconocidas siguen siendo desconocidas y el valor de mercado no se presenta como resultado de caja factual.

**Límite de privacidad:** los `sets/*.json` legacy siguen sin cifrarse automáticamente. El wizard de migración/limpieza queda como siguiente gate visible; Android SAF / iOS security-scoped se aplaza.


### Qué es

**OVDP Hub** es una aplicación instalable en Flutter/Dart para consultar bonos soberanos ucranianos (OVDP), fuentes de mercado y escenarios personales de inversión. Plataformas objetivo: **Windows, macOS, Android e iOS**. Web/PWA no forma parte del producto activo.

Código activo: `apps/native`. El checkpoint actual es **0.9.3+20**. Incluye el Pulso económico y el acceso a cartera cifrada de v0.9.2, además de los flujos factuales de venta/amortización/cupón/historial/reporting y migración integrados después.

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
- regla tipada de reserve floor / saldo mínimo: desde su fecha efectiva el importe debe permanecer líquido y no se trata como un gasto;
- exportaciones locales deterministas CSV/ICS del Planner para escenario/necesidades/cobertura/flujo de caja en la carpeta `exports` del espacio de trabajo activo; PDF queda aplazado hasta estabilizar el informe;
- el texto generado del planificador / etiquetas predefinidas se guarda como IDs estables y se localiza al mostrarlo; los nombres del usuario permanecen literales;
- persistencia portable de escenarios en JSON;
- interfaz activa y principales errores para el usuario localizados en **UK / EN / FR / DE / ES / KO / JA**.

El cupón nominal no se trata como rentabilidad de mercado, una observación solo de rentabilidad no se convierte automáticamente en precio y las comisiones, impuestos o FX desconocidos nunca se sustituyen silenciosamente por cero.

### Planificador

El planificador sigue siendo de una sola moneda por diseño. Permite distribución por vencimientos, modo de beneficio calculado y cobertura de gastos futuros. La cantidad y el precio total pueden editarse manualmente.

Desarrollo después del checkpoint 0.9.0 publicado:

1. **DONE** — prioridad explícita de fuentes de precio;
2. **DONE** — supuestos de comisión de compra;
3. **DONE** — supuestos fiscales verificados;
4. **DONE** — supuestos FX;
5. **DONE** — supuestos de salida;
6. **DONE** — comparación neutral A/B/C;
7. **DONE** — localización del texto generado / etiquetas predefinidas + regresión;
8. **DONE** — checkpoint prerelease v0.9.0;
9. **DONE** — reserve floor / saldo mínimo;
10. **DONE** — exportaciones locales deterministas CSV/ICS; PDF aplazado;
11. **DONE** — base de vault cifrado / dominio privado / migración no destructiva; 12. **DONE** — checkpoint v0.9.2+19; 13. **DONE** — venta/amortización/historial + migración; 14. **DONE** — cupón + ledger por ISIN; 15. **DONE** — resumen de caja factual + posiciones cerradas; 16. **DOING** — checkpoint v0.9.3+20.

OVDP Hub no ejecuta operaciones ni confirma disponibilidad con un vendedor.

### Datos y privacidad

Los catálogos y escenarios se guardan en el dispositivo. En desktop se puede abrir o copiar una carpeta de trabajo. OVDP Hub no mantiene un servidor central para datos privados de cartera.

Los JSON legacy de las selecciones **no se migran automáticamente al instalar v0.9.3**. El asistente explícito copia los metadatos privados compatibles al vault cifrado y verifica la copia; los `sets/*.json` de origen permanecen en su lugar y nunca se eliminan automáticamente. No guarde claves de firma, documentos KYC u otros secretos en el workspace legacy.

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
