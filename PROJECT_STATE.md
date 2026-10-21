# PROJECT_STATE — OVDP Hub

Оновлено: **21.10.2026**

## Джерело правди

- Активний продукт: Flutter/Dart у `apps/native`.
- Платформи checkpoint: Windows, macOS, Android та iOS unsigned.
- UI: UK / EN / FR / DE / ES / KO / JA.
- Останній опублікований prerelease: **v0.10.1 / 0.10.1+23**.
- Поточний `main`: F5 private collections інтегровано squash-комітом `c6fcdecd4edfbe0ad681195b17bf48df77abfd52`.
- Активний наступний slice: PR #157 `feat/public-broker-offers-20261021`; ще не merged і не released.
- Кандидат наступного release checkpoint: **v0.11.0 / 0.11.0+24**, лише після фінальних exact-head і post-merge gates.

## Інтегровано після v0.10.1

### F5 — приватні добірки

Приватні добірки з назвою та нотаткою зберігаються в encrypted vault, підтримують create/edit/reopen і очищення приватної чернетки при lock. Публічні annotation-free списки ISIN працюють без портфеля. Явне перенесення старого plaintext-файла видаляє джерело тільки після перевірки повної encrypted-копії, незмінності source та чинної vault-авторизації; невідоме поле, конфлікт, lock або помилка працюють fail-closed. Payload schema v5 читає v1–v4; crypto/KDF не змінено.

Exact-head F5 gates пройдено: analyze/tests, Windows/macOS packaged ZIP smoke, Android release та iOS unsigned. Post-merge main verification також успішна. Докази записано в Issue #18.

## Активна перевірка

PR #157 додає незалежні read-only adapters для публічних сторінок Inzhur і UNIVER та поєднує їх з наявними observations ПриватБанку. Зіставлення перевіряє ISIN, currency і maturity. Price, yield, quantity, source timestamp та retrievedAt не змішуються; missing data лишається unknown. Збій одного provider не приховує інші джерела, а останнє успішне observation зберігає власний час разом з error marker.

Немає broker login/OTP, приватних endpoints, виконання угод, копіювання стороннього коду чи твердження про партнерство. Деталі: `docs/PUBLIC_BROKER_SOURCES_20261021.md`.

## Межа доказу

CI/compile/package evidence не дорівнює physical-device runtime validation. Відкладені: Android physical-device SAF, signed iOS device validation, production signing, notarization, stores, installers та auto-update.

Історія: `CHANGELOG.md`, `WORKLOG.md`, `docs/releases/`, merged PR та Issue #18.
