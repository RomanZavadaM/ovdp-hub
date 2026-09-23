# OVDP Hub 0.8.8

**Release date / Дата:** 23.09.2026  
**Status:** prerelease / test checkpoint  
**App version:** 0.8.8+16  
**Copyright:** © 2026 Roman Zavada (Роман Завада). All rights reserved.

---

## Українська

### Що нового після v0.8.7
- **Перевірені податкові припущення для ОВДП 2026:** для фізособи-резидента України доступний явно вибраний профіль з перевіреними 0% правилами для ПДФО та військового збору щодо процентів та інвестиційного прибутку. Невідомий податок не прирівнюється до нуля.
- **FX-порівняння:** можна вручну задати валюту порівняння, курс, дату й URL джерела. Основний cashflow лишається у валюті сценарію; FX — лише порівняльний перерахунок.
- **Достроковий продаж по кожній позиції:** для конкретного ISIN можна задати дату та BID/ручну ціну продажу. Після продажу майбутні купони/погашення цієї позиції не враховуються, а sale proceeds входять у cashflow з урахуванням settlement delay.
- **Майбутні потреби й витрати:** основна потреба має назву, дату й суму та може бути регулярною. Повторення зберігається як typed правило з інтервалом у місяцях і кількістю платежів; дати коректно переходять через кінець місяця. Додаткові потреби залишаються окремими одноразовими записами.
- **Збереження сценарію:** tax / FX / exit / recurring needs проходять save/load без тихого спрощення старих даних.
- **Локалізація й документація:** нові елементи та помилки доступні UK / EN / FR / DE / ES / KO / JA; README розділений на повноцінні мовні сторінки.

### Що ще не завершено
A/B/C comparison лишається окремим draft-слайсом і **не входить до v0.8.8**. Reserve-floor/minimum-balance need та generated planner copy localization також ще не завершені.

---

## English

### What’s new since v0.8.7
- **Verified 2026 OVDP tax assumptions:** an explicitly selected profile is available for an individual resident of Ukraine, with verified 0% PIT and military-levy rules for interest and investment profit. Unknown tax is never treated as zero.
- **FX comparison:** users can enter a comparison currency, rate, date, and source URL. The base cashflow remains in the scenario currency; FX is a comparison layer only.
- **Per-position early sale:** each ISIN can have its own sale date and BID/manual exit price. Contractual payments after the sale are removed and sale proceeds enter cashflow with settlement delay.
- **Future needs and expenses:** the primary need now has a name, date, and amount and can recur. Recurrence is stored as a typed interval/count rule with month-end-safe expansion. Additional needs remain separate one-off items.
- **Scenario persistence:** tax / FX / exit / recurring needs survive save/load without silently flattening richer data.
- **Localization and docs:** new UI/errors are available in UK / EN / FR / DE / ES / KO / JA; README content is split into full language pages.

### Not finished yet
A/B/C comparison remains a separate draft slice and is **not included in v0.8.8**. Reserve-floor/minimum-balance needs and generated planner copy localization also remain unfinished.

---

## Français

### Nouveautés depuis v0.8.7
- **Hypothèses fiscales OVDP 2026 vérifiées :** profil sélectionné explicitement pour une personne physique résidente d’Ukraine, avec règles vérifiées à 0% pour l’impôt sur le revenu et le prélèvement militaire sur intérêts et plus-value d’investissement. Un impôt inconnu n’est jamais assimilé à zéro.
- **Comparaison FX :** l’utilisateur peut saisir devise, taux, date et URL de source. Le cash-flow principal reste dans la devise du scénario; la conversion FX est uniquement comparative.
- **Vente anticipée par position :** chaque ISIN peut avoir sa propre date de vente et son prix BID/manuellement saisi. Les paiements contractuels postérieurs à la vente sont supprimés et le produit de vente entre dans le cash-flow avec le délai de règlement.
- **Besoins et dépenses futurs :** le besoin principal possède nom, date et montant et peut être récurrent. La récurrence est conservée comme règle typée intervalle/nombre, avec gestion correcte des fins de mois. Les besoins supplémentaires restent ponctuels.
- **Persistance :** tax / FX / exit / besoins récurrents sont conservés au save/load sans simplification silencieuse.
- **Localisation et documentation :** nouvelles interfaces/erreurs en UK / EN / FR / DE / ES / KO / JA; README séparé en pages linguistiques complètes.

