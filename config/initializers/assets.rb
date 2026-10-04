# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# sassc-rails（rails_admin 用）が CSS 圧縮を Sass に差し替えるため無効化する。
# Tailwind のビルド済み CSS は Sass では処理できず、構文エラーになる。
Rails.application.config.assets.css_compressor = nil

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w[ admin.js admin.css ]
