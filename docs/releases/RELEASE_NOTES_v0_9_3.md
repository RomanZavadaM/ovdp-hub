# OVDP Hub v0.9.3 — 0.9.3+20

Дата: 25.09.2026  
Статус: test / prerelease

---

## Українська

### Що нового
- **Фактичний продаж ОВДП**: продаж зберігається лише з явним розподілом проданих облігацій по конкретних purchase lots. Програма не вгадує FIFO/LIFO і не підміняє собівартість.
- **Фактичне погашення та купони**: окремі user-facing дії поверх існуючого encrypted private payload.
- **Історія портфеля та per-ISIN ledger**: купівля, продаж, купон і погашення показуються як фактичні записи з датами, сумами, кількістю там, де вона визначена, та збереженими примітками.
- **Закриті позиції не зникають**: ISIN з нульовим залишком показуються окремо й залишаються доступними для перегляду історії.
- **Фактичний грошовий підсумок по валюті**: суми купівель, відомі комісії, надходження від продажів, купони та погашення. Це cash result, а не ринкова оцінка відкритих позицій.
- Якщо хоча б одна релевантна acquisition/disposal commission невідома, точний net cash result лишається **невідомим** — невідома комісія ніколи не вважається нулем.
- **Legacy migration wizard**: явне non-destructive перенесення приватних метаданих старих добірок/сценаріїв у encrypted vault з migrated/already/conflict/invalid counts і перевіркою encrypted copy.
- Source legacy JSON **не видаляються автоматично**. Встановлення v0.9.3 саме по собі не мігрує старі plaintext-файли.
- UI нового portfolio lifecycle локалізовано UK/EN/FR/DE/ES/KO/JA.

### Безпека та дані
- Portfolio лишається локальним і використовує існуючий encrypted vault/private payload; нового plaintext portfolio store немає.
- Після будь-якої migration attempt unlocked plaintext session відкидається, щоб stale state не міг перезаписати durable migrated vault.
- Цей checkpoint не додає торгівлю, KYC, централізований portfolio backend або передачу приватного портфеля на сервер.

### Release verification
- Full `flutter analyze` + `flutter test`.
- Windows/macOS exact packaged ZIP smoke: ZIP розпаковується, запускається саме packaged executable і звіряється product/version/build та три appearance: `classic/studio/dashboard`.
- Публікуються Windows x64, macOS, Android test, unsigned iOS, START/source, SHA-256 manifest і legal notices.

### Межі
- macOS portfolio unlock лишається залежним від Data Protection Keychain runtime/provisioning.
- Android SAF / iOS security-scoped external-folder access лишається deferred.
- Production signing/notarization/store distribution не входять у цей prerelease.
- OVDP Hub не виконує угоди; ринкові дані й розрахунки потрібно звіряти з первинними джерелами.

---

## English

### What’s new
- **Factual OVDP sales** with explicit allocation to acquisition lots. The app does not invent FIFO/LIFO or silently infer cost basis.
- **Factual redemptions and coupons** as user-facing actions on the encrypted private payload.
- **Portfolio history and per-ISIN ledger** for purchases, sales, coupons and redemptions, including persisted notes.
- **Closed positions remain inspectable** after units reach zero.
- **Per-currency factual cash summary** from persisted purchase amounts, known fees, sale proceeds, coupons and redemptions. It is a cash result, not a market valuation of open positions.
- If any relevant acquisition/disposal fee is unknown, the exact net cash result remains **unknown**; unknown is never treated as zero.
- **Explicit non-destructive legacy migration wizard** with migrated/already/conflict/invalid counts and encrypted-copy verification.
- Legacy source JSON files are **not deleted automatically**, and installing v0.9.3 does not automatically migrate them.
- New portfolio lifecycle UI is localized in UK/EN/FR/DE/ES/KO/JA.

