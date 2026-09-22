import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AppLanguage {
  uk('uk', 'Українська', 'Основна мова'),
  en('en', 'English', 'Англійська'),
  fr('fr', 'Français', 'Французька'),
  de('de', 'Deutsch', 'Німецька'),
  es('es', 'Español', 'Іспанська'),
  ko('ko', '한국어', 'Корейська'),
  ja('ja', '日本語', 'Японська');

  final String code;
  final String nativeName;
  final String ukrainianDescription;
  const AppLanguage(this.code, this.nativeName, this.ukrainianDescription);

  Locale get locale => Locale(code);
}

@immutable
class LocaleState {
  final AppLanguage language;
  const LocaleState({this.language = AppLanguage.uk});
}

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(const LocaleState());
  void select(AppLanguage language) => emit(LocaleState(language: language));
}

class HubStrings {
  final AppLanguage language;
  const HubStrings(this.language);

  static HubStrings of(BuildContext context) =>
      HubStrings(context.watch<LocaleCubit>().state.language);

  static const Set<int> fullyLocalizedScreens = {0, 2, 5};

  bool screenIsFullyLocalized(int index) =>
      language == AppLanguage.uk || fullyLocalizedScreens.contains(index);

  String text(String key) =>
      _translations[language.code]?[key] ??
      _translations['uk']?[key] ??
      key;

  String fmt(String key, Map<String, Object?> values) {
    var result = text(key);
    for (final entry in values.entries) {
      result = result.replaceAll(
        '{' + entry.key + '}',
        (entry.value ?? '').toString(),
      );
    }
    return result;
  }

  bool hasExplicit(String key) =>
      _translations[language.code]?.containsKey(key) ?? false;

