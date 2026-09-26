# macOS Portfolio Keychain runtime gate

Дата: **26.09.2026**  
Base `main`: **`e1b20add6b674b02bb83a8d0a1362de2d2c471f0`**  
Integrated main: **`4c1617b3f0636c6ca33a35b2f992766dc4649cde`**  
Checkpoint: **v0.9.3 / 0.9.3+20**

## Мета

Увімкнути encrypted Portfolio на macOS лише після реального runtime-доказу, що packaged macOS app може стабільно використовувати Keychain для device DEK / revision state і пройти vault recovery lifecycle.

Цей slice **не** є production signing/notarization і **не** розширює Android SAF / iOS security-scoped storage.

## Вихідний стан

- `LocalEncryptedPortfolioGateway.supported` дозволяв Windows / Android / iOS і навмисно не дозволяв macOS.
- `FlutterSecureStorageVaultDeviceKeyStore` уже допускав `TargetPlatform.macOS`.
- macOS options мали `usesDataProtectionKeychain: true`, але current test-build не має Keychain Sharing provisioning.
- Старий packaged desktop smoke перевіряв запуск/version/build/appearance contract, але не торкався Keychain або vault.

## Прийнята конфігурація

Проєкт pinned на `flutter_secure_storage: 11.2.0`.

OVDP Hub не має вимоги ділитися Keychain item з іншим застосунком, тому macOS secure-storage використовує звичайний системний Keychain:

- `accountName: ua.ovdphub.vault`;
- `accessibility: unlocked_this_device`;
- `synchronizable: false`;
- `usesDataProtectionKeychain: false`;
- `useSecureEnclave: false`.

Production Developer ID/notarization лишається окремим distribution gate.

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
- runtime log: `PASS: packaged macOS app completed real Keychain/vault create-open-lock-reopen-backup-restore-rotation-cleanup smoke.`;
- artifact: `OVDP-Hub-0.9.3-b20-macos-462-1-404de25`;
- artifact SHA-256: `26eba99618fd40758aaa7a2c91deb1f4653596d4fadc114bed220abd66201c78`.

Після цього Gate A дозволив перейти до enablement.

## Gate B — Portfolio enablement — PASSED

Після Gate A:

- macOS додано до encrypted Portfolio capability;
- capability винесено у deterministic contract `isEncryptedPortfolioPlatformSupported(...)`;
- regression фіксує Windows/macOS/Android/iOS як supported, Linux/Fuchsia/web — unsupported;
- portable external-file backup UI **не** розширено на macOS: він лишається Windows-only до окремого user-facing file-flow validation;
- повторено analyze/tests + packaged Windows/macOS runtime gates вже після enablement.

Evidence:

- enablement commit: **`3d32a05dd61327e219653e418a9ce448a58fc0e8`**;
- platform-contract test head: **`c5a23e087b0bf168ee757cc0fc63849ebb802f4b`**;
- native run **#464** / workflow run `36236470390` — verify success, Windows packaged smoke success, macOS packaged Keychain/vault smoke success;
- macOS artifact: `OVDP-Hub-0.9.3-b20-macos-464-1-402b0e2`, SHA-256 `fd9714910cc6ac39f85b02e5da896fa47738982ff691dc47c4095867c9bb2be2`;
- Windows artifact: `OVDP-Hub-0.9.3-b20-windows-464-1-402b0e2`, SHA-256 `106441b4ba07a057aa4a53eafb4be21ddcc4a46a123aff522ccc2ad8963586ff`.

## Final exact-head / merge evidence — PASSED

- final docs-synced PR head: **`890917667b97a5ff4950e2d4dda43fbc6152881a`**;
- native run **#465 — success**: `flutter analyze`, **204 tests**, Windows packaged smoke, macOS packaged real Keychain/vault smoke;
- final Windows artifact: `OVDP-Hub-0.9.3-b20-windows-465-1-2f0b228`, SHA-256 `c3df3476537f9ea061521aab9b03f1408f040177aab9e4d968eb538b8eab57d7`;
- final macOS artifact: `OVDP-Hub-0.9.3-b20-macos-465-1-2f0b228`, SHA-256 `1ad00208a63e1585d524503751c2315ba61593d39653f4af18ad87b641e2bf76`;
- release-PR run **#110 — success**: exact Windows/macOS release ZIP smoke;
- PR #127 squash-merged into `main` as **`4c1617b3f0636c6ca33a35b2f992766dc4649cde`**;
- post-merge native run **#466 — success**, including verify + START/source;
- START artifact: `OVDP-Hub-0.9.3-test-466-1-START`, SHA-256 `5b7dcb427357ab88785223434d6ab3784e1682e6ecb75a592cca9a6431ea21cb`;
- release workflow after merge correctly detected existing v0.9.3 and skipped republishing/build jobs.

## Fail-closed правила

- Не додавати `keychain-access-groups` тільки заради CI: це окремий provisioning/distribution contract.
- Не вважати compile або звичайний app launch доказом Keychain persistence.
- Не використовувати mock secure storage як runtime evidence.
- Smoke використовує унікальний vault id і прибирає лише власні test keys/files.
- macOS external portable backup/restore file-picker flow не вважати автоматично валідованим через Keychain gate.

## Acceptance — COMPLETE

- [x] Gate A packaged macOS runtime smoke — green;
- [x] final gateway capability містить macOS;
- [x] platform capability regression додано;
- [x] post-enablement analyze/tests — green;
- [x] post-enablement packaged macOS Keychain/vault runtime smoke — green;
- [x] Windows packaged smoke не регресував;
- [x] capability docs + UK/EN/FR/DE/ES/KO/JA user guides synchronized;
- [x] PR #127 final docs-synced exact-head gates — green;
- [x] merge у `main` + post-merge verification — green;
- [x] canonical state sync prepared after merge.

## Наступний platform gate

**Android SAF + iOS security-scoped external-folder access.** Він має вирішити user-facing external workspace/backup file flow на mobile окремо від production signing/notarization/store distribution.
