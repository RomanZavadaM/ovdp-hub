import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/platform/mobile_external_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(MethodChannelMobileExternalStorage.channelName);
  const storage = MethodChannelMobileExternalStorage(supportedOverride: true);

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('grant map rejects malformed ids', () {
    expect(
      () => ExternalFolderGrant.fromMap(const {'id': '', 'label': 'Folder'}),
      throwsFormatException,
    );
    expect(
      () => ExternalFolderGrant.fromMap(const {'id': 'valid-grant', 'label': ''}),
      throwsFormatException,
    );
  });

  test('method-channel contract rejects traversal before native call', () async {
    var called = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          called = true;
          return null;
        });

    await expectLater(
      storage.readWorkspaceText(
        grantId: '12345678',
        relativePath: '../catalogs/latest.json',
        maxBytes: 1024,
      ),
      throwsFormatException,
    );
    expect(called, isFalse);
  });

  test('native grant loss is surfaced fail closed', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          throw PlatformException(code: 'workspace.external_permission_lost');
        });

    await expectLater(
      storage.workspaceFolderAvailable('12345678'),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'workspace.external_permission_lost',
        ),
      ),
    );
  });

  test('import rejects native payload above declared limit', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'importEncryptedBackup');
          return Uint8List(9);
        });

    await expectLater(
      storage.importEncryptedBackup(maxBytes: 8),
      throwsFormatException,
    );
  });

  test('cancelled native backup import stays a cancellation', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => null);

    expect(await storage.importEncryptedBackup(maxBytes: 1024), isNull);
  });
}
