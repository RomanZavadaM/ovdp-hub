# Нативний клієнт ОВДП Hub

Flutter 3.47.5 / Dart 3.13.4. Деталі продукту, сховища та запуску розробника — у кореневому README.

```sh
flutter pub get
flutter analyze
flutter test
flutter build windows --release
```

Користувач запускає готовий застосунок без SDK та сервера. Поширюйте весь release-каталог із бібліотеками та ресурсами.

Пакування macOS зараз налаштоване для прямого поширення поза Mac App Store (без sandbox). Для Mac App Store потрібно окремо додати sandbox і стійкі дозволи на папки. Apple signing/notarization ще не налаштовано. Мобільні зовнішні папки також ще потребують платформних адаптерів.
