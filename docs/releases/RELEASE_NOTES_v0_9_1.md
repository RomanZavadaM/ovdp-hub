# OVDP Hub 0.9.1

**Release date / Дата:** 24.09.2026  
**Status:** prerelease / test checkpoint  
**App version:** 0.9.1+18  
**Copyright:** © 2026 Roman Zavada (Роман Завада). All rights reserved.

---

## Українська

### Що нового після v0.9.0
- **«Світла панель»:** третє необов’язкове оформлення; Classic та «Робочий кабінет» збережені.
- **Planner reserve floor:** мінімальний ліквідний залишок від заданої дати не вважається витратою й входить у coverage.
- **Локальні CSV/ICS exports:** deterministic exports scenario/needs/coverage/cashflow у папку `exports/` активного workspace.
- **Encrypted-vault foundation:** security-reviewed sodium/libsodium, XChaCha20-Poly1305, Argon2id, device-key adapters, atomic encrypted local store, recovery/backup, rollback detection, session locking та non-destructive local-delete lifecycle.
- **Private portfolio domain foundation:** factual acquisition lots, coupon/redemption events, factual disposals з explicit lot allocation та derived holdings без вигаданого FIFO/LIFO.
- **Non-destructive legacy migration core:** schema v3 може зашифровано зберегти legacy collection name/note/savedAt/selected ISINs/raw Planner scenario. Public Bond snapshots не копіюються; SavedSet не перетворюється на «фактичний портфель»; source JSON не видаляється автоматично.
- **Backward compatibility:** private payload schema v1/v2 декодуються; новий canonical encode — schema v3.

### Важливі межі
- **User-facing vault/migration/portfolio UI ще не підключено.** Поточні legacy `sets/*.json` у workspace не можна вважати автоматично зашифрованими після оновлення.
- Migration core не має delete API; старі plaintext-файли зберігаються до окремої явної дії користувача в майбутньому UI.
- macOS Data Protection Keychain runtime/provisioning залишається release gate перед user-facing unlock.
- Windows/macOS тестові пакети не мають production code signing; Android використовує development/test signing; iOS package unsigned.
- OVDP Hub не виконує угоди. Ринкові дані та розрахунки перед практичним використанням слід перевіряти за першоджерелами.

---

## English

### What’s new since v0.9.0
- **Light Dashboard:** a third optional appearance; Classic and Workbench remain available.
- **Planner reserve floor:** a minimum liquid balance from an effective date is tracked separately from spending and participates in coverage.
- **Local CSV/ICS exports:** deterministic scenario/needs/coverage/cashflow exports into the active workspace `exports/` folder.
- **Encrypted-vault foundation:** security-reviewed sodium/libsodium, XChaCha20-Poly1305, Argon2id, device-key adapters, atomic encrypted local storage, recovery/backup, rollback detection, session locking, and non-destructive local-delete lifecycle.
- **Private portfolio domain foundation:** factual acquisition lots, coupon/redemption events, factual disposals with explicit lot allocation, and derived holdings without invented FIFO/LIFO.
- **Non-destructive legacy migration core:** schema v3 can preserve legacy collection name/note/savedAt/selected ISINs/raw Planner scenario inside the encrypted payload. Public Bond snapshots are omitted; SavedSet data is never reinterpreted as factual holdings; source JSON is never auto-deleted.
- **Backward compatibility:** private payload schema v1/v2 remains decodable; new canonical encoding is schema v3.

### Important boundaries
- **The user-facing vault/migration/portfolio UI is not wired yet.** Existing legacy workspace `sets/*.json` must not be assumed to become encrypted automatically after updating.
- The migration core has no delete API; plaintext source files remain until a future explicit user cleanup action.
- macOS Data Protection Keychain runtime/provisioning remains a release gate before user-facing unlock.
- Windows/macOS test packages are not production code-signed; Android uses development/test signing; the iOS package is unsigned.
- OVDP Hub does not execute trades. Verify market data and calculations against primary sources before practical use.

---

## Français

### Nouveautés depuis v0.9.0
- **Tableau clair :** troisième apparence optionnelle; Classic et « Poste de travail » restent disponibles.
- **Reserve floor du Planner :** le solde liquide minimum à partir d’une date donnée est séparé des dépenses et pris en compte dans la couverture.
- **Exports CSV/ICS locaux :** exports déterministes scenario/needs/coverage/cashflow dans `exports/` du workspace actif.
- **Fondation du coffre chiffré :** sodium/libsodium audité, XChaCha20-Poly1305, Argon2id, clés liées à l’OS, stockage chiffré atomique, recovery/backup, détection de rollback, verrouillage de session et suppression locale non destructive.
- **Fondation du portefeuille privé :** lots d’acquisition factuels, événements coupon/remboursement, cessions factuelles avec allocation explicite aux lots, sans FIFO/LIFO inventé.
- **Migration legacy non destructive :** le schéma v3 conserve de façon chiffrée name/note/savedAt/ISIN sélectionnés/scenario Planner brut. Les snapshots Bond publics ne sont pas copiés; un SavedSet n’est jamais converti en portefeuille factuel; les JSON source ne sont jamais supprimés automatiquement.

