require "rails_helper"

RSpec.describe "Recipes", type: :request do
  let(:user) { create(:user) }
  let(:other) { create(:user) }
  let(:herb) { create(:herb) }

  describe "GET /recipes" do
    it "未ログインでも一覧が表示される" do
      create(:recipe, :public, title: "公開ブレンド")
      get recipes_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("公開ブレンド")
    end

    it "非公開レシピは一覧に表示されない" do
      create(:recipe, title: "非公開ブレンド")
      get recipes_path
      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("非公開ブレンド")
    end
  end

  describe "GET /recipes/:id" do
    context "未ログインの場合" do
      it "公開レシピは表示される" do
        recipe = create(:recipe, :public)
        get recipe_path(recipe)
        expect(response).to have_http_status(:ok)
      end

      it "非公開レシピは 404 になる" do
        recipe = create(:recipe)
        get recipe_path(recipe)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "ログイン済みの場合" do
      before { sign_in user }

      it "自分の非公開レシピは表示される" do
        recipe = create(:recipe, user: user)
        get recipe_path(recipe)
        expect(response).to have_http_status(:ok)
      end

      it "他人の公開レシピは表示される" do
        recipe = create(:recipe, :public, user: other)
        get recipe_path(recipe)
        expect(response).to have_http_status(:ok)
      end

      it "他人の非公開レシピは 404 になる" do
        recipe = create(:recipe, user: other)
        get recipe_path(recipe)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /recipes/new" do
    it "ログイン済みなら作成画面が表示される" do
      sign_in user
      get new_recipe_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /recipes" do
    before { sign_in user }

    let(:valid_params) do
      {
        recipe: {
          title: "おやすみブレンド",
          brewed_at: "2026-10-01",
          recipe_herbs_attributes: {
            "0" => { herb_id: herb.id, quantity: 2, unit: "g" }
          }
        }
      }
    end

    # 2-Step Flow: STEP 1（配合）を保存したら STEP 2（感想入力）へ進む
    it "レシピと配合ハーブを保存し、感想入力画面へリダイレクトする" do
      expect {
        post recipes_path, params: valid_params
      }.to change(Recipe, :count).by(1).and change(RecipeHerb, :count).by(1)

      recipe = Recipe.find_by!(title: "おやすみブレンド")
      expect(recipe.user).to eq user
      expect(recipe.drinking_log).to be_nil
      expect(response).to redirect_to(new_recipe_drinking_log_path(recipe))
    end

    it "title がないと保存されず、フォームを再表示する" do
      invalid_params = valid_params.deep_merge(recipe: { title: "" })

      expect {
        post recipes_path, params: invalid_params
      }.not_to change(Recipe, :count)

      expect(response).to have_http_status(422)
    end
  end

  describe "GET /recipes/:id/edit" do
    before { sign_in user }

    it "自分のレシピなら編集画面が表示される" do
      recipe = create(:recipe, user: user)
      get edit_recipe_path(recipe)
      expect(response).to have_http_status(:ok)
    end

    it "他人のレシピは公開されていても 404 になる" do
      recipe = create(:recipe, :public, user: other)
      get edit_recipe_path(recipe)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /recipes/:id" do
    before { sign_in user }

    it "自分のレシピを更新し、詳細画面へリダイレクトする" do
      recipe = create(:recipe, user: user, title: "変更前")
      patch recipe_path(recipe), params: { recipe: { title: "変更後" } }

      expect(response).to redirect_to(recipe_path(recipe))
      expect(recipe.reload.title).to eq "変更後"
    end

    it "title を空にすると更新されず、フォームを再表示する" do
      recipe = create(:recipe, user: user, title: "変更前")
      patch recipe_path(recipe), params: { recipe: { title: "" } }

      expect(response).to have_http_status(422)
      expect(recipe.reload.title).to eq "変更前"
    end

    it "他人のレシピは更新できず 404 になる" do
      recipe = create(:recipe, :public, user: other, title: "変更前")
      patch recipe_path(recipe), params: { recipe: { title: "変更後" } }

      expect(response).to have_http_status(:not_found)
      expect(recipe.reload.title).to eq "変更前"
    end
  end

  describe "DELETE /recipes/:id" do
    before { sign_in user }

    it "自分のレシピを削除し、ホームへリダイレクトする" do
      recipe = create(:recipe, user: user)

      expect {
        delete recipe_path(recipe)
      }.to change(Recipe, :count).by(-1)

      expect(response).to redirect_to(home_path)
    end

    it "他人のレシピは削除できず 404 になる" do
      recipe = create(:recipe, :public, user: other)

      expect {
        delete recipe_path(recipe)
      }.not_to change(Recipe, :count)

      expect(response).to have_http_status(:not_found)
    end
  end
end
