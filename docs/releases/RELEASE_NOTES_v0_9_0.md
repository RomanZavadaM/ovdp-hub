# OVDP Hub 0.9.0

**Release date / Дата:** 24.09.2026  
**Status:** prerelease / test checkpoint  
**App version:** 0.9.0+17  
**Copyright:** © 2026 Roman Zavada (Роман Завада). All rights reserved.

---

## Українська

### Що нового після v0.8.8
- **Порівняння A/B/C:** у «Добірках» можна нейтрально зіставити 2–3 збережені сценарії. A/B/C — лише мітки за порядком вибору, а не рейтинг і не автоматична рекомендація.
- **Строга сумісність сценаріїв:** порівнюються лише плани з однаковими базовими умовами — валюта, бюджет, резерв, дати/горизонт, settlement delay та економічні потреби. Якщо базові умови різні, порівняння fail closed.
- **Пояснення відмінностей:** таблиця показує strategy, склад позицій, вибрані ціни, purchase fee, tax state, reserve, basis/value прибутку, coverage shortfall, кількість early exits та FX comparison.
- **Recurring needs у comparison:** однакові typed recurring needs підтримуються; непідтримані reserve-floor needs не домислюються.
- **Generated Planner copy локалізовано правильно:** стандартні назви плану, основної потреби, додаткових витрат і generated scenario description тепер зберігаються як стабільні технічні ідентифікатори та показуються мовою інтерфейсу.
- **Текст користувача не перекладається:** власні назви планів/потреб/витрат зберігаються буквально.
- **7 мов:** UK / EN / FR / DE / ES / KO / JA для нового generated copy та comparison UI.
- **Regression:** актуальний main після цих змін пройшов analyze та 110/110 Flutter tests.

### Межі цього prerelease
- Reserve-floor/minimum-balance need ще не реалізований у UI.
- Encrypted vault та фактичний portfolio/holdings залишаються майбутнім етапом.
- Windows/macOS test packages не мають production code signing; Android використовує test/development signing; iOS package unsigned.
- OVDP Hub не виконує угоди. Дані та розрахунки перед практичним використанням слід перевіряти за першоджерелами.

---

## English

### What’s new since v0.8.8
- **A/B/C comparison:** Collections can neutrally compare 2–3 saved scenarios. A/B/C are order labels only, not a ranking or automatic recommendation.
- **Strict scenario comparability:** plans are compared only when currency, budget, reserve, dates/horizon, settlement delay, and economic needs match. Different baselines fail closed.
- **Explained differences:** the table shows strategy, position composition, selected prices, purchase fee, tax state, reserve, profit basis/value, coverage shortfall, early-exit count, and FX comparison.
- **Recurring needs in comparison:** identical typed recurring needs are supported; unsupported reserve-floor needs are never guessed.
- **Generated Planner copy is now correctly localized:** default plan, primary-need, additional-expense names, and generated scenario descriptions are stored as stable technical identifiers and rendered in the selected interface language.
- **User text remains literal:** custom plan/need/expense names are not auto-translated.
- **7 languages:** UK / EN / FR / DE / ES / KO / JA for new generated copy and comparison UI.
- **Regression:** current main after these changes passed analyze and 110/110 Flutter tests.

### Prerelease boundaries
- Reserve-floor/minimum-balance needs are not yet implemented in the UI.
- Encrypted vault and real portfolio/holdings remain future work.
- Windows/macOS test packages are not production code-signed; Android uses test/development signing; the iOS package is unsigned.
- OVDP Hub does not execute trades. Verify market data and calculations against primary sources before practical use.

---

## Français

### Nouveautés depuis v0.8.8
- **Comparaison A/B/C :** les « Sélections » peuvent comparer de façon neutre 2 à 3 scénarios enregistrés. A/B/C sont uniquement des étiquettes d’ordre, pas un classement ni une recommandation automatique.
- **Comparabilité stricte :** les scénarios ne sont comparés que si devise, budget, réserve, dates/horizon, délai de règlement et besoins économiques sont identiques. Sinon, la comparaison échoue de manière fermée.
- **Différences expliquées :** le tableau affiche stratégie, composition des positions, prix sélectionnés, frais d’achat, état fiscal, réserve, base/valeur du profit, déficit de couverture, nombre de sorties anticipées et comparaison FX.
- **Besoins récurrents :** les mêmes besoins récurrents typés sont pris en charge; les besoins reserve-floor non pris en charge ne sont jamais supposés.
- **Texte généré du planificateur localisé correctement :** noms par défaut du plan, du besoin principal, des dépenses supplémentaires et description générée du scénario sont stockés comme identifiants techniques stables puis affichés dans la langue choisie.
- **Le texte utilisateur reste littéral :** les noms saisis par l’utilisateur ne sont pas traduits automatiquement.
- **7 langues :** UK / EN / FR / DE / ES / KO / JA pour le nouveau texte généré et l’interface de comparaison.
- **Régression :** le main actuel a passé analyze et 110/110 tests Flutter.

