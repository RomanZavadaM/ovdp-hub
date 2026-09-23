# OVDP Hub 0.8.7

**Release date / Дата:** 23.09.2026  
**Status:** prerelease / test checkpoint  
**App version:** 0.8.7+15  
**Copyright:** © 2026 Roman Zavada (Роман Завада). All rights reserved.

---

## Українська

### Що нового
- **Кілька джерел ціни:** для одного ISIN можна зберігати кілька `PriceObservation` і явно визначати їхній пріоритет.
- **Контроль користувача:** джерела можна додавати, вибирати та переставляти; повернення до оцінки за номіналом є явною дією.
- **Без тихої підміни:** yield-only та nominal estimate не стають ринковою ціною автоматично.
- **Комісії придбання:** невідома комісія більше не трактується як нуль. Можна підтвердити нульову комісію або ввести відому загальну комісію придбання.
- **Розрахунок:** відома комісія зменшує доступний бюджет, резерв і розрахований прибуток; при невідомій комісії результат явно позначений як до комісій.
- **Збереження:** price-source priority та fee assumptions зберігаються у сценарії без тихого переписування старих даних.
- **Локалізація:** нові елементи UI та помилки доступні UK / EN / FR / DE / ES / KO / JA.

### Ще не завершено
Податки, FX, достроковий продаж і A/B/C comparison ще не підключені до повного розрахунку. Невідомий податок або комісія не означає 0.

---

## English

### What’s new
- **Multiple price sources:** one ISIN can keep several `PriceObservation` entries with an explicit user-controlled priority.
- **User control:** sources can be added, selected and reordered; returning to a nominal estimate is always explicit.
- **No silent substitution:** yield-only observations and nominal estimates never become a market price automatically.
- **Purchase fees:** an unknown fee is no longer treated as zero. The user can confirm zero fees or enter a known aggregate purchase fee.
- **Calculation impact:** a known fee reduces available budget, reserve and calculated profit; with unknown fees the result is explicitly shown as pre-fee.
- **Persistence:** price-source priority and fee assumptions are stored with the scenario without silently rewriting legacy data.
- **Localization:** the new UI and related errors are available in UK / EN / FR / DE / ES / KO / JA.

### Not finished yet
Taxes, FX, early exit and A/B/C comparison are not yet fully wired into calculations. An unknown tax or fee never means zero.

---

## Français

### Nouveautés
- **Plusieurs sources de prix :** un même ISIN peut conserver plusieurs `PriceObservation` avec une priorité choisie explicitement par l’utilisateur.
- **Contrôle utilisateur :** les sources peuvent être ajoutées, sélectionnées et réordonnées ; le retour à une estimation nominale reste une action explicite.
- **Aucune substitution silencieuse :** une observation de rendement seul ou une estimation nominale ne devient jamais automatiquement un prix de marché.
- **Frais d’achat :** un frais inconnu n’est plus assimilé à zéro. L’utilisateur peut confirmer l’absence de frais ou saisir un montant global connu.
- **Effet sur le calcul :** un frais connu réduit le budget disponible, la réserve et le bénéfice calculé ; si les frais sont inconnus, le résultat est clairement indiqué avant frais.
- **Persistance :** la priorité des sources et les hypothèses de frais sont enregistrées sans réécrire silencieusement les anciennes données.
- **Localisation :** la nouvelle interface et les erreurs associées sont disponibles en UK / EN / FR / DE / ES / KO / JA.

### Pas encore terminé
Les impôts, le FX, la sortie anticipée et la comparaison A/B/C ne sont pas encore entièrement intégrés aux calculs. Un impôt ou des frais inconnus ne signifient jamais zéro.

---

## Deutsch

### Neu
- **Mehrere Preisquellen:** Für eine ISIN können mehrere `PriceObservation`-Einträge mit ausdrücklich vom Nutzer festgelegter Priorität gespeichert werden.
- **Nutzerkontrolle:** Quellen können hinzugefügt, ausgewählt und umsortiert werden; die Rückkehr zur Nominalwert-Schätzung erfolgt immer ausdrücklich.
- **Keine stille Ersetzung:** Yield-only-Beobachtungen und Nominalwert-Schätzungen werden nie automatisch zum Marktpreis.
- **Kaufgebühren:** Eine unbekannte Gebühr wird nicht mehr als null behandelt. Nullgebühren können bestätigt oder eine bekannte Gesamtkaufgebühr eingegeben werden.
- **Auswirkung auf die Berechnung:** Eine bekannte Gebühr reduziert verfügbares Budget, Reserve und berechneten Gewinn; bei unbekannten Gebühren wird das Ergebnis ausdrücklich als vor Gebühren angezeigt.
- **Speicherung:** Preisquellen-Priorität und Gebührenannahmen werden im Szenario gespeichert, ohne ältere Daten still umzuschreiben.
- **Lokalisierung:** Neue UI-Elemente und zugehörige Fehler sind in UK / EN / FR / DE / ES / KO / JA verfügbar.

