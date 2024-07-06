# ベースイメージを指定
FROM ruby:3.3-slim-bullseye

# パッケージのインストール
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libvips pkg-config curl && \
    curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn

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

# Yarnのインストールとプリコンパイルの実行
RUN yarn install --check-files
RUN bundle exec rails assets:precompile

# Dockerイメージのエントリーポイントを指定
ENTRYPOINT ["./entrypoint.sh"]

# サービスを実行するポートを指定
EXPOSE 3000

# デフォルトコマンドを指定
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]