### Limites du prerelease
- Le besoin reserve-floor/minimum-balance n’est pas encore disponible dans l’interface.
- Le coffre chiffré et le portefeuille réel restent des travaux futurs.
- Les packages Windows/macOS ne sont pas signés pour la production; Android utilise une signature de test/développement; le package iOS est non signé.
- OVDP Hub n’exécute pas d’ordres. Vérifiez données de marché et calculs auprès des sources primaires avant usage pratique.

---

## Deutsch

### Neu seit v0.8.8
- **A/B/C-Vergleich:** In „Sammlungen“ können 2–3 gespeicherte Szenarien neutral verglichen werden. A/B/C sind nur Reihenfolge-Markierungen, kein Ranking und keine automatische Empfehlung.
- **Strenge Vergleichbarkeit:** Verglichen wird nur bei gleicher Währung, gleichem Budget, Reserve, Datums-/Zeithorizont, Settlement Delay und wirtschaftlichen Bedarfen. Unterschiedliche Baselines führen zu fail closed.
- **Erklärte Unterschiede:** Die Tabelle zeigt Strategie, Positionszusammensetzung, ausgewählte Preise, Kaufgebühr, Steuerstatus, Reserve, Gewinnbasis/-wert, Deckungsdefizit, Anzahl vorzeitiger Verkäufe und FX-Vergleich.
- **Wiederkehrende Bedarfe:** identische typisierte recurring needs werden unterstützt; nicht unterstützte reserve-floor needs werden nicht erraten.
- **Generierter Planner-Text korrekt lokalisiert:** Standardnamen für Plan, Hauptbedarf, zusätzliche Ausgaben und generierte Szenariobeschreibungen werden als stabile technische Kennungen gespeichert und in der gewählten Sprache angezeigt.
- **Benutzertext bleibt unverändert:** eigene Plan-/Bedarfs-/Ausgabennamen werden nicht automatisch übersetzt.
- **7 Sprachen:** UK / EN / FR / DE / ES / KO / JA für neuen generated copy und Vergleichs-UI.
- **Regression:** aktuelles main bestand analyze und 110/110 Flutter-Tests.

### Grenzen dieses Prerelease
- Reserve-floor/minimum-balance needs sind im UI noch nicht implementiert.
- Verschlüsselter Vault und echtes Portfolio/Holdings bleiben zukünftige Arbeiten.
- Windows/macOS-Testpakete sind nicht produktiv code-signiert; Android nutzt Test-/Development-Signing; das iOS-Paket ist unsigniert.
- OVDP Hub führt keine Geschäfte aus. Marktdaten und Berechnungen sollten vor praktischer Nutzung anhand von Primärquellen geprüft werden.

---

## Español

### Novedades desde v0.8.8
- **Comparación A/B/C:** «Selecciones» permite comparar de forma neutral 2–3 escenarios guardados. A/B/C son solo etiquetas según el orden de selección, no un ranking ni una recomendación automática.
- **Comparabilidad estricta:** solo se comparan planes con la misma moneda, presupuesto, reserva, fechas/horizonte, settlement delay y necesidades económicas. Si la base difiere, la comparación falla de forma cerrada.
- **Diferencias explicadas:** la tabla muestra estrategia, composición, precios seleccionados, comisión de compra, estado fiscal, reserva, base/valor del beneficio, déficit de cobertura, número de salidas anticipadas y comparación FX.
- **Necesidades recurrentes:** se admiten necesidades recurrentes tipadas idénticas; las reserve-floor no compatibles nunca se inventan.
- **Texto generado del planificador correctamente localizado:** nombres predeterminados del plan, necesidad principal, gastos adicionales y descripción generada del escenario se guardan como identificadores técnicos estables y se muestran en el idioma elegido.
- **El texto del usuario permanece literal:** los nombres personalizados no se traducen automáticamente.
- **7 idiomas:** UK / EN / FR / DE / ES / KO / JA para el nuevo texto generado y la interfaz de comparación.
- **Regresión:** el main actual superó analyze y 110/110 pruebas Flutter.

