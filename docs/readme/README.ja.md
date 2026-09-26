# OVDP Hub

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · [🇫🇷 Français](README.fr.md) · [🇩🇪 Deutsch](README.de.md) · [🇪🇸 Español](README.es.md) · [🇰🇷 한국어](README.ko.md) · **🇯🇵 日本語**

> **現在スコープの最終 checkpoint: [OVDP Hub v0.9.4](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.9.4) — 0.9.4+21**
>
> **開発状態: PARKED / 現在の範囲で完了。アクティブ開発なし。**
>
> [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-START.zip) · [SHA-256](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/SHA256SUMS.txt)

## 製品

OVDP Hub はウクライナ国債 OVDP 向けの local-first Flutter/Dart アプリです。市場ソース確認、シナリオ計画、中立比較、事実ベースの暗号化個人ポートフォリオを提供します。

## v0.9.4

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

## 検証と PARKED の境界

v0.9.4 release run #113 は analyze、**218/218 tests**、Windows/macOS exact packaged ZIP smoke、Android release packaging、unsigned iOS packaging、START/source、checksums、legal notices を通過しました。

延期され、active NEXT ではない項目: Android 実機 SAF persistence/revoke 検証、signed iOS development build + iPhone runtime 検証、production signing/notarization/store distribution、installer、auto-update。これら実機シナリオを `RUNTIME VALIDATED` とは表記しません。

## プライバシーとライセンス

個人ポートフォリオはローカルで暗号化されます。legacy workspace JSON は平文のまま残る場合があり、migration は source JSON を自動削除しません。

Copyright © 2026 Roman Zavada. All rights reserved. Proprietary software であり、公開リポジトリは open-source license を付与しません。[LICENSE.md](../../LICENSE.md) 参照。
