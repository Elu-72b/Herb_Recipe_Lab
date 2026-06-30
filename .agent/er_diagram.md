erDiagram
    users ||--o{ recipes : "作成する"
    users ||--o{ herbs : "投稿する(任意)"
    users ||--o{ tea_reviews : "投稿する"
    users ||--o{ bookmarks : "保存する"

    recipes ||--o{ recipe_herbs : "配合する"
    herbs   |o--o{ recipe_herbs : "材料となる(任意)"
    recipes ||--o| drinking_logs : "飲用後の感想(STEP2)"
    recipes ||--o{ bookmarks : "登録される"

    recipes ||--o{ flavor_tags_recipes : ""
    flavor_tags ||--o{ flavor_tags_recipes : ""
    recipes ||--o{ functional_tags_recipes : ""
    functional_tags ||--o{ functional_tags_recipes : ""

    herbs ||--o{ herb_flavor_tags : ""
    flavor_tags ||--o{ herb_flavor_tags : ""
    herbs ||--o{ herb_functional_tags : ""
    functional_tags ||--o{ herb_functional_tags : ""
    herbs ||--o{ herb_caution_tags : ""
    caution_tags ||--o{ herb_caution_tags : ""

    tea_reviews ||--o{ tea_review_herbs : "配合する"
    herbs ||--o{ tea_review_herbs : "材料となる"

    users {
        bigint id PK
        string name "ユーザー名"
        string email "メール(Unique)"
        string encrypted_password "暗号化PW"
        string reset_password_token "再設定トークン"
        datetime created_at
    }
    recipes {
        bigint id PK
        bigint user_id FK
        string title "レシピ名"
        date brewed_at "作成日"
        integer amount "抽出量(200ml基準)"
        text memo "淹れる前のメモ"
        boolean is_public "公開設定(default false)"
        datetime created_at
    }
    recipe_herbs {
        bigint id PK
        bigint recipe_id FK
        bigint herb_id FK "任意(nullable)"
        string custom_herb_name "その他の自由入力名"
        float quantity "配合量"
        integer unit "0:小さじ 1:大さじ 2:g 3:枚 4:個"
        datetime created_at
    }
    herbs {
        bigint id PK
        bigint user_id FK "投稿者(任意)"
        string name "ハーブ名"
        string alias_name "別名"
        text description "説明"
        text active_ingredients "有効成分"
        text flavor_description "風味解説"
        text effect_description "効能解説"
        text caution_description "禁忌解説"
        text history "歴史"
        string image "画像(旧列/現ActiveStorage)"
        datetime created_at
    }
    drinking_logs {
        bigint id PK
        bigint recipe_id FK "1対1"
        integer rating "5段階評価"
        integer sweetness "甘味"
        integer bitterness "苦味"
        integer astringency "渋味"
        integer freshness "清涼感"
        integer spicy "スパイシー"
        integer fruity "フルーティー"
        integer flowery "華やかさ"
        integer acidity "酸味"
        text impression "感想"
        datetime created_at
    }
    bookmarks {
        bigint id PK
        bigint user_id FK
        bigint recipe_id FK
        datetime created_at
    }
    flavor_tags {
        bigint id PK
        string name "風味タグ名"
    }
    functional_tags {
        bigint id PK
        string name "効能タグ名"
    }
    caution_tags {
        bigint id PK
        string name "禁忌タグ名"
    }
    flavor_tags_recipes {
        bigint flavor_tag_id FK
        bigint recipe_id FK
    }
    functional_tags_recipes {
        bigint functional_tag_id FK
        bigint recipe_id FK
    }
    herb_flavor_tags {
        bigint id PK
        bigint herb_id FK
        bigint flavor_tag_id FK
    }
    herb_functional_tags {
        bigint id PK
        bigint herb_id FK
        bigint functional_tag_id FK
    }
    herb_caution_tags {
        bigint id PK
        bigint herb_id FK
        bigint caution_tag_id FK
    }
    tea_reviews {
        bigint id PK
        bigint user_id FK
        string brand "ブランド"
        string name "商品名"
        string purchase_place "購入場所"
        text description "説明"
        integer rating "5段階評価"
        integer sweetness "甘味"
        integer acidity "酸味"
        integer bitterness "苦味"
        integer astringency "渋味"
        integer fruity "フルーティー"
        integer spicy "スパイシー"
        integer freshness "清涼感"
        integer flowery "華やかさ"
        text impression "感想"
        string custom_herb_names "自由入力名(配列)"
        datetime created_at
    }
    tea_review_herbs {
        bigint id PK
        bigint tea_review_id FK
        bigint herb_id FK
        string custom_herb_name "その他の自由入力名"
        decimal quantity "配合量"
        string unit "単位(文字列)"
        datetime created_at
    }
