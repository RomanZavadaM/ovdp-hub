# OVDP Hub v0.10.0 — 0.10.0+22

Дата: 02.10.2026  
Статус: test / prerelease

Перший етап після відновлення розробки: захист приватних даних за результатами аудиту коду від 01.10.2026 та перші продуктові можливості для реальних розрахунків.

---

## Українська

### Захист приватних даних
- **Пароль відновлення при відкритті портфеля (опція).** Ключ пристрою видаляється, портфель відкривається лише після введення пароля; ключ живе тільки в пам'яті відкритої сесії. Захист від відкату ревізій зберігається.
- **Сценарії Planner із приватними сумами — лише в зашифрованому портфелі.** Без портфеля або коли він заблокований застосунок пояснює це й нічого не пише у відкриту робочу папку. «Добірки» позначають, де зберігається сценарій, і переносять старі відкриті сценарії у vault; відкриті файли видаляються тільки після перевірки зашифрованої копії.
- **Керування локальним портфелем:** видалення з явним підтвердженням (також вихід, якщо пароль забуто); відновлення старішої резервної копії лише після підтвердження; зрозумілі повідомлення про конфлікти.
- Argon2id виконується у фоновому потоці — інтерфейс не зависає під час створення, відкриття паролем, відновлення чи зміни пароля.
- CSV-експорт захищений від виконання формул у таблицях; ICS не містить «голих» `\r`.
- На Windows/macOS перемикання на інше вікно більше не блокує портфель за 15 секунд (згортання й таймер бездіяльності діють як раніше).

### Нові можливості
- **Калькулятор облігації з каталогу:** обраний випуск, дата розрахунку, чиста ціна та комісія у валюті випуску; НКД за графіком НБУ (орієнтовно) і дохідність до погашення XIRR ACT/365F. Синтетичний навчальний приклад лишився як режим за замовчуванням.
- **Очікувані надходження портфеля на 12 місяців** за графіком НБУ та підказки «можливо, не записано» для минулих виплат із кнопкою, що відкриває заповнений запис купона.
- **Річна дохідність плану** в Planner (XIRR ACT/365F, без реінвестування, з відомою комісією) поряд із прибутком до погашення.
- Оновлення каталогу НБУ більше не падає через один невідомий рядок: такі рядки відкладаються в `rejected`; якщо відхилено понад половину — оновлення зупиняється як ймовірна зміна формату.
- Android: файлові операції резервної копії виконуються поза UI-потоком; повторний вибір тієї ж папки не створює нових записів доступу.

### Сумісність
- Зашифрований payload портфеля: схема **v4** (`privateScenarios`); дані v1–v3 відкриваються без змін. Попередні версії застосунку не відкриють портфель після запису в v4.
- Сценарії з приватними сумами більше не синхронізуються між пристроями через спільну папку.

### Межі
- Фізична перевірка Android SAF/iOS, підписування, нотаризація, магазини, інсталятори й автооновлення лишаються відкладеними.
- НКД і дохідності — орієнтовні розрахунки, а не котирування чи інвестиційна рекомендація.
- OVDP Hub не виконує купівлю/продаж цінних паперів і не є брокером.

---

## English

### Privacy protection
- **Optional recovery password on portfolio open.** The device key is removed; the portfolio opens only after the password is entered and the key lives only in memory for the open session. Rollback protection is preserved.
- **Planner scenarios with private amounts are stored only in the encrypted portfolio.** Without an open portfolio the app explains why and writes nothing to the plaintext workspace. Collections mark where a scenario is stored and move old plaintext scenarios into the vault; plaintext files are deleted only after the encrypted copy is verified.
- **Local portfolio management:** deletion behind explicit confirmation (also the way out after a forgotten password); restoring an older backup only after confirmation; clear conflict messages.
- Argon2id runs on a background isolate, so the UI no longer freezes.
- CSV export is protected against spreadsheet formula execution; ICS never contains a bare `\r`.
- On Windows/macOS switching to another window no longer locks the portfolio after 15 seconds.

### New capabilities
- **Catalog bond calculator:** selected issue, settlement date, clean price and fee in the issue currency; indicative accrued interest from the NBU schedule and yield to maturity (XIRR ACT/365F).
- **Expected portfolio receipts for 12 months** from the NBU schedule, plus "possibly not recorded" hints for past payments with a prefilled coupon entry.
- **Plan annual yield** in Planner (XIRR ACT/365F, no reinvestment, known fee included) next to profit to maturity.
- The NBU catalog refresh no longer fails on a single unexpected row; such rows are listed as `rejected`, and more than half rejected still stops the refresh.
- Android: backup file I/O runs off the UI thread; re-selecting a folder reuses its grant.

### Compatibility
- Encrypted portfolio payload schema **v4** (`privateScenarios`); v1–v3 data open unchanged. Older app versions cannot open a portfolio written as v4.
- Scenarios with private amounts no longer sync between devices through a shared folder.

### Boundaries
Physical Android SAF/iOS validation, signing, notarization, stores, installers and auto-update remain deferred. Accrued interest and yields are indicative calculations, not quotes or investment advice. OVDP Hub does not execute trades and is not a broker.

