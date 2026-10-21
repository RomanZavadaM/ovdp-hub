import '../../l10n/hub_locale.dart';

extension PublicOfferStrings on HubStrings {
  String offerText(String key) => _copy[language.code]?[key] ?? _copy['uk']![key] ?? key;
}

const _copy = <String, Map<String, String>>{
  'uk': {
    'rejected': 'Пропущено рядків', 'unmatched': 'Не зіставлено з НБУ (ISIN, валюта або дата погашення)',
    'title': 'Публічні пропозиції за ISIN', 'load': 'Оновити всі публічні джерела',
    'notice': 'Індикативні дані з відкритих сторінок. Комісії та повна вартість не підтверджені. Остаточні умови перевіряйте у продавця.',
    'unavailable': 'Джерело недоступне або змінило формат. Попередні дані можуть бути застарілими.',
    'purchase': 'Опублікована ціна купівлі', 'sale': 'Опублікована ціна продажу',
    'yield': 'Заявлена дохідність', 'quantity': 'Опублікована кількість',
    'timestamp': 'Джерело не вказує час актуальності котирувань.',
    'empty': 'Завантажте джерела. Тут будуть пропозиції, зіставлені з каталогом НБУ за ISIN і валютою.',
  },
  'en': {
    'rejected': 'Rejected rows', 'unmatched': 'Not matched to NBU (ISIN, currency or maturity)',
    'title': 'Public offers by ISIN', 'load': 'Refresh all public sources',
    'notice': 'Indicative data from public pages. Fees and total cost are unverified. Confirm final terms with the seller.',
    'unavailable': 'Source unavailable or its format changed. Previous data may be stale.',
    'purchase': 'Published purchase price', 'sale': 'Published sale price',
    'yield': 'Listed yield', 'quantity': 'Published quantity',
    'timestamp': 'The source does not state a quote timestamp.',
    'empty': 'Load sources to see offers matched to the NBU catalog by ISIN and currency.',
  },
  'fr': {
    'rejected': 'Lignes rejetées', 'unmatched': 'Non rapprochées du NBU (ISIN, devise ou échéance)',
    'title': 'Offres publiques par ISIN', 'load': 'Actualiser les sources publiques',
    'notice': 'Données indicatives de pages publiques. Frais et coût total non vérifiés. Confirmez les conditions auprès du vendeur.',
    'unavailable': 'Source indisponible ou format modifié. Les données précédentes peuvent être périmées.',
    'purchase': 'Prix d’achat publié', 'sale': 'Prix de vente publié',
    'yield': 'Rendement annoncé', 'quantity': 'Quantité publiée',
    'timestamp': 'La source ne précise pas la date de validité des cotations.',
    'empty': 'Chargez les sources pour afficher les offres reliées au catalogue NBU par ISIN et devise.',
  },
  'de': {
    'rejected': 'Verworfene Zeilen', 'unmatched': 'Kein NBU-Abgleich (ISIN, Währung oder Fälligkeit)',
    'title': 'Öffentliche Angebote nach ISIN', 'load': 'Öffentliche Quellen aktualisieren',
    'notice': 'Indikative Daten öffentlicher Seiten. Gebühren und Gesamtkosten sind ungeprüft. Bestätigen Sie die Bedingungen beim Anbieter.',
    'unavailable': 'Quelle nicht verfügbar oder Format geändert. Frühere Daten können veraltet sein.',
    'purchase': 'Veröffentlichter Kaufpreis', 'sale': 'Veröffentlichter Verkaufspreis',
    'yield': 'Angegebene Rendite', 'quantity': 'Veröffentlichte Stückzahl',
    'timestamp': 'Die Quelle nennt keinen Gültigkeitszeitpunkt der Kurse.',
    'empty': 'Laden Sie Quellen, um Angebote nach ISIN und Währung mit dem NBU-Katalog abzugleichen.',
  },
  'es': {
    'rejected': 'Filas rechazadas', 'unmatched': 'Sin coincidencia NBU (ISIN, moneda o vencimiento)',
    'title': 'Ofertas públicas por ISIN', 'load': 'Actualizar fuentes públicas',
    'notice': 'Datos indicativos de páginas públicas. Comisiones y coste total sin verificar. Confirme las condiciones con el vendedor.',
    'unavailable': 'Fuente no disponible o formato modificado. Los datos anteriores pueden estar desactualizados.',
    'purchase': 'Precio de compra publicado', 'sale': 'Precio de venta publicado',
    'yield': 'Rentabilidad anunciada', 'quantity': 'Cantidad publicada',
    'timestamp': 'La fuente no indica la fecha de vigencia de las cotizaciones.',
    'empty': 'Cargue las fuentes para ver ofertas vinculadas al catálogo NBU por ISIN y moneda.',
  },
  'ko': {
    'rejected': '제외된 행', 'unmatched': 'NBU 불일치 (ISIN, 통화 또는 만기)',
    'title': 'ISIN별 공개 제안', 'load': '모든 공개 출처 새로고침',
    'notice': '공개 페이지의 참고용 정보입니다. 수수료와 총비용은 확인되지 않았습니다. 최종 조건은 판매자에게 확인하세요.',
    'unavailable': '출처에 접근할 수 없거나 형식이 변경되었습니다. 이전 정보는 오래되었을 수 있습니다.',
    'purchase': '게시된 매수가', 'sale': '게시된 매도가',
    'yield': '표시 수익률', 'quantity': '게시된 수량',
    'timestamp': '출처에 호가의 기준 시간이 명시되어 있지 않습니다.',
    'empty': '출처를 불러오면 ISIN과 통화로 NBU 목록과 연결된 제안이 표시됩니다.',
  },
  'ja': {
    'rejected': '除外された行', 'unmatched': 'NBUと不一致（ISIN、通貨、償還日）',
    'title': 'ISIN別の公開オファー', 'load': 'すべての公開情報源を更新',
    'notice': '公開ページの参考情報です。手数料と総費用は未確認です。最終条件は販売者に確認してください。',
    'unavailable': '情報源にアクセスできないか形式が変更されました。以前の情報は古い可能性があります。',
    'purchase': '公開購入価格', 'sale': '公開売却価格',
    'yield': '表示利回り', 'quantity': '公開数量',
    'timestamp': '情報源は気配値の基準時刻を示していません。',
    'empty': '情報源を読み込むと、ISINと通貨でNBUカタログに照合されたオファーを表示します。',
  },
};
