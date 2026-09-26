# OVDP Hub v0.9.4 — 0.9.4+21

Дата: 26.09.2026  
Статус: test / prerelease — **parked checkpoint**

Це контрольний реліз, яким проєкт **OVDP Hub закривається на поточному рівні**. Нові функції після цього checkpoint не плануються, доки власник окремо не відновить розробку.

---

## Українська

### Що увійшло після v0.9.3
- підтвердження та rotation recovery secret, Windows portable encrypted backup/restore;
- безпечне редагування критеріїв і дат Planner без тихого скидання сформованого сценарію;
- повна локалізація Catalog та збереження language/appearance preferences;
- спільний locale-friendly date control для Planner + Portfolio;
- macOS Keychain runtime-перевірка та ввімкнення encrypted Portfolio на macOS;
- Android SAF та iOS security-scoped external-storage foundation;
- зовнішній mobile workspace і encrypted backup transport з fail-closed semantics;
- вбудований двоетапний Android/iOS runtime self-test після terminate/relaunch;
- CI gates: 218/218 tests, Windows/macOS packaged smoke, Android release APK, unsigned iOS release compile.

### Межі checkpoint
- Android physical-device SAF persistence/revoke сценарії **не оголошуються runtime-validated** і відкладені.
- iOS development signing і фізичний iPhone runtime test **відкладені**.
- Windows production signing, macOS notarization, Android/iOS store distribution та installers/auto-update відкладені.
- iOS asset лишається unsigned compile/test package.
- OVDP Hub не виконує купівлю/продаж цінних паперів і не є брокером.

### Статус розвитку
Після v0.9.4 проєкт має статус **PARKED / завершений на поточному рівні**. Повернення до розробки починається з `START_HERE.md`, `PROJECT_STATE.md` і `WORKLOG.md`; завершені PR/slices не повторювати.

---

## English

### Included since v0.9.3
- recovery-secret confirmation/rotation and Windows portable encrypted backup/restore;
- safe Planner criteria/date editing without silent scenario reset;
- Catalog localization and persisted language/appearance preferences;
- shared locale-friendly date controls for Planner and Portfolio;
- macOS Keychain runtime proof and encrypted Portfolio enablement;
- Android SAF and iOS security-scoped external-storage foundation;
- mobile external workspace and encrypted backup transport with fail-closed semantics;
- integrated two-phase Android/iOS runtime self-test across terminate/relaunch;
- CI gates: 218/218 tests, Windows/macOS packaged smoke, Android release APK and unsigned iOS release compile.

### Checkpoint boundaries
- Android physical-device SAF persistence/revoke behavior is **not claimed runtime-validated** and is deferred.
- iOS development signing and physical iPhone runtime validation are deferred.
- Production signing/notarization/store distribution/installers/auto-update remain deferred.
- The iOS asset remains an unsigned compile/test package.
- OVDP Hub does not execute trades and is not a broker.

### Development status
After v0.9.4 the project is **PARKED / complete at the current scope** until the owner explicitly reopens development.

---

## Français

### Inclus depuis v0.9.3
- confirmation/rotation du secret de récupération et sauvegarde/restauration chiffrée portable sous Windows;
- édition sûre des critères/dates du Planner sans réinitialisation silencieuse;
- localisation du catalogue et persistance de la langue/de l’apparence;
- contrôles de date partagés Planner + Portfolio;
- validation Keychain macOS et activation du Portfolio chiffré;
- fondation Android SAF et iOS security-scoped pour le stockage externe;
- workspace mobile externe, transport de sauvegarde chiffrée et test runtime en deux phases;
- CI: 218/218 tests, smoke Windows/macOS, APK Android et build iOS non signé.

### Limites
Les validations physiques Android SAF et iOS signé/iPhone sont différées. La signature de production, la notarisation, la distribution store, les installateurs et l’auto-update restent différés. Le projet est **PARKED** au périmètre actuel.

---

## Deutsch