### Limites importantes
- **L’interface utilisateur vault/migration/portfolio n’est pas encore raccordée.** Les `sets/*.json` legacy ne deviennent pas automatiquement chiffrés après la mise à jour.
- Le cœur de migration ne possède aucune API de suppression; les sources plaintext restent présentes jusqu’à une future action explicite.
- Le runtime/provisioning macOS Data Protection Keychain reste un gate avant le déverrouillage utilisateur.
- Les packages Windows/macOS ne sont pas signés production; Android utilise une signature test/développement; iOS est non signé.
- OVDP Hub n’exécute pas d’ordres; vérifiez données et calculs auprès des sources primaires.

---

## Deutsch

### Neu seit v0.9.0
- **Helles Dashboard:** drittes optionales Erscheinungsbild; Classic und Workbench bleiben verfügbar.
- **Planner Reserve Floor:** ein Mindest-Liquiditätsbestand ab einem Stichtag wird getrennt von Ausgaben behandelt und in die Coverage einbezogen.
- **Lokale CSV/ICS-Exporte:** deterministische scenario/needs/coverage/cashflow-Dateien im `exports/`-Ordner des aktiven Workspace.
- **Encrypted-Vault-Grundlage:** geprüftes sodium/libsodium, XChaCha20-Poly1305, Argon2id, OS-gebundene Device Keys, atomarer verschlüsselter Local Store, Recovery/Backup, Rollback-Erkennung und Session Locking.
- **Private-Portfolio-Grundlage:** faktische Acquisition Lots, Coupon/Redemption Events und faktische Disposals mit expliziter Lot-Zuordnung ohne erfundenes FIFO/LIFO.
- **Nicht-destruktive Legacy-Migration:** Schema v3 kann name/note/savedAt/ausgewählte ISINs/raw Planner scenario verschlüsselt bewahren. Öffentliche Bond-Snapshots werden nicht kopiert; SavedSet wird nicht als faktisches Portfolio interpretiert; Quell-JSON wird nie automatisch gelöscht.

### Wichtige Grenzen
- **Vault-/Migration-/Portfolio-UI ist noch nicht angebunden.** Bestehende `sets/*.json` werden durch das Update nicht automatisch verschlüsselt.
- Der Migration Core hat keine Delete-API; Plaintext-Quellen bleiben bis zu einer späteren expliziten Benutzeraktion erhalten.
- macOS Data Protection Keychain Runtime/Provisioning bleibt ein Gate vor user-facing Unlock.
- Windows/macOS-Testpakete sind nicht produktiv signiert; Android nutzt Test-/Development-Signing; iOS ist unsigniert.
- OVDP Hub führt keine Geschäfte aus; Marktinformationen und Berechnungen vor praktischer Nutzung anhand von Primärquellen prüfen.

---

## Español

### Novedades desde v0.9.0
- **Panel claro:** tercera apariencia opcional; Classic y Workbench siguen disponibles.
- **Reserve floor del Planner:** un saldo líquido mínimo desde una fecha efectiva se mantiene separado del gasto y participa en la cobertura.
- **Exportaciones CSV/ICS locales:** archivos deterministas de scenario/needs/coverage/cashflow en `exports/` del workspace activo.
- **Base del vault cifrado:** sodium/libsodium revisado, XChaCha20-Poly1305, Argon2id, claves vinculadas al sistema operativo, almacenamiento cifrado atómico, recovery/backup, detección de rollback y bloqueo de sesión.
- **Base del portfolio privado:** lotes de adquisición factuales, eventos coupon/redemption y disposals factuales con asignación explícita a lotes, sin inventar FIFO/LIFO.
- **Migración legacy no destructiva:** schema v3 conserva de forma cifrada name/note/savedAt/ISIN seleccionados/raw Planner scenario. No se copian snapshots públicos de Bond; SavedSet no se interpreta como holdings factuales; el JSON fuente nunca se borra automáticamente.

