RailsAdmin.config do |config|
  config.asset_source = :sprockets

  # 画面上部とブラウザのタブに表示するアプリ名
  config.main_app_name = [ "Herb Recipe Lab", "Admin" ]

  # ApplicationController を継承させ、rescue_from CanCan::AccessDenied を /admin にも効かせる
  config.parent_controller = "::ApplicationController"

  # Devise 連携（未ログインはログイン画面へ）
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  # 認可は cancancan の Ability に委譲
  config.authorize_with :cancancan

  # bulk_delete は誤操作防止のため含めない。
  # history_* は監査アダプタ（paper_trail 等）が無いと動かないため含めない。
  config.actions do
    dashboard
    index
    new
    export
    show
    edit
    delete
  end

  # 管理画面に出すモデルを明示する（空配列だと全モデルが対象になるため、必ず列挙する）。
  # DrinkingLog・Bookmark・中間テーブル・GoodJob は含めない。
  # #102 では Herb とタグ 3 種のみ、#103 で User・Recipe・TeaReview を追加する。
  config.included_models = %w[Herb FlavorTag FunctionalTag CautionTag User Recipe TeaReview]

  config.model "Herb" do
    navigation_label "マスタ管理"

    # 画像はサムネイルのみ表示する（rails_admin 標準の表示）
    configure :image, :active_storage do
      label "画像"
    end

    # カラムを持たない仮想項目。添付画像のファイル名を表示する
    configure :image_filename, :string do
      label "ファイル名"
      formatted_value do
        image = bindings[:object].image
        image.filename.to_s if image.attached?
      end
      sortable false
      filterable false
      searchable false
    end

    list do
      field(:id) { sticky true }
      field(:name) { sticky true }
      field :alias_name
      field :image
      field :image_filename
      field :updated_at
    end
    show do
      field :name
      field :alias_name
      field :image
      field :image_filename
      field :description
      field :active_ingredients
      field :flavor_description
      field :effect_description
      field :caution_description
      field :caution
      field :history
      field :flavor_tags
      field :functional_tags
      field :caution_tags
      field :updated_at
    end
    edit do
      field :name
      field :alias_name
      field :description
      field :active_ingredients
      field :flavor_description
      field :effect_description
      field :caution_description
      field :caution
      field :history
      # 旧 string 列 image と区別するため、添付として型を明示する
      field :image
      field :flavor_tags
      field :functional_tags
      field :caution_tags
    end
    export do
      field :id
      field :name
      field :alias_name
      field :description
    end
  end

  %w[FlavorTag CautionTag].each do |model_name|
    config.model model_name do
      navigation_label "マスタ管理"
      list do
        field(:id) { sticky true }
        field(:name) { sticky true }
        field :created_at
        field :updated_at
      end
    end
  end

  config.model "FunctionalTag" do
    navigation_label "マスタ管理"
    list do
      field(:id) { sticky true }
      field(:name) { sticky true }
      # カラムではなくメソッドのため、並べ替え・絞り込み・検索の対象外にする
      field :category, :string do
        label "分類"
        sortable false
        filterable false
        searchable false
      end
      field :created_at
      field :updated_at
    end
  end

  config.model "User" do
    navigation_label "ユーザー管理"
      list do
        field(:id) { sticky true }
        field(:name) { sticky true }
        field(:email) { sticky true }
        field :admin
        field :created_at
        field :updated_at
    end
    show do
      field :id
      field :name
      field :email
      field :admin
      field :provider
      field :created_at
      field :recipes
      field :tea_reviews
    end
    edit do
      field :admin   # メール・パスワード・名前は編集させない
    end
    export do
      field :id
      field :name
      field :admin
      field :created_at   # email・認証系カラムは出力しない
    end
  end

  config.model "Recipe" do
    navigation_label "投稿管理"
    label "公開ブレンドレシピ"
    list do
      field(:id) { sticky true }
      field(:title) { sticky true }
      field :user
      field :is_public
      field :created_at
      field :updated_at
    end
    show do
      field :title
      field :user
      field :brewed_at
      field :herbs   # RecipeHerb は管理対象外のため、配合ハーブ名を表示する
      field :memo
      field :is_public
    end
    edit do
      field :is_public   # 非公開化のみ
    end
  end

  config.model "TeaReview" do
    navigation_label "投稿管理"
    label "既製ブレンド"
    # belongs_to :herb は対応する herb_id カラムが無く、自動検出されるとエラーになるため隠す
    configure :herb do
      hide
    end
    # 配列カラムは rails_admin で正しく表示できないため隠す
    configure :custom_herb_names do
      hide
    end
    list do
      field(:id) { sticky true }
      field(:name) { sticky true }
      field :brand
      field :user
      field :rating
      field :created_at
      field :updated_at
    end
    edit do
      field :user do
        visible { bindings[:object].new_record? }   # 新規作成時のみ投稿者を選択可能にする
      end
      field :rating do
        visible { bindings[:object].new_record? }   # 必須項目のため新規作成時のみ入力させる
      end
      field :brand
      field :name
      field :purchase_place
      field :description
      field :image   # tea_reviews には旧 string 列が無いため型の明示は不要（自動で active_storage と判定される）
      field :herbs
      # impression / rating / 味覚チャート系は投稿者の感想なので編集させない
    end
  end
end