### Pas encore terminé
La comparaison A/B/C reste un slice draft séparé et **n’est pas incluse dans v0.8.8**. Les besoins reserve-floor/minimum-balance et la localisation du texte généré restent également à faire.

---

## Deutsch

### Neu seit v0.8.7
- **Geprüfte OVDP-Steuerannahmen 2026:** explizit auswählbares Profil für eine in der Ukraine ansässige Privatperson mit verifizierten 0%-Regeln für Einkommensteuer und Militärabgabe auf Zinsen und Anlagegewinn. Unbekannte Steuer wird nie als null behandelt.
- **FX-Vergleich:** Vergleichswährung, Kurs, Datum und Quellen-URL können manuell eingegeben werden. Der Basis-Cashflow bleibt in der Szenariowährung; FX dient nur dem Vergleich.
- **Vorzeitiger Verkauf je Position:** jede ISIN kann ein eigenes Verkaufsdatum und einen BID-/manuellen Exit-Preis haben. Vertragliche Zahlungen nach dem Verkauf entfallen; der Verkaufserlös wird mit Settlement Delay in den Cashflow aufgenommen.
- **Künftige Bedarfe und Ausgaben:** der Hauptbedarf hat Name, Datum und Betrag und kann wiederkehrend sein. Die Wiederholung wird als typisierte Intervall-/Anzahlregel gespeichert und behandelt Monatsenden korrekt. Weitere Bedarfe bleiben einmalige Einträge.
- **Persistenz:** tax / FX / exit / recurring needs bleiben über save/load erhalten, ohne reichere Daten still zu vereinfachen.
- **Lokalisierung und Dokumentation:** neue UI/Fehler in UK / EN / FR / DE / ES / KO / JA; README als vollständige Sprachseiten.

### Noch nicht abgeschlossen
Der A/B/C-Vergleich bleibt ein separater Draft-Slice und ist **nicht in v0.8.8 enthalten**. Reserve-floor/minimum-balance needs und generated planner copy localization sind ebenfalls noch offen.

---

## Español

### Novedades desde v0.8.7
- **Supuestos fiscales OVDP 2026 verificados:** perfil seleccionado explícitamente para una persona física residente en Ucrania, con reglas verificadas del 0% para impuesto sobre la renta y tasa militar sobre intereses y beneficio de inversión. Un impuesto desconocido nunca se trata como cero.
- **Comparación FX:** se pueden introducir moneda de comparación, tipo, fecha y URL de la fuente. El flujo de caja base permanece en la moneda del escenario; FX solo es una vista comparativa.
- **Venta anticipada por posición:** cada ISIN puede tener su propia fecha de venta y precio BID/manual. Los pagos contractuales posteriores a la venta se eliminan y el ingreso por venta entra en el flujo de caja con settlement delay.
- **Necesidades y gastos futuros:** la necesidad principal tiene nombre, fecha e importe y puede ser recurrente. La recurrencia se guarda como regla tipada de intervalo/cantidad con ajuste correcto a fin de mes. Las necesidades adicionales siguen siendo únicas.
- **Persistencia:** tax / FX / exit / recurring needs sobreviven al save/load sin simplificación silenciosa.
- **Localización y documentación:** nueva UI/errores en UK / EN / FR / DE / ES / KO / JA; README separado en páginas completas por idioma.

