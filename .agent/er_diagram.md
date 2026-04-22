erDiagram
users ||--o{ recipes : "作成する"
users ||--o{ bookmarks : "保存する"

    recipes ||--|{ recipe_herbs : "配合する"
    herbs ||--o{ recipe_herbs : "材料となる"

    recipes ||--o| drinking_logs : "飲用後の感想（STEP 2）"

    recipes }o--o{ flavor_tags : "分類する(風味)"
    recipes }o--o{ functional_tags : "分類する(効能)"

    recipes ||--o{ bookmarks : "お気に入り登録される"

    users {
        bigint id PK
        string name "ユーザー名"
        string email "メールアドレス (Unique)"
        string encrypted_password "暗号化パスワード"
        datetime created_at
    }

    recipes {
        bigint id PK
        bigint user_id FK
        string title "レシピ名"
        date brewed_at "作成日"
        integer amount "抽出量(200ml基準)"
        text memo "淹れる前のメモ"
        boolean is_public "公開設定"
        datetime created_at
    }

    recipe_herbs {
        bigint id PK
        bigint recipe_id FK
        bigint herb_id FK
        float quantity "配合量"
        integer unit "単位(0:g, 1:小さじ, 2:枚, 3:個...)"
    }

    herbs {
        bigint id PK
        string name "ハーブ名"
        text description "説明"
        string image "画像URL"
        text caution "禁忌"
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
        text impression "感想・味のメモ"
        datetime created_at
    }

    flavor_tags {
        bigint id PK
        string name "タグ名"
    }

    functional_tags {
        bigint id PK
        string name "タグ名"
    }

    bookmarks {
        bigint id PK
        bigint user_id FK
        bigint recipe_id FK
    }