  static const Map<String, Map<String, String>> _translations = {
    'uk': {
      'catalog': 'Каталог', 'collections': 'Добірки', 'calculator': 'Калькулятор',
      'workspace': 'Сховище', 'planning': 'Планування', 'sellers': 'Продавці',
      'about': 'Про програму', 'language': 'Мова / Language',
      'studioTitle': 'Аналітичний кабінет', 'workspaceClosed': 'Сховище не відкрито',
      'localData': 'Дані на вашому пристрої', 'close': 'Закрити',
      'back': 'Повернутися', 'discardDraft': 'Відкинути чернетку',
      'unsavedTitle': 'Є незбережена добірка',
      'unsavedBody': 'Збережіть її перед продовженням або відкиньте чернетку.',
      'classicDesign': 'Класичний дизайн', 'studioDesign': 'Дизайн «Робочий кабінет»',
      'translationIncomplete': 'Переклад цього модуля ще неповний. Частина тексту може залишатися українською.',
      'aboutBody': 'ОВДП Hub є proprietary software. Публічна видимість вихідного коду не є open-source ліцензією. Повні умови використання містяться у LICENSE.md.',
      'decisionSpace': 'ПРОСТІР ДЛЯ РІШЕНЬ', 'explore': 'ДОСЛІДИТИ',
      'myDecisions': 'МОЇ РІШЕННЯ',
      'sidebarInfo': 'Без облікового запису\nСценарії у вашій робочій папці\n\nТестова prerelease версія',
      'heroKicker': 'ДОСЛІДЖУЙТЕ. ПОРІВНЮЙТЕ. ПЛАНУЙТЕ.',
      'heroTitle': 'Облігації під ваші плани',
      'heroBody': 'Від випуску ОВДП — до календаря ваших коштів.\nПорівнюйте строки та перевіряйте майбутні витрати.',
      'planFunds': 'Планувати кошти', 'viewSellers': 'Переглянути продавців',
      'bondNominal': 'Номінал', 'bondRate': 'Ставка', 'bondMaturity': 'Погашення',
      'paymentSchedule': 'Графік виплат на одну облігацію', 'coupon': 'Купон',
      'redemption': 'Погашення', 'earlyRedemption': 'Дострокове погашення',
      'openWorkspace': 'Відкрийте робочу папку',
      'catalogOffline': 'Каталог і збережені набори будуть доступні без інтернету.',
      'setupWorkspace': 'Налаштувати сховище',
      'catalogClassicTitle': 'Ваш простір для обдуманих рішень',
      'catalogIntro': 'Публічні дані НБУ · Порівняння випусків · Власні сценарії',
      'issuesInSelection': 'Випусків у вибірці', 'issuesInCurrency': 'Випусків у {currency}',
      'loaded': 'Завантажено: {date}', 'staleSnapshot': 'Знімок старший за 24 години',
      'nominalNotYield': 'Номінальна ставка не є дохідністю купівлі. Цін брокерів у каталозі немає.',
      'refreshNbu': 'Оновити напряму з НБУ', 'searchIsin': 'Пошук за ISIN',
      'allCurrencies': 'Усі валюти', 'activeOnly': 'Непогашені за строком',
      'allTerms': 'Усі строки', 'shortTerm': 'До 12 місяців', 'longTerm': 'Від 24 місяців',
      'noIssues': 'За цими критеріями випусків немає.', 'issueDetails': 'Деталі випуску',
      'nominalRate': 'номінальна ставка',
      'calcTitle': 'Навчальний калькулятор',
      'calcExample': 'СИНТЕТИЧНИЙ ПРИКЛАД · Купівля 22.09.2026, єдина виплата 1000 грн 22.09.2027 на облігацію. НКД, податки й регулярні витрати — 0. Це не ринкова пропозиція.',
      'quantity': 'Кількість облігацій', 'cleanPrice': 'Чиста ціна, грн',
      'oneTimeFee': 'Разова комісія, грн', 'calculateLocal': 'Розрахувати локально',
      'costs': 'Витрати', 'receipts': 'Надходження', 'result': 'Результат',
      'approxXirr': 'Орієнтовна XIRR ACT/365F',
      'sellersTitle': 'Продавці · публічні котирування',
      'sellersIntro': 'НБУ описує випуски та виплати. Тут — окремі дані продавця, отримані безпосередньо з його сайту. Ваші плани й портфель не передаються.',
      'privatbank': 'ПриватБанк', 'loadPrivat': 'Завантажити котирування ПриватБанку',
      'sourceDate': 'Дата на сайті: {date}', 'loadedAt': 'Завантажено: {date}',
      'sellerExplanation': 'ASK — дохідність продажу банком клієнту; BID — купівлі банком. Це не ціна за облігацію. SIM і YTM — різні методи розрахунку. Обсяг, остаточна ціна з НКД та комісії потребують підтвердження.',
      'askOnly': 'Лише з котируванням продажу (ASK)',
      'pressLoad': 'Натисніть завантаження. Вбудованих або вигаданих котирувань немає.',
      'noSellerIssues': 'Немає непогашених випусків за цим фільтром.',
      'notConfirmed': 'Наявність і кількість не підтверджені', 'otherSellers': 'Інші продавці',
      'icuText': 'ICU Trade — торгівля в сервісі брокера. Автоматичне джерело котирувань ще не підключене.',
      'senseText': 'Sense Bank — пропозиції в Sense SuperApp. Автоматичне джерело котирувань ще не підключене.',
      'sellerPlanHint': 'Для сценарію: скопіюйте ISIN, знайдіть випуск у каталозі та введіть у планувальнику повну ціну продавця. Завантажені тут котирування зберігаються лише до закриття застосунку.',
      'futureWarning': 'Дата джерела в майбутньому. Актуальність не підтверджена.',
      'staleWarning': 'Котирування не за сьогодні. Уточніть умови у продавця.',
      'unknownWarning': 'Джерело не має надійної дати даних. Перевірте умови у продавця.',
      'refreshFailed': 'Не вдалося оновити. Показано попереднє завантаження, якщо воно є.',
    },
    'en': {
      'catalog': 'Catalog', 'collections': 'Collections', 'calculator': 'Calculator',
      'workspace': 'Storage', 'planning': 'Planning', 'sellers': 'Sellers',
      'about': 'About', 'language': 'Language', 'studioTitle': 'Analytics workspace',
      'workspaceClosed': 'Storage is not open', 'localData': 'Data on your device',
      'close': 'Close', 'back': 'Go back', 'discardDraft': 'Discard draft',
      'unsavedTitle': 'There is an unsaved collection',
      'unsavedBody': 'Save it before continuing or discard the draft.',
      'classicDesign': 'Classic design', 'studioDesign': 'Workspace design',
      'translationIncomplete': 'This module is not fully translated yet. Some text may remain in Ukrainian.',
      'aboutBody': 'OVDP Hub is proprietary software. Public visibility of the source code is not an open-source license. Full terms are in LICENSE.md.',
      'decisionSpace': 'DECISION SPACE', 'explore': 'EXPLORE', 'myDecisions': 'MY DECISIONS',
      'sidebarInfo': 'No account required\nScenarios stay in your workspace\n\nTest prerelease',
      'heroKicker': 'EXPLORE. COMPARE. PLAN.', 'heroTitle': 'Bonds for your plans',
      'heroBody': 'From a government bond issue to your cash calendar.\nCompare maturities and check future expenses.',
      'planFunds': 'Plan cash', 'viewSellers': 'View sellers',
      'bondNominal': 'Nominal', 'bondRate': 'Rate', 'bondMaturity': 'Maturity',
      'paymentSchedule': 'Payment schedule per bond', 'coupon': 'Coupon',
      'redemption': 'Redemption', 'earlyRedemption': 'Early redemption',
      'openWorkspace': 'Open a workspace',
      'catalogOffline': 'The catalog and saved collections will be available offline.',
      'setupWorkspace': 'Set up storage', 'catalogClassicTitle': 'Your space for informed decisions',
      'catalogIntro': 'NBU public data · Compare issues · Your own scenarios',
      'issuesInSelection': 'Issues in selection', 'issuesInCurrency': 'Issues in {currency}',
      'loaded': 'Loaded: {date}', 'staleSnapshot': 'Snapshot is older than 24 hours',
      'nominalNotYield': 'The nominal rate is not a purchase yield. Broker prices are not included in the catalog.',
      'refreshNbu': 'Refresh directly from NBU', 'searchIsin': 'Search by ISIN',
      'allCurrencies': 'All currencies', 'activeOnly': 'Not yet matured',
      'allTerms': 'All maturities', 'shortTerm': 'Up to 12 months', 'longTerm': 'From 24 months',
      'noIssues': 'No issues match these filters.', 'issueDetails': 'Issue details',
      'nominalRate': 'nominal rate',
      'calcTitle': 'Educational calculator',
      'calcExample': 'SYNTHETIC EXAMPLE · Purchase 22.09.2026, one payment of UAH 1000 on 22.09.2027 per bond. Accrued interest, taxes and recurring costs are 0. This is not a market offer.',
      'quantity': 'Number of bonds', 'cleanPrice': 'Clean price, UAH',
      'oneTimeFee': 'One-time fee, UAH', 'calculateLocal': 'Calculate locally',
      'costs': 'Costs', 'receipts': 'Receipts', 'result': 'Result',
      'approxXirr': 'Approximate XIRR ACT/365F',
      'sellersTitle': 'Sellers · public quotes',
      'sellersIntro': 'NBU describes issues and payments. This section shows separate seller data loaded directly from the seller website. Your plans and portfolio are not transmitted.',
      'privatbank': 'PrivatBank', 'loadPrivat': 'Load PrivatBank quotes',
      'sourceDate': 'Source date: {date}', 'loadedAt': 'Loaded: {date}',
      'sellerExplanation': 'ASK is the yield for a bank sale to a client; BID is for a bank purchase. It is not a bond price. SIM and YTM are different methods. Quantity, final dirty price and fees require confirmation.',
      'askOnly': 'Only with an ASK quote',
      'pressLoad': 'Load the data first. There are no built-in or invented quotes.',
      'noSellerIssues': 'No non-matured issues match this filter.',
      'notConfirmed': 'Availability and quantity are not confirmed',
      'otherSellers': 'Other sellers',
      'icuText': 'ICU Trade provides trading through the broker service. An automated public quote source is not connected yet.',
      'senseText': 'Sense Bank offers bonds in Sense SuperApp. An automated public quote source is not connected yet.',
      'sellerPlanHint': 'For a scenario: copy the ISIN, find the issue in the catalog and enter the seller full price in the planner. Loaded quotes are kept only until the app is closed.',
      'futureWarning': 'The source date is in the future. Freshness is not confirmed.',
      'staleWarning': 'The quote is not dated today. Confirm the terms with the seller.',
      'unknownWarning': 'The source has no reliable data date. Confirm the terms with the seller.',
      'refreshFailed': 'Refresh failed. The previous snapshot is kept when available.',
    },
    'fr': {
      'catalog':'Catalogue','collections':'Sélections','calculator':'Calculateur','workspace':'Stockage','planning':'Planification','sellers':'Vendeurs','about':'À propos','language':'Langue','studioTitle':'Espace analytique','workspaceClosed':'Stockage non ouvert','localData':'Données sur votre appareil',
      'close':'Fermer','back':'Retour','discardDraft':'Supprimer le brouillon','unsavedTitle':'Une sélection n’est pas enregistrée','unsavedBody':'Enregistrez-la avant de continuer ou supprimez le brouillon.','classicDesign':'Design classique','studioDesign':'Design espace de travail','translationIncomplete':'Ce module n’est pas encore entièrement traduit. Certains textes peuvent rester en ukrainien.','aboutBody':'OVDP Hub est un logiciel propriétaire. La visibilité publique du code source ne constitue pas une licence open source. Les conditions complètes figurent dans LICENSE.md.',
      'decisionSpace':'ESPACE DE DÉCISION','explore':'EXPLORER','myDecisions':'MES DÉCISIONS','sidebarInfo':'Aucun compte requis\nScénarios dans votre espace local\n\nPrérelease de test','heroKicker':'EXPLORER. COMPARER. PLANIFIER.','heroTitle':'Des obligations pour vos projets','heroBody':'De l’émission d’OVDP au calendrier de vos liquidités.\nComparez les échéances et vérifiez vos dépenses futures.','planFunds':'Planifier les liquidités','viewSellers':'Voir les vendeurs',
      'bondNominal':'Nominal','bondRate':'Taux','bondMaturity':'Échéance','paymentSchedule':'Calendrier des paiements par obligation','coupon':'Coupon','redemption':'Remboursement','earlyRedemption':'Remboursement anticipé',
      'openWorkspace':'Ouvrir un espace de travail','catalogOffline':'Le catalogue et les sélections enregistrées seront disponibles hors ligne.','setupWorkspace':'Configurer le stockage','catalogClassicTitle':'Votre espace pour des décisions éclairées','catalogIntro':'Données publiques NBU · Comparaison des émissions · Vos scénarios','issuesInSelection':'Émissions sélectionnées','issuesInCurrency':'Émissions en {currency}','loaded':'Chargé : {date}','staleSnapshot':'Instantané de plus de 24 heures','nominalNotYield':'Le taux nominal n’est pas le rendement d’achat. Les prix des courtiers ne figurent pas dans le catalogue.','refreshNbu':'Actualiser depuis la NBU','searchIsin':'Rechercher par ISIN','allCurrencies':'Toutes les devises','activeOnly':'Non échues','allTerms':'Toutes les échéances','shortTerm':'Jusqu’à 12 mois','longTerm':'À partir de 24 mois','noIssues':'Aucune émission ne correspond à ces filtres.','issueDetails':'Détails de l’émission','nominalRate':'taux nominal',
      'calcTitle':'Calculateur pédagogique','calcExample':'EXEMPLE SYNTHÉTIQUE · Achat le 22.09.2026, paiement unique de 1000 UAH le 22.09.2027 par obligation. Intérêts courus, impôts et coûts récurrents : 0. Ce n’est pas une offre de marché.','quantity':'Nombre d’obligations','cleanPrice':'Prix net, UAH','oneTimeFee':'Commission unique, UAH','calculateLocal':'Calculer localement','costs':'Coûts','receipts':'Encaissements','result':'Résultat','approxXirr':'XIRR ACT/365F approximatif',
      'sellersTitle':'Vendeurs · cotations publiques','sellersIntro':'La NBU décrit les émissions et paiements. Ici figurent séparément les données du vendeur chargées depuis son site. Vos plans et votre portefeuille ne sont pas transmis.','privatbank':'PrivatBank','loadPrivat':'Charger les cotations PrivatBank','sourceDate':'Date source : {date}','loadedAt':'Chargé : {date}','sellerExplanation':'ASK est le rendement de vente de la banque au client ; BID celui de l’achat par la banque. Ce n’est pas le prix d’une obligation. SIM et YTM sont différents. Quantité, prix total et commissions doivent être confirmés.','askOnly':'Uniquement avec cotation ASK','pressLoad':'Chargez d’abord les données. Aucune cotation intégrée ou inventée.','noSellerIssues':'Aucune émission non échue ne correspond au filtre.','notConfirmed':'Disponibilité et quantité non confirmées','otherSellers':'Autres vendeurs','icuText':'ICU Trade permet de négocier via le service du courtier. Aucune source automatique publique n’est encore connectée.','senseText':'Sense Bank propose des obligations dans Sense SuperApp. Aucune source automatique publique n’est encore connectée.','sellerPlanHint':'Pour un scénario : copiez l’ISIN, trouvez l’émission dans le catalogue et saisissez le prix total du vendeur dans le planificateur. Les cotations sont conservées uniquement jusqu’à la fermeture de l’application.','futureWarning':'La date source est dans le futur. L’actualité n’est pas confirmée.','staleWarning':'La cotation n’est pas datée d’aujourd’hui. Confirmez les conditions auprès du vendeur.','unknownWarning':'La source ne fournit pas de date fiable. Confirmez les conditions auprès du vendeur.','refreshFailed':'Échec de l’actualisation. L’instantané précédent est conservé s’il existe.',
    },
    'de': {
      'catalog':'Katalog','collections':'Sammlungen','calculator':'Rechner','workspace':'Speicher','planning':'Planung','sellers':'Anbieter','about':'Über','language':'Sprache','studioTitle':'Analysebereich','workspaceClosed':'Speicher ist nicht geöffnet','localData':'Daten auf Ihrem Gerät',
      'close':'Schließen','back':'Zurück','discardDraft':'Entwurf verwerfen','unsavedTitle':'Eine Sammlung ist noch nicht gespeichert','unsavedBody':'Speichern Sie sie vor dem Fortfahren oder verwerfen Sie den Entwurf.','classicDesign':'Klassisches Design','studioDesign':'Arbeitsbereich-Design','translationIncomplete':'Dieses Modul ist noch nicht vollständig übersetzt. Einige Texte können auf Ukrainisch bleiben.','aboutBody':'OVDP Hub ist proprietäre Software. Die öffentliche Sichtbarkeit des Quellcodes ist keine Open-Source-Lizenz. Die vollständigen Bedingungen stehen in LICENSE.md.',
      'decisionSpace':'ENTSCHEIDUNGSRAUM','explore':'ANALYSIEREN','myDecisions':'MEINE ENTSCHEIDUNGEN','sidebarInfo':'Kein Konto erforderlich\nSzenarien bleiben lokal\n\nTest-Prerelease','heroKicker':'ANALYSIEREN. VERGLEICHEN. PLANEN.','heroTitle':'Anleihen für Ihre Pläne','heroBody':'Von der OVDP-Emission bis zu Ihrem Liquiditätskalender.\nVergleichen Sie Laufzeiten und prüfen Sie künftige Ausgaben.','planFunds':'Liquidität planen','viewSellers':'Anbieter ansehen',
      'bondNominal':'Nennwert','bondRate':'Satz','bondMaturity':'Fälligkeit','paymentSchedule':'Zahlungsplan je Anleihe','coupon':'Kupon','redemption':'Tilgung','earlyRedemption':'Vorzeitige Tilgung',
      'openWorkspace':'Arbeitsordner öffnen','catalogOffline':'Katalog und gespeicherte Sammlungen sind offline verfügbar.','setupWorkspace':'Speicher einrichten','catalogClassicTitle':'Ihr Raum für fundierte Entscheidungen','catalogIntro':'Öffentliche NBU-Daten · Emissionen vergleichen · Eigene Szenarien','issuesInSelection':'Emissionen in Auswahl','issuesInCurrency':'Emissionen in {currency}','loaded':'Geladen: {date}','staleSnapshot':'Snapshot älter als 24 Stunden','nominalNotYield':'Der Nominalzins ist nicht die Kaufrendite. Brokerpreise sind nicht im Katalog enthalten.','refreshNbu':'Direkt von der NBU aktualisieren','searchIsin':'Nach ISIN suchen','allCurrencies':'Alle Währungen','activeOnly':'Noch nicht fällig','allTerms':'Alle Laufzeiten','shortTerm':'Bis 12 Monate','longTerm':'Ab 24 Monaten','noIssues':'Keine Emission entspricht diesen Filtern.','issueDetails':'Emissionsdetails','nominalRate':'Nominalzins',
      'calcTitle':'Lernrechner','calcExample':'SYNTHETISCHES BEISPIEL · Kauf am 22.09.2026, einmalige Zahlung von 1000 UAH am 22.09.2027 je Anleihe. Stückzinsen, Steuern und laufende Kosten: 0. Kein Marktangebot.','quantity':'Anzahl der Anleihen','cleanPrice':'Clean Price, UAH','oneTimeFee':'Einmalige Gebühr, UAH','calculateLocal':'Lokal berechnen','costs':'Kosten','receipts':'Zuflüsse','result':'Ergebnis','approxXirr':'Ungefähre XIRR ACT/365F',
      'sellersTitle':'Anbieter · öffentliche Kurse','sellersIntro':'Die NBU beschreibt Emissionen und Zahlungen. Hier werden separate Anbieterdaten direkt von dessen Website geladen. Ihre Pläne und Ihr Portfolio werden nicht übertragen.','privatbank':'PrivatBank','loadPrivat':'PrivatBank-Kurse laden','sourceDate':'Quelldatum: {date}','loadedAt':'Geladen: {date}','sellerExplanation':'ASK ist die Rendite beim Verkauf der Bank an den Kunden; BID beim Ankauf durch die Bank. Das ist kein Anleihepreis. SIM und YTM sind unterschiedliche Methoden. Menge, Vollpreis und Gebühren müssen bestätigt werden.','askOnly':'Nur mit ASK-Kurs','pressLoad':'Laden Sie zuerst die Daten. Es gibt keine eingebauten oder erfundenen Kurse.','noSellerIssues':'Keine nicht fällige Emission entspricht dem Filter.','notConfirmed':'Verfügbarkeit und Menge nicht bestätigt','otherSellers':'Weitere Anbieter','icuText':'ICU Trade ermöglicht Handel über den Brokerdienst. Eine automatische öffentliche Kursquelle ist noch nicht verbunden.','senseText':'Sense Bank bietet Anleihen in der Sense SuperApp an. Eine automatische öffentliche Kursquelle ist noch nicht verbunden.','sellerPlanHint':'Für ein Szenario: ISIN kopieren, Emission im Katalog finden und den Vollpreis des Anbieters im Planer eingeben. Geladene Kurse bleiben nur bis zum Schließen der App erhalten.','futureWarning':'Das Quelldatum liegt in der Zukunft. Aktualität ist nicht bestätigt.','staleWarning':'Der Kurs ist nicht von heute. Konditionen beim Anbieter bestätigen.','unknownWarning':'Die Quelle hat kein verlässliches Datumsfeld. Konditionen beim Anbieter bestätigen.','refreshFailed':'Aktualisierung fehlgeschlagen. Ein vorhandener vorheriger Snapshot bleibt erhalten.',
    },
    'es': {
      'catalog':'Catálogo','collections':'Colecciones','calculator':'Calculadora','workspace':'Almacenamiento','planning':'Planificación','sellers':'Vendedores','about':'Acerca de','language':'Idioma','studioTitle':'Espacio analítico','workspaceClosed':'El almacenamiento no está abierto','localData':'Datos en su dispositivo',
      'close':'Cerrar','back':'Volver','discardDraft':'Descartar borrador','unsavedTitle':'Hay una colección sin guardar','unsavedBody':'Guárdela antes de continuar o descarte el borrador.','classicDesign':'Diseño clásico','studioDesign':'Diseño de espacio de trabajo','translationIncomplete':'Este módulo aún no está completamente traducido. Parte del texto puede permanecer en ucraniano.','aboutBody':'OVDP Hub es software propietario. La visibilidad pública del código fuente no constituye una licencia de código abierto. Las condiciones completas están en LICENSE.md.',
      'decisionSpace':'ESPACIO DE DECISIÓN','explore':'EXPLORAR','myDecisions':'MIS DECISIONES','sidebarInfo':'Sin cuenta\nEscenarios en su espacio local\n\nPrerelease de prueba','heroKicker':'EXPLORE. COMPARE. PLANIFIQUE.','heroTitle':'Bonos para sus planes','heroBody':'Desde una emisión OVDP hasta su calendario de efectivo.\nCompare vencimientos y revise gastos futuros.','planFunds':'Planificar efectivo','viewSellers':'Ver vendedores',
      'bondNominal':'Nominal','bondRate':'Tasa','bondMaturity':'Vencimiento','paymentSchedule':'Calendario de pagos por bono','coupon':'Cupón','redemption':'Amortización','earlyRedemption':'Amortización anticipada',
      'openWorkspace':'Abra un espacio de trabajo','catalogOffline':'El catálogo y las colecciones guardadas estarán disponibles sin conexión.','setupWorkspace':'Configurar almacenamiento','catalogClassicTitle':'Su espacio para decisiones informadas','catalogIntro':'Datos públicos del NBU · Compare emisiones · Sus escenarios','issuesInSelection':'Emisiones seleccionadas','issuesInCurrency':'Emisiones en {currency}','loaded':'Cargado: {date}','staleSnapshot':'Instantánea de más de 24 horas','nominalNotYield':'La tasa nominal no es el rendimiento de compra. El catálogo no contiene precios de brókeres.','refreshNbu':'Actualizar directamente desde NBU','searchIsin':'Buscar por ISIN','allCurrencies':'Todas las divisas','activeOnly':'No vencidos','allTerms':'Todos los plazos','shortTerm':'Hasta 12 meses','longTerm':'Desde 24 meses','noIssues':'Ninguna emisión coincide con estos filtros.','issueDetails':'Detalles de la emisión','nominalRate':'tasa nominal',
      'calcTitle':'Calculadora educativa','calcExample':'EJEMPLO SINTÉTICO · Compra el 22.09.2026, un pago de 1000 UAH el 22.09.2027 por bono. Interés acumulado, impuestos y costes recurrentes: 0. No es una oferta de mercado.','quantity':'Número de bonos','cleanPrice':'Precio limpio, UAH','oneTimeFee':'Comisión única, UAH','calculateLocal':'Calcular localmente','costs':'Costes','receipts':'Ingresos','result':'Resultado','approxXirr':'XIRR ACT/365F aproximada',
      'sellersTitle':'Vendedores · cotizaciones públicas','sellersIntro':'El NBU describe emisiones y pagos. Aquí se muestran por separado datos del vendedor cargados directamente desde su sitio. Sus planes y cartera no se transmiten.','privatbank':'PrivatBank','loadPrivat':'Cargar cotizaciones de PrivatBank','sourceDate':'Fecha de la fuente: {date}','loadedAt':'Cargado: {date}','sellerExplanation':'ASK es el rendimiento de venta del banco al cliente; BID es el de compra del banco. No es el precio del bono. SIM y YTM son métodos distintos. Cantidad, precio total y comisiones requieren confirmación.','askOnly':'Solo con cotización ASK','pressLoad':'Cargue los datos primero. No hay cotizaciones integradas ni inventadas.','noSellerIssues':'No hay emisiones no vencidas para este filtro.','notConfirmed':'Disponibilidad y cantidad no confirmadas','otherSellers':'Otros vendedores','icuText':'ICU Trade permite operar mediante el servicio del bróker. Aún no hay una fuente automática pública conectada.','senseText':'Sense Bank ofrece bonos en Sense SuperApp. Aún no hay una fuente automática pública conectada.','sellerPlanHint':'Para un escenario: copie el ISIN, encuentre la emisión en el catálogo e introduzca el precio total del vendedor en el planificador. Las cotizaciones cargadas se conservan solo hasta cerrar la aplicación.','futureWarning':'La fecha de la fuente está en el futuro. La actualidad no está confirmada.','staleWarning':'La cotización no es de hoy. Confirme las condiciones con el vendedor.','unknownWarning':'La fuente no tiene una fecha fiable. Confirme las condiciones con el vendedor.','refreshFailed':'No se pudo actualizar. Se conserva la instantánea anterior si existe.',
    },
    'ko': {
      'catalog':'카탈로그','collections':'컬렉션','calculator':'계산기','workspace':'저장소','planning':'계획','sellers':'판매자','about':'정보','language':'언어','studioTitle':'분석 작업공간','workspaceClosed':'저장소가 열려 있지 않습니다','localData':'기기의 데이터',
      'close':'닫기','back':'돌아가기','discardDraft':'초안 버리기','unsavedTitle':'저장하지 않은 컬렉션이 있습니다','unsavedBody':'계속하기 전에 저장하거나 초안을 버리세요.','classicDesign':'클래식 디자인','studioDesign':'작업공간 디자인','translationIncomplete':'이 모듈의 번역은 아직 완전하지 않습니다. 일부 텍스트는 우크라이나어로 남을 수 있습니다.','aboutBody':'OVDP Hub는 독점 소프트웨어입니다. 소스 코드가 공개되어 있어도 오픈 소스 라이선스를 의미하지 않습니다. 전체 조건은 LICENSE.md에 있습니다.',
      'decisionSpace':'의사결정 공간','explore':'탐색','myDecisions':'내 결정','sidebarInfo':'계정 불필요\n시나리오는 로컬 작업공간에 저장\n\n테스트 프리릴리스','heroKicker':'탐색. 비교. 계획.','heroTitle':'계획을 위한 국채','heroBody':'OVDP 발행 정보부터 현금흐름 일정까지.\n만기를 비교하고 미래 지출을 확인하세요.','planFunds':'현금 계획','viewSellers':'판매자 보기',
      'bondNominal':'액면가','bondRate':'금리','bondMaturity':'만기','paymentSchedule':'채권 1개당 지급 일정','coupon':'쿠폰','redemption':'상환','earlyRedemption':'조기 상환',
      'openWorkspace':'작업공간 열기','catalogOffline':'카탈로그와 저장된 컬렉션을 오프라인에서도 사용할 수 있습니다.','setupWorkspace':'저장소 설정','catalogClassicTitle':'신중한 결정을 위한 공간','catalogIntro':'NBU 공개 데이터 · 발행 비교 · 개인 시나리오','issuesInSelection':'선택된 발행 수','issuesInCurrency':'{currency} 발행 수','loaded':'불러온 시각: {date}','staleSnapshot':'스냅샷이 24시간보다 오래되었습니다','nominalNotYield':'명목금리는 매수 수익률이 아닙니다. 카탈로그에는 브로커 가격이 없습니다.','refreshNbu':'NBU에서 직접 새로고침','searchIsin':'ISIN 검색','allCurrencies':'모든 통화','activeOnly':'미상환만','allTerms':'모든 만기','shortTerm':'12개월 이하','longTerm':'24개월 이상','noIssues':'조건에 맞는 발행이 없습니다.','issueDetails':'발행 상세','nominalRate':'명목금리',
      'calcTitle':'교육용 계산기','calcExample':'합성 예시 · 2026-09-22 매수, 채권 1개당 2027-09-22에 1000 UAH 1회 지급. 경과이자, 세금, 정기 비용은 0입니다. 시장 제안이 아닙니다.','quantity':'채권 수량','cleanPrice':'클린 가격, UAH','oneTimeFee':'일회성 수수료, UAH','calculateLocal':'로컬 계산','costs':'비용','receipts':'수입','result':'결과','approxXirr':'예상 XIRR ACT/365F',
      'sellersTitle':'판매자 · 공개 호가','sellersIntro':'NBU는 발행과 지급을 설명합니다. 여기서는 판매자 사이트에서 직접 가져온 데이터를 별도로 표시합니다. 계획과 포트폴리오는 전송되지 않습니다.','privatbank':'PrivatBank','loadPrivat':'PrivatBank 호가 불러오기','sourceDate':'소스 날짜: {date}','loadedAt':'불러온 시각: {date}','sellerExplanation':'ASK는 은행이 고객에게 판매할 때의 수익률, BID는 은행이 매수할 때의 수익률입니다. 채권 가격이 아닙니다. SIM과 YTM은 다른 방식입니다. 수량, 최종 총액 가격과 수수료는 확인이 필요합니다.','askOnly':'ASK 호가가 있는 항목만','pressLoad':'먼저 데이터를 불러오세요. 내장되거나 임의로 만든 호가는 없습니다.','noSellerIssues':'필터에 맞는 미상환 발행이 없습니다.','notConfirmed':'가용 여부와 수량은 확인되지 않았습니다','otherSellers':'기타 판매자','icuText':'ICU Trade는 브로커 서비스를 통해 거래합니다. 자동 공개 호가 소스는 아직 연결되지 않았습니다.','senseText':'Sense Bank는 Sense SuperApp에서 채권을 제공합니다. 자동 공개 호가 소스는 아직 연결되지 않았습니다.','sellerPlanHint':'시나리오에서는 ISIN을 복사해 카탈로그에서 발행을 찾고 판매자의 총액 가격을 계획기에 입력하세요. 불러온 호가는 앱을 닫을 때까지만 유지됩니다.','futureWarning':'소스 날짜가 미래입니다. 최신성은 확인되지 않았습니다.','staleWarning':'오늘 날짜의 호가가 아닙니다. 판매자에게 조건을 확인하세요.','unknownWarning':'소스에 신뢰할 수 있는 날짜가 없습니다. 판매자에게 조건을 확인하세요.','refreshFailed':'새로고침에 실패했습니다. 가능한 경우 이전 스냅샷을 유지합니다.',
    },
    'ja': {
      'catalog':'カタログ','collections':'コレクション','calculator':'計算機','workspace':'ストレージ','planning':'計画','sellers':'販売者','about':'このアプリについて','language':'言語','studioTitle':'分析ワークスペース','workspaceClosed':'ストレージが開かれていません','localData':'端末上のデータ',
      'close':'閉じる','back':'戻る','discardDraft':'下書きを破棄','unsavedTitle':'未保存のコレクションがあります','unsavedBody':'続行する前に保存するか、下書きを破棄してください。','classicDesign':'クラシック表示','studioDesign':'ワークスペース表示','translationIncomplete':'このモジュールの翻訳はまだ完了していません。一部のテキストはウクライナ語のまま表示される場合があります。','aboutBody':'OVDP Hub はプロプライエタリソフトウェアです。ソースコードが公開されていてもオープンソースライセンスを意味しません。完全な条件は LICENSE.md にあります。',
      'decisionSpace':'意思決定スペース','explore':'調べる','myDecisions':'自分の判断','sidebarInfo':'アカウント不要\nシナリオはローカルに保存\n\nテスト版プレリリース','heroKicker':'調べる。比較する。計画する。','heroTitle':'計画に合わせた国債','heroBody':'OVDP の発行情報から資金カレンダーまで。\n満期を比較し、将来の支出を確認します。','planFunds':'資金を計画','viewSellers':'販売者を見る',
      'bondNominal':'額面','bondRate':'利率','bondMaturity':'満期','paymentSchedule':'債券1口あたりの支払予定','coupon':'クーポン','redemption':'償還','earlyRedemption':'早期償還',
      'openWorkspace':'ワークスペースを開く','catalogOffline':'カタログと保存済みコレクションはオフラインでも利用できます。','setupWorkspace':'ストレージを設定','catalogClassicTitle':'十分な情報で判断するためのスペース','catalogIntro':'NBU 公開データ · 発行を比較 · 自分のシナリオ','issuesInSelection':'選択中の発行数','issuesInCurrency':'{currency} の発行数','loaded':'読み込み: {date}','staleSnapshot':'スナップショットは24時間以上前です','nominalNotYield':'名目利率は購入利回りではありません。カタログにブローカー価格は含まれません。','refreshNbu':'NBU から直接更新','searchIsin':'ISIN で検索','allCurrencies':'すべての通貨','activeOnly':'未償還のみ','allTerms':'すべての期間','shortTerm':'12か月以内','longTerm':'24か月以上','noIssues':'条件に一致する発行はありません。','issueDetails':'発行詳細','nominalRate':'名目利率',
      'calcTitle':'学習用計算機','calcExample':'合成例 · 2026-09-22 に購入し、債券1口あたり 2027-09-22 に 1000 UAH を1回受け取る想定です。経過利息、税金、継続費用は 0。市場のオファーではありません。','quantity':'債券数','cleanPrice':'クリーン価格、UAH','oneTimeFee':'一回限りの手数料、UAH','calculateLocal':'端末内で計算','costs':'費用','receipts':'受取額','result':'結果','approxXirr':'概算 XIRR ACT/365F',
      'sellersTitle':'販売者 · 公開クォート','sellersIntro':'NBU は発行条件と支払を説明します。ここでは販売者サイトから直接取得したデータを別に表示します。計画やポートフォリオは送信されません。','privatbank':'PrivatBank','loadPrivat':'PrivatBank のクォートを取得','sourceDate':'ソース日付: {date}','loadedAt':'取得時刻: {date}','sellerExplanation':'ASK は銀行が顧客へ販売する際の利回り、BID は銀行が買い取る際の利回りです。債券価格そのものではありません。SIM と YTM は異なる方法です。数量、最終的なダーティ価格、手数料は確認が必要です。','askOnly':'ASK クォートがあるものだけ','pressLoad':'まずデータを取得してください。内蔵または架空のクォートはありません。','noSellerIssues':'この条件に一致する未償還発行はありません。','notConfirmed':'在庫と数量は確認されていません','otherSellers':'その他の販売者','icuText':'ICU Trade はブローカーサービスで取引できます。自動の公開クォート源はまだ接続されていません。','senseText':'Sense Bank は Sense SuperApp で債券を提供しています。自動の公開クォート源はまだ接続されていません。','sellerPlanHint':'シナリオでは ISIN をコピーし、カタログで発行を探して販売者の総額価格をプランナーへ入力してください。取得したクォートはアプリ終了までのみ保持されます。','futureWarning':'ソース日付が未来です。最新性は確認されていません。','staleWarning':'今日の日付のクォートではありません。販売者に条件を確認してください。','unknownWarning':'ソースに信頼できる日付がありません。販売者に条件を確認してください。','refreshFailed':'更新に失敗しました。利用可能であれば以前のスナップショットを保持します。',
    },
  };
}