---

## Français

- **Mot de passe de récupération à l’ouverture (option)** : la clé de l’appareil est supprimée et le portefeuille ne s’ouvre qu’avec le mot de passe.
- **Scénarios du Planner avec montants privés uniquement dans le portefeuille chiffré**, avec migration vérifiée des anciens fichiers en clair.
- Suppression du portefeuille local avec confirmation, restauration confirmée d’une sauvegarde plus ancienne.
- Argon2id en arrière-plan, export CSV protégé contre les formules, pas de verrouillage sur simple perte de focus sous Windows/macOS.
- **Calculateur d’obligation du catalogue** (intérêts courus indicatifs, rendement à l’échéance), **encaissements attendus sur 12 mois** du portefeuille, **rendement annuel du plan**.
- Rafraîchissement du catalogue NBU tolérant aux lignes inattendues.
- Schéma de portefeuille chiffré **v4** ; les anciennes versions ne peuvent pas l’ouvrir. Les validations physiques, la signature et la distribution restent différées. Pas de conseil en investissement.

---

## Deutsch

- **Wiederherstellungspasswort beim Öffnen (optional)**: Der Geräteschlüssel wird entfernt; das Portfolio öffnet sich nur mit dem Passwort.
- **Planner-Szenarien mit privaten Beträgen nur im verschlüsselten Portfolio**, mit geprüfter Übernahme alter Klartextdateien.
- Löschen des lokalen Portfolios mit Bestätigung, bestätigte Wiederherstellung älterer Sicherungen.
- Argon2id im Hintergrund, CSV-Export gegen Formeln geschützt, keine Sperre bei bloßem Fokusverlust unter Windows/macOS.
- **Anleiherechner für den Katalog** (Stückzinsen als Richtwert, Rendite bis Fälligkeit), **erwartete Portfolio-Eingänge für 12 Monate**, **Jahresrendite des Plans**.
- NBU-Katalogaktualisierung tolerant gegenüber unerwarteten Zeilen.
- Verschlüsseltes Portfolio-Schema **v4**; ältere Versionen können es nicht öffnen. Physische Validierung, Signierung und Vertrieb bleiben zurückgestellt. Keine Anlageberatung.

---

## Español

- **Contraseña de recuperación al abrir (opcional)**: se elimina la clave del dispositivo y la cartera solo se abre con la contraseña.
- **Escenarios del Planner con importes privados solo en la cartera cifrada**, con migración verificada de los archivos antiguos sin cifrar.
- Eliminación de la cartera local con confirmación, restauración confirmada de copias más antiguas.
- Argon2id en segundo plano, exportación CSV protegida contra fórmulas, sin bloqueo por simple pérdida de foco en Windows/macOS.
- **Calculadora de bonos del catálogo** (intereses devengados orientativos, rendimiento al vencimiento), **ingresos esperados de la cartera a 12 meses**, **rendimiento anual del plan**.
- Actualización del catálogo NBU tolerante a filas inesperadas.
- Esquema de cartera cifrada **v4**; las versiones anteriores no pueden abrirla. La validación física, la firma y la distribución siguen aplazadas. No es asesoramiento de inversión.

---

## 한국어

- **열 때 복구 비밀번호 요구(선택)**: 기기 키가 삭제되고 비밀번호로만 포트폴리오가 열립니다.
- **개인 금액이 포함된 Planner 시나리오는 암호화된 포트폴리오에만 저장**되며, 기존 평문 파일은 검증 후 이전·삭제됩니다.
- 확인 후 로컬 포트폴리오 삭제, 확인 후 이전 백업 복원.
- Argon2id 백그라운드 실행, 수식 실행을 막는 CSV 내보내기, Windows/macOS에서 포커스 이동만으로 잠기지 않음.
- **카탈로그 채권 계산기**(경과이자 참고치, 만기수익률), **12개월 예상 수입**, **계획 연수익률**.
- 예기치 않은 행에도 견디는 NBU 카탈로그 갱신.
- 암호화 포트폴리오 스키마 **v4**: 이전 버전 앱은 열 수 없습니다. 실기기 검증·서명·배포는 연기되었습니다. 투자 권유가 아닙니다.

---

## 日本語

- **開くときの復旧パスワード（任意）**: 端末の鍵を削除し、パスワードでのみポートフォリオを開きます。
- **非公開金額を含む Planner シナリオは暗号化ポートフォリオにのみ保存**され、既存の平文ファイルは検証後に移行・削除されます。
- 確認付きのローカルポートフォリオ削除、確認付きの古いバックアップ復元。
- Argon2id のバックグラウンド実行、数式実行を防ぐ CSV 書き出し、Windows/macOS でフォーカス移動だけではロックしない。
- **カタログ債券の計算機**（経過利息の目安、満期利回り）、**12か月の受取予定**、**プランの年利回り**。
- 想定外の行に強い NBU カタログ更新。
- 暗号化ポートフォリオのスキーマ **v4**: 旧バージョンでは開けません。実機検証・署名・配布は延期。投資助言ではありません。
