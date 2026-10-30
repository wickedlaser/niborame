# 煮干しラーメン店検索アプリ

関西を中心に、煮干しラーメンを食べられる店を探すためのポートフォリオアプリです。まずは作者が知っている店舗の情報を掲載し、味のジャンルや紹介文から店を探せることを目指しています。

公開アプリ: https://niborame.fly.dev/

## 現在の機能

- 店舗一覧とトップページの表示
- 登録済み店舗のジャンル絞り込み
- 店名・住所のキーワード検索とジャンル絞り込みの併用
- 店舗詳細（紹介文、住所、営業時間、画像）の表示
- 管理者画面からの店舗画像アップロード（JPEG、PNG、WebP、GIF、5MBまで）
- Place IDが設定された店舗の営業時間・住所・位置を、詳細表示時にPlaces APIから取得
- 保存済みの緯度・経度とGoogle Maps APIキーがある場合の地図表示
- 地図情報がない場合は、住所からGoogleマップを開くリンクを表示
- お問い合わせフォーム（入力内容をメールアプリで送信）

店舗情報はPostgreSQLの `ramen_shops` テーブルに保存します。初期データは `db/seeds.rb` で管理し、初期データの投入にGoogle APIキーは不要です。管理画面でGoogle Place IDを設定すると、詳細ページを開くたびにPlaces APIから営業時間・住所・位置を取得して表示します。APIから取得した情報はDBへ保存しません。

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

地図を埋め込む場合は `.env` に `GOOGLE_MAPS_API_KEY` を設定してください。Place IDから情報を取得するにはGoogle CloudでPlaces API (New)を有効にし、課金設定のあるプロジェクトのキーを `GOOGLE_PLACES_API_KEY` に設定してください。Place Detailsの利用量に応じた料金が発生する場合があります。フォーム送信先は `CONTACT_EMAIL` に設定します。Fly.ioでは必要な値をそれぞれアプリのsecretとして設定してください。フォーム送信後は利用者のメールアプリが開き、利用者が内容を確認して送信します。利用規約 (`/terms`) とプライバシーポリシー (`/privacy`) を公開しています。公開前に運営者情報などの記載内容を確認してください。Google Maps PlatformのAPIキーには、利用APIと利用元に応じた制限を設定してください。

緯度・経度が未登録、または地図キーが未設定の場合は住所からGoogleマップを開くリンクを表示します。

## 店舗データを変更する

店舗の初期データは `db/seeds.rb` にあります。店舗を追加・編集した後、次を実行するとデータベースへ反映できます。

```bash
docker compose exec runner bin/rails db:seed
```

シードは店舗名をキーに、未登録の店舗だけを追加します。登録済み店舗の情報は上書きしません。Google Place IDがある店舗は、詳細ページ表示時に営業時間・住所・位置を取得します。Place IDがない店舗では手入力の営業時間・住所を表示できます。

管理画面では、管理者ログイン後に店舗情報の追加・編集・削除ができます。ローカルでは `.env` に `ADMIN_USERNAME` と `ADMIN_PASSWORD` を設定してComposeを再起動し、`http://localhost:3000/admin/login` にアクセスしてください。Fly.ioではこれらをアプリのsecretとして設定します。管理者アカウントの自己登録機能はありません。

## テスト

```bash
docker compose run --rm -e RAILS_ENV=test -e DATABASE_URL=postgres://postgres:postgres@postgres:5432/myapp_test runner bin/rails db:prepare
docker compose run --rm -e RAILS_ENV=test -e DATABASE_URL=postgres://postgres:postgres@postgres:5432/myapp_test runner bundle exec rspec
```

## デプロイ

Fly.ioの設定は `fly.toml` にあります。リリース時に `db:prepare` を実行し、アプリの稼働確認には `/up` を使用します。本番では管理者認証用の `ADMIN_USERNAME`・`ADMIN_PASSWORD`、問い合わせ用の `CONTACT_EMAIL`、利用する場合は `GOOGLE_MAPS_API_KEY`・`GOOGLE_PLACES_API_KEY` をFly.io secretsに設定します。Active StorageのTigris用認証情報とbucket名も必要です。

## 今後の候補

- 店舗情報の確認日と公式情報へのリンク
- 煮干しメニューの分類基準の明確化
- 必要性を確認した上での口コミ、評価機能
