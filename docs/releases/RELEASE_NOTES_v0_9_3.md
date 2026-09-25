# OVDP Hub v0.9.3 — 0.9.3+20

Дата: 25.09.2026  
Статус: test / prerelease

---

## Українська

### Що нового
- **Фактичні продажі та погашення:** продаж вимагає явного розподілу по лотах придбання; історія зберігає purchase / sale / coupon / redemption без вигаданого FIFO/LIFO.
- **Купони та деталізація ISIN:** можна додавати фактично отриманий купон і відкривати єдиний ledger по кожному ISIN.
- **Закриті позиції не зникають:** ISIN з нульовим залишком лишаються доступними в окремому блоці та відкривають ту саму фактичну історію.
- **Фактичний грошовий підсумок:** окремо показуються суми купівель, продажів, купонів, погашень і відомих комісій по валюті.
- **Невідомі комісії не підміняються нулем:** точний чистий грошовий результат не показується, якщо релевантна комісія невідома.
- **Legacy migration wizard:** явне non-destructive перенесення підтримуваних legacy-даних у зашифрований payload з перевіркою encrypted copy; source JSON автоматично не видаляється.

### Межі
- Грошовий підсумок не додає поточну ринкову вартість відкритих позицій і тому не є ринковою оцінкою чи показником інвестиційної дохідності.
- Android SAF / iOS security-scoped external-folder access лишається відкладеним до окремого mobile storage gate.
- Production signing/notarization ще не є частиною цього test prerelease.
- OVDP Hub не виконує операції купівлі/продажу.

---

## English

### What’s new
- **Factual sales and redemptions:** sales require explicit acquisition-lot allocation; history preserves purchase / sale / coupon / redemption facts without invented FIFO/LIFO.
- **Coupons and per-ISIN detail:** record a received coupon and inspect one factual ledger for each ISIN.
- **Closed positions remain visible:** zero-unit ISINs stay accessible and open the same factual ledger.
- **Factual cash summary:** purchase amounts, sale proceeds, coupons, redemptions, and known fees are shown separately per currency.
- **Unknown fees stay unknown:** an exact net cash result is withheld whenever a relevant acquisition/disposal fee is unknown.
- **Legacy migration wizard:** explicit non-destructive migration into the encrypted payload with encrypted-copy verification; source JSON is never auto-deleted.

### Boundaries
- The cash summary excludes current market value of open positions, so it is not market valuation or investment-performance reporting.
- Android SAF / iOS security-scoped external-folder access remains deferred.
- Production signing/notarization is not part of this test prerelease.
- OVDP Hub does not execute trades.

---

## Français

### Nouveautés
- Ventes et remboursements factuels avec allocation explicite aux lots d’acquisition, sans FIFO/LIFO inventé.
- Coupons reçus et ledger factuel unique par ISIN.
- Les positions clôturées restent visibles et consultables.
- Résumé de trésorerie factuel par devise : achats, ventes, coupons, remboursements et frais connus.
- Un résultat net exact n’est pas affiché si un frais pertinent est inconnu.
- Assistant de migration legacy non destructif avec vérification de la copie chiffrée; le JSON source n’est jamais supprimé automatiquement.

### Limites
- La valeur de marché actuelle des positions ouvertes n’entre pas dans ce résumé; ce n’est pas une mesure de performance.
- Android SAF / iOS security-scoped reste différé.
- La signature/notarisation de production reste hors de ce prerelease.

---

## Deutsch

### Neu
- Faktische Verkäufe und Tilgungen mit expliziter Zuordnung zu Erwerbslots; kein erfundenes FIFO/LIFO.
- Erhaltene Coupons und ein faktisches Ledger je ISIN.
- Geschlossene Positionen bleiben sichtbar und prüfbar.
- Faktische Cash-Zusammenfassung je Währung: Käufe, Verkäufe, Coupons, Tilgungen und bekannte Gebühren.
- Ein exaktes Nettoergebnis wird nicht gezeigt, wenn eine relevante Gebühr unbekannt ist.
- Nicht-destruktiver Legacy-Migrationsassistent mit Prüfung der verschlüsselten Kopie; Quell-JSON wird nie automatisch gelöscht.

### Grenzen
- Der aktuelle Marktwert offener Positionen wird nicht eingerechnet; dies ist keine Performance-Kennzahl.
- Android SAF / iOS security-scoped bleibt zurückgestellt.
- Production Signing/Notarization ist nicht Teil dieses Test-Prereleases.

---

## Español

### Novedades
- Ventas y amortizaciones factuales con asignación explícita a lotes de adquisición; sin FIFO/LIFO inventado.
- Cupones recibidos y ledger factual por ISIN.
- Las posiciones cerradas siguen visibles y consultables.
- Resumen de caja factual por divisa: compras, ventas, cupones, amortizaciones y comisiones conocidas.
- El resultado neto exacto no se muestra si una comisión relevante es desconocida.
- Asistente de migración legacy no destructivo con verificación de la copia cifrada; el JSON fuente nunca se elimina automáticamente.

### Límites
- No se incorpora el valor de mercado actual de posiciones abiertas; no es una métrica de rentabilidad.
- Android SAF / iOS security-scoped sigue aplazado.
- El firmado/notarización de producción no forma parte de este prerelease de prueba.

---

## 한국어

### 변경 사항
- 실제 매도/상환을 기록하며 매수 lot 할당을 명시적으로 요구하고 임의 FIFO/LIFO를 만들지 않습니다.
- 실제 수령 쿠폰과 ISIN별 factual ledger를 제공합니다.
- 수량이 0인 종료 포지션도 계속 조회할 수 있습니다.
- 통화별 실제 현금 요약에서 매수, 매도대금, 쿠폰, 상환, 알려진 수수료를 분리해 표시합니다.
- 관련 수수료가 미확인인 경우 정확한 순현금 결과를 표시하지 않습니다.
- 암호화 복사본을 검증하는 비파괴 legacy migration wizard를 추가하며 원본 JSON은 자동 삭제하지 않습니다.

### 범위
- 열린 포지션의 현재 시장가치는 현금 요약에 포함되지 않으며 투자수익률 지표가 아닙니다.
- Android SAF / iOS security-scoped 외부 폴더 접근은 연기됩니다.
- production signing/notarization은 이번 테스트 prerelease 범위가 아닙니다.

---

## 日本語

### 変更点
- 実売却・償還を記録し、取得ロットへの明示的な割当を要求します。FIFO/LIFO を勝手に推定しません。
- 実受取クーポンと ISIN ごとの factual ledger を追加しました。
- 保有数量が 0 のクローズ済みポジションも引き続き参照できます。
- 通貨ごとの実キャッシュ概要で、購入額・売却入金・クーポン・償還・既知手数料を分離表示します。
- 関連手数料が不明な場合、正確な純キャッシュ結果は表示しません。
- 暗号化コピーを検証する非破壊 legacy migration wizard を追加し、source JSON は自動削除しません。

### 境界
- オープンポジションの現在市場価値は含めないため、投資パフォーマンス指標ではありません。
- Android SAF / iOS security-scoped 外部フォルダー対応は延期されています。
- production signing/notarization は今回の test prerelease には含まれません。

---

## Packaging / Пакування

Очікувані assets:
- `OVDP-Hub-0.9.3-Windows-x64.zip`
- `OVDP-Hub-0.9.3-macOS.zip`
- `OVDP-Hub-0.9.3-Android-test.zip`
- `OVDP-Hub-0.9.3-iOS-unsigned.zip`
- `OVDP-Hub-0.9.3-START.zip`
- `SHA256SUMS.txt`
- legal notices