### Aún no terminado
La comparación A/B/C sigue siendo un slice draft separado y **no está incluida en v0.8.8**. Las necesidades reserve-floor/minimum-balance y la localización del texto generado también siguen pendientes.

---

## 한국어

### v0.8.7 이후 변경 사항
- **검증된 2026 OVDP 세금 가정:** 우크라이나 거주 개인용 프로필을 명시적으로 선택할 수 있으며 이자와 투자이익에 대한 소득세 및 군사세 0% 규칙이 검증되어 있습니다. 미확인 세금을 0으로 간주하지 않습니다.
- **FX 비교:** 비교 통화, 환율, 날짜, 출처 URL을 직접 입력할 수 있습니다. 기본 현금흐름은 시나리오 통화에 유지되고 FX는 비교용 표시만 제공합니다.
- **포지션별 만기 전 매도:** 각 ISIN에 자체 매도일과 BID/수동 exit 가격을 지정할 수 있습니다. 매도 후 계약상 지급은 제외되고 매도대금은 settlement delay를 반영해 현금흐름에 들어갑니다.
- **미래 필요와 지출:** 주요 필요에 이름/날짜/금액이 있으며 반복 필요로 설정할 수 있습니다. 반복은 월 간격과 횟수의 typed 규칙으로 저장되고 월말도 안전하게 처리합니다. 추가 필요는 일회성 항목으로 유지됩니다.
- **시나리오 저장:** tax / FX / exit / recurring needs가 save/load를 거쳐도 더 풍부한 데이터를 조용히 단순화하지 않습니다.
- **현지화와 문서:** 새 UI/오류는 UK / EN / FR / DE / ES / KO / JA로 제공되며 README는 전체 언어 페이지로 분리되었습니다.

### 아직 완료되지 않은 항목
A/B/C 비교는 별도의 draft slice이며 **v0.8.8에 포함되지 않습니다**. Reserve-floor/minimum-balance need와 generated planner copy localization도 아직 미완료입니다.

---

## 日本語

### v0.8.7 以降の変更
- **検証済み 2026 OVDP 税務前提:** ウクライナ居住個人向けのプロファイルを明示的に選択でき、利息・投資利益に対する所得税および軍事税 0% ルールが検証されています。不明な税金を 0 として扱いません。
- **FX 比較:** 比較通貨、レート、日付、情報源 URL を手動入力できます。基準キャッシュフローはシナリオ通貨のままで、FX は比較表示のみです。
- **ポジション別の満期前売却:** 各 ISIN に個別の売却日と BID/手動 exit 価格を設定できます。売却後の契約上の支払は除外され、売却代金は settlement delay を反映して cashflow に入ります。
- **将来の必要額と支出:** 主な必要額に名称・日付・金額を持たせ、定期的な必要額にできます。繰り返しは月間隔と回数の typed ルールで保存され、月末も安全に処理します。追加の必要額は一回限り項目として残ります。
- **シナリオ保存:** tax / FX / exit / recurring needs は save/load 後も豊富なデータを暗黙に単純化しません。
- **ローカライズと文書:** 新しい UI/エラーは UK / EN / FR / DE / ES / KO / JA で提供され、README は完全な言語別ページに分割されました。

### 未完了
A/B/C 比較は別の draft slice のままで **v0.8.8 には含まれません**。Reserve-floor/minimum-balance need と generated planner copy localization も未完了です。

---

## Packaging / Пакування

Release pipeline builds:
- `OVDP-Hub-0.8.8-Windows-x64.zip`
- `OVDP-Hub-0.8.8-macOS.zip`
- `OVDP-Hub-0.8.8-Android-test.zip`
- `OVDP-Hub-0.8.8-iOS-unsigned.zip`
- `OVDP-Hub-0.8.8-START.zip`
- `SHA256SUMS.txt`
- legal notices

Windows/macOS packages are not production code-signed. Android uses the current test/development signing configuration. The iOS package is unsigned.
