# 🌿 Herb Recipe Lab

**ハーブティーの「配合」から「感想」まで、試行錯誤を再現可能なレシピとして資産化する研究・記録アプリ。**

![Ruby](https://img.shields.io/badge/Ruby-3.4-CC342D?logo=ruby&logoColor=white&style=for-the-badge)
![Rails](https://img.shields.io/badge/Rails-8.1-CC0000?logo=rubyonrails&logoColor=white&style=for-the-badge)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?logo=postgresql&logoColor=white&style=for-the-badge)
![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white&style=for-the-badge)
![TailwindCSS](https://img.shields.io/badge/Tailwind_CSS-v4-38B2AC?logo=tailwindcss&logoColor=white&style=for-the-badge)
![Hotwire](https://img.shields.io/badge/Hotwire-Turbo_/_Stimulus-5cb85c?style=for-the-badge)
![Render](https://img.shields.io/badge/Render-Deploy-46E3B7?logo=render&logoColor=white&style=for-the-badge)
![Neon](https://img.shields.io/badge/Neon-Postgres-00E599?logo=neon&logoColor=white&style=for-the-badge)

🔗 **サービスURL** : https://herb-recipe-lab.com

> 📝 **ログイン不要で体験できます。** 公開レシピ・ハーブ図鑑は新規登録なしで閲覧可能です。レシピ投稿・ブックマーク・市販ハーブティーレビュー・AI ブレンド提案などはログインが必要で、操作時にログインへ誘導します。

---

## 📖 目次

- [🌱 サービス概要](#-サービス概要)
- [✨ 主な機能](#-主な機能)
- [🛠 技術スタック](#-技術スタック)
- [💡 工夫した点・技術的チャレンジ](#-工夫した点技術的チャレンジ)
- [🔀 画面遷移図](#-画面遷移図)
- [🚀 開発環境セットアップ](#-開発環境セットアップ)
- [📅 今後の実装予定](#-今後の実装予定)

---

## 🌱 サービス概要

**Herb Recipe Lab** は、ハーブティーのブレンドレシピを記録・整理・共有できるアプリです。

「美味しかった配合を忘れてしまう」「苦手だったブレンドをまた作ってしまう」——そんなハーブブレンドの試行錯誤を、**「配合（STEP 1）」→「飲用後の感想（STEP 2）」の2段階で記録**することで、"あの一杯" を再現可能なレシピとして蓄積できます。味の好みや手持ちのハーブからレシピを検索でき、自分だけのハーブデータベースを育てられるのが特徴です。
既存のレシピサービスでは、ハーブ特有の「効能」や「配合比」を管理しにくく、手持ちのハーブや苦手な成分から探すこともできません。Herb Recipe Lab は **味の好みで探す・苦手/禁忌を除外して探す** ことに特化し、「購買」ではなく「研究（記録）」のためのアプリを目指しています。

---

## ✨ 主な機能

### 実装済み機能

<!-- prettier-ignore -->
| 機能 | 説明 |
| --- | --- |
| ユーザー認証 | Devise によるメール登録 / ログイン / ログアウト / パスワード再設定。Google アカウントでのログイン / 新規登録（OmniAuth）にも対応。新規登録時に利用規約・プライバシーポリシーへの同意を取得。 |
| ハーブ管理 | 50音順のハーブマスタから選択。マスタにない材料は「その他」として自由入力で追加可能。入力補助のオートコンプリート付き。 |
| **2段階保存によるブレンド記録** | **STEP 1（淹れる前）**: 日付・タイトル・ハーブ配合・分量を記録。**STEP 2（飲用後）**: 実際の味・香りの感想を後から追記。 |
| 単位管理 | 配合量を `小さじ / 大さじ / g / 枚 / 個` から選択して記録（200ml あたりの分量）。 |
| 風味チャート & 5段階評価 | 甘味・苦味・渋味・清涼感・スパイシー・フルーティー・華やかさ・酸味の8要素＋5段階評価で味を客観的に可視化。 |
| タグ管理 | 風味タグ・効能タグ・禁忌タグを独自の中間テーブルで多対多管理。 |
| 多角的レシピ検索 | 使用ハーブ（AND）・風味・効能・苦手ハーブ/禁忌の除外を組み合わせたクロス検索。Stimulus で絞り込みパネルの開閉やハーブ名の入力補助（オートコンプリート）も実装。 |
| 公開 / 非公開設定 | レシピごとに公開設定が可能。公開レシピは未ログインでも閲覧できるタイムラインに表示。 |
| ブックマーク | 気になる公開レシピを保存。 |
| 市販ハーブティーレビュー | 自作レシピだけでなく、既製品の飲用感を商品画像付きで記録（ログイン必須）。 |
| ハーブ図鑑 | ハーブの画像・風味・効能・禁忌・歴史などをまとめた一覧 / 詳細ページ。 |
| レスポンシブUI | スマートフォン / PC 両対応のレイアウト。 |
| プロフィール | 名前・メールアドレスの編集、パスワード変更、退会。自分のレシピはホームの「マイレシピ」タブに集約表示。 |
| AI ブレンド提案 | 効能・風味・避けたい禁忌をチップで選ぶ（＋自由記述）と、条件に合う既存の公開レシピと、Gemini API が生成した新規ブレンド案を併せて表示。Gemini が使えない場合も既存レシピは表示される。 |
| 管理画面 | 管理者のみ `/admin`（RailsAdmin + CanCanCan）からハーブ・タグ・市販ハーブティー・公開レシピ・ユーザーを管理。 |

### 画面と利用条件

<!-- prettier-ignore -->
| 画面 | パス | ログイン |
| --- | --- | --- |
| トップ（ログインフォーム） | `/` | 不要 |
| 公開レシピ一覧 / 詳細 | `/recipes`, `/recipes/:id` | 不要（非公開レシピは本人のみ） |
| ハーブ図鑑 一覧 / 詳細 | `/herbs`, `/herbs/:id` | 不要 |
| 利用規約 / プライバシーポリシー | `/terms`, `/privacy` | 不要 |
| ホーム（公開タイムライン / マイレシピ） | `/home` | 必要 |
| レシピの作成 / 編集 / 削除 | `/recipes/new` ほか | 必要（本人のみ） |
| 飲用後の感想（STEP 2） | `/recipes/:id/drinking_logs/new` ほか | 必要 |
| ブックマーク | `/bookmarks` | 必要 |
| 市販ハーブティーレビュー | `/tea_reviews` | 必要 |
| AI ブレンド提案 | `/recipe_suggestion` | 必要 |
| プロフィール / パスワード変更 / 退会 | `/profile` | 必要 |
| 管理画面 | `/admin` | 管理者のみ |

---

## 🛠 技術スタック

<!-- prettier-ignore -->
| カテゴリ | 使用技術 |
| --- | --- |
| 言語 | Ruby 3.4 |
| フレームワーク | Ruby on Rails 8.1 |
| データベース | PostgreSQL |
| フロントエンド | Hotwire（Turbo / Stimulus）, TailwindCSS 4, daisyUI, jsbundling（esbuild）/ cssbundling |
| 認証 | Devise, OmniAuth（Google OAuth 2.0） |
| 認可・管理画面 | CanCanCan, RailsAdmin |
| 外部API | Gemini API（Faraday で直接呼び出し） |
| 検索 | Ransack |
| ページネーション | Kaminari |
| 非同期処理 | GoodJob（PostgreSQL バックエンド） |
| 画像ストレージ | Active Storage + Cloudinary |
| テスト | Minitest, RSpec（FactoryBot / Faker）, Capybara, Selenium, SimpleCov |
| CI | GitHub Actions（Brakeman / RuboCop / Minitest / RSpec） |
| 開発ツール | RuboCop（rails-omakase）, Brakeman（静的セキュリティ解析）, letter_opener_web |
| インフラ | Docker / Docker Compose, Render（デプロイ）, Neon（マネージドPostgreSQL） |

### 技術選定の理由

- **Ruby on Rails**: 規約による高い開発速度と、個人開発の生産性を重視して採用。
- **Rails 8.1**: 開発当初は情報量の多い 7.2 を採用。7.2 のサポート終了(2026-08)を受け、テストを整備したうえで 8.0 → 8.1 と段階的にアップグレードした。
- **Hotwire（Turbo / Stimulus）**: ページ全体を再読み込みせず、変更があった部分だけをサーバー側のHTMLで差し替えることで、JavaScript を最小限に抑えつつ軽快な操作感を実現するため採用。ブックマークの非同期更新（Turbo Stream）や、検索欄の開閉・タグ入力などのリッチなフォーム操作（Stimulus）で活用。
- **PostgreSQL + GoodJob**: メール送信などの時間のかかる処理を将来的にバックグラウンド化するための基盤として、ジョブ管理に GoodJob を採用。ジョブの状態を PostgreSQL に保存するため、別途 Redis のようなミドルウェアを用意せずに済み、構成をシンプルに保てる。
- **Cloudinary**: Render の永続ストレージ制約を回避し、画像配信を外部化。
- **Neon**: 本番DBにサーバーレスの PostgreSQL（Neon）を採用し、DB の運用・スケーリングをマネージドに任せている。
- **Gemini API**: 手持ちのハーブ・好みから新規ブレンドを提案する機能に採用。無料枠で扱いやすく、JSON Schema 指定の構造化出力が使えるため。
- **OmniAuth（Google）**: 新規登録の手間を減らし、離脱を抑えるため採用。
- **RailsAdmin + CanCanCan**: マスタデータ（ハーブ・タグ）の運用を管理画面で行うため。権限を CanCanCan で一元管理している。

---

## 💡 工夫した点・技術的チャレンジ

- **2段階保存フローの設計**: 「配合（`recipes`）」と「飲用後の感想（`drinking_logs`）」を別アクション・別テーブルで保存。淹れる前と後で記録タイミングが異なる、という実体験に即したデータモデルを設計した。
- **単位の enum 管理**: `recipe_herbs.unit`（小さじ / 大さじ / g / 枚 / 個）を enum で管理し、「200ml あたりの分量」として統一して記録できるようにした。
- **検索ロジックの集約**: Ransack に加え、使用ハーブ AND・風味・効能・禁忌除外のクロス検索を `ApplicationController#apply_herb_based_filters` に集約。コントローラを薄く保ちつつ、レシピ・市販レビュー双方で再利用している。
- **N+1 対策の徹底**: 一覧取得では `includes(:user, :drinking_log, recipe_herbs: :herb)` を用い、関連先のクエリ発行を抑制。
- **Hotwire によるUX改善**: ブックマークの追加 / 解除を Turbo Stream でページ遷移なしに反映。検索欄の絞り込みパネル開閉、配合行の動的追加、タグ入力、画像プレビューなどを Stimulus コントローラで実装し、入力中のコンテキストを保ったまま操作できるようにした。
- **Cloudinary + ActiveStorage による画像保存** とバリアント生成。
- **ログイン不要の閲覧導線**: 公開レシピ・ハーブ図鑑は未ログインで閲覧可能にし、投稿・保存などの操作時にのみログインへ誘導することで、新規ユーザーの離脱を抑える設計にした。
- **AI ブレンド提案の耐障害設計**: 既存レシピ検索（`RecipeSuggestion::Finder`、DB 由来）と Gemini による生成（`Generator`）を分離。Generator は例外を投げずエラーを値で返すため、Gemini が落ちても既存レシピの検索結果は表示される。応答は Structured Output（JSON Schema）で形を固定し、生成された提案は DB 上のハーブと照合（sanitize）して実在しないハーブを除外している。
- **Gemini API の安全な呼び出し**: 専用 gem は使わず Faraday で薄くラップ。API キーは URL クエリではなくヘッダ（`x-goog-api-key`）で送り、ログへの漏洩を防いでいる。モデルは応答時間を実測して選定し、環境変数で差し替え可能。

---

## 🔀 画面遷移図

[Herb Recipe Lab\_画面遷移図（Figma）](https://www.figma.com/design/E3mrzaweJAsVvJkzc73dIC/Herb-Recipe-Lab_%E7%94%BB%E9%9D%A2%E9%81%B7%E7%A7%BB%E5%9B%B3?node-id=0-1&p=f&t=VGqqywNLFX1MHnwZ-0)

---

## 🚀 開発環境セットアップ

本プロジェクトは Docker 上で動作します。

```bash
# 1. リポジトリをクローン
git clone https://github.com/Elu-72b/Herb_Recipe_Lab.git
cd Herb_Recipe_Lab

# 2. 環境変数ファイルを用意（.env.example をコピーして値を設定）
cp .env.example .env

# 3. コンテナをビルド
docker compose build

# 4. データベースを作成・マイグレーション・初期データ投入
docker compose run --rm web bin/rails db:create db:migrate db:seed

# 5. コンテナを起動
docker compose up
```

> `.env` には Cloudinary（画像保存）・メール送信・Google ログイン・Gemini API に必要なキーを設定します。各キーの一覧は `.env.example` を参照してください。

起動後、ブラウザで http://localhost:3000 にアクセスします。

```bash
# よく使うコマンド（すべて docker compose exec web 経由）
docker compose exec web bin/rails test              # テスト実行（Minitest）
docker compose exec web bundle exec rspec           # テスト実行（RSpec）
docker compose exec web bin/rails db:migrate        # マイグレーション
docker compose exec web yarn build:css              # CSS ビルド
docker compose exec web bin/rails console           # コンソール
```

開発環境では gem `letter_opener_web` により `/letter_opener` で送信メールをブラウザ確認できます。

---

## 📅 今後の実装予定

- **ハーブ図鑑の非同期表示** — レシピ入力画面を離れずに、Turbo Frame / Stream でハーブ情報を非同期表示する（現状は別ページでの閲覧）。
- **コミュニティ機能の拡充** — ユーザー間のフォロー、好みの近いユーザーとのマッチング。
- **味のマッピング / 香りチャートの可視化強化**。
- **ハーブの用途コラム投稿機能**。
