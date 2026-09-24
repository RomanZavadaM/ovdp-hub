# OVDP Hub v0.9.2 — 0.9.2+19

Дата: 24.09.2026  
Статус: test / prerelease

---

## Українська

### Що нового
- **«Економічний пульс»** постійно видимий у shell: USD/UAH, EUR/UAH з НБУ, дохідність останнього гривневого аукціону ОВДП і дата найближчого аукціону з Мінфіну. Кожен показник має дату/джерело; відсутні дані не підміняються вигаданими значеннями.
- **«Мій портфель»** став окремим user-facing розділом у Classic / «Робочому кабінеті» / «Світлій панелі».
- Перший фактичний portfolio flow: створення локального зашифрованого портфеля, відкриття/блокування, додавання фактичної покупки ОВДП і derived holdings.
- Портфель використовує наявний encrypted-vault/private-portfolio schema; паралельного plaintext-сховища не створюється.
- UI портфеля та «Економічного пульсу» локалізовано UK/EN/FR/DE/ES/KO/JA.

### Реальні release-тести
Після виявленої невідповідності між кодом і фактичною Windows-збіркою release gate посилено:
- widget regression відкриває реальний selector дизайну і перемикає **Classic → «Робочий кабінет» → «Світла панель»**;
- user-flow tests натискають реальні NavigationBar / NavigationRail / StudioSidebar controls;
- version/build у UI походить з build metadata, а не hardcoded рядка;
- Windows і macOS jobs пакують ZIP, потім **розпаковують саме цей ZIP і запускають packaged executable**;
- executable видає release contract, який перевіряє product, version/build і рівно три appearance: `classic/studio/dashboard`;
- artifact, що не пройшов smoke, не може бути опублікований.

### Важливі межі
- Legacy `sets/*.json` не шифруються автоматично; migration/cleanup wizard ще окремий наступний user-facing gate.
- macOS user-facing portfolio unlock лишається обмеженим до завершення Data Protection Keychain runtime/provisioning gate.
- Android SAF / iOS security-scoped external-folder access відкладено до мобільного storage slice.
- OVDP Hub не виконує операції купівлі/продажу; ринкові дані й розрахунки потрібно звіряти з первинними джерелами.

---

## English

### What’s new
- Persistent **Economic Pulse** in the app shell: NBU USD/UAH and EUR/UAH, latest UAH OVDP auction yield, and the next MinFin auction date, each with explicit source/date and fail-closed unavailable states.
- **My portfolio** is now a user-facing section in Classic, Workbench, and Light Dashboard.
- First factual portfolio flow: create a local encrypted portfolio, open/lock it, add a factual OVDP purchase, and view derived holdings.
- The flow reuses the existing encrypted vault/private portfolio schema; no parallel plaintext portfolio database is introduced.
- Portfolio and Economic Pulse UI are localized in UK/EN/FR/DE/ES/KO/JA.

### Real release verification
The release gate now tests the exact packaged desktop artifact:
- the UI regression opens the real appearance selector and switches all three modes;
- navigation tests use real visible controls;
- displayed version/build come from build metadata;
- Windows/macOS ZIPs are extracted and the packaged executable itself is launched;
- the executable release contract must report the expected product, version/build, and exactly `classic/studio/dashboard`;
- a failing packaged artifact cannot be published.

### Important boundaries
- Legacy `sets/*.json` are not automatically encrypted; migration/cleanup wizard remains a separate user-facing gate.
- macOS user-facing portfolio unlock still depends on the Data Protection Keychain runtime/provisioning gate.
- Android SAF / iOS security-scoped external-folder access remains deferred.
- OVDP Hub does not execute trades.

---

## Français

### Nouveautés
- **Pouls économique** permanent : USD/UAH, EUR/UAH (NBU), rendement de la dernière adjudication OVDP en UAH et date de la prochaine adjudication MinFin, avec source/date explicites.
- **Mon portefeuille** devient une section visible dans Classic, Workbench et Light Dashboard.
- Premier flux factuel : créer un portefeuille local chiffré, l’ouvrir/le verrouiller, ajouter un achat réel d’OVDP et afficher les positions dérivées.
- Aucune base plaintext parallèle : le flux réutilise le vault chiffré existant.
- UI localisée UK/EN/FR/DE/ES/KO/JA.

### Vérification de release
Les ZIP Windows/macOS sont maintenant extraits et **l’exécutable réellement emballé** est lancé. Son contrat de release doit confirmer le produit, la version/build et exactement trois apparences : `classic/studio/dashboard`. Un artifact qui échoue n’est pas publié.

### Limites
- Les anciens `sets/*.json` ne sont pas chiffrés automatiquement.
- Le déverrouillage user-facing macOS reste soumis au gate Data Protection Keychain.
- Android SAF / iOS security-scoped access reste différé.

---

## Deutsch

