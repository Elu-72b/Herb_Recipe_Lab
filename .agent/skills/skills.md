# SKILLS.md — Herb Recipe Lab / Claude Code スキルガイド

> このファイルは「どう実装するか」の判断基準をまとめたものです。
> `CLAUDE.md` のルールを前提としています。

---

## SKILL 01｜2段階保存フローの実装

### これは何？

レシピを「配合（STEP 1）」と「飲用後の感想（STEP 2）」の2回に分けて保存する仕組みです。
料理に例えると「レシピカードを書く」→「実際に作って感想を書き足す」イメージです。

### テーブル設計の考え方

```
recipes テーブル
  - title       : レシピ名
  - brewed_at   : 作成日
  - status      : "step1_saved" | "step2_saved"（どちらまで記録したか）
  - user_id     : 作成者

drinking_logs テーブル（STEP 2 の感想を別テーブルで管理）
  - recipe_id   : どのレシピの感想か
  - comment     : 感想テキスト
  - rated_at    : 飲んだ日時
```

### Controller の書き方

```ruby
# recipes_controller.rb

# STEP 1: 配合を保存
def create
  @recipe = current_user.recipes.new(recipe_params)
  if @recipe.save
    redirect_to edit_recipe_path(@recipe), notice: "STEP 1 を保存しました。次は感想を記録しましょう！"
  else
    render :new, status: :unprocessable_entity
  end
end

# STEP 2: 感想を追記（別アクション or DrinkingLogsController に切り出す）
def add_log
  @recipe = current_user.recipes.find(params[:id])
  @log = @recipe.drinking_logs.new(log_params)
  if @log.save
    redirect_to @recipe, notice: "飲用記録を保存しました！"
  else
    render :edit, status: :unprocessable_entity
  end
end
```

---

## SKILL 02｜単位切り替え（g ↔ 小さじ）

### これは何？

1つのハーブの分量を「g」と「小さじ（tsp）」で切り替えられる機能です。

### DB の持ち方

```ruby
# recipe_herbs テーブル
# - amount  : decimal（数値）
# - unit    : string  "g" または "tsp"
```

### Stimulus でのUI切り替え（JavaScript）

```javascript
// app/javascript/controllers/unit_toggle_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["select", "label"];

  toggle() {
    const unit = this.selectTarget.value; // "g" or "tsp"
    this.labelTarget.textContent = unit;
  }
}
```

```html
<!-- View での使用例 -->
<div data-controller="unit-toggle">
  <input type="number" name="recipe_herb[amount]" />
  <select
    data-unit-toggle-target="select"
    data-action="change->unit-toggle#toggle"
  >
    <option value="g">g</option>
    <option value="tsp">小さじ</option>
  </select>
  <span data-unit-toggle-target="label">g</span>
</div>
```

---

## SKILL 03｜ハーブ辞典の Turbo Stream 非同期表示

### これは何？

レシピ入力画面から **ページ遷移なしで** ハーブの詳細情報を表示する機能です。
図書館でレシピを書きながら、隣の辞書をパッと引くようなイメージです。

### 実装の流れ

1. レシピ入力画面にハーブ名のリンクを置く
2. クリックで Turbo Stream リクエストを送信
3. サイドパネルの HTML だけを差し替える

```ruby
# herbs_controller.rb
def show
  @herb = Herb.find(params[:id])

  respond_to do |format|
    format.html         # 通常のページ表示
    format.turbo_stream # サイドパネルだけ更新
  end
end
```

```erb
<%# app/views/herbs/show.turbo_stream.erb %>
<%= turbo_stream.replace "herb-detail-panel" do %>
  <%= render "herbs/detail", herb: @herb %>
<% end %>
```

```erb
<%# レイアウト側に差し替え先を用意 %>
<div id="herb-detail-panel">
  <%# ここがTurboで書き換わる %>
</div>
```

---

## SKILL 04｜Ransack を使ったレシピ検索

