import '../../l10n/hub_locale.dart';

class MobileStorageRuntimeProbeStrings {
  final AppLanguage language;

  const MobileStorageRuntimeProbeStrings(this.language);

  String get title => _value('title');
  String get intro => _value('intro');
  String get idle => _value('idle');
  String get start => _value('start');
  String get restartRequired => _value('restartRequired');
  String get readyAfterRestart => _value('readyAfterRestart');
  String get continueTest => _value('continueTest');
  String get passed => _value('passed');
  String get permissionLost => _value('permissionLost');
  String get failed => _value('failed');
  String get reset => _value('reset');
  String get testing => _value('testing');
  String folder(String label) => _value('folder').replaceAll('{folder}', label);
  String error(String code) => _value('error').replaceAll('{code}', code);

  String _value(String key) => (_translations[language.code] ?? _translations['uk']!)[key]!;

  static const _translations = <String, Map<String, String>>{
    'uk': {
      'title': 'Перевірка мобільного сховища',
      'intro': 'Тест створює лише технічний файл у вибраній папці. Етап 1 перевіряє запис і читання, потім потрібен повний перезапуск застосунку. Етап 2 доводить, що Android SAF або iOS bookmark зберіг доступ після нового запуску.',
      'idle': 'Перевірка ще не запускалась.',
      'start': 'Почати перевірку',
      'restartRequired': 'Етап 1 пройдено. Повністю закрийте OVDP Hub і відкрийте його знову. Не натискайте «Продовжити» до нового запуску.',
      'readyAfterRestart': 'Новий запуск підтверджено. Можна перевірити той самий дозвіл на папку та завершити тест.',
      'continueTest': 'Продовжити після перезапуску',
      'passed': 'Перевірка пройдена: збережений доступ пережив перезапуск, читання/запис/список/видалення спрацювали.',
      'permissionLost': 'Доступ до вибраної папки втрачено. Програма зупинила операцію явно — fail-closed поведінка спрацювала.',
      'failed': 'Перевірку не завершено.',
      'reset': 'Скинути перевірку',
      'testing': 'Перевіряю…',
      'folder': 'Папка: {folder}',
      'error': 'Код: {code}',
    },
    'en': {
      'title': 'Mobile storage validation',
      'intro': 'The test creates only a technical file in the selected folder. Stage 1 verifies write/read, then the app must be fully restarted. Stage 2 proves that the Android SAF grant or iOS bookmark still works after a new launch.',
      'idle': 'The validation has not been started yet.',
      'start': 'Start validation',
      'restartRequired': 'Stage 1 passed. Fully close OVDP Hub and open it again. Do not continue until a new app launch.',
      'readyAfterRestart': 'A new launch is confirmed. You can now validate the same folder permission and finish the test.',
      'continueTest': 'Continue after restart',
      'passed': 'Validation passed: persisted access survived restart and read/write/list/delete all worked.',
      'permissionLost': 'Access to the selected folder was lost. The operation stopped explicitly, confirming fail-closed behavior.',
      'failed': 'Validation was not completed.',
      'reset': 'Reset validation',
      'testing': 'Checking…',
      'folder': 'Folder: {folder}',
      'error': 'Code: {code}',
    },
    'fr': {
      'title': 'Validation du stockage mobile',
      'intro': 'Le test crée uniquement un fichier technique dans le dossier choisi. L’étape 1 vérifie l’écriture et la lecture, puis l’application doit être complètement redémarrée. L’étape 2 confirme que l’autorisation SAF Android ou le signet iOS fonctionne encore après un nouveau lancement.',
      'idle': 'La validation n’a pas encore été lancée.',
      'start': 'Démarrer la validation',
      'restartRequired': 'Étape 1 réussie. Fermez complètement OVDP Hub puis rouvrez-le. Ne continuez pas avant un nouveau lancement.',
      'readyAfterRestart': 'Un nouveau lancement est confirmé. Vous pouvez vérifier la même autorisation de dossier et terminer le test.',
      'continueTest': 'Continuer après redémarrage',
      'passed': 'Validation réussie : l’accès persistant a survécu au redémarrage et lecture/écriture/liste/suppression ont fonctionné.',
      'permissionLost': 'L’accès au dossier sélectionné a été perdu. L’opération a été arrêtée explicitement, conformément au mode fail-closed.',
      'failed': 'La validation n’a pas été terminée.',
      'reset': 'Réinitialiser la validation',
      'testing': 'Vérification…',
      'folder': 'Dossier : {folder}',
      'error': 'Code : {code}',
    },
    'de': {
      'title': 'Prüfung des mobilen Speichers',
      'intro': 'Der Test erstellt nur eine technische Datei im gewählten Ordner. Stufe 1 prüft Schreiben und Lesen, danach muss die App vollständig neu gestartet werden. Stufe 2 bestätigt, dass die Android-SAF-Berechtigung oder das iOS-Lesezeichen nach einem neuen Start weiter funktioniert.',
      'idle': 'Die Prüfung wurde noch nicht gestartet.',
      'start': 'Prüfung starten',
      'restartRequired': 'Stufe 1 bestanden. OVDP Hub vollständig schließen und erneut öffnen. Erst nach einem neuen App-Start fortfahren.',
      'readyAfterRestart': 'Ein neuer Start wurde bestätigt. Jetzt kann dieselbe Ordnerberechtigung geprüft und der Test abgeschlossen werden.',
      'continueTest': 'Nach Neustart fortfahren',
      'passed': 'Prüfung bestanden: Der gespeicherte Zugriff hat den Neustart überstanden und Lesen/Schreiben/Auflisten/Löschen funktionierten.',
      'permissionLost': 'Der Zugriff auf den gewählten Ordner ging verloren. Die Operation wurde ausdrücklich gestoppt; Fail-closed funktioniert.',
      'failed': 'Die Prüfung wurde nicht abgeschlossen.',
      'reset': 'Prüfung zurücksetzen',
      'testing': 'Prüfung läuft…',
      'folder': 'Ordner: {folder}',
      'error': 'Code: {code}',
    },
    'es': {
      'title': 'Validación del almacenamiento móvil',
      'intro': 'La prueba crea únicamente un archivo técnico en la carpeta elegida. La etapa 1 verifica escritura y lectura; después hay que cerrar y volver a abrir por completo la aplicación. La etapa 2 demuestra que el permiso SAF de Android o el marcador de iOS sigue funcionando tras un nuevo inicio.',
      'idle': 'La validación aún no se ha iniciado.',
      'start': 'Iniciar validación',
      'restartRequired': 'Etapa 1 superada. Cierre completamente OVDP Hub y vuelva a abrirlo. No continúe hasta un nuevo inicio de la aplicación.',
      'readyAfterRestart': 'Se confirmó un nuevo inicio. Ahora puede verificar el mismo permiso de carpeta y terminar la prueba.',
      'continueTest': 'Continuar después del reinicio',
      'passed': 'Validación superada: el acceso persistente sobrevivió al reinicio y lectura/escritura/listado/eliminación funcionaron.',
      'permissionLost': 'Se perdió el acceso a la carpeta seleccionada. La operación se detuvo explícitamente, confirmando el comportamiento fail-closed.',
      'failed': 'La validación no se completó.',
      'reset': 'Restablecer validación',
      'testing': 'Comprobando…',
      'folder': 'Carpeta: {folder}',
      'error': 'Código: {code}',
    },
    'ko': {
      'title': '모바일 저장소 검증',
      'intro': '선택한 폴더에 기술용 테스트 파일만 만듭니다. 1단계에서 쓰기와 읽기를 확인한 뒤 앱을 완전히 종료하고 다시 실행해야 합니다. 2단계에서는 Android SAF 권한 또는 iOS 북마크가 새 실행 후에도 유지되는지 확인합니다.',
      'idle': '아직 검증을 시작하지 않았습니다.',
      'start': '검증 시작',
      'restartRequired': '1단계를 통과했습니다. OVDP Hub를 완전히 종료한 뒤 다시 여세요. 새 앱 실행 전에는 계속하지 마세요.',
      'readyAfterRestart': '새 실행이 확인되었습니다. 같은 폴더 권한을 검증하고 테스트를 완료할 수 있습니다.',
      'continueTest': '재시작 후 계속',
      'passed': '검증 성공: 저장된 접근 권한이 재시작 후에도 유지되었고 읽기/쓰기/목록/삭제가 모두 동작했습니다.',
      'permissionLost': '선택한 폴더의 접근 권한을 잃었습니다. 작업이 명시적으로 중단되어 fail-closed 동작이 확인되었습니다.',
      'failed': '검증을 완료하지 못했습니다.',
      'reset': '검증 초기화',
      'testing': '확인 중…',
      'folder': '폴더: {folder}',
      'error': '코드: {code}',
    },
    'ja': {
      'title': 'モバイルストレージ検証',
      'intro': '選択したフォルダーには技術的なテストファイルだけを作成します。ステージ1で書き込みと読み込みを確認し、その後アプリを完全に終了して再起動します。ステージ2では Android SAF 権限または iOS ブックマークが新しい起動後も有効かを確認します。',
      'idle': '検証はまだ開始されていません。',
      'start': '検証を開始',
      'restartRequired': 'ステージ1に成功しました。OVDP Hub を完全に終了してから再度開いてください。新しい起動までは続行しないでください。',
      'readyAfterRestart': '新しい起動を確認しました。同じフォルダー権限を検証してテストを完了できます。',
      'continueTest': '再起動後に続行',
      'passed': '検証成功：保存されたアクセスは再起動後も有効で、読み込み・書き込み・一覧・削除がすべて動作しました。',
      'permissionLost': '選択したフォルダーへのアクセスが失われました。処理は明示的に停止され、fail-closed 動作が確認されました。',
      'failed': '検証を完了できませんでした。',
      'reset': '検証をリセット',
      'testing': '確認中…',
      'folder': 'フォルダー: {folder}',
      'error': 'コード: {code}',
    },
  };
}