### Seit v0.9.3 enthalten
- Bestätigung/Rotation des Recovery-Secrets und portables verschlüsseltes Windows-Backup/Restore;
- sichere Planner-Kriterien/Datumsbearbeitung ohne stillen Reset;
- Katalog-Lokalisierung und persistente Sprache/Appearance;
- gemeinsame Datumssteuerung für Planner + Portfolio;
- macOS-Keychain-Runtime-Prüfung und Aktivierung des verschlüsselten Portfolios;
- Android SAF / iOS security-scoped External-Storage-Grundlage;
- externer Mobile-Workspace, verschlüsselter Backup-Transport und zweiphasiger Runtime-Self-Test;
- CI: 218/218 Tests, Windows/macOS Packaged Smoke, Android APK, unsigned iOS Build.

### Grenzen
Physische Android-SAF- und signierte iOS/iPhone-Runtime-Validierung sind aufgeschoben. Production Signing/Notarization/Store Distribution/Installer/Auto-Update bleiben deferred. Projektstatus: **PARKED**.

---

## Español

### Incluido desde v0.9.3
- confirmación/rotación del recovery secret y backup/restore cifrado portable en Windows;
- edición segura de criterios/fechas del Planner sin reset silencioso;
- localización del catálogo y persistencia de idioma/apariencia;
- controles de fecha compartidos Planner + Portfolio;
- validación runtime de Keychain en macOS y activación del Portfolio cifrado;
- base Android SAF e iOS security-scoped para almacenamiento externo;
- workspace móvil externo, transporte de backup cifrado y self-test runtime en dos fases;
- CI: 218/218 tests, smoke Windows/macOS, APK Android y build iOS unsigned.

### Límites
La validación física Android SAF y la validación iOS firmada/iPhone quedan aplazadas. También quedan aplazados production signing/notarization/store distribution/installers/auto-update. Estado del proyecto: **PARKED**.

---

## 한국어

### v0.9.3 이후 포함 사항
- recovery secret 확인/회전 및 Windows portable encrypted backup/restore;
- 기존 시나리오를 조용히 초기화하지 않는 Planner 기준/날짜 편집;
- Catalog 전체 로컬라이즈 및 언어/appearance 저장;
- Planner + Portfolio 공용 locale-friendly 날짜 컨트롤;
- macOS Keychain runtime 검증과 encrypted Portfolio 활성화;
- Android SAF 및 iOS security-scoped 외부 저장소 기반;
- mobile external workspace, encrypted backup transport, terminate/relaunch 2단계 self-test;
- CI: 218/218 tests, Windows/macOS packaged smoke, Android APK, unsigned iOS build.

### 범위
실기기 Android SAF persistence/revoke 검증과 signed iOS/iPhone runtime 검증은 연기합니다. Production signing/notarization/store distribution/installers/auto-update도 연기합니다. 프로젝트 상태는 **PARKED** 입니다.

---

## 日本語

### v0.9.3 以降に含まれるもの
- recovery secret の確認/rotation と Windows portable encrypted backup/restore;
- 生成済みシナリオを黙って消さない Planner 条件・日付編集;
- Catalog のローカライズと language/appearance の永続化;
- Planner + Portfolio 共通の locale-friendly date control;
- macOS Keychain runtime 検証と encrypted Portfolio の有効化;
- Android SAF / iOS security-scoped external storage 基盤;
- mobile external workspace、暗号化 backup transport、terminate/relaunch を跨ぐ二段階 self-test;
- CI: 218/218 tests、Windows/macOS packaged smoke、Android APK、unsigned iOS build。

### 境界
Android 実機 SAF persistence/revoke と signed iOS/iPhone runtime validation は延期します。Production signing/notarization/store distribution/installers/auto-update も延期です。プロジェクト状態は **PARKED** です。

---

## Packaging / Пакування

Очікувані assets:
- `OVDP-Hub-0.9.4-Windows-x64.zip`
- `OVDP-Hub-0.9.4-macOS.zip`
- `OVDP-Hub-0.9.4-Android-test.zip`
- `OVDP-Hub-0.9.4-iOS-unsigned.zip`
- `OVDP-Hub-0.9.4-START.zip`
- `SHA256SUMS.txt`
- legal notices
