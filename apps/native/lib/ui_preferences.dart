import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'features/appearance/appearance_cubit.dart';
import 'l10n/hub_locale.dart';

class UiPreferencesSnapshot {
  final AppLanguage language;
  final HubAppearance appearance;

  const UiPreferencesSnapshot({
    this.language = AppLanguage.uk,
    this.appearance = HubAppearance.studio,
  });

  UiPreferencesSnapshot copyWith({
    AppLanguage? language,
    HubAppearance? appearance,
  }) => UiPreferencesSnapshot(
    language: language ?? this.language,
    appearance: appearance ?? this.appearance,
  );

  Map<String, dynamic> toJson() => {
    'schemaVersion': 1,
    'language': language.code,
    'appearance': appearance.name,
  };

  factory UiPreferencesSnapshot.parse(Map<String, dynamic> json) {
    if (json['schemaVersion'] != 1 ||
        json['language'] is! String ||
        json['appearance'] is! String) {
      throw const FormatException('ui_preferences.invalid');
    }
    final language = AppLanguage.values
        .where((value) => value.code == json['language'])
        .firstOrNull;
    final appearance = HubAppearance.values
        .where((value) => value.name == json['appearance'])
        .firstOrNull;
    if (language == null || appearance == null) {
      throw const FormatException('ui_preferences.invalid');
    }
    return UiPreferencesSnapshot(
      language: language,
      appearance: appearance,
    );
  }
}

abstract interface class UiPreferencesPersistence {
  UiPreferencesSnapshot get current;
  Future<void> selectLanguage(AppLanguage language);
  Future<void> selectAppearance(HubAppearance appearance);
  Future<void> flush();
}

class UiPreferencesStore implements UiPreferencesPersistence {
  final File file;
  UiPreferencesSnapshot _current;
  Future<void> _tail = Future.value();

  UiPreferencesStore._(this.file, this._current);

  @override
  UiPreferencesSnapshot get current => _current;

  static Future<UiPreferencesStore> open(File file) async {
    var current = const UiPreferencesSnapshot();
    try {
      if (await file.exists()) {
        final decoded = jsonDecode(await file.readAsString());
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('ui_preferences.invalid');
        }
        current = UiPreferencesSnapshot.parse(decoded);
      }
    } on Object {
      current = const UiPreferencesSnapshot();
    }
    return UiPreferencesStore._(file, current);
  }

  @override
  Future<void> selectLanguage(AppLanguage language) =>
      _persist(_current.copyWith(language: language));

  @override
  Future<void> selectAppearance(HubAppearance appearance) =>
      _persist(_current.copyWith(appearance: appearance));

  @override
  Future<void> flush() => _tail;

  Future<void> _persist(UiPreferencesSnapshot next) {
    _current = next;
    final write = _tail.then((_) async {
      await file.parent.create(recursive: true);
      await file.writeAsString(
        jsonEncode(_current.toJson()),
        flush: true,
      );
    });
    _tail = write.catchError((_) {});
    return write;
  }
}

Future<UiPreferencesStore> openPlatformUiPreferencesStore() async {
  final directory = await getApplicationSupportDirectory();
  return UiPreferencesStore.open(
    File(p.join(directory.path, 'ui-preferences.json')),
  );
}
