# START_HERE — OVDP Hub

> Перша точка входу для нового чату або відновлення після обриву.

## Startup protocol

Перед будь-якою роботою:

1. Прочитати `PROJECT_RULES.md`.
2. Прочитати `PROJECT_STATE.md`.
3. Прочитати `WORKLOG.md`.
4. Перевірити фактичний GitHub: `main` SHA, відкриті PR, active PR head, останні workflow runs.
5. Прочитати останні записи GitHub Issue **#18**.
6. Якщо GitHub і текст суперечать одне одному — GitHub має пріоритет, після чого документацію треба синхронізувати.
7. Продовжити перший `DOING` / `NEXT`; merged роботу не повторювати.

## Джерела істини

- `PROJECT_RULES.md` — незмінні правила проєкту.
- `PROJECT_STATE.md` — лише підтверджений інтегрований стан `main`.
- `WORKLOG.md` — активний slice / точний NEXT.
- GitHub Issue #18 — append-only development ledger.
- `apps/native/pubspec.yaml` — machine source version/build.
- `docs/roadmap.md` — середньостроковий roadmap.
- `CHANGELOG.md` і `docs/releases/` — історія релізів.

## Команда власника «злити у main»

**«злити у main / зливай у main»** означає повний test-release checkpoint, а не простий merge:

1. new version/build;
2. green exact-head PR checks;
3. merge у `main`;
4. Windows/macOS/Android/iOS + START/source;
5. packaged desktop executable smoke;
6. SHA256/legal notices;
7. immutable tag + GitHub prerelease;
8. asset verification;
9. docs/worklog/ledger sync.

## Поточний технічний контекст

- Repository: `RomanZavadaM/ovdp-hub`
- Active product: `apps/native` Flutter/Dart
- Published checkpoint: **v0.9.3 / 0.9.3+20**
- Published release commit: `e2ec96322a1acb953589eeeb45e8ec50cd5d198a`
- Current integrated `main`: **`e6e0a6ae3fb74b6fab8adf155eb6d3d338a11959`**
- Platforms: Windows / macOS / Android / iOS
- Languages: UK / EN / FR / DE / ES / KO / JA

## Останні інтегровані slices

- macOS Portfolio Keychain runtime validation + enablement — PR #127 → `4c1617b3…`.
- Mobile external-storage foundation — PR #130 → `5934984a…` — DONE.
- Post-merge state sync — PR #131 → `587d88d1…` — DONE.
- Mobile external-storage real-device runtime probe harness — **PR #132 → `e6e0a6ae…` — DONE for implementation/CI scope**.

### PR #132 — підтверджений стан

Інтегровано production-backed двоетапний self-test у розділ **«Сховище»** на Android/iOS:

- phase 1: system folder picker → technical probe write → read → list;
- pending state зберігає opaque grant/bookmark reference, label, token і launch id;
- той самий process launch не може завершити тест — потрібен реальний terminate/relaunch;
- phase 2: persisted grant/bookmark availability → old probe read/list → rewrite/read → delete → final list verification;
- permission/provider loss показується fail-closed;
- UI локалізований UK / EN / FR / DE / ES / KO / JA;
- панель показує app version + OS для evidence screenshot;
- протокол тестування: `docs/maintenance/MOBILE_STORAGE_RUNTIME_VALIDATION.md`.

Exact PR head: `4d59750c0bea01d39cf495ab054befc1beb6e266`.

Final Ready run **#511 — SUCCESS**:
- verify success;
- Windows packaged release + smoke success;
- macOS packaged release + smoke success;
- Android release APK compile/package success;
- iOS unsigned release compile/package success.

Artifacts #511:
- Windows `OVDP-Hub-0.9.3-b20-windows-511-1-089f849`, SHA-256 `749375aa8666c2205840d2f41723ffdd3526fe017d219337dae78952f5374214`;
- macOS `OVDP-Hub-0.9.3-b20-macos-511-1-089f849`, SHA-256 `4664f2cdea03d4fcb61469037192c395c0fc8a92f9e62af61e6a94a091a69431`;
- Android `OVDP-Hub-Android-test-511-1`, SHA-256 `9e848a0330986f67e6df1c0c98413e34c8ce2ace5dbd3b5e6cacc781ca3894e0`;
- iOS `OVDP-Hub-iOS-unsigned-511-1`, SHA-256 `ab5a6755ffd016d4b3e38892e2ac45f1694e80c0245dbfbdd89f5be6b959872a`.

PR #132 squash-merged у `main` як **`e6e0a6ae3fb74b6fab8adf155eb6d3d338a11959`**.

Post-merge run **#512 — SUCCESS**:
- `flutter analyze` success;
- **218/218 tests** success;
- START/source success.

START artifact: `OVDP-Hub-0.9.3-test-512-1-START`, SHA-256 `a9d62bd77b433c26f3ab9fdfa4d1ac9b8b385dab22b4e5b2a5b6a12798e4a4f9`.

## Межа доказу

Implementation, regression tests і cross-platform compile/package gate для harness закриті.

**Ще не доведено фізичним device evidence:**
- Android SAF persisted URI grant після terminate/relaunch;
- Android revoked grant/provider-loss behavior на реальному пристрої;
- iOS bookmark restore після terminate/relaunch;
- iOS stale/lost/provider/security-scope edge cases на реальному пристрої.

CI не може оголосити ці сценарії `RUNTIME VALIDATED` самостійно.

## NEXT

**Реальний Android/iOS external-storage runtime validation через уже інтегровану self-test панель.**

Порядок:
1. Android: встановити test APK з run #511.
2. Відкрити `Сховище` → mobile storage validation → почати тест → вибрати реальну папку/provider.
3. Повністю завершити застосунок і запустити знову; завершити phase 2.
4. Окремо перевірити revoke/provider loss → fail-closed.
5. Записати device model / OS / app version / provider / outcome + screenshot у Issue #18 за шаблоном `docs/maintenance/MOBILE_STORAGE_RUNTIME_VALIDATION.md`.
6. iOS: виконати той самий протокол на development-signed build/Xcode; unsigned CI artifact є лише compile evidence і на iPhone не встановлюється як тестова збірка.
7. Лише після Android + iOS evidence змінити статус на `RUNTIME VALIDATED`.

Production signing/notarization/store distribution лишається окремим пізнішим gate.

## Rule for new chats

Recommended phrase:

> **Продовжуємо OVDP Hub. Відкрий у GitHub `START_HERE.md` і продовжуй строго за ним.**

Цього достатньо: не покладатися на пам’ять старого чату й не відновлювати merged branches як джерела коду.
