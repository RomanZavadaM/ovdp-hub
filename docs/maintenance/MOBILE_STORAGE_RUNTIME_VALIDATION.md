# Android / iOS mobile external-storage runtime validation

Оновлено: **26.09.2026**

## Мета

PR #130 довів implementation, contract tests і release compilation Android/iOS. Цей окремий gate має довести на реальному пристрої, що системний дозвіл на зовнішню папку переживає повний перезапуск OVDP Hub і що втрата доступу обробляється fail-closed.

Для цього PR #132 додає в `Сховище` двоетапну панель **«Перевірка мобільного сховища»**. Вона використовує той самий production `MobileExternalStorage` bridge, що й робоча папка/backup, а не тестовий mock.

## Що робить self-test

### Етап 1 — до перезапуску

1. Користувач натискає `Почати перевірку`.
2. Відкривається системний Android/iOS folder picker.
3. Програма отримує production SAF grant / iOS bookmark.
4. У вибраній папці створюється лише технічний файл:
   `OVDP-Hub-Workspace/runtime-validation/probe.json`.
5. Програма одразу перевіряє write → read → list.
6. В app-private support зберігаються лише opaque grant id, display label, probe token і id поточного запуску.
7. Панель переходить у стан `Етап 1 пройдено` і **не дозволяє завершити тест у тому самому запуску**.

### Етап 2 — після повного перезапуску

1. Повністю закрити OVDP Hub / force-stop, а не лише перейти у background.
2. Запустити застосунок знову.
3. У `Сховище` панель має показати `Новий запуск підтверджено`.
4. Натиснути `Продовжити після перезапуску`.
5. Програма через збережений production grant/bookmark виконує:
   - availability;
   - read старого probe;
   - list;
   - rewrite;
   - повторний read;
   - delete;
   - повторний list і підтвердження видалення.
6. App-private pending state видаляється тільки після повного успіху.

Успішний результат означає: **persisted external access пережив новий process launch і production I/O contract працює**.

## Fail-closed evidence

Окремим прогоном потрібно перевірити втрату доступу:

- Android: після етапу 1 зробити вибрану локацію недоступною (наприклад, від’єднати/демонтувати provider/storage або іншим способом забрати доступ), потім перезапустити OVDP Hub.
- iOS: після етапу 1 зробити file-provider location недоступною / sign out / remove provider access, потім перезапустити OVDP Hub.

Очікувано панель не створює іншу папку і не підміняє дані. Вона показує explicit `workspace.external_permission_lost` / permission-lost state.

## Android evidence card

Заповнити в Issue #18:

- Device model:
- Android version:
- Exact app build / artifact:
- Artifact SHA-256:
- Storage provider/location:
- Phase 1 write/read/list: PASS / FAIL
- Full app force-stop + relaunch performed: YES / NO
- Phase 2 persisted grant restore: PASS / FAIL
- Read/list/rewrite/read/delete/list: PASS / FAIL
- Provider/grant loss fail-closed: PASS / FAIL / NOT TESTED
- Screenshot/log reference:
- Notes:

## iOS evidence card

Заповнити в Issue #18:

- Device model:
- iOS version:
- Exact app build:
- Installation/signing method:
- Storage provider/location:
- Phase 1 write/read/list: PASS / FAIL
- Full app termination + relaunch performed: YES / NO
- Phase 2 bookmark restore: PASS / FAIL
- Security-scoped read/list/rewrite/read/delete/list: PASS / FAIL
- Provider/bookmark loss fail-closed: PASS / FAIL / NOT TESTED
- Screenshot/log reference:
- Notes:

## Важливо про iOS installation

GitHub CI artifact `iOS-unsigned` доводить compilation/package, але **unsigned build не є фізично встановлюваним доказом**. Для physical-device validation потрібен development-signed запуск через Xcode / Apple development signing або інший дозволений signed test build. Це не означає готовність App Store distribution і не закриває production signing gate.

## Acceptance

Mobile external storage можна позначити `RUNTIME VALIDATED` лише коли:

1. Android device card має phase 1 + real relaunch + phase 2 PASS.
2. iOS device card має phase 1 + real relaunch + phase 2 PASS.
3. Для обох платформ зафіксовано exact build/device/OS/provider.
4. Fail-closed provider/permission-loss behavior перевірено або окремо лишено як незакритий gate — його не можна мовчки вважати PASS.

## Межі

- Self-test не змінює encrypted Portfolio schema/crypto.
- Self-test не пише приватні дані портфеля.
- Probe-файл технічний і видаляється після успішного етапу 2 або при `Скинути перевірку` (best effort при вже втраченому provider access).
- Production signing / App Store / Play Store readiness залишається окремим етапом.

Status: **HARNESS IN PR #132; PHYSICAL-DEVICE EVIDENCE PENDING**.
