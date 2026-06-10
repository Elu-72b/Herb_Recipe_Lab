source "https://rubygems.org"

# フレームワーク
gem "rails", "~> 7.2.3", ">= 7.2.3.1"

# データベース
gem "pg", "~> 1.1"

# Webサーバー
gem "puma", ">= 5.0"

# アセットパイプライン
gem "sprockets-rails"

# JavaScript バンドル
gem "jsbundling-rails"

# Hotwire - ページ高速化（Turbo）
gem "turbo-rails"

# Hotwire - 軽量 JS フレームワーク（Stimulus）
gem "stimulus-rails"

# CSS バンドル
gem "cssbundling-rails"

# TailwindCSS
gem "tailwindcss-rails", "~> 4.4"

# ログイン認証
gem "devise", "~> 4.9"

# ページネーション
gem "kaminari", "~> 1.2"

# 検索機能
gem "ransack"

# 非同期ジョブ（PostgreSQL バックエンド）
gem "good_job"

# 画像ストレージ（Cloudinary）
gem "cloudinary", "~> 2.0"
gem "activestorage-cloudinary-service"

# 画像処理（Active Storage バリアント）
gem "image_processing", "~> 1.2"

# Active Storage バリデーション
gem "active_storage_validations"

# 起動時間の短縮キャッシュ
gem "bootsnap", require: false

# タイムゾーンデータ（Windows 向け）
gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development do
  # デバッグコンソール
  gem "web-console"

  # 開発環境でのメール確認（ブラウザ表示）
  gem "letter_opener_web"
end

group :development, :test do
  # デバッガー
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # セキュリティ静的解析
  gem "brakeman", require: false

  # Ruby スタイルガイド（Rails 公式）
  gem "rubocop-rails-omakase", require: false

  # 環境変数管理（.env ファイル読み込み）
  gem "dotenv-rails"
end

group :test do
  # システムテスト
  gem "capybara"
  gem "selenium-webdriver"
end