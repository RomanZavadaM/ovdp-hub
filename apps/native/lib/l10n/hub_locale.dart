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

  static const Map<String, Map<String, String>> _translations = {
    'uk': {
      'catalog': 'Каталог', 'collections': 'Добірки', 'calculator': 'Калькулятор',
      'workspace': 'Сховище', 'planning': 'Планування', 'sellers': 'Продавці',
      'about': 'Про програму', 'language': 'Мова / Language',
      'studioTitle': 'Аналітичний кабінет', 'workspaceClosed': 'Сховище не відкрито',
      'localData': 'Дані на вашому пристрої', 'classicDesign': 'Класичний дизайн',
      'studioDesign': 'Дизайн «Робочий кабінет»', 'aboutLegal': 'ОВДП Hub є proprietary software. Публічна видимість вихідного коду не є open-source ліцензією. Повні умови використання містяться у LICENSE.md у комплекті програми та репозиторії.',
      'spaceForDecisions': 'ПРОСТІР ДЛЯ РІШЕНЬ', 'explore': 'ДОСЛІДИТИ', 'myDecisions': 'МОЇ РІШЕННЯ',
      'noAccount': 'Без облікового запису', 'scenariosLocal': 'Сценарії у вашій робочій папці', 'testVersion': 'Тестова версія',
      'heroEyebrow': 'ДОСЛІДЖУЙТЕ. ПОРІВНЮЙТЕ. ПЛАНУЙТЕ.', 'heroTitle': 'Облігації під ваші плани',
      'heroBody': 'Від випуску ОВДП — до календаря ваших коштів.\nПорівнюйте строки та перевіряйте майбутні витрати.',
      'planFunds': 'Планувати кошти', 'viewSellers': 'Переглянути продавців',
      'openWorkspace': 'Відкрийте робочу папку', 'catalogOffline': 'Каталог і збережені набори будуть доступні без інтернету.',
      'setupStorage': 'Налаштувати сховище', 'catalogHero': 'Ваш простір для обдуманих рішень',
      'publicDataLine': 'Публічні дані НБУ · Порівняння випусків · Власні сценарії',
      'issuesSelected': 'Випусків у вибірці', 'issuesIn': 'Випусків у', 'loaded': 'Завантажено',
      'stale24': 'Знімок старший за 24 години', 'nominalNotYield': 'Номінальна ставка не є дохідністю купівлі. Цін брокерів у каталозі немає.',
      'refreshNbu': 'Оновити напряму з НБУ', 'searchIsin': 'Пошук за ISIN', 'allCurrencies': 'Усі валюти',
      'activeOnly': 'Непогашені за строком', 'allTerms': 'Усі строки', 'upTo12': 'До 12 місяців',
      'from24': 'Від 24 місяців', 'noIssues': 'За цими критеріями випусків немає.',
      'issueDetails': 'Деталі випуску', 'nominalRate': 'номінальна ставка', 'maturity': 'Погашення',
      'auctionPlan': 'План аукціонів Мінфіну', 'auctionSnapshot': 'Збережена редакція від 17.09.2026, вересень 2026. План може змінюватися; це не підтвердження проведення або пропозиція купівлі.',
      'copySource': 'Скопіювати адресу джерела', 'sourceCopied': 'Посилання Мінфіну скопійовано',
      'sellerHeading': 'Продавці · публічні котирування',
      'sellerIntro': 'НБУ описує випуски та виплати. Тут — окремі дані продавця, отримані безпосередньо з його сайту. Ваші плани й портфель не передаються.',
      'loadPrivat': 'Завантажити котирування ПриватБанку', 'sourceDate': 'Дата на сайті', 'loadedAt': 'Завантажено',
      'sellerNote': 'ASK — дохідність продажу банком клієнту; BID — купівлі банком. Це не ціна за облігацію. SIM і YTM — різні методи розрахунку, їх не слід прямо порівнювати. Обсяг, остаточна ціна з НКД та комісії потребують підтвердження. Автоматично в ціни планувальника ці котирування не переносяться.',
      'askOnly': 'Лише з котируванням продажу (ASK)', 'sellerLoadPrompt': 'Натисніть завантаження. Вбудованих або вигаданих котирувань немає.',
      'noSellerIssues': 'Немає непогашених випусків за цим фільтром.', 'availabilityUnknown': 'Наявність і кількість не підтверджені',
      'otherSellers': 'Інші продавці', 'icuNote': 'ICU Trade — торгівля в сервісі брокера. Автоматичне джерело котирувань ще не підключене.',
      'senseNote': 'Sense Bank — пропозиції в Sense SuperApp. Автоматичне джерело котирувань ще не підключене.',
      'sellerScenarioHint': 'Для сценарію: скопіюйте ISIN, знайдіть випуск у каталозі та введіть у планувальнику повну ціну продавця. Завантажені тут котирування зберігаються лише до закриття застосунку.',
      'futureData': 'Дата джерела в майбутньому. Актуальність не підтверджена.',
      'staleData': 'Котирування не за сьогодні. Уточніть умови у продавця.',
      'unknownDate': 'Джерело не має надійної дати даних. Перевірте умови у продавця.',
      'refreshFailed': 'Не вдалося оновити. Показано попереднє завантаження, якщо воно є.',
    },
    'en': {
      'catalog':'Catalog','collections':'Collections','calculator':'Calculator','workspace':'Storage','planning':'Planning','sellers':'Sellers',
      'about':'About','language':'Language','studioTitle':'Analytics workspace','workspaceClosed':'Storage is not open','localData':'Data on your device',
      'classicDesign':'Classic design','studioDesign':'Workspace design','aboutLegal':'OVDP Hub is proprietary software. Public visibility of the source code is not an open-source license. Full terms are in LICENSE.md distributed with the app and in the repository.',
      'spaceForDecisions':'SPACE FOR DECISIONS','explore':'EXPLORE','myDecisions':'MY DECISIONS','noAccount':'No account','scenariosLocal':'Scenarios in your workspace folder','testVersion':'Test version',
      'heroEyebrow':'EXPLORE. COMPARE. PLAN.','heroTitle':'Bonds for your plans','heroBody':'From a government bond issue to your cash calendar.\nCompare maturities and check future expenses.',
      'planFunds':'Plan funds','viewSellers':'View sellers','openWorkspace':'Open a workspace folder','catalogOffline':'The catalog and saved sets will be available offline.',
      'setupStorage':'Configure storage','catalogHero':'Your space for considered decisions','publicDataLine':'NBU public data · Compare issues · Your scenarios',
      'issuesSelected':'Issues in selection','issuesIn':'Issues in','loaded':'Loaded','stale24':'Snapshot is older than 24 hours',
      'nominalNotYield':'The nominal rate is not the purchase yield. Broker prices are not included in the catalog.','refreshNbu':'Refresh directly from NBU',
      'searchIsin':'Search by ISIN','allCurrencies':'All currencies','activeOnly':'Not yet matured','allTerms':'All maturities','upTo12':'Up to 12 months','from24':'From 24 months',
      'noIssues':'No issues match these criteria.','issueDetails':'Issue details','nominalRate':'nominal rate','maturity':'Maturity',
      'auctionPlan':'Ministry of Finance auction plan','auctionSnapshot':'Saved edition dated 17 Sep 2026 for September 2026. The plan may change; it is not confirmation of an auction or an offer to buy.',
      'copySource':'Copy source address','sourceCopied':'Ministry of Finance link copied','sellerHeading':'Sellers · public quotes',
      'sellerIntro':'NBU describes issues and payments. Here, seller data are obtained directly from the seller website. Your plans and portfolio are not transmitted.',
      'loadPrivat':'Load PrivatBank quotes','sourceDate':'Date on website','loadedAt':'Loaded',
      'sellerNote':'ASK is the yield for a bank sale to a client; BID is the bank purchase yield. It is not the bond price. SIM and YTM are different methods and should not be compared directly. Quantity, final dirty price and fees require confirmation. These yields are not transferred automatically into planner prices.',
      'askOnly':'Only with sell quote (ASK)','sellerLoadPrompt':'Press load. There are no embedded or invented quotes.','noSellerIssues':'No unmatured issues match this filter.',
      'availabilityUnknown':'Availability and quantity are not confirmed','otherSellers':'Other sellers',
      'icuNote':'ICU Trade is a broker trading service. An automatic quote source is not connected yet.','senseNote':'Sense Bank offers bonds in Sense SuperApp. An automatic quote source is not connected yet.',
      'sellerScenarioHint':'For a scenario: copy the ISIN, find the issue in the catalog and enter the seller full price in the planner. Quotes loaded here are kept only until the app closes.',
      'futureData':'The source date is in the future. Freshness is not confirmed.','staleData':'The quote is not dated today. Confirm terms with the seller.',
      'unknownDate':'The source has no reliable data date. Confirm terms with the seller.','refreshFailed':'Refresh failed. The previous load is shown if available.',
    },
    'fr': {
      'catalog':'Catalogue','collections':'Sélections','calculator':'Calculateur','workspace':'Stockage','planning':'Planification','sellers':'Vendeurs','about':'À propos','language':'Langue',
      'studioTitle':'Espace analytique','workspaceClosed':'Stockage non ouvert','localData':'Données sur votre appareil','classicDesign':'Design classique','studioDesign':'Design espace de travail',
      'aboutLegal':'OVDP Hub est un logiciel propriétaire. La visibilité publique du code source ne constitue pas une licence open source. Les conditions complètes figurent dans LICENSE.md.',
      'spaceForDecisions':'ESPACE DE DÉCISION','explore':'EXPLORER','myDecisions':'MES DÉCISIONS','noAccount':'Sans compte','scenariosLocal':'Scénarios dans votre dossier de travail','testVersion':'Version de test',
      'heroEyebrow':'EXPLOREZ. COMPAREZ. PLANIFIEZ.','heroTitle':'Des obligations pour vos projets','heroBody':'De l’émission d’OVDP à votre calendrier de trésorerie.\nComparez les échéances et vérifiez les dépenses futures.',
      'planFunds':'Planifier les fonds','viewSellers':'Voir les vendeurs','openWorkspace':'Ouvrir un dossier de travail','catalogOffline':'Le catalogue et les sélections enregistrées seront disponibles hors ligne.',
      'setupStorage':'Configurer le stockage','catalogHero':'Votre espace de décision','publicDataLine':'Données publiques NBU · Comparaison · Vos scénarios','issuesSelected':'Émissions sélectionnées','issuesIn':'Émissions en',
      'loaded':'Chargé','stale24':'Instantané de plus de 24 h','nominalNotYield':'Le taux nominal n’est pas le rendement d’achat. Le catalogue ne contient pas les prix des courtiers.',
      'refreshNbu':'Actualiser depuis la NBU','searchIsin':'Rechercher par ISIN','allCurrencies':'Toutes les devises','activeOnly':'Non échues','allTerms':'Toutes les échéances','upTo12':'Jusqu’à 12 mois','from24':'À partir de 24 mois',
      'noIssues':'Aucune émission ne correspond.','issueDetails':'Détails de l’émission','nominalRate':'taux nominal','maturity':'Échéance','auctionPlan':'Calendrier des enchères du ministère des Finances',
      'auctionSnapshot':'Édition enregistrée du 17/09/2026 pour septembre 2026. Le calendrier peut changer; ce n’est ni une confirmation ni une offre d’achat.','copySource':'Copier l’adresse de la source','sourceCopied':'Lien du ministère copié',
      'sellerHeading':'Vendeurs · cotations publiques','sellerIntro':'La NBU décrit les émissions et paiements. Ici, les données du vendeur proviennent directement de son site. Vos plans et portefeuille ne sont pas transmis.',
      'loadPrivat':'Charger les cotations PrivatBank','sourceDate':'Date sur le site','loadedAt':'Chargé','sellerNote':'ASK est le rendement de vente de la banque au client; BID celui du rachat par la banque. Ce n’est pas le prix de l’obligation. SIM et YTM sont des méthodes différentes. Quantité, prix final avec intérêts courus et frais doivent être confirmés.',
      'askOnly':'Seulement avec ASK','sellerLoadPrompt':'Appuyez sur charger. Aucune cotation intégrée ou inventée.','noSellerIssues':'Aucune émission non échue pour ce filtre.','availabilityUnknown':'Disponibilité et quantité non confirmées','otherSellers':'Autres vendeurs',
      'icuNote':'ICU Trade est un service de courtage. La source automatique de cotations n’est pas encore connectée.','senseNote':'Sense Bank propose des obligations dans Sense SuperApp. La source automatique n’est pas encore connectée.',
      'sellerScenarioHint':'Pour un scénario: copiez l’ISIN, trouvez l’émission dans le catalogue et saisissez le prix complet du vendeur dans le planificateur. Les cotations chargées restent seulement jusqu’à la fermeture de l’application.',
      'futureData':'La date de la source est future. L’actualité n’est pas confirmée.','staleData':'La cotation n’est pas datée d’aujourd’hui. Confirmez les conditions avec le vendeur.','unknownDate':'La source n’a pas de date fiable. Confirmez les conditions avec le vendeur.','refreshFailed':'Échec de l’actualisation. Le chargement précédent reste affiché si disponible.',
    },
    'de': {
      'catalog':'Katalog','collections':'Sammlungen','calculator':'Rechner','workspace':'Speicher','planning':'Planung','sellers':'Anbieter','about':'Über','language':'Sprache','studioTitle':'Analysebereich',
      'workspaceClosed':'Speicher ist nicht geöffnet','localData':'Daten auf Ihrem Gerät','classicDesign':'Klassisches Design','studioDesign':'Arbeitsbereich-Design','aboutLegal':'OVDP Hub ist proprietäre Software. Die öffentliche Sichtbarkeit des Quellcodes ist keine Open-Source-Lizenz. Die vollständigen Bedingungen stehen in LICENSE.md.',
      'spaceForDecisions':'RAUM FÜR ENTSCHEIDUNGEN','explore':'ANALYSIEREN','myDecisions':'MEINE ENTSCHEIDUNGEN','noAccount':'Kein Konto','scenariosLocal':'Szenarien in Ihrem Arbeitsordner','testVersion':'Testversion',
      'heroEyebrow':'ANALYSIEREN. VERGLEICHEN. PLANEN.','heroTitle':'Anleihen für Ihre Pläne','heroBody':'Von der OVDP-Emission bis zu Ihrem Liquiditätskalender.\nVergleichen Sie Laufzeiten und prüfen Sie künftige Ausgaben.',
      'planFunds':'Mittel planen','viewSellers':'Anbieter ansehen','openWorkspace':'Arbeitsordner öffnen','catalogOffline':'Katalog und gespeicherte Sammlungen sind offline verfügbar.','setupStorage':'Speicher einrichten','catalogHero':'Ihr Raum für fundierte Entscheidungen',
      'publicDataLine':'Öffentliche NBU-Daten · Emissionen vergleichen · Eigene Szenarien','issuesSelected':'Emissionen in Auswahl','issuesIn':'Emissionen in','loaded':'Geladen','stale24':'Snapshot ist älter als 24 Stunden',
      'nominalNotYield':'Der Nominalzins ist nicht die Kaufrendite. Brokerpreise sind nicht im Katalog enthalten.','refreshNbu':'Direkt von der NBU aktualisieren','searchIsin':'Nach ISIN suchen','allCurrencies':'Alle Währungen','activeOnly':'Noch nicht fällig','allTerms':'Alle Laufzeiten','upTo12':'Bis 12 Monate','from24':'Ab 24 Monate','noIssues':'Keine passenden Emissionen.','issueDetails':'Emissionsdetails','nominalRate':'Nominalzins','maturity':'Fälligkeit',
      'auctionPlan':'Auktionsplan des Finanzministeriums','auctionSnapshot':'Gespeicherter Stand vom 17.09.2026 für September 2026. Der Plan kann sich ändern; er ist weder Bestätigung noch Kaufangebot.','copySource':'Quelladresse kopieren','sourceCopied':'Link des Finanzministeriums kopiert',
      'sellerHeading':'Anbieter · öffentliche Kurse','sellerIntro':'Die NBU beschreibt Emissionen und Zahlungen. Hier stammen die Anbieterdaten direkt von dessen Website. Ihre Pläne und Ihr Portfolio werden nicht übertragen.','loadPrivat':'PrivatBank-Kurse laden','sourceDate':'Datum auf Website','loadedAt':'Geladen',
      'sellerNote':'ASK ist die Rendite beim Verkauf der Bank an den Kunden; BID beim Ankauf durch die Bank. Das ist nicht der Anleihepreis. SIM und YTM sind unterschiedliche Methoden. Menge, endgültiger Dirty Price und Gebühren müssen bestätigt werden.','askOnly':'Nur mit ASK','sellerLoadPrompt':'Laden drücken. Es gibt keine eingebetteten oder erfundenen Kurse.','noSellerIssues':'Keine noch laufenden Emissionen für diesen Filter.','availabilityUnknown':'Verfügbarkeit und Menge nicht bestätigt','otherSellers':'Weitere Anbieter',
      'icuNote':'ICU Trade ist ein Brokerdienst. Eine automatische Kursquelle ist noch nicht angebunden.','senseNote':'Sense Bank bietet Anleihen in Sense SuperApp. Eine automatische Kursquelle ist noch nicht angebunden.','sellerScenarioHint':'Für ein Szenario: ISIN kopieren, Emission im Katalog finden und den vollständigen Anbieterpreis im Planer eingeben. Geladene Kurse bleiben nur bis zum Schließen der App erhalten.',
      'futureData':'Das Quelldatum liegt in der Zukunft. Aktualität ist nicht bestätigt.','staleData':'Der Kurs ist nicht von heute. Bedingungen beim Anbieter bestätigen.','unknownDate':'Die Quelle hat kein zuverlässiges Datumsfeld. Bedingungen beim Anbieter bestätigen.','refreshFailed':'Aktualisierung fehlgeschlagen. Falls vorhanden, bleibt die vorige Ladung sichtbar.',
    },
    'es': {
      'catalog':'Catálogo','collections':'Colecciones','calculator':'Calculadora','workspace':'Almacenamiento','planning':'Planificación','sellers':'Vendedores','about':'Acerca de','language':'Idioma','studioTitle':'Espacio analítico','workspaceClosed':'Almacenamiento no abierto','localData':'Datos en su dispositivo','classicDesign':'Diseño clásico','studioDesign':'Diseño de espacio de trabajo','aboutLegal':'OVDP Hub es software propietario. La visibilidad pública del código fuente no constituye una licencia de código abierto. Las condiciones completas están en LICENSE.md.',
      'spaceForDecisions':'ESPACIO PARA DECISIONES','explore':'EXPLORAR','myDecisions':'MIS DECISIONES','noAccount':'Sin cuenta','scenariosLocal':'Escenarios en su carpeta de trabajo','testVersion':'Versión de prueba','heroEyebrow':'EXPLORE. COMPARE. PLANIFIQUE.','heroTitle':'Bonos para sus planes','heroBody':'Desde la emisión de OVDP hasta su calendario de efectivo.\nCompare vencimientos y compruebe gastos futuros.','planFunds':'Planificar fondos','viewSellers':'Ver vendedores',
      'openWorkspace':'Abrir carpeta de trabajo','catalogOffline':'El catálogo y las colecciones guardadas estarán disponibles sin conexión.','setupStorage':'Configurar almacenamiento','catalogHero':'Su espacio para decisiones informadas','publicDataLine':'Datos públicos del NBU · Comparar emisiones · Sus escenarios','issuesSelected':'Emisiones seleccionadas','issuesIn':'Emisiones en','loaded':'Cargado','stale24':'La instantánea tiene más de 24 horas','nominalNotYield':'La tasa nominal no es el rendimiento de compra. El catálogo no incluye precios de bróker.','refreshNbu':'Actualizar desde NBU','searchIsin':'Buscar por ISIN','allCurrencies':'Todas las monedas','activeOnly':'No vencidas','allTerms':'Todos los vencimientos','upTo12':'Hasta 12 meses','from24':'Desde 24 meses','noIssues':'No hay emisiones con estos criterios.','issueDetails':'Detalles de la emisión','nominalRate':'tasa nominal','maturity':'Vencimiento',
      'auctionPlan':'Plan de subastas del Ministerio de Finanzas','auctionSnapshot':'Edición guardada del 17/09/2026 para septiembre de 2026. El plan puede cambiar; no confirma una subasta ni es una oferta de compra.','copySource':'Copiar dirección de la fuente','sourceCopied':'Enlace del Ministerio copiado','sellerHeading':'Vendedores · cotizaciones públicas','sellerIntro':'El NBU describe emisiones y pagos. Aquí los datos del vendedor se obtienen directamente de su sitio. Sus planes y cartera no se transmiten.','loadPrivat':'Cargar cotizaciones de PrivatBank','sourceDate':'Fecha en el sitio','loadedAt':'Cargado','sellerNote':'ASK es el rendimiento de venta del banco al cliente; BID, el rendimiento de compra del banco. No es el precio del bono. SIM y YTM son métodos distintos. La cantidad, el precio final con interés acumulado y las comisiones requieren confirmación.','askOnly':'Solo con ASK','sellerLoadPrompt':'Pulse cargar. No hay cotizaciones integradas ni inventadas.','noSellerIssues':'No hay emisiones no vencidas para este filtro.','availabilityUnknown':'Disponibilidad y cantidad no confirmadas','otherSellers':'Otros vendedores','icuNote':'ICU Trade es un servicio de bróker. La fuente automática de cotizaciones aún no está conectada.','senseNote':'Sense Bank ofrece bonos en Sense SuperApp. La fuente automática aún no está conectada.','sellerScenarioHint':'Para un escenario: copie el ISIN, busque la emisión en el catálogo e introduzca el precio completo del vendedor en el planificador. Las cotizaciones cargadas se conservan solo hasta cerrar la app.','futureData':'La fecha de la fuente está en el futuro. La actualidad no está confirmada.','staleData':'La cotización no es de hoy. Confirme las condiciones con el vendedor.','unknownDate':'La fuente no tiene una fecha fiable. Confirme las condiciones con el vendedor.','refreshFailed':'No se pudo actualizar. Se muestra la carga anterior si está disponible.',
    },
    'ko': {
      'catalog':'카탈로그','collections':'컬렉션','calculator':'계산기','workspace':'저장소','planning':'계획','sellers':'판매자','about':'정보','language':'언어','studioTitle':'분석 작업공간','workspaceClosed':'저장소가 열려 있지 않습니다','localData':'기기의 데이터','classicDesign':'클래식 디자인','studioDesign':'작업공간 디자인','aboutLegal':'OVDP Hub는 독점 소프트웨어입니다. 소스 코드가 공개되어 있어도 오픈 소스 라이선스를 의미하지 않습니다. 전체 조건은 LICENSE.md에 있습니다.',
      'spaceForDecisions':'의사결정 공간','explore':'탐색','myDecisions':'내 결정','noAccount':'계정 없음','scenariosLocal':'작업 폴더의 시나리오','testVersion':'테스트 버전','heroEyebrow':'탐색. 비교. 계획.','heroTitle':'계획을 위한 채권','heroBody':'OVDP 발행부터 자금 일정까지.\n만기를 비교하고 향후 지출을 확인하세요.','planFunds':'자금 계획','viewSellers':'판매자 보기','openWorkspace':'작업 폴더 열기','catalogOffline':'카탈로그와 저장된 컬렉션을 오프라인에서도 사용할 수 있습니다.','setupStorage':'저장소 설정','catalogHero':'신중한 결정을 위한 공간','publicDataLine':'NBU 공개 데이터 · 발행 비교 · 내 시나리오','issuesSelected':'선택된 발행 수','issuesIn':'통화별 발행','loaded':'불러옴','stale24':'스냅샷이 24시간보다 오래됨','nominalNotYield':'표면금리는 매수 수익률이 아닙니다. 카탈로그에는 브로커 가격이 없습니다.','refreshNbu':'NBU에서 직접 새로고침','searchIsin':'ISIN 검색','allCurrencies':'모든 통화','activeOnly':'미상환만','allTerms':'모든 만기','upTo12':'12개월 이하','from24':'24개월 이상','noIssues':'조건에 맞는 발행이 없습니다.','issueDetails':'발행 상세','nominalRate':'표면금리','maturity':'만기',
      'auctionPlan':'재무부 경매 계획','auctionSnapshot':'2026-09-17에 저장된 2026년 9월 계획입니다. 계획은 변경될 수 있으며 경매 확정이나 매수 제안이 아닙니다.','copySource':'출처 주소 복사','sourceCopied':'재무부 링크를 복사했습니다','sellerHeading':'판매자 · 공개 호가','sellerIntro':'NBU는 발행과 지급을 설명합니다. 여기의 판매자 데이터는 판매자 웹사이트에서 직접 가져옵니다. 사용자의 계획과 포트폴리오는 전송되지 않습니다.','loadPrivat':'PrivatBank 호가 불러오기','sourceDate':'웹사이트 날짜','loadedAt':'불러옴','sellerNote':'ASK는 은행이 고객에게 판매할 때의 수익률이고 BID는 은행 매수 수익률입니다. 채권 가격 자체가 아닙니다. SIM과 YTM은 서로 다른 방식입니다. 수량, 경과이자를 포함한 최종 가격, 수수료는 확인이 필요합니다.','askOnly':'ASK가 있는 항목만','sellerLoadPrompt':'불러오기를 누르세요. 내장되거나 임의로 만든 호가는 없습니다.','noSellerIssues':'이 필터에 맞는 미상환 발행이 없습니다.','availabilityUnknown':'가용 수량은 확인되지 않았습니다','otherSellers':'기타 판매자','icuNote':'ICU Trade는 브로커 거래 서비스입니다. 자동 호가 출처는 아직 연결되지 않았습니다.','senseNote':'Sense Bank는 Sense SuperApp에서 채권을 제공합니다. 자동 호가 출처는 아직 연결되지 않았습니다.','sellerScenarioHint':'시나리오에서는 ISIN을 복사해 카탈로그에서 찾고 판매자의 전체 가격을 계획기에 입력하세요. 불러온 호가는 앱을 닫을 때까지만 유지됩니다.','futureData':'출처 날짜가 미래입니다. 최신성은 확인되지 않았습니다.','staleData':'오늘 날짜의 호가가 아닙니다. 판매자에게 조건을 확인하세요.','unknownDate':'출처에 신뢰할 수 있는 데이터 날짜가 없습니다. 판매자에게 조건을 확인하세요.','refreshFailed':'새로고침에 실패했습니다. 가능하면 이전 데이터를 표시합니다.',
    },
    'ja': {
      'catalog':'カタログ','collections':'コレクション','calculator':'計算機','workspace':'ストレージ','planning':'計画','sellers':'販売者','about':'このアプリについて','language':'言語','studioTitle':'分析ワークスペース','workspaceClosed':'ストレージが開かれていません','localData':'端末上のデータ','classicDesign':'クラシックデザイン','studioDesign':'ワークスペースデザイン','aboutLegal':'OVDP Hub はプロプライエタリソフトウェアです。ソースコードが公開されていてもオープンソースライセンスではありません。完全な条件は LICENSE.md にあります。',
      'spaceForDecisions':'意思決定のための空間','explore':'調べる','myDecisions':'自分の判断','noAccount':'アカウントなし','scenariosLocal':'作業フォルダー内のシナリオ','testVersion':'テスト版','heroEyebrow':'調べる。比べる。計画する。','heroTitle':'計画に合わせた債券','heroBody':'OVDPの発行から資金カレンダーまで。\n満期を比較し、将来の支出を確認します。','planFunds':'資金を計画','viewSellers':'販売者を見る','openWorkspace':'作業フォルダーを開く','catalogOffline':'カタログと保存済みコレクションはオフラインでも利用できます。','setupStorage':'ストレージを設定','catalogHero':'慎重な判断のための空間','publicDataLine':'NBU公開データ · 発行比較 · 自分のシナリオ','issuesSelected':'選択中の発行数','issuesIn':'通貨別発行','loaded':'取得日時','stale24':'スナップショットは24時間以上前です','nominalNotYield':'表面利率は購入利回りではありません。カタログにブローカー価格は含まれません。','refreshNbu':'NBUから直接更新','searchIsin':'ISINで検索','allCurrencies':'すべての通貨','activeOnly':'未償還のみ','allTerms':'すべての満期','upTo12':'12か月以内','from24':'24か月以上','noIssues':'条件に一致する発行はありません。','issueDetails':'発行詳細','nominalRate':'表面利率','maturity':'満期',
      'auctionPlan':'財務省オークション予定','auctionSnapshot':'2026年9月17日保存の2026年9月版です。予定は変更される可能性があり、実施確認や購入提案ではありません。','copySource':'出典アドレスをコピー','sourceCopied':'財務省リンクをコピーしました','sellerHeading':'販売者 · 公開気配値','sellerIntro':'NBUは発行条件と支払いを示します。ここでは販売者サイトから直接取得したデータを表示します。利用者の計画やポートフォリオは送信されません。','loadPrivat':'PrivatBankの気配値を取得','sourceDate':'サイト上の日付','loadedAt':'取得日時','sellerNote':'ASKは銀行が顧客へ売る際の利回り、BIDは銀行が買う際の利回りです。債券価格そのものではありません。SIMとYTMは異なる方式です。数量、経過利息を含む最終価格、手数料は確認が必要です。','askOnly':'ASKありのみ','sellerLoadPrompt':'取得ボタンを押してください。埋め込みや架空の気配値はありません。','noSellerIssues':'このフィルターに一致する未償還発行はありません。','availabilityUnknown':'在庫と数量は未確認です','otherSellers':'その他の販売者','icuNote':'ICU Tradeはブローカー取引サービスです。自動気配値ソースはまだ接続されていません。','senseNote':'Sense BankはSense SuperAppで債券を提供しています。自動気配値ソースはまだ接続されていません。','sellerScenarioHint':'シナリオではISINをコピーしてカタログで発行を探し、販売者の総額を計画画面に入力してください。取得した気配値はアプリ終了までのみ保持されます。','futureData':'出典の日付が未来です。最新性は確認できません。','staleData':'今日の日付の気配値ではありません。販売者に条件を確認してください。','unknownDate':'信頼できるデータ日付がありません。販売者に条件を確認してください。','refreshFailed':'更新できませんでした。利用できる場合は前回のデータを表示します。',
    },
  };


  static const Map<String, Map<String, String>> _calculatorTranslations = {
    'uk': {
      'calcTitle': 'Навчальний калькулятор',
      'calcExample': 'СИНТЕТИЧНИЙ ПРИКЛАД · Купівля 22.09.2026, єдина виплата 1000 грн 22.09.2027 на облігацію. НКД, податки й регулярні витрати — 0. Це не ринкова пропозиція.',
      'quantity': 'Кількість облігацій',
      'cleanPrice': 'Чиста ціна, грн',
      'oneTimeFee': 'Разова комісія, грн',
      'calculateLocal': 'Розрахувати локально',
      'costs': 'Витрати',
      'receipts': 'Надходження',
      'result': 'Результат',
      'approxXirr': 'Орієнтовна XIRR ACT/365F',
    },
    'en': {
      'calcTitle': 'Educational calculator',
      'calcExample': 'SYNTHETIC EXAMPLE · Purchase 22.09.2026, one payment of UAH 1000 on 22.09.2027 per bond. Accrued interest, taxes and recurring costs are 0. This is not a market offer.',
      'quantity': 'Number of bonds',
      'cleanPrice': 'Clean price, UAH',
      'oneTimeFee': 'One-time fee, UAH',
      'calculateLocal': 'Calculate locally',
      'costs': 'Costs',
      'receipts': 'Receipts',
      'result': 'Result',
      'approxXirr': 'Approximate XIRR ACT/365F',
    },
    'fr': {
      'calcTitle': 'Calculateur pédagogique',
      'calcExample': 'EXEMPLE SYNTHÉTIQUE · Achat le 22.09.2026, paiement unique de 1000 UAH le 22.09.2027 par obligation. Intérêts courus, impôts et coûts récurrents : 0. Ce n’est pas une offre de marché.',
      'quantity': 'Nombre d’obligations',
      'cleanPrice': 'Prix net, UAH',
      'oneTimeFee': 'Commission unique, UAH',
      'calculateLocal': 'Calculer localement',
      'costs': 'Coûts',
      'receipts': 'Encaissements',
      'result': 'Résultat',
      'approxXirr': 'XIRR ACT/365F approximatif',
    },
    'de': {
      'calcTitle': 'Lernrechner',
      'calcExample': 'SYNTHETISCHES BEISPIEL · Kauf am 22.09.2026, eine Zahlung von 1000 UAH je Anleihe am 22.09.2027. Stückzinsen, Steuern und laufende Kosten sind 0. Dies ist kein Marktangebot.',
      'quantity': 'Anzahl der Anleihen',
      'cleanPrice': 'Clean Price, UAH',
      'oneTimeFee': 'Einmalige Gebühr, UAH',
      'calculateLocal': 'Lokal berechnen',
      'costs': 'Kosten',
      'receipts': 'Einnahmen',
      'result': 'Ergebnis',
      'approxXirr': 'Ungefähre XIRR ACT/365F',
    },
    'es': {
      'calcTitle': 'Calculadora educativa',
      'calcExample': 'EJEMPLO SINTÉTICO · Compra el 22.09.2026 y un único pago de 1000 UAH por bono el 22.09.2027. Interés acumulado, impuestos y costes recurrentes: 0. No es una oferta de mercado.',
      'quantity': 'Número de bonos',
      'cleanPrice': 'Precio limpio, UAH',
      'oneTimeFee': 'Comisión única, UAH',
      'calculateLocal': 'Calcular localmente',
      'costs': 'Costes',
      'receipts': 'Ingresos',
      'result': 'Resultado',
      'approxXirr': 'XIRR ACT/365F aproximada',
    },
    'ko': {
      'calcTitle': '학습용 계산기',
      'calcExample': '합성 예시 · 2026-09-22 매수, 채권 1개당 2027-09-22에 1000 UAH 1회 지급. 경과이자, 세금, 정기 비용은 0입니다. 시장 제안이 아닙니다.',
      'quantity': '채권 수량',
      'cleanPrice': '클린 가격, UAH',
      'oneTimeFee': '일회성 수수료, UAH',
      'calculateLocal': '로컬 계산',
      'costs': '비용',
      'receipts': '수입',
      'result': '결과',
      'approxXirr': '예상 XIRR ACT/365F',
    },
    'ja': {
      'calcTitle': '学習用計算機',
      'calcExample': '合成例 · 2026-09-22 に購入し、債券1口あたり 2027-09-22 に 1000 UAH を1回受け取る想定です。経過利息、税金、継続費用は 0。市場のオファーではありません。',
      'quantity': '債券数',
      'cleanPrice': 'クリーン価格、UAH',
      'oneTimeFee': '一回限りの手数料、UAH',
      'calculateLocal': '端末内で計算',
      'costs': '費用',
      'receipts': '受取額',
      'result': '結果',
      'approxXirr': '概算 XIRR ACT/365F',
    },
  };

  String text(String key) =>
      _translations[language.code]?[key] ??
      _calculatorTranslations[language.code]?[key] ??
      _translations['uk']?[key] ??
      _calculatorTranslations['uk']?[key] ??
      key;
}
