# OVDP Hub

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · [🇫🇷 Français](README.fr.md) · [🇩🇪 Deutsch](README.de.md) · [🇪🇸 Español](README.es.md) · [🇰🇷 한국어](README.ko.md) · **🇯🇵 日本語**

> **現在のテストリリース: [OVDP Hub v0.10.1](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.10.1) — 0.10.1+23**
>
ACTIVE — v0.10.1 is published; the next checkpoint is under verification.
>
> [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-START.zip) · [SHA-256](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/SHA256SUMS.txt)

## 製品

OVDP Hub はウクライナ国債 OVDP 向けの local-first Flutter/Dart アプリです。市場ソース確認、シナリオ計画、中立比較、事実ベースの暗号化個人ポートフォリオを提供します。

## v0.10.1 の新機能

- 暗号化コピーと現在のソースを再確認した後にのみ平文を削除する、より安全な非公開 Planner 移行;
- ロック時に非公開 Planner を消去し、ダイアログ、日付選択、古い非同期完了をキャンセル;
- lock/background/dispose が未完了の recovery/create/restore/migration を中止し、遅延した鍵を削除;
- 非公開 CSV/ICS export は平文への明示的な同意を必要とし、正確な保存先を表示;
- 暗号方式、KDF パラメータ、payload schema は変更なし。schema v5 を維持。


## v0.10.1 以降 — 次のチェックポイント候補

- F5 は `main` に統合済みです。名前とメモを持つ非公開コレクションはポートフォリオ内で暗号化され、編集・再表示でき、ロック時に下書きを消去します。
- 公開 ISIN リストはポートフォリオなしで動作し、非公開メモを含みません。
- 旧平文コレクションの移動は明示操作です。完全な暗号化コピーと変更されていない元データを検証した後だけ元データを削除し、競合・未知のフィールド・ロック・エラー時は元データを保持します。
- Payload schema v5 は v1–v4 を読み取り、暗号方式と KDF は変更しません。
- PR #157 は Inzhur、UNIVER、PrivatBank の公開情報を ISIN・通貨・償還日で比較する読み取り専用画面を準備します。価格・利回り・数量・情報源時刻は分離し、不明値を推測しません。
- まだ公開リリースではなく、現在のダウンロードは v0.10.1 です。

## 製品の範囲

- NBU / MinFin / seller レイヤーと provenance/freshness;
- fees / tax / FX / recurring needs / reserve floor / position ごとの early exit を含む Planner;
- 自動 winner を持たない A/B/C 比較;
- deterministic CSV/ICS export と Economic Pulse;
- purchase/sale/coupon/redemption、明示的 lot allocation、ISIN ledger を持つ暗号化 Portfolio;
- recovery secret の確認/rotation と Windows portable encrypted backup/restore;
- real packaged lifecycle smoke を通過した macOS Keychain ベース Portfolio;
- Android SAF / iOS security-scoped external-storage 基盤;
- mobile external workspace、暗号化 backup transport、fail-closed permission semantics;
- terminate/relaunch を跨ぐ二段階 mobile self-test;
- Classic / Workbench / Light Dashboard と UK/EN/FR/DE/ES/KO/JA UI、language/appearance の永続化。

実キャッシュ概要はオープンポジションの現在市場価値を含まないため、投資パフォーマンス指標ではありません。不明な fee は 0 に置き換えません。

## インストール

Windows: ZIP 全体を展開して `ovdp_hub.exe` を実行します。macOS: `ovdp_hub.app` を開きます; この checkpoint は notarized ではありません。Android: `OVDP-Hub.apk` をインストールします。iOS package は unsigned で、インストールには別途 Apple signing/provisioning が必要です。

完全ガイド: **[日本語ユーザーガイド](../user-guide/USER_GUIDE.ja.md)**.

## 検証と境界

PR #155 の exact head は analyze、**314 tests**、Windows/macOS exact ZIP smoke、Android release、unsigned iOS packaging を通過しました。v0.10.1 release workflow はこれらを再実行し、START/source、checksums、legal notices を公開する必要があります。

延期: Android 実機 SAF 検証、signed iOS 実機検証、production signing/notarization/store 配布、インストーラー、自動更新。経過利息と利回りは目安であり、投資助言ではありません。

## プライバシーとライセンス

個人ポートフォリオはローカルで暗号化されます。legacy workspace JSON は平文のまま残る場合があり、migration は source JSON を自動削除しません。

Copyright © 2026 Roman Zavada. All rights reserved. Proprietary software であり、公開リポジトリは open-source license を付与しません。[LICENSE.md](../../LICENSE.md) 参照。
