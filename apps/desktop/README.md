# ОВДП Hub для Windows і macOS

Desktop-клієнт — це Tauri 2 оболонка над тим самим статичним Next.js застосунком, який працює у Web/PWA. Вона не додає серверного сховища: локальні налаштування та майбутні приватні дані зберігаються на пристрої користувача.

## Локальний запуск

Потрібні Node.js, pnpm та Rust toolchain із системними залежностями Tauri.

```bash
pnpm install
pnpm desktop:dev
```

Для production-збірки:

```bash
pnpm desktop:build
```

Tauri збирає web-ресурси з `apps/web/out` і створює інсталятори для поточної платформи. Windows збирається у Windows runner, macOS — у macOS runner; релізний workflow додамо після першої перевірки локальної оболонки.
