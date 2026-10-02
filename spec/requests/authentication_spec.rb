require "rails_helper"

# ログインが必要なページへ未ログインでアクセスした場合の確認
RSpec.describe "未ログイン時のアクセス制限", type: :request do
  let(:recipe) { create(:recipe, :public) }
  let(:herb) { create(:herb) }

  shared_examples "ログイン画面へリダイレクトする" do
    it "ログイン画面へリダイレクトする" do
      subject
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "レシピ" do
    describe "GET /recipes/new" do
      subject { get new_recipe_path }

      it_behaves_like "ログイン画面へリダイレクトする"
    end

    describe "POST /recipes" do
      subject { post recipes_path, params: { recipe: { title: "テスト", brewed_at: "2026-10-01" } } }

      it_behaves_like "ログイン画面へリダイレクトする"

      it "レシピは作成されない" do
        expect { subject }.not_to change(Recipe, :count)
      end
    end

    describe "GET /recipes/:id/edit" do
      subject { get edit_recipe_path(recipe) }

      it_behaves_like "ログイン画面へリダイレクトする"
    end

    describe "PATCH /recipes/:id" do
      subject { patch recipe_path(recipe), params: { recipe: { title: "変更後" } } }

      it_behaves_like "ログイン画面へリダイレクトする"
    end

    describe "DELETE /recipes/:id" do
      subject { delete recipe_path(recipe) }

      it_behaves_like "ログイン画面へリダイレクトする"

      it "レシピは削除されない" do
        recipe
        expect { subject }.not_to change(Recipe, :count)
      end
    end
  end

  describe "感想" do
    describe "GET /recipes/:recipe_id/drinking_logs/new" do
      subject { get new_recipe_drinking_log_path(recipe) }

      it_behaves_like "ログイン画面へリダイレクトする"
    end

    describe "POST /recipes/:recipe_id/drinking_logs" do
      subject { post recipe_drinking_logs_path(recipe), params: { drinking_log: { rating: 4 } } }

      it_behaves_like "ログイン画面へリダイレクトする"

      it "感想は作成されない" do
        recipe
        expect { subject }.not_to change(DrinkingLog, :count)
      end
    end
  end

  describe "ハーブ図鑑" do
    describe "GET /herbs/new" do
      subject { get new_herb_path }

      it_behaves_like "ログイン画面へリダイレクトする"
    end

    describe "POST /herbs" do
      subject { post herbs_path, params: { herb: { name: "テストハーブ" } } }

      it_behaves_like "ログイン画面へリダイレクトする"

      it "ハーブは登録されない" do
        expect { subject }.not_to change(Herb, :count)
      end
    end

    describe "GET /herbs/:id/edit" do
      subject { get edit_herb_path(herb) }

      it_behaves_like "ログイン画面へリダイレクトする"
    end

    describe "DELETE /herbs/:id" do
      subject { delete herb_path(herb) }

      it_behaves_like "ログイン画面へリダイレクトする"

      it "ハーブは削除されない" do
        herb
        expect { subject }.not_to change(Herb, :count)
      end
    end
  end

  describe "その他のページ" do
    describe "GET /home" do
      subject { get home_path }

      it_behaves_like "ログイン画面へリダイレクトする"
    end

    describe "GET /profile" do
      subject { get profile_path }

      it_behaves_like "ログイン画面へリダイレクトする"
    end

    describe "GET /tea_reviews" do
      subject { get tea_reviews_path }

      it_behaves_like "ログイン画面へリダイレクトする"
    end

    describe "GET /bookmarks" do
      subject { get bookmarks_path }

      it_behaves_like "ログイン画面へリダイレクトする"
    end

    describe "GET /recipe_suggestion" do
      subject { get recipe_suggestion_path }

      it_behaves_like "ログイン画面へリダイレクトする"
    end
  end

  describe "未ログインでも閲覧できるページ" do
    it "トップページが表示される" do
      get root_path
      expect(response).to have_http_status(:ok)
    end

    it "利用規約が表示される" do
      get terms_path
      expect(response).to have_http_status(:ok)
    end

    it "プライバシーポリシーが表示される" do
      get privacy_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "ログイン済みの場合" do
    it "トップページからホームへリダイレクトする" do
      sign_in create(:user)
      get root_path
      expect(response).to redirect_to(home_path)
    end
  end
end
