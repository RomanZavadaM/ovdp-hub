# OVDP Hub

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · [🇫🇷 Français](README.fr.md) · [🇩🇪 Deutsch](README.de.md) · [🇪🇸 Español](README.es.md) · [🇰🇷 한국어](README.ko.md) · **🇯🇵 日本語**

> **現在のテストリリース: [OVDP Hub v0.10.0](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.10.0) — 0.10.0+22**
>
> **開発状態: ACTIVE — 2026-10-01 に開発再開、2026-10-02 に v0.10.0 公開。**
>
> [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.0/OVDP-Hub-0.10.0-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.0/OVDP-Hub-0.10.0-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.0/OVDP-Hub-0.10.0-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.0/OVDP-Hub-0.10.0-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.0/OVDP-Hub-0.10.0-START.zip) · [SHA-256](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.0/SHA256SUMS.txt)

## 製品

OVDP Hub はウクライナ国債 OVDP 向けの local-first Flutter/Dart アプリです。市場ソース確認、シナリオ計画、中立比較、事実ベースの暗号化個人ポートフォリオを提供します。

## v0.10.0 の新機能

- ポートフォリオを開くときの**復旧パスワード**（任意）;
- 非公開金額を含む Planner シナリオは**暗号化ポートフォリオにのみ**保存;
- 確認付きのローカルポートフォリオ削除と古いバックアップの復元;
- **カタログ債券の計算機**（経過利息の目安、満期利回り）;
- 12か月の**受取予定**と「未記録の可能性」の表示;
- **プランの年利回り**、バックグラウンド Argon2id、数式安全な CSV、堅牢な NBU カタログ更新。

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

v0.10.0 release run #116（commit `933a7bd`）は analyze、**264 tests**、capability 一覧を含む Windows/macOS exact packaged ZIP smoke、Android release packaging、unsigned iOS packaging、START/source、checksums、legal notices を通過しました。

延期: Android 実機 SAF 検証、signed iOS 実機検証、production signing/notarization/store 配布、インストーラー、自動更新。経過利息と利回りは目安であり、投資助言ではありません。

## プライバシーとライセンス

個人ポートフォリオはローカルで暗号化されます。legacy workspace JSON は平文のまま残る場合があり、migration は source JSON を自動削除しません。

Copyright © 2026 Roman Zavada. All rights reserved. Proprietary software であり、公開リポジトリは open-source license を付与しません。[LICENSE.md](../../LICENSE.md) 参照。
