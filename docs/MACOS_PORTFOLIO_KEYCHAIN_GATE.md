# macOS Portfolio Keychain runtime gate

Дата: **26.09.2026**  
Base `main`: **`e1b20add6b674b02bb83a8d0a1362de2d2c471f0`**  
Checkpoint: **v0.9.3 / 0.9.3+20**

## Мета

Увімкнути encrypted Portfolio на macOS лише після реального runtime-доказу, що packaged macOS app може стабільно використовувати Keychain для device DEK / revision state і пройти vault recovery lifecycle.

Цей slice **не** є production signing/notarization і **не** розширює Android SAF / iOS security-scoped storage.

## Поточний факт

- `LocalEncryptedPortfolioGateway.supported` дозволяє Windows / Android / iOS і навмисно не дозволяє macOS.
- `FlutterSecureStorageVaultDeviceKeyStore` уже допускає `TargetPlatform.macOS`.
- macOS options зараз мають:
  - `accountName: ua.ovdphub.vault`;
  - `accessibility: unlocked_this_device`;
  - `synchronizable: false`;
  - `usesDataProtectionKeychain: true`;
  - `useSecureEnclave: false`.
- `macos/Runner/Release.entitlements` і `DebugProfile.entitlements` не містять `keychain-access-groups`.
- Поточний packaged desktop smoke перевіряє запуск/version/build/appearance contract, але не торкається Keychain або vault.

## Upstream constraint

Проєкт pinned на `flutter_secure_storage: 11.2.0`.

Документація пакета для macOS зазначає:
- Data Protection Keychain / Keychain Sharing потребує відповідного entitlement і provisioning;
- без App Group / sharing між застосунками можна використати `MacOsOptions(usesDataProtectionKeychain: false)`, що працює через звичайний macOS Keychain без Keychain Sharing provisioning.

Reference: https://pub.dev/packages/flutter_secure_storage

OVDP Hub не має вимоги ділитися Keychain item з іншим застосунком, тому **candidate configuration** для цього gate — `usesDataProtectionKeychain: false` лише для macOS. Це не вважається прийнятим рішенням до runtime green.

## Gate A — runtime proof до enablement

До зміни `PortfolioGateway.supported` packaged macOS executable має пройти спеціальний runtime smoke, який реально викликає platform plugin і перевіряє:

1. Keychain DEK write → read round-trip;
2. highest accepted revision write → read;
3. encrypted vault create/open;
4. session unlock → lock → reopen;
5. encrypted portable backup creation;
6. local vault + device key cleanup;
7. restore backup через recovery secret на fresh local state;
8. recovery secret rotation;
9. backup після rotation;
10. old recovery secret fail-closed, new recovery secret restores;
11. фінальний cleanup Keychain item + temp files.

Smoke повинен виконуватися **саме packaged macOS executable**, а не `flutter test` mock.

## Gate B — Portfolio enablement

Лише після Gate A green:

- додати `Platform.isMacOS` до `LocalEncryptedPortfolioGateway.supported`;
- залишити portable external-file backup UI окремо від цього рішення, якщо його file-flow ще не валідовано як user-facing macOS contract;
- додати regression/contract, що macOS capability матриця не повернеться у disabled випадково;
- повторити exact-head analyze/tests + packaged macOS runtime smoke;
- тільки після final green інтегрувати PR у `main`.

## Fail-closed правила

- Не додавати `keychain-access-groups` тільки заради проходження CI: це змінює provisioning/distribution contract і належить до окремого signing gate.
- Не вважати compile або звичайний app launch доказом Keychain persistence.
- Не використовувати mock secure storage як runtime evidence.
- Не видаляти/перезаписувати чужі Keychain items: smoke використовує унікальний vault id і прибирає лише власні test keys.
- При будь-якому runtime failure macOS Portfolio лишається disabled.

## Acceptance

Slice DONE лише якщо одночасно виконано:

- Gate A packaged macOS runtime smoke — green;
- final gateway capability містить macOS;
- final exact-head Flutter analyze/tests — green;
- final packaged macOS runtime smoke після enablement — green;
- Windows packaged smoke не регресував;
- docs/platform capability state синхронізований;
- GitHub Issue #18 містить exact heads/runs і результат gate.
