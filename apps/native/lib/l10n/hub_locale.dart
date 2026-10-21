import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../errors.dart';

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
  final ValueChanged<AppLanguage>? onSelected;

  LocaleCubit({
    AppLanguage initialLanguage = AppLanguage.uk,
    this.onSelected,
  }) : super(LocaleState(language: initialLanguage));

  void select(AppLanguage language) {
    if (state.language == language) return;
    emit(LocaleState(language: language));
    onSelected?.call(language);
  }
}

class HubStrings {
  final AppLanguage language;
  const HubStrings(this.language);

  static const Map<String, Map<String, String>> _translations = {
    'uk': {
      'catalog': 'Каталог', 'collections': 'Добірки', 'calculator': 'Калькулятор',
      'workspace': 'Сховище', 'planning': 'Планування', 'sellers': 'Продавці', 'portfolio': 'Мій портфель',
      'economicPulse': 'Економічний пульс', 'pulseUsd': 'USD / UAH', 'pulseEur': 'EUR / UAH', 'pulseAuctionYield': 'ОВДП · останній аукціон', 'pulseNextAuction': 'Наступний аукціон', 'pulseUnavailable': 'Немає підтверджених даних', 'pulseRefresh': 'Оновити економічні показники','portfolioTitle':'Мій портфель','portfolioPlatformPending':'Захищений портфель на цій платформі ще проходить перевірку. Каталог, планування та інші розділи працюють як раніше.','portfolioCreateIntro':'Створіть локальний зашифрований портфель для фактичних покупок ОВДП. Це окремо від сценаріїв і добірок.','portfolioCreate':'Створити захищений портфель','portfolioSecurityNote':'Фактичні дані портфеля зберігаються локально у зашифрованому vault. Пароль відновлення не надсилається на сервер OVDP Hub.','portfolioRecoveryExplain':'Задайте пароль відновлення. Він потрібен для відновлення ключа, якщо локальний ключ пристрою буде втрачено.','portfolioRecoverySecret':'Пароль відновлення','portfolioRecoveryKeep':'Збережіть цей пароль окремо від пристрою. OVDP Hub не зможе показати вам його пізніше.','portfolioRecoveryConfirm':'Підтвердіть пароль відновлення','portfolioRecoveryMismatch':'Паролі відновлення не збігаються.','portfolioRecoveryBackupTitle':'Відновлення та резервна копія','portfolioRecoveryBackupInfo':'Змініть пароль відновлення за потреби та створіть переносну зашифровану копію портфеля. Файл резервної копії не містить відкритих даних портфеля.','portfolioBackupCreate':'Створити зашифровану резервну копію','portfolioBackupSaved':'Зашифровану резервну копію збережено: {path}','portfolioBackupUnavailable':'Вибір місця для переносної резервної копії на цій платформі ще не підтримується. Збережіть пароль відновлення окремо.','portfolioRecoveryChange':'Змінити пароль відновлення','portfolioRecoveryChangeTitle':'Новий пароль відновлення','portfolioRecoveryChanged':'Пароль відновлення оновлено.','portfolioRestoreBackup':'Відновити з резервної копії','portfolioRestoreTitle':'Відновити зашифрований портфель','portfolioRestoreExplain':'Виберіть переносну зашифровану резервну копію та введіть пароль відновлення, яким вона була захищена.','portfolioRestoreDone':'Портфель відновлено із зашифрованої резервної копії.','portfolioRecoveryShort':'Введіть щонайменше 12 символів.','portfolioCancel':'Скасувати','portfolioLockedBody':'Портфель існує, але приватні дані зараз заблоковані. Відкрийте vault на цьому пристрої, щоб переглянути позиції.','portfolioOpen':'Відкрити портфель','portfolioUnlockedBody':'Показані фактичні записи з локального зашифрованого портфеля. Позиції розраховуються з покупок, продажів і погашень.','portfolioLock':'Заблокувати портфель','portfolioPositions':'Позицій','portfolioUnits':'Облігацій','portfolioLots':'Покупок','portfolioFacts':'Інших подій','portfolioHoldings':'Поточні позиції','portfolioAddPurchase':'Додати покупку','portfolioEmpty':'У портфелі ще немає фактичних позицій. Додайте першу покупку ОВДП.','portfolioPurchaseUnits':'Кількість облігацій','portfolioPurchaseDate':'Дата купівлі','portfolioTradeAmount':'Сума купівлі без комісії','portfolioFeeKnown':'Комісія відома','portfolioFeeAmount':'Загальна комісія','portfolioBrokerLabel':'Банк / брокер / рахунок (необов’язково)','portfolioInvalidInput':'Перевірте ISIN, дату, кількість і суми.','portfolioIssueMissing':'Цього ISIN немає у поточному каталозі НБУ. Спочатку оновіть каталог або перевірте номер.','portfolioSavePurchase':'Зберегти покупку','portfolioOperationFailed':'Операцію з портфелем не завершено. Дані не були тихо замінені або створені заново.','portfolioMaturity':'погашення','portfolioAddSale':'Додати продаж','portfolioAddRedemption':'Додати погашення','portfolioAddCoupon':'Додати купон','portfolioCouponDate':'Дата купона','portfolioCouponAmount':'Сума купона','portfolioCouponNote':'Примітка до купона (необов’язково)','portfolioSaveCoupon':'Зберегти купон','portfolioDetails':'Деталі','portfolioIsinDetails':'Деталі позиції','portfolioCurrentUnits':'Поточна кількість','portfolioClose':'Закрити','portfolioCashSummary':'Фактичний грошовий підсумок','portfolioCashSummaryInfo':'Лише зафіксовані грошові факти. Поточна ринкова вартість відкритих позицій не додається, тому це не ринкова оцінка і не показник прибутковості.','portfolioCashPurchases':'Суми купівель без комісій','portfolioCashSales':'Надходження від продажів до комісій','portfolioCashCoupons':'Отримані купони','portfolioCashRedemptions':'Отримані погашення','portfolioCashKnownFees':'Відомі комісії','portfolioCashUnknownFeesFlag':'Є невідомі комісії','portfolioCashNet':'Чистий фактичний грошовий результат','portfolioCashNetUnknown':'Невідомий через невідомі комісії','portfolioClosedPositions':'Закриті позиції','portfolioClosedPosition':'Закрита позиція','portfolioHistory':'Історія фактів','portfolioHistoryEmpty':'Фактичних операцій ще немає.','portfolioSaleDate':'Дата продажу','portfolioSaleProceeds':'Сума надходження від продажу','portfolioSaleAllocation':'Розподіл проданих облігацій по покупках','portfolioSaleAvailable':'Доступно в цій покупці','portfolioSaleNote':'Примітка до продажу (необов’язково)','portfolioSaveSale':'Зберегти продаж','portfolioRedemptionDate':'Дата погашення','portfolioRedemptionAmount':'Сума надходження від погашення','portfolioRedemptionUnits':'Кількість погашених облігацій','portfolioRedemptionNote':'Примітка до погашення (необов’язково)','portfolioSaveRedemption':'Зберегти погашення','portfolioHistoryPurchase':'Купівля','portfolioHistorySale':'Продаж','portfolioHistoryCoupon':'Купон','portfolioHistoryRedemption':'Погашення','portfolioMigrationTitle':'Перенесення старих добірок','portfolioMigrationButton':'Перенести старі дані','portfolioMigrationExplain':'Копіює приватні метадані старих добірок і сценаріїв до зашифрованого vault. Публічні знімки ОВДП не дублюються, факти портфеля не вигадуються.','portfolioMigrationPlaintextWarning':'Вихідні JSON-файли залишаться на місці. Програма не видаляє їх автоматично.','portfolioMigrationRun':'Запустити перенесення','portfolioMigrationMigrated':'Перенесено','portfolioMigrationAlready':'Уже були перенесені','portfolioMigrationConflicts':'Конфлікти','portfolioMigrationInvalid':'Некоректні файли','portfolioMigrationVerified':'Зашифровану копію перевірено','portfolioMigrationPlaintextRemaining':'Вихідних plaintext-файлів залишилось','portfolioMigrationDone':'Закрити звіт','portfolioAllocationRequired':'Вкажіть кількість хоча б для однієї покупки.','portfolioSaleAfterRedemption':'Продаж після вже зафіксованого погашення для цього ISIN неможливо додати без точного розподілу погашення по лотах.','portfolioMigrationFailed':'Перенесення не завершено. Вихідні файли не видалено.','portfolioNoHoldingsForAction':'Немає поточних позицій для цієї операції.','portfolioLot':'Покупка від',
      'about': 'Про програму', 'language': 'Мова / Language',
      'studioTitle': 'Аналітичний кабінет', 'workspaceClosed': 'Сховище не відкрито',
      'localData': 'Дані на вашому пристрої', 'classicDesign': 'Класичний 