# OVDP Hub

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · [🇫🇷 Français](README.fr.md) · [🇩🇪 Deutsch](README.de.md) · [🇪🇸 Español](README.es.md) · [🇰🇷 한국어](README.ko.md) · **🇯🇵 日本語**

> **Current published prerelease / Поточний опублікований prerelease: [OVDP Hub v0.9.2](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.9.2) (0.9.2+19)**
>
> Downloads / Завантаження: [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.2/OVDP-Hub-0.9.1-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.2/OVDP-Hub-0.9.1-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.2/OVDP-Hub-0.9.1-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.2/OVDP-Hub-0.9.1-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.2/OVDP-Hub-0.9.1-START.zip) · [SHA-256](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.2/SHA256SUMS.txt)

---

### v0.9.2 チェックポイント

**v0.9.2+19** では常時表示の **経済パルス** と、初のユーザー向け **マイポートフォリオ** フローを追加します。ローカル暗号化ポートフォリオの作成/開く/ロック、実購入 OVDP の記録、derived holdings 表示に対応します。さらに実際に配布する Windows/macOS ZIP と executable 自体を検証する release gate を追加しました。

**プライバシー境界:** legacy `sets/*.json` は引き続き自動暗号化されません。migration/cleanup wizard は次の別ユーザー工程で、Android SAF / iOS security-scoped は延期されています。


### 概要

**OVDP Hub** は、ウクライナ国債（OVDP）、市場データの情報源、個人向け投資シナリオを確認するためのインストール型 Flutter/Dart アプリです。対象プラットフォームは **Windows、macOS、Android、iOS** です。Web/PWA は現在の製品範囲には含まれません。

アクティブなコードは `apps/native` です。現在のチェックポイントは **0.9.2+19** です。0.9.0 以降の UI/Planner/export と、検証済みの内部 vault/private-domain/migration 基盤を含みます。ユーザー向け vault/migration/portfolio 接続はまだ別段階です。

### 現在利用できる機能

- NBU 公開データを基にしたローカル OVDP カタログ;
- 検索、フィルター、支払スケジュール、発行比較;
- provenance、source date、retrieved time、freshness/status を分離して表示する **NBU / 財務省 / 販売者** データ層;
- 財務省入札カレンダーと placement/switch の詳細結果;
- ユーザーが明示的に優先順位を決める複数の価格ソース;
- 予算、準備金、償還期間、将来支出を扱うプランナー;
- 明示的な購入手数料前提。不明な手数料を 0 とみなさない;
- 2026 年のウクライナ居住個人向け OVDP 検証済み税務プロファイルと **不明 / 検証済み 0** の明確な区別;
- 基準 cashflow の通貨を混在させない、手動レート・日付・情報源 URL による明示的 FX 比較;
- 各ポジションごとの売却日と BID/手動 exit 価格による満期前売却;
- typed ルールとして保存される定期的な主な必要額と、個別の一回限り追加必要額;
- 厳密な比較条件と自動的な勝者判定なしで、保存済みシナリオ 2～3 件を中立的に比較する **A/B/C** 機能;
- typed reserve floor / 最低残高ルール。適用日以降はその金額を流動資金として残し、支出として扱わない;
- 現在のワークスペースの `exports` フォルダーへ scenario/needs/coverage/cashflow を保存する決定的なローカル Planner CSV/ICS エクスポート。PDF はレポート構造安定後まで延期;
- Planner の生成文言 / preset label は安定した ID として保存し表示時にローカライズし、ユーザー入力の名称はそのまま保持;
- ポータブルな JSON ワークスペースへのシナリオ保存;
- アクティブ UI と主要なユーザー向けエラーを **UK / EN / FR / DE / ES / KO / JA** にローカライズ.

名目クーポンを市場利回りとはみなしません。yield-only の観測値を自動的に価格として使用せず、不明な手数料、税金、FX を暗黙に 0 に置き換えません。

### プランナー

プランナーは意図的に単一通貨シナリオを維持します。償還期間配分、計算利益モード、将来支出の充足を扱い、数量と総額価格は手動で変更できます。

公開済み 0.9.0 チェックポイント以降の開発:

1. **DONE** — 明示的な価格ソース優先順位;
2. **DONE** — 購入手数料前提;
3. **DONE** — 検証済み税務前提;
4. **DONE** — FX 前提;
5. **DONE** — exit 前提;
6. **DONE** — 中立的な A/B/C 比較;
7. **DONE** — Planner 生成文言 / preset label のローカライズ + 回帰テスト;
8. **DONE** — v0.9.0 prerelease checkpoint;
9. **DONE** — reserve floor / 最低残高;
10. **DONE** — 決定的なローカル CSV/ICS エクスポート。PDF は延期;
11. **DONE** — encrypted-vault/private-domain/非破壊 migration 基盤; 12. **DONE** — v0.9.2+18 チェックポイント; 13. **NEXT** — Android SAF / iOS security-scoped 外部フォルダーアクセス; ユーザー向け vault/migration UX は別 gate.

OVDP Hub は実際の売買を実行せず、販売者の在庫を確認しません。

### データとプライバシー

カタログとシナリオはユーザー端末に保存されます。デスクトップではワークスペースフォルダーを開く、またはコピーできます。OVDP Hub は個人ポートフォリオデータ用の中央サーバーを運用しません。

現在のユーザー向け選択フローで使う legacy workspace JSON は、将来の明示的な vault/migration フローが接続され正常に実行されるまで **平文** のままです。v0.9.2 には検証済み encrypted-vault/private-payload/migration 基盤がありますが、既存の `sets/*.json` を自動で書き換えたり削除したりしません。Legacy workspace に署名鍵、KYC 文書、その他の秘密情報を保存しないでください。

### クイックテスト

通常の変更では `flutter analyze`、`flutter test`、START パッケージ作成を実行します。Windows では `START.bat`、macOS では `START.command` を使用します。初回のローカル実行には Flutter 3.47.5 と各 OS のビルドツールが必要です。

正式な prerelease は Windows/macOS/Android/iOS、START/source、`SHA256SUMS.txt`、法的通知、不変 tag、GitHub Release を生成します。

### 著作権

**Copyright © 2026 Roman Zavada. All rights reserved.**

OVDP Hub は **プロプライエタリソフトウェア**です。公開リポジトリであることは、オープンソースライセンスや、コピー、変更、再公開、販売、再配布、派生版作成の許可を意味しません。

[LICENSE.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/LICENSE.md)、[COPYRIGHT.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/COPYRIGHT.md)、[THIRD_PARTY_NOTICES.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/THIRD_PARTY_NOTICES.md)、[LEGAL_AND_COPYRIGHT.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/docs/LEGAL_AND_COPYRIGHT.md) を参照してください。

### 開発

```sh
cd apps/native
flutter pub get
flutter analyze
flutter test
flutter build windows --release
```

その他の対象: `flutter build macos --release`、`flutter build apk --release`、`flutter build ipa --release`.

プロジェクト状態: [START_HERE.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/START_HERE.md)、[PROJECT_STATE.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/PROJECT_STATE.md)、[PROJECT_RULES.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/PROJECT_RULES.md)、[WORKLOG.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/WORKLOG.md)、[CHANGELOG.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/CHANGELOG.md).

---

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · [🇫🇷 Français](README.fr.md) · [🇩🇪 Deutsch](README.de.md) · [🇪🇸 Español](README.es.md) · [🇰🇷 한국어](README.ko.md) · **🇯🇵 日本語**
