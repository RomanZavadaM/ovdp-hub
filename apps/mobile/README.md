# Мобільний застосунок

Кросплатформний Expo Router каркас для iOS, Android і web. Працює з тим самим `@ovdp/market-data` і має вкладки «Каталог», «Аукціони» та «Калькулятор».

```sh
pnpm --filter @ovdp/mobile install
pnpm --filter @ovdp/mobile start
```

Поточний зріз уже показує каталог НБУ з pull-to-refresh, пошуком ISIN і валютними фільтрами. Калькулятор підключається до спільного пакета на наступному кроці.

Приватні дані, портфель і ключі не мають серверного сховища. Для майбутнього локального vault використовуємо SecureStore/Keychain/Keystore після окремого threat model review.
