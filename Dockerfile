# ベースイメージを指定
FROM ruby:3.3-slim-bullseye

# パッケージのインストール
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libvips pkg-config

# Bundlerの特定バージョンをインストール
RUN gem install bundler -v '2.5.6'

# アプリケーションディレクトリを作成
RUN mkdir /app
WORKDIR /app

# GemfileとGemfile.lockをコピー
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

# Bundle installの実行
RUN bundle install

# アプリケーションのソースをコピー
COPY . /app

# Dockerイメージのエントリーポイントを指定
ENTRYPOINT ["./entrypoint.sh"]

# サービスを実行するポートを指定
EXPOSE 3000
