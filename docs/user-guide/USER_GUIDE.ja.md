# OVDP Hub v0.9.3 — ユーザーガイド

## 目的
OVDP Hub はウクライナ国債 OVDP 向けの local-first アプリです。市場ソース確認、シナリオ計画、比較、事実ベースの暗号化個人ポートフォリオを提供します。取引の実行は行いません。

## インストール
**Windows:** ZIP 全体を展開し、`ovdp_hub.exe` を実行します。DLL/リソースを実行ファイルと同じフォルダーに残してください。テスト prerelease は production code-signing がないため SmartScreen が表示される場合があります。

**macOS:** ZIP を展開し `ovdp_hub.app` を開きます。現在の prerelease は notarized ではありません。最初にブロックされた場合、System Settings → Privacy & Security に **Open Anyway** が表示されることがあります。

**Android:** Android ZIP を展開して `OVDP-Hub.apk` をインストールします。development signing のテストビルドです。

**iOS:** 公開パッケージは unsigned で、別途 Apple signing/provisioning が必要です。

## 言語と外観
対応言語: Ukrainian / English / Français / Deutsch / Español / 한국어 / 日本語。外観: Classic / Workbench / Light Dashboard。選択した言語と外観はこの端末にローカル保存され、次回起動時に復元されます。

## 市場と ISIN
カタログで OVDP を検索・絞り込みできます。ISIN カードでは NBU / MinFin / seller を分離し、source date、retrieved time、freshness/status を表示します。yield-only や nominal は自動的に取引価格として扱われません。

## Planner
1 シナリオは 1 基準通貨です。budget、reserve、horizon、needs、positions、fees、tax、FX、early exit、reserve floor、one-off/recurring needs を設定できます。未知の値は 0 にせず unknown のまま保持します。

A/B/C は互換性のある保存済みシナリオ 2–3 件を比較しますが、自動 winner は選びません。CSV/ICS はローカル `exports/` に保存されます。

## マイポートフォリオ
ポートフォリオはローカル暗号化フローで create/open/lock をサポートします。

**購入:** 実際の ISIN/日付/数量/金額と手数料状態を記録します。

**売却:** acquisition lot への割当を明示します。FIFO/LIFO を勝手に推定しません。

**クーポン / 償還:** 実際に受領した金額だけを記録します。

**ISIN ledger:** purchase/sale/coupon/redemption 履歴を確認できます。数量 0 のクローズ済みポジションも残ります。

**実キャッシュ概要:** 通貨ごとに購入額、売却入金、クーポン、償還、既知手数料を表示します。関連手数料が unknown の場合、正確な net cash result は表示しません。

オープンポジションの現在市場価値を加算しないため、市場価値評価や投資パフォーマンス指標ではありません。

## Legacy migration
migration wizard は対応するユーザー legacy データを暗号化 payload にコピーし、暗号化コピーを検証します。source JSON は自動削除しません。

## バックアップと更新
大きな更新前にポートフォリオをロックし、workspace をバックアップし、encrypted portable backup を確認し、recovery material を別に保管してください。Desktop 更新は新しいプログラムフォルダーに展開し、新版を確認するまで workspace を保持してください。

Windows の **マイポートフォリオ**では、持ち運べる暗号化バックアップを作成し、それを使って空のローカルポートフォリオを復元できます。作成時には復旧シークレットを2回入力し、後から変更することもできます。Android/iOS の外部ファイルフローは別の SAF/security-scoped 段階まで延期されています。

## 検証とよくある問題
GitHub Release の `SHA256SUMS.txt` でダウンロードを検証できます。unsigned test prerelease のため SmartScreen/macOS 警告が出る場合があります。「Unknown fee」は意図した状態です。iOS unsigned ZIP はそのままではインストールできません。

## 制限
OVDP Hub はブローカーではありません。金融行動の前に価格、手数料、税、日付、条件を一次情報とご自身の銀行/ブローカーで確認してください。