### Noch nicht abgeschlossen
Steuern, FX, vorzeitiger Verkauf und A/B/C-Vergleich sind noch nicht vollständig in die Berechnungen eingebunden. Unbekannte Steuern oder Gebühren bedeuten niemals null.

---

## Español

### Novedades
- **Varias fuentes de precio:** un ISIN puede conservar varias `PriceObservation` con una prioridad definida explícitamente por el usuario.
- **Control del usuario:** las fuentes se pueden añadir, seleccionar y reordenar; volver a una estimación por nominal siempre es una acción explícita.
- **Sin sustituciones silenciosas:** las observaciones de solo rendimiento y las estimaciones por nominal nunca se convierten automáticamente en precio de mercado.
- **Comisiones de compra:** una comisión desconocida ya no se considera cero. El usuario puede confirmar comisión cero o introducir una comisión total conocida.
- **Impacto en el cálculo:** una comisión conocida reduce el presupuesto disponible, la reserva y el beneficio calculado; con comisión desconocida el resultado se muestra claramente antes de comisiones.
- **Persistencia:** la prioridad de fuentes y las hipótesis de comisiones se guardan sin reescribir silenciosamente datos antiguos.
- **Localización:** la nueva interfaz y los errores relacionados están disponibles en UK / EN / FR / DE / ES / KO / JA.

### Aún no terminado
Impuestos, FX, salida anticipada y comparación A/B/C todavía no están completamente conectados al cálculo. Un impuesto o una comisión desconocidos nunca significan cero.

---

## 한국어

### 새로운 기능
- **여러 가격 출처:** 하나의 ISIN에 여러 `PriceObservation`을 저장하고 사용자가 우선순위를 명시적으로 정할 수 있습니다.
- **사용자 제어:** 가격 출처를 추가·선택·재정렬할 수 있으며 액면가 추정으로 돌아가는 동작도 항상 명시적입니다.
- **자동 대체 없음:** 수익률만 있는 관측값이나 액면가 추정이 자동으로 시장가격이 되지 않습니다.
- **매수 수수료:** 알 수 없는 수수료를 더 이상 0으로 간주하지 않습니다. 수수료 0을 확인하거나 알려진 총 매수 수수료를 입력할 수 있습니다.
- **계산 반영:** 알려진 수수료는 사용 가능 예산, 준비금, 계산 수익을 줄입니다. 수수료가 미확인인 경우 결과는 수수료 차감 전 값으로 명확히 표시됩니다.
- **저장:** 가격 출처 우선순위와 수수료 가정은 기존 데이터를 조용히 덮어쓰지 않고 시나리오에 저장됩니다.
- **현지화:** 새 UI와 관련 오류는 UK / EN / FR / DE / ES / KO / JA로 제공됩니다.

### 아직 완료되지 않은 항목
세금, FX, 만기 전 매도 및 A/B/C 비교는 아직 전체 계산에 완전히 연결되지 않았습니다. 알 수 없는 세금이나 수수료는 0을 의미하지 않습니다.

---

## 日本語

### 新機能
- **複数の価格ソース:** 1つのISINに複数の`PriceObservation`を保持し、ユーザーが優先順位を明示的に指定できます。
- **ユーザーによる制御:** ソースの追加・選択・並べ替えが可能で、額面推定へ戻す操作も常に明示的です。
- **暗黙の置き換えなし:** 利回りのみの観測値や額面推定が自動的に市場価格になることはありません。
- **購入手数料:** 不明な手数料を0として扱いません。手数料0を確認するか、既知の購入手数料総額を入力できます。
- **計算への反映:** 既知の手数料は利用可能予算、予備資金、計算利益を減らします。手数料が不明な場合、結果は手数料控除前であることを明示します。
- **保存:** 価格ソースの優先順位と手数料の仮定は、旧データを暗黙に書き換えることなくシナリオに保存されます。
- **ローカライズ:** 新しいUIと関連エラーは UK / EN / FR / DE / ES / KO / JA で利用できます。

### 未完了
税金、FX、満期前売却、A/B/C比較はまだ計算へ完全には接続されていません。不明な税金や手数料を0とは扱いません。

---

## Packaging / Пакування

The release pipeline builds:
- `OVDP-Hub-0.8.7-Windows-x64.zip`
- `OVDP-Hub-0.8.7-macOS.zip`
- `OVDP-Hub-0.8.7-Android-test.zip`
- `OVDP-Hub-0.8.7-iOS-unsigned.zip`
- `OVDP-Hub-0.8.7-START.zip`
- `SHA256SUMS.txt`
- legal notices

Windows/macOS packages are not production code-signed. Android uses the current test/development signing configuration. The iOS package is unsigned.