### これは何？

「使っているハーブ」「風味」「効能」などで絞り込み検索ができる機能です。
Ransack は Rails 用の検索ライブラリで、検索フォームをシンプルに書けます。

### 基本パターン

```ruby
# recipes_controller.rb
def index
  @q = Recipe.ransack(params[:q])
  @recipes = @q.result(distinct: true).includes(:herbs).page(params[:page])
end
```

```erb
<%# views/recipes/index.html.erb %>
<%= search_form_for @q do |f| %>
  <%= f.label :title_cont, "タイトル" %>
  <%= f.search_field :title_cont, placeholder: "例: カモミール" %>

  <%= f.submit "検索" %>
<% end %>
```

### 検索キーの命名ルール（Ransack）

| キー末尾 | 意味                   | 例                |
| -------- | ---------------------- | ----------------- |
| `_cont`  | 部分一致（LIKE検索）   | `title_cont`      |
| `_eq`    | 完全一致               | `status_eq`       |
| `_in`    | 複数値のいずれかに一致 | `flavor_in`       |
| `_gteq`  | 以上                   | `created_at_gteq` |

---

## SKILL 05｜Gemini API 連携（ブレンド提案）

### これは何？

手持ちのハーブを渡すと、AIがブレンドの組み合わせを提案してくれる機能です。

### Service オブジェクトとして切り出す

複雑な外部API処理は Controller に書かず、`app/services/` に独立したクラスを作ります。

```ruby
# app/services/gemini_blend_suggestion_service.rb
class GeminiBlendSuggestionService
  def initialize(herb_names)
    @herb_names = herb_names
  end

  def call
    prompt = build_prompt
    response = call_gemini_api(prompt)
    parse_response(response)
  end

  private

  def build_prompt
    "以下のハーブからおすすめのブレンドを3つ提案してください。\n" \
    "ハーブ: #{@herb_names.join(', ')}\n" \
    "出力形式: ブレンド名、配合比、期待できる効果"
  end

  def call_gemini_api(prompt)
    # Gemini API への HTTP リクエスト（実装時に詳細を追加）
  end

  def parse_response(response)
    # レスポンスのパース処理
  end
end
```

```ruby
# Controller からの呼び出し方
def suggest
  herb_names = current_user.herbs.pluck(:name)
  @suggestions = GeminiBlendSuggestionService.new(herb_names).call
end
```

---

## SKILL 06｜Devise 認証の基本

### 主なヘルパーメソッド

```ruby
current_user          # ログイン中のユーザーオブジェクト
user_signed_in?       # ログインしているか（true/false）
authenticate_user!    # ログインしていなければリダイレクト（before_action で使う）
```

### Controller での使い方

```ruby
class RecipesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  # index と show は未ログインでも見られる。それ以外はログインが必要。

  def create
    @recipe = current_user.recipes.new(recipe_params)
    # ...
  end
end
```

---

## SKILL 07｜テストの書き方（RSpec）

### モデルのテスト例

```ruby
# spec/models/recipe_spec.rb
RSpec.describe Recipe, type: :model do
  describe "バリデーション" do
    it "タイトルがないと無効" do
      recipe = build(:recipe, title: nil)
      expect(recipe).not_to be_valid
    end

    it "タイトルがあれば有効" do
      recipe = build(:recipe)
      expect(recipe).to be_valid
    end
  end
end
```

### テスト実行コマンド

```bash
# 全テスト
docker compose exec web bundle exec rspec

# 特定ファイル
docker compose exec web bundle exec rspec spec/models/recipe_spec.rb

# 特定の行
docker compose exec web bundle exec rspec spec/models/recipe_spec.rb:10
```

---

## スキルの追加方法

新しい実装パターンが確立したら、このファイルに `## SKILL XX｜タイトル` の形式で追記してください。
「何のためのスキルか」を冒頭の「これは何？」に必ず書くようにしてください。