### Límites importantes
- **La UI de vault/migration/portfolio todavía no está conectada.** Los `sets/*.json` existentes no pasan a estar cifrados automáticamente tras actualizar.
- El núcleo de migración no tiene API de borrado; los archivos plaintext permanecen hasta una futura acción explícita del usuario.
- El runtime/provisioning de macOS Data Protection Keychain sigue siendo un gate antes del desbloqueo visible para el usuario.
- Windows/macOS no tienen firma de producción; Android usa firma de prueba/desarrollo; iOS está sin firmar.
- OVDP Hub no ejecuta operaciones; verifique datos de mercado y cálculos con fuentes primarias.

---

## 한국어

### v0.9.0 이후 변경 사항
- **라이트 대시보드:** 세 번째 선택형 외관이며 Classic과 Workbench는 그대로 유지됩니다.
- **Planner reserve floor:** 특정 날짜부터 유지해야 하는 최소 유동 잔액을 지출과 분리하고 coverage에 반영합니다.
- **로컬 CSV/ICS 내보내기:** 활성 workspace의 `exports/` 폴더에 scenario/needs/coverage/cashflow를 결정적으로 저장합니다.
- **암호화 vault 기반:** 검토된 sodium/libsodium, XChaCha20-Poly1305, Argon2id, OS device-key adapter, 원자적 암호화 local store, recovery/backup, rollback detection, session locking.
- **비공개 portfolio 도메인 기반:** 사실 기반 acquisition lot, coupon/redemption event, 명시적 lot allocation이 있는 factual disposal. FIFO/LIFO를 임의로 만들지 않습니다.
- **비파괴 legacy migration core:** schema v3는 legacy collection의 name/note/savedAt/선택 ISIN/raw Planner scenario를 암호화 payload에 보존합니다. 공개 Bond snapshot은 복사하지 않으며 SavedSet을 실제 보유 포지션으로 해석하지 않고 source JSON도 자동 삭제하지 않습니다.

### 중요 범위
- **사용자용 vault/migration/portfolio UI는 아직 연결되지 않았습니다.** 기존 `sets/*.json`은 업데이트만으로 자동 암호화되지 않습니다.
- migration core에는 delete API가 없으며 plaintext source는 향후 명시적 사용자 정리 동작 전까지 유지됩니다.
- macOS Data Protection Keychain runtime/provisioning은 사용자 unlock 전에 필요한 release gate입니다.
- Windows/macOS는 production signing이 없고 Android는 test/development signing, iOS는 unsigned입니다.
- OVDP Hub는 거래를 실행하지 않습니다. 실제 사용 전 시장 데이터와 계산을 1차 출처로 확인하십시오.

---

## 日本語

### v0.9.0 以降の変更
- **ライトダッシュボード:** 3 つ目の任意外観。Classic と Workbench はそのまま利用できます。
- **Planner reserve floor:** 指定日以降に維持する最低流動残高を支出とは分離し、coverage に反映します。
- **ローカル CSV/ICS エクスポート:** active workspace の `exports/` に scenario/needs/coverage/cashflow を決定的に保存します。
- **暗号化 vault 基盤:** レビュー済み sodium/libsodium、XChaCha20-Poly1305、Argon2id、OS device-key adapter、atomic encrypted local store、recovery/backup、rollback detection、session locking。
- **private portfolio ドメイン基盤:** factual acquisition lot、coupon/redemption event、explicit lot allocation 付き factual disposal。FIFO/LIFO を推測しません。
- **非破壊 legacy migration core:** schema v3 は legacy collection の name/note/savedAt/選択 ISIN/raw Planner scenario を暗号化 payload に保持します。公開 Bond snapshot はコピーせず、SavedSet を factual holdings と解釈せず、source JSON を自動削除しません。

### 重要な範囲
- **ユーザー向け vault/migration/portfolio UI はまだ接続されていません。** 既存の `sets/*.json` はアップデートだけでは自動暗号化されません。
- migration core に delete API はなく、plaintext source は将来の明示的なユーザー操作まで保持されます。
- macOS Data Protection Keychain の runtime/provisioning は user-facing unlock 前の release gate です。
- Windows/macOS は production signing 未対応、Android は test/development signing、iOS は unsigned です。
- OVDP Hub は取引を実行しません。実利用前に市場データと計算を一次情報源で確認してください。

---

## Packaging / Пакування

The full release workflow must build and publish:
- `OVDP-Hub-0.9.1-Windows-x64.zip`
- `OVDP-Hub-0.9.1-macOS.zip`
- `OVDP-Hub-0.9.1-Android-test.zip`
- `OVDP-Hub-0.9.1-iOS-unsigned.zip`
- `OVDP-Hub-0.9.1-START.zip`
- `SHA256SUMS.txt`
- legal notices

The checkpoint is not considered published until verify, all platform jobs, START/source packaging, checksums and the final immutable GitHub prerelease publication succeed.