### Límites del prerelease
- La necesidad reserve-floor/minimum-balance aún no está implementada en la interfaz.
- El vault cifrado y el portfolio/holdings real quedan para etapas futuras.
- Los paquetes Windows/macOS no tienen firma de producción; Android usa firma de prueba/desarrollo; el paquete iOS no está firmado.
- OVDP Hub no ejecuta operaciones. Verifique los datos de mercado y los cálculos con las fuentes primarias antes del uso práctico.

---

## 한국어

### v0.8.8 이후 변경 사항
- **A/B/C 비교:** «선택»에서 저장된 시나리오 2–3개를 중립적으로 비교할 수 있습니다. A/B/C는 선택 순서 표시일 뿐 순위나 자동 추천이 아닙니다.
- **엄격한 비교 조건:** 통화, 예산, 준비금, 날짜/기간, settlement delay, 경제적 필요가 같은 계획만 비교합니다. 기준이 다르면 fail closed 처리합니다.
- **차이 설명:** 표에는 전략, 포지션 구성, 선택 가격, 매수 수수료, 세금 상태, 준비금, 수익 기준/값, 부족액, 조기 매도 수, FX 비교가 표시됩니다.
- **반복 필요 지원:** 동일한 typed recurring needs를 지원하며, 미지원 reserve-floor needs는 추정하지 않습니다.
- **Planner 생성 문구의 올바른 현지화:** 기본 계획명, 주요 필요명, 추가 지출명, 생성된 시나리오 설명은 안정적인 기술 식별자로 저장하고 선택한 UI 언어로 표시합니다.
- **사용자 입력은 그대로 유지:** 사용자가 입력한 계획/필요/지출 이름은 자동 번역하지 않습니다.
- **7개 언어:** 새 generated copy와 비교 UI에 UK / EN / FR / DE / ES / KO / JA 지원.
- **회귀 테스트:** 현재 main은 analyze와 Flutter 테스트 110/110을 통과했습니다.

### Prerelease 범위
- Reserve-floor/minimum-balance need는 아직 UI에 구현되지 않았습니다.
- 암호화 vault와 실제 portfolio/holdings는 이후 단계입니다.
- Windows/macOS 테스트 패키지는 production code signing이 없고, Android는 test/development signing을 사용하며, iOS 패키지는 unsigned입니다.
- OVDP Hub는 거래를 실행하지 않습니다. 실제 사용 전 시장 데이터와 계산을 1차 출처로 확인하십시오.

---

## 日本語

### v0.8.8 以降の変更
- **A/B/C 比較:** 「選択」で保存済みシナリオ 2～3 件を中立的に比較できます。A/B/C は選択順のラベルであり、ランキングや自動推奨ではありません。
- **厳密な比較条件:** 通貨、予算、準備金、日付/期間、settlement delay、経済的必要額が同じプランだけを比較します。基準が異なる場合は fail closed します。
- **差異の説明:** 表には strategy、ポジション構成、選択価格、購入手数料、税状態、準備金、利益の基準/値、coverage shortfall、早期売却数、FX 比較を表示します。
- **定期的な必要額:** 同一の typed recurring needs を比較でき、未対応の reserve-floor needs を推測しません。
- **Planner の生成文言を正しくローカライズ:** デフォルトのプラン名、主な必要額、追加支出名、生成シナリオ説明は安定した技術 ID として保存し、選択中の UI 言語で表示します。
- **ユーザー入力はそのまま保持:** ユーザーが付けたプラン/必要額/支出名は自動翻訳しません。
- **7 言語:** 新しい generated copy と比較 UI を UK / EN / FR / DE / ES / KO / JA で提供します。
- **回帰テスト:** 現在の main は analyze と Flutter tests 110/110 を通過しました。

### Prerelease の範囲
- Reserve-floor/minimum-balance need はまだ UI に実装されていません。
- 暗号化 vault と実際の portfolio/holdings は今後の段階です。
- Windows/macOS テストパッケージは production code signing 未対応、Android は test/development signing、iOS パッケージは unsigned です。
- OVDP Hub は取引を実行しません。実利用前に市場データと計算を一次情報源で確認してください。

---

## Packaging / Пакування

The full release workflow must successfully build and publish:
- `OVDP-Hub-0.9.0-Windows-x64.zip`
- `OVDP-Hub-0.9.0-macOS.zip`
- `OVDP-Hub-0.9.0-Android-test.zip`
- `OVDP-Hub-0.9.0-iOS-unsigned.zip`
- `OVDP-Hub-0.9.0-START.zip`
- `SHA256SUMS.txt`
- legal notices

The release is not considered published unless all gated platform jobs and the final GitHub prerelease publication succeed.
