# OVDP Hub

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · [🇫🇷 Français](README.fr.md) · [🇩🇪 Deutsch](README.de.md) · [🇪🇸 Español](README.es.md) · [🇰🇷 한국어](README.ko.md) · **🇯🇵 日本語**

> **現在の test prerelease: [OVDP Hub v0.9.3](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.9.3) — 0.9.3+20**
>
> [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-START.zip)

## 製品
OVDP Hub はウクライナ国債 OVDP 向けの local-first Flutter/Dart アプリです。市場ソース確認、シナリオ計画、中立比較、事実ベースの暗号化個人ポートフォリオを提供します。

## v0.9.3 の主な機能
- NBU / MinFin / seller レイヤーと provenance/freshness;
- fees / tax / FX / early exit / reserve floor / recurring needs を含む Planner;
- 自動 winner を持たない A/B/C 比較;
- deterministic CSV/ICS export;
- 常時 Economic Pulse;
- purchase/sale/coupon/redemption の暗号化ポートフォリオ;
- 推測 FIFO/LIFO ではなく acquisition lot の明示割当;
- ISIN ledger とクローズ済みポジション;
- unknown fee を 0 にしない実キャッシュ概要;
- 暗号化コピー検証付き非破壊 legacy migration;
- Classic / Workbench / Light Dashboard;
- UK/EN/FR/DE/ES/KO/JA UI.

実キャッシュ概要はオープンポジションの現在市場価値を含まないため、投資パフォーマンス指標ではありません。

## インストール
Windows: ZIP 全体を展開し `ovdp_hub.exe` を実行します。macOS: `ovdp_hub.app` を開きます; 現在の prerelease は notarized ではありません。Android: `OVDP-Hub.apk` をインストールします。iOS パッケージは unsigned です。

完全ガイド: **[日本語ユーザーガイド](../user-guide/USER_GUIDE.ja.md)**.

## プライバシー
個人ポートフォリオはローカルで暗号化されます。legacy workspace JSON は平文のまま残る場合があり、migration は source JSON を自動削除しません。

## 検証とライセンス
v0.9.3 は analyze/tests、Windows/macOS 実配布 ZIP の executable smoke、Android、unsigned iOS、START/source、checksums、legal notices を通過しています。

Copyright © 2026 Roman Zavada. All rights reserved. Proprietary software; [LICENSE.md](../../LICENSE.md) 参照.
