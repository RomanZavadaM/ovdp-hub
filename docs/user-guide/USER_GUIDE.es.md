# OVDP Hub v0.9.3 — Guía de usuario

## Finalidad
OVDP Hub es una aplicación local-first para bonos estatales ucranianos OVDP: fuentes de mercado, planificación de escenarios, comparación y cartera personal cifrada con datos factuales. La aplicación no ejecuta operaciones.

## Instalación
**Windows:** extraiga todo el ZIP y ejecute `ovdp_hub.exe`. Mantenga DLL y recursos junto al ejecutable. El prerelease no tiene firma de producción, por lo que SmartScreen puede aparecer.

**macOS:** extraiga el ZIP y abra `ovdp_hub.app`. El prerelease no está notarizado; después de un primer bloqueo, macOS puede ofrecer **Open Anyway** en System Settings → Privacy & Security.

**Android:** extraiga el ZIP Android e instale `OVDP-Hub.apk`. Es un build de prueba firmado en modo desarrollo.

**iOS:** el paquete publicado es unsigned y requiere signing/provisioning Apple por separado.

## Idioma y apariencia
Idiomas: ucraniano, inglés, francés, alemán, español, coreano y japonés. Apariencias: Classic, Workbench y Light Dashboard.

## Mercado e ISIN
El catálogo permite buscar y filtrar OVDP. La ficha ISIN mantiene separados NBU, MinFin y vendedores y muestra fecha, fuente y freshness/status. Un yield-only o el nominal nunca se convierte silenciosamente en precio negociable.

## Planificador
Un escenario usa una sola divisa base. Configure presupuesto, reserva, horizonte, necesidades, posiciones, comisiones, impuestos, FX, salida anticipada, reserve floor y necesidades puntuales/recurrentes. Los valores desconocidos deben seguir siendo desconocidos y no convertirse en cero.

A/B/C compara 2–3 escenarios compatibles sin elegir automáticamente un ganador. Los CSV/ICS se guardan localmente en `exports/`.

## Mi cartera
La cartera es un flujo local cifrado con crear/abrir/bloquear.

**Compra:** registre ISIN/fecha/unidades/importe y estado de comisión.

**Venta:** asigne explícitamente la venta a lotes de adquisición; no se inventa FIFO/LIFO.

**Cupón / amortización:** registre solo importes realmente recibidos.

**Ledger por ISIN:** conserva compras/ventas/cupones/amortizaciones; las posiciones cerradas siguen visibles.

**Resumen de caja factual:** muestra compras, ingresos de ventas, cupones, amortizaciones y comisiones conocidas por divisa. Si una comisión relevante es desconocida, no se muestra un resultado neto exacto.

No es una valoración de mercado ni una métrica de rendimiento, porque no añade el valor de mercado actual de posiciones abiertas.

## Migración legacy
El asistente copia datos legacy compatibles al payload cifrado y verifica la copia. La migración es no destructiva: el JSON fuente nunca se elimina automáticamente.

## Copias de seguridad y actualizaciones
Antes de una actualización importante, bloquee la cartera, haga copia del workspace, verifique el backup cifrado portátil y guarde el recovery material por separado. Para actualizar desktop, use una nueva carpeta del programa y conserve los datos hasta verificar la nueva versión.

En Windows, **Mi cartera** puede crear una copia cifrada portátil y restaurar con ella una cartera local vacía. El secreto de recuperación se introduce dos veces al crear la cartera y puede cambiarse después. Los flujos de archivos externos Android/iOS siguen diferidos hasta la etapa SAF/security-scoped separada.

## Verificación y problemas comunes
Use `SHA256SUMS.txt` para verificar descargas. SmartScreen o avisos de macOS son posibles en este prerelease sin firma de producción. “Unknown fee” es un estado intencional. El paquete iOS unsigned no se instala directamente.

## Límites
OVDP Hub no es un bróker. Verifique precios, comisiones, impuestos, fechas y condiciones con fuentes primarias y su banco/bróker antes de actuar financieramente.