### Neu
- Permanenter **Wirtschaftspuls** mit USD/UAH, EUR/UAH (NBU), letzter UAH-OVDP-Auktionsrendite und nächstem MinFin-Auktionstermin samt Quelle/Datum.
- **Mein Portfolio** ist jetzt in Classic, Workbench und Light Dashboard sichtbar.
- Erster faktischer Portfolio-Flow: lokales verschlüsseltes Portfolio erstellen, öffnen/sperren, realen OVDP-Kauf erfassen und abgeleitete Bestände anzeigen.
- Keine parallele Plaintext-Datenbank; der vorhandene verschlüsselte Vault wird verwendet.
- UI in UK/EN/FR/DE/ES/KO/JA.

### Release-Prüfung
Windows/macOS-ZIPs werden extrahiert und der **tatsächlich gepackte Executable** wird gestartet. Der Release-Contract muss Produkt, Version/Build und genau `classic/studio/dashboard` bestätigen. Ein fehlerhaftes Artifact wird nicht veröffentlicht.

### Grenzen
- Legacy-`sets/*.json` werden nicht automatisch verschlüsselt.
- macOS Portfolio-Unlock bleibt bis zum Data-Protection-Keychain-Gate eingeschränkt.
- Android SAF / iOS security-scoped access bleibt zurückgestellt.

---

## Español

### Novedades
- **Pulso económico** permanente: USD/UAH, EUR/UAH (NBU), rendimiento de la última subasta OVDP en UAH y próxima fecha de subasta MinFin, con fuente/fecha explícitas.
- **Mi cartera** aparece como sección visible en Classic, Workbench y Light Dashboard.
- Primer flujo factual: crear cartera local cifrada, abrir/bloquear, añadir una compra real de OVDP y ver holdings derivados.
- No se crea una base plaintext paralela; se reutiliza el vault cifrado existente.
- UI localizada UK/EN/FR/DE/ES/KO/JA.

### Verificación de release
Los ZIP de Windows/macOS se extraen y se ejecuta **el binario realmente empaquetado**. Su contrato debe confirmar producto, versión/build y exactamente `classic/studio/dashboard`. Un artifact que falle no se publica.

### Límites
- Los `sets/*.json` antiguos no se cifran automáticamente.
- El desbloqueo de portfolio en macOS sigue dependiendo del gate Data Protection Keychain.
- Android SAF / iOS security-scoped access sigue aplazado.

---

## 한국어

### 변경 사항
- NBU USD/UAH, EUR/UAH, 최근 UAH OVDP 경매 수익률, 다음 MinFin 경매일을 날짜/출처와 함께 보여주는 상시 **경제 지표**.
- Classic / Workbench / Light Dashboard에 **내 포트폴리오** 사용자 화면 추가.
- 로컬 암호화 포트폴리오 생성, 열기/잠금, 실제 OVDP 매수 추가, derived holdings 표시.
- 별도 plaintext 포트폴리오 DB 없이 기존 encrypted vault/private schema를 사용.
- UK/EN/FR/DE/ES/KO/JA UI.

### 실제 release 검증
Windows/macOS ZIP을 실제로 풀고 **그 안의 executable 자체를 실행**해 product, version/build, 그리고 정확히 `classic/studio/dashboard` 3개 appearance를 검증합니다. 실패한 artifact는 공개되지 않습니다.

### 범위
- 기존 `sets/*.json`은 자동 암호화되지 않습니다.
- macOS portfolio unlock은 Data Protection Keychain gate 완료 전까지 제한됩니다.
- Android SAF / iOS security-scoped access는 연기됩니다.

---

## 日本語

### 変更点
- NBU の USD/UAH・EUR/UAH、直近 UAH OVDP 入札利回り、次回 MinFin 入札日を日付/出典付きで常時表示する **経済パルス**。
- Classic / Workbench / Light Dashboard に **マイポートフォリオ** を追加。
- ローカル暗号化ポートフォリオの作成、開く/ロック、実購入 OVDP の追加、derived holdings 表示。
- 別の plaintext portfolio DB は作らず、既存 encrypted vault/private schema を利用。
- UK/EN/FR/DE/ES/KO/JA UI。

### 実際の release 検証
Windows/macOS ZIP を実際に展開し、**その ZIP 内の executable 自体を起動**して product、version/build、正確に `classic/studio/dashboard` の3 appearanceを確認します。失敗した artifact は公開されません。

### 境界
- 既存 `sets/*.json` は自動暗号化されません。
- macOS portfolio unlock は Data Protection Keychain gate 完了まで制限されます。
- Android SAF / iOS security-scoped access は延期されています。

---

## Packaging / Пакування

Очікувані assets:
- `OVDP-Hub-0.9.2-Windows-x64.zip`
- `OVDP-Hub-0.9.2-macOS.zip`
- `OVDP-Hub-0.9.2-Android-test.zip`
- `OVDP-Hub-0.9.2-iOS-unsigned.zip`
- `OVDP-Hub-0.9.2-START.zip`
- `SHA256SUMS.txt`
- legal notices