### Security and release verification
- The portfolio remains local and reuses the existing encrypted vault/private payload; no parallel plaintext portfolio store is introduced.
- After every migration attempt, stale unlocked plaintext session state is discarded.
- Full Flutter verification plus exact packaged Windows/macOS ZIP executable smoke is required before publication.
- Release assets: Windows x64, macOS, Android test, unsigned iOS, START/source, SHA-256 manifest and legal notices.

### Boundaries
- macOS portfolio unlock still depends on Data Protection Keychain runtime/provisioning.
- Android SAF / iOS security-scoped external-folder access remains deferred.
- Production signing/notarization/store distribution is not part of this prerelease.
- OVDP Hub does not execute trades.

---

## Français

### Nouveautés
- Ventes factuelles d’OVDP avec allocation explicite aux lots d’achat, sans FIFO/LIFO inventé.
- Remboursements et coupons factuels dans le portefeuille chiffré.
- Historique et ledger par ISIN pour achat / vente / coupon / remboursement.
- Les positions clôturées restent consultables après un solde à zéro.
- Synthèse de trésorerie factuelle par devise à partir des montants réellement enregistrés. Ce n’est pas une valorisation de marché.
- Si des frais d’achat ou de vente sont inconnus, le résultat net exact reste **inconnu**; une valeur inconnue n’est jamais remplacée par zéro.
- Assistant explicite de migration legacy non destructive avec vérification de la copie chiffrée.
- Les JSON source legacy ne sont jamais supprimés automatiquement et l’installation de v0.9.3 ne les migre pas automatiquement.
- UI localisée UK/EN/FR/DE/ES/KO/JA.

### Vérification / limites
- Vérification Flutter complète et smoke du ZIP/exécutable Windows/macOS réellement emballé.
- Assets: Windows, macOS, Android test, iOS non signé, START/source, SHA-256 et notices légales.
- Android SAF / accès iOS security-scoped reste différé; signature de production non incluse.

---

## Deutsch

### Neu
- Faktische OVDP-Verkäufe mit expliziter Zuordnung zu Kauflots; kein erfundenes FIFO/LIFO.
- Faktische Rückzahlungen und Kupons im verschlüsselten Portfolio.
- Historie und ISIN-Ledger für Kauf / Verkauf / Kupon / Rückzahlung.
- Geschlossene Positionen bleiben auch bei Bestand null einsehbar.
- Faktische Cash-Übersicht je Währung aus gespeicherten Zahlungsdaten; keine Marktwertschätzung offener Positionen.
- Bei unbekannten Kauf-/Verkaufsgebühren bleibt das exakte Netto-Cash-Ergebnis **unbekannt**; unbekannt wird nie als null behandelt.
- Expliziter, nicht-destruktiver Legacy-Migrationsassistent mit Verifikation der verschlüsselten Kopie.
- Legacy-JSON-Quelldateien werden nicht automatisch gelöscht oder allein durch das Update migriert.
- UI in UK/EN/FR/DE/ES/KO/JA.

### Verifikation / Grenzen
- Vollständige Flutter-Prüfung plus Smoke-Test der tatsächlich gepackten Windows/macOS-ZIPs.
- Windows, macOS, Android-Test, unsigned iOS, START/source, SHA-256 und rechtliche Hinweise.
- Android SAF / iOS security-scoped Zugriff und Production Signing bleiben zurückgestellt.

---

## Español

### Novedades
- Ventas factuales de OVDP con asignación explícita a lotes de compra; sin FIFO/LIFO inventado.
- Amortizaciones y cupones factuales en la cartera cifrada.
- Historial y ledger por ISIN para compra / venta / cupón / amortización.
- Las posiciones cerradas siguen siendo consultables con saldo cero.
- Resumen de caja factual por divisa usando solo importes persistidos; no es una valoración de mercado de posiciones abiertas.
- Si alguna comisión relevante es desconocida, el resultado neto exacto permanece **desconocido**; nunca se sustituye por cero.
- Asistente explícito de migración legacy no destructiva con verificación de la copia cifrada.
- Los JSON legacy de origen no se eliminan ni se migran automáticamente solo por instalar v0.9.3.
- UI localizada UK/EN/FR/DE/ES/KO/JA.

