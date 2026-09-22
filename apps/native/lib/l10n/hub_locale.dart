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
      'catalog': 'Каталог',
      'collections': 'Добірки',
      'calculator': 'Калькулятор',
      'workspace': 'Сховище',
      'planning': 'Планування',
      'sellers': 'Продавці',
      'about': 'Про програму',
      'language': 'Мова / Language',
      'studioTitle': 'Аналітичний кабінет',
      'workspaceClosed': 'Сховище не відкрито',
      'localData': 'Дані на вашому пристрої',
    },
    'en': {
      'catalog': 'Catalog',
      'collections': 'Collections',
      'calculator': 'Calculator',
      'workspace': 'Storage',
      'planning': 'Planning',
      'sellers': 'Sellers',
      'about': 'About',
      'language': 'Language',
      'studioTitle': 'Analytics workspace',
      'workspaceClosed': 'Storage is not open',
      'localData': 'Data on your device',
    },
    'fr': {
      'catalog': 'Catalogue',
      'collections': 'Sélections',
      'calculator': 'Calculateur',
      'workspace': 'Stockage',
      'planning': 'Planification',
      'sellers': 'Vendeurs',
      'about': 'À propos',
      'language': 'Langue',
      'studioTitle': 'Espace analytique',
      'workspaceClosed': 'Stockage non ouvert',
      'localData': 'Données sur votre appareil',
    },
    'de': {
      'catalog': 'Katalog',
      'collections': 'Sammlungen',
      'calculator': 'Rechner',
      'workspace': 'Speicher',
      'planning': 'Planung',
      'sellers': 'Anbieter',
      'about': 'Über',
      'language': 'Sprache',
      'studioTitle': 'Analysebereich',
      'workspaceClosed': 'Speicher ist nicht geöffnet',
      'localData': 'Daten auf Ihrem Gerät',
    },
    'es': {
      'catalog': 'Catálogo',
      'collections': 'Colecciones',
      'calculator': 'Calculadora',
      'workspace': 'Almacenamiento',
      'planning': 'Planificación',
      'sellers': 'Vendedores',
      'about': 'Acerca de',
      'language': 'Idioma',
      'studioTitle': 'Espacio analítico',
      'workspaceClosed': 'Almacenamiento no abierto',
      'localData': 'Datos en su dispositivo',
    },
    'ko': {
      'catalog': '카탈로그',
      'collections': '컬렉션',
      'calculator': '계산기',
      'workspace': '저장소',
      'planning': '계획',
      'sellers': '판매자',
      'about': '정보',
      'language': '언어',
      'studioTitle': '분석 작업공간',
      'workspaceClosed': '저장소가 열려 있지 않습니다',
      'localData': '기기의 데이터',
    },
    'ja': {
      'catalog': 'カタログ',
      'collections': 'コレクション',
      'calculator': '計算機',
      'workspace': 'ストレージ',
      'planning': '計画',
      'sellers': '販売者',
      'about': 'このアプリについて',
      'language': '言語',
      'studioTitle': '分析ワークスペース',
      'workspaceClosed': 'ストレージが開かれていません',
      'localData': '端末上のデータ',
    },
  };

  String text(String key) =>
      _translations[language.code]?[key] ??
      _translations['uk']?[key] ??
      key;
}
