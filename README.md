# niborame — 煮干しラーメンの店舗ガイド

関西を中心に、煮干しラーメンを食べられる店を探すためのポートフォリオアプリです。まずは作者が知っている店舗の情報を掲載し、味のジャンルや紹介文から店を探せることを目指しています。

公開アプリ: [niborame](https://niborame.fly.dev/)

## 現在の機能

- 店舗一覧とトップページの表示
- 登録済み店舗のジャンル絞り込み
- 店名・住所のキーワード検索とジャンル絞り込みの併用
- 店舗詳細（紹介文、住所、営業時間、画像）の表示
- 管理者画面からの店舗画像アップロード（JPEG、PNG、WebP、GIF、5MBまで）
- Place IDが設定された店舗の住所・位置・営業時間・Google Mapsの評価と評価件数を詳細表示時に取得
- Google Mapsの写真を最大3枚表示し、投稿者情報とGoogle Mapsへのリンクを掲載
- Places APIから取得した位置、または保存済みの緯度・経度を使った地図表示（Maps APIキーが必要）
- 地図情報がない場合は、住所からGoogleマップを開くリンクを表示
- お問い合わせフォーム（入力内容をメールアプリで送信）
- 藍色を基調に、明るい本文・読みやすいフッターで統一したレスポンシブUI

店舗情報はPostgreSQLの `ramen_shops` テーブルに保存します。初期データは `db/seeds.rb` で管理し、初期データの投入にGoogle APIキーは不要です。管理画面でGoogle Place IDを設定すると、詳細ページを開くたびにPlaces APIから住所・位置・営業時間・評価・評価件数・写真情報を取得します。Place ID以外のGoogle由来の詳細情報や写真名はDBへ保存しません。写真取得には10分間有効の署名付きURLを使い、詳細ページと写真取得経路はキャッシュを抑制します。

## 技術スタック

- **言語・フレームワーク:** Ruby 3.3.3、Ruby on Rails 7.1
- **データベース:** PostgreSQL
- **フロントエンド:** HTML、SCSS、JavaScript、Bootstrap 5、Vite
- **画像管理:** Active Storage、Fly.io Tigris
- **外部API:** Google Maps JavaScript API、Google Places API
- **問い合わせ:** メールアプリを使った送信
- **コンテナ:** Docker、Docker Compose
- **テスト:** RSpec
- **バージョン管理:** Git、GitHub
- **デプロイ:** Fly.io

## ローカルで起動する

Docker DesktopとDocker Composeを用意し、リポジトリのルートで実行します。

```bash
docker compose up --build -d
docker compose exec runner bin/rails db:seed
```

ブラウザで http://localhost:3000 を開きます。終了するときは次を実行します。

```bash
docker compose down
```

### 環境変数

ローカルではリポジトリ直下の `.env` に設定します。キーやパスワードをGitへコミットしないでください。

| 変数 | 用途 |
| --- | --- |
| `GOOGLE_PLACES_API_KEY` | Places API (New)による詳細情報・評価・写真の取得 |
| `GOOGLE_MAPS_API_KEY` | Maps JavaScript APIによる地図表示 |
| `ADMIN_USERNAME` / `ADMIN_PASSWORD` | 管理画面のログイン情報 |
| `CONTACT_EMAIL` | お問い合わせの送信先 |

Google APIを利用する場合はGoogle Cloudで対象APIと課金設定を有効にし、キーに適切なAPI制限・利用元制限を設定します。詳細ページや写真の取得にはAPI利用料が発生する場合があります。Google APIキーがなくても、保存済み店舗情報の一覧・詳細は表示できます。

`.env` の設定を変更した後は、コンテナを再作成して反映します。

```bash
docker compose up -d --force-recreate runner
```

お問い合わせフォームは確認画面から利用者のメールアプリを開く仕組みです。フォームの内容はデータベースに保存せず、サーバーからのメール送信は行いません。利用規約 (`/terms`) とプライバシーポリシー (`/privacy`) も公開しています。

## 店舗データを変更する

店舗の初期データは `db/seeds.rb` にあります。店舗を追加・編集した後、次を実行するとデータベースへ反映できます。

```bash
docker compose exec runner bin/rails db:seed
```

シードは店舗名をキーに、未登録の店舗だけを追加します。登録済み店舗の情報は上書きしません。Place IDがない店舗やAPI取得に失敗した場合は、保存済みの住所・営業時間などを表示します。地図表示に必要な位置やMaps APIキーがない場合は、Google Mapsへのリンクを表示します。

管理画面では、管理者ログイン後に店舗情報の追加・編集・削除ができます。ローカルでは `.env` に `ADMIN_USERNAME` と `ADMIN_PASSWORD` を設定してComposeを再起動し、`http://localhost:3000/admin/login` にアクセスしてください。Fly.ioではこれらをアプリのsecretとして設定します。管理者アカウントの自己登録機能はありません。

### Google Place IDの登録

1. [Google公式のPlace ID検索ページ](https://developers.google.com/maps/documentation/places/web-service/place-id?hl=ja)で、店舗名・住所を検索します。
2. 管理画面の店舗編集で「Google Place ID（任意）」に取得したIDを入力し、保存します。
3. 店舗詳細で評価・写真・地図を確認します。DBへ緯度・経度を手入力する必要はありません。

Place IDは店舗ごとの登録項目です。`.env` に入れるAPIキーとは異なります。CID（数値の店舗識別子）はこの欄では使用できません。

## テスト

```bash
docker compose run --rm -e RAILS_ENV=test -e DATABASE_URL=postgres://postgres:postgres@postgres:5432/myapp_test runner bin/rails db:prepare
docker compose run --rm -e RAILS_ENV=test -e DATABASE_URL=postgres://postgres:postgres@postgres:5432/myapp_test runner bundle exec rspec
```

現在のRSpecは30件です。Google APIの応答はテスト内で模擬し、取得情報の表示、保存済み情報へのフォールバック、DBにGoogle由来の詳細情報を保存しないこと、署名付き写真URLのリダイレクトなどを検証しています。

実ブラウザでは主要7画面をPC幅・スマホ幅（390px・320px）で確認しています。本番のヘルスチェック、主要ページと新しいCSSの配信も確認済みです。Google APIとの実通信による評価・写真・地図の表示は、正しいPlace IDとAPI設定を持つ店舗で別途確認が必要です。

## デプロイ

本番と対応するソースは `main` で管理します。機能ブランチで変更し、差分とテスト結果を確認してから `main` に取り込みます。

Fly.ioの設定は `fly.toml` にあります。デプロイ時の `db:prepare` と `/up` のヘルスチェックを利用します。

```bash
flyctl deploy --remote-only -a niborame
```

本番の環境変数はFly.ioのsecretsで設定します。上記の管理者認証情報・問い合わせ先・Google APIキーのほか、Active StorageのTigris用認証情報とbucket名が必要です。ローカルの `.env`、開発ログ、アップロード画像はデプロイイメージに含めません。

## 今後の候補

- 管理画面でPlace IDの設定や取得失敗を確認しやすくする
- 店舗情報の確認日と公式情報へのリンク
- 煮干しメニューの分類基準の明確化
- 必要性を確認した上での独自の口コミ・評価投稿機能