### Verificación / límites
- Verificación Flutter completa y smoke del ZIP/ejecutable Windows/macOS realmente empaquetado.
- Assets para Windows, macOS, Android test, iOS unsigned, START/source, SHA-256 y avisos legales.
- Android SAF / iOS security-scoped access y firma de producción siguen aplazados.

---

## 한국어

### 변경 사항
- 실제 OVDP 매도를 매수 로트에 명시적으로 배분합니다. FIFO/LIFO를 임의로 추정하지 않습니다.
- 암호화 포트폴리오에서 실제 상환과 쿠폰을 기록할 수 있습니다.
- 매수 / 매도 / 쿠폰 / 상환을 ISIN별 실제 이력으로 확인할 수 있습니다.
- 보유 수량이 0이 된 종료 포지션도 계속 조회할 수 있습니다.
- 저장된 실제 현금 사실만으로 통화별 현금 요약을 계산합니다. 보유 포지션의 시장가치 평가는 포함하지 않습니다.
- 관련 수수료가 하나라도 미확인 상태이면 정확한 순현금 결과는 **알 수 없음**으로 유지하며 0으로 처리하지 않습니다.
- 암호화 복사본 검증이 포함된 명시적 비파괴 legacy migration wizard가 추가되었습니다.
- 기존 source JSON은 자동 삭제되지 않으며 v0.9.3 설치만으로 자동 이전되지 않습니다.
- 새 포트폴리오 UI는 UK/EN/FR/DE/ES/KO/JA를 지원합니다.

### 검증 / 범위
- 전체 Flutter 검사와 실제 패키징된 Windows/macOS ZIP executable smoke를 수행합니다.
- Windows, macOS, Android test, unsigned iOS, START/source, SHA-256, legal notices를 제공합니다.
- Android SAF / iOS security-scoped access 및 production signing은 계속 연기됩니다.

---

## 日本語

### 変更点
- 実売却を購入ロットへ明示的に割り当てます。FIFO/LIFO を推測しません。
- 暗号化ポートフォリオで実際の償還とクーポンを記録できます。
- 購入 / 売却 / クーポン / 償還を ISIN ごとの実績 ledger で確認できます。
- 残高がゼロになった終了ポジションも履歴を参照できます。
- 保存済みの実績キャッシュのみから通貨別集計を行い、保有ポジションの市場価値は実績結果に混ぜません。
- 関連手数料が不明なら正確な純キャッシュ結果も **不明** のままです。不明値をゼロ扱いしません。
- 暗号化コピー検証付きの明示的・非破壊 legacy migration wizard を追加しました。
- Legacy source JSON は自動削除されず、v0.9.3 をインストールしただけでは自動移行されません。
- 新しいポートフォリオ UI は UK/EN/FR/DE/ES/KO/JA に対応します。

### 検証 / 境界
- Flutter 全体検証と、実際にパッケージされた Windows/macOS ZIP executable smoke を実施します。
- Windows、macOS、Android test、unsigned iOS、START/source、SHA-256、legal notices を公開します。
- Android SAF / iOS security-scoped access と production signing は引き続き deferred です。

---

## Packaging / Пакування

Очікувані assets:
- `OVDP-Hub-0.9.3-Windows-x64.zip`
- `OVDP-Hub-0.9.3-macOS.zip`
- `OVDP-Hub-0.9.3-Android-test.zip`
- `OVDP-Hub-0.9.3-iOS-unsigned.zip`
- `OVDP-Hub-0.9.3-START.zip`
- `SHA256SUMS.txt`
- `LICENSE.md`
- `COPYRIGHT.md`
- `LEGAL_AND_COPYRIGHT.md`
- `THIRD_PARTY_NOTICES.md`
