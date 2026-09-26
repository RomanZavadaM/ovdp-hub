# macOS Portfolio Keychain runtime gate

Дата: **26.09.2026**  
Base `main`: **`e1b20add6b674b02bb83a8d0a1362de2d2c471f0`**  
Checkpoint: **v0.9.3 / 0.9.3+20**

## Мета

Увімкнути encrypted Portfolio на macOS лише після реального runtime-доказу, що packaged macOS app може стабільно використовувати Keychain для device DEK / revision state і пройти vault recovery lifecycle.

Цей slice **не** є production signing/notarization і **не** розширює Android SAF / iOS security-scoped storage.

## Вихідний стан

- `LocalEncryptedPortfolioGateway.supported` дозволяв Windows / Android / iOS і навмисно не дозволяв macOS.
- `FlutterSecureStorageVaultDeviceKeyStore` уже допускав `TargetPlatform.macOS`.
- macOS options мали `usesDataProtectionKeychain: true`, але `Release.entitlements` / `DebugProfile.entitlements` не мають `keychain-access-groups` і поточний test-build не має provisioning для Keychain Sharing.
- Старий packaged desktop smoke перевіряв запуск/version/build/appearance contract, але не торкався Keychain або vault.

## Прийнята конфігурація

Проєкт pinned на `flutter_secure_storage: 11.2.0`.

OVDP Hub не має вимоги ділитися Keychain item з іншим застосунком, тому macOS secure-storage переведено на звичайний системний Keychain:

- `accountName: ua.ovdphub.vault`;
- `accessibility: unlocked_this_device`;
- `synchronizable: false`;
- `usesDataProtectionKeychain: false`;
- `useSecureEnclave: false`.

Це дозволяє не вводити Keychain Sharing/provisioning у звичайний unsigned test-build. Production Developer ID/notarization лишається окремим distribution gate.

## Gate A — runtime proof до enablement — PASSED

До зміни `PortfolioGateway.supported` packaged macOS executable отримав спеціальний smoke-mode, який реально викликає platform plugin і перевіряє:

1. Keychain DEK write → read round-trip;
2. highest accepted revision write → read;
3. encrypted vault create/open;
4. session unlock → lock → reopen;
5. save + monotonic revision;
6. encrypted portable backup creation;
7. local vault + device key cleanup;
8. restore backup через recovery secret на fresh local state;
9. recovery secret rotation;
10. backup після rotation;
11. old recovery secret fail-closed;
12. new recovery secret restores;
13. фінальний cleanup Keychain item + temp files.

Smoke виконується **саме packaged macOS executable**, а не `flutter test` mock.

Evidence:

- PR #127 pre-enablement head: **`4568de2d6a833e5a723ebf50c6f289a75f842cbf`**;
- Ready native run **#462** / workflow run `36236068148` — verify + Windows/macOS packaged jobs success;
- macOS merge-ref under test: `404de251a98c42bf5be1ea658bce489aeda315db`;
- runtime log: `PASS: packaged macOS app completed real Keychain/vault create-open-lock-reopen-backup-restore-rotation-cleanup smoke.`;
- artifact: `OVDP-Hub-0.9.3-b20-macos-462-1-404de25`;
- artifact SHA-256: `26eba99618fd40758aaa7a2c91deb1f4653596d4fadc114bed220abd66201c78`;
- artifact ID: `10904322484`.

Після цього Gate A дозволив перейти до enablement.

## Gate B — Portfolio enablement — PASSED

Після Gate A:

- macOS додано до encrypted Portfolio capability;
- capability винесено у deterministic contract `isEncryptedPortfolioPlatformSupported(...)`;
- regression фіксує Windows/macOS/Android/iOS як supported, Linux/Fuchsia/web — unsupported;
- portable external-file backup UI **не** розширено на macOS: він лишається Windows-only до окремого user-facing file-flow validation;
- повторено analyze/tests + packaged Windows/macOS runtime gates вже після enablement.

Evidence на product head:

- enablement commit: **`3d32a05dd61327e219653e418a9ce448a58fc0e8`**;
- platform-contract test head: **`c5a23e087b0bf168ee757cc0fc63849ebb802f4b`**;
- native run **#464** / workflow run `36236470390` — verify success, Windows packaged smoke success, macOS packaged Keychain/vault smoke success;
- PR merge-ref under test: `402b0e2ee02fe4134a13821d10377e0f9a737c64`;
- macOS runtime log знову підтвердив: `PASS: packaged macOS app completed real Keychain/vault create-open-lock-reopen-backup-restore-rotation-cleanup smoke.`;
- macOS artifact: `OVDP-Hub-0.9.3-b20-macos-464-1-402b0e2`;
- macOS artifact SHA-256: `fd9714910cc6ac39f85b02e5da896fa47738982ff691dc47c4095867c9bb2be2`;
- macOS artifact ID: `10905025021`;
- Windows artifact: `OVDP-Hub-0.9.3-b20-windows-464-1-402b0e2`;
- Windows artifact SHA-256: `106441b4ba07a057aa4a53eafb4be21ddcc4a46a123aff522ccc2ad8963586ff`;
- Windows artifact ID: `10904392791`.

## Fail-closed правила

- Не додавати `keychain-access-groups` тільки заради проходження CI: це змінює provisioning/distribution contract і належить до окремого signing gate.
- Не вважати compile або звичайний app launch доказом Keychain persistence.
- Не використовувати mock secure storage як runtime evidence.
- Не видаляти/перезаписувати чужі Keychain items: smoke використовує унікальний vault id і прибирає лише власні test keys.
- macOS external portable backup/restore file-picker flow не вважати автоматично валідованим через Keychain gate.

## Acceptance

Product acceptance для цього slice виконано:

- [x] Gate A packaged macOS runtime smoke — green;
- [x] final gateway capability містить macOS;
- [x] platform capability regression додано;
- [x] post-enablement exact-head Flutter analyze/tests — green;
- [x] post-enablement packaged macOS Keychain/vault runtime smoke — green;
- [x] Windows packaged smoke не регресував;
- [x] capability docs та user guides підготовлені до синхронізації;
- [ ] PR #127 final docs-synced exact-head gates;
- [ ] merge у `main` + post-merge verification;
- [ ] post-merge canonical state (`START_HERE` / `PROJECT_STATE` / `WORKLOG` / roadmap / Issue #18) sync.
