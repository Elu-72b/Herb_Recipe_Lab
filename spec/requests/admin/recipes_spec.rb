require "rails_helper"

# 公開ブレンドレシピ管理（閲覧・削除・非公開化のみ。非公開レシピは対象外）
RSpec.describe "管理画面の公開ブレンドレシピ管理", type: :request do
  let(:admin) { create(:user, :admin) }
  let!(:public_recipe) { create(:recipe, :public, title: "公開ブレンド") }
  let!(:private_recipe) { create(:recipe, title: "非公開ブレンド") }

  before { sign_in admin }

  it "一覧に公開レシピのみ表示される" do
    get rails_admin.index_path(model_name: "recipe")
    expect(response.body).to include("公開ブレンド")
    expect(response.body).not_to include("非公開ブレンド")
  end

  it "非公開レシピの詳細には到達できない" do
    top_path = root_path
    get rails_admin.show_path(model_name: "recipe", id: private_recipe.id)
    expect(response).to redirect_to(top_path)
  end

  it "公開レシピを非公開化できる（is_public 以外は変更されない）" do
    put rails_admin.edit_path(model_name: "recipe", id: public_recipe.id),
        params: { recipe: { is_public: "0", title: "改ざん" } }

    public_recipe.reload
    expect(public_recipe.is_public).to be false
    expect(public_recipe.title).to eq "公開ブレンド"
  end

  it "非公開レシピを公開にはできない" do
    put rails_admin.edit_path(model_name: "recipe", id: private_recipe.id), params: { recipe: { is_public: "1" } }
    expect(private_recipe.reload.is_public).to be false
  end

  it "公開レシピを削除すると、感想（DrinkingLog）も削除される" do
    create(:drinking_log, recipe: public_recipe)
    expect {
      delete rails_admin.delete_path(model_name: "recipe", id: public_recipe.id)
    }.to change(Recipe, :count).by(-1).and change(DrinkingLog, :count).by(-1)
  end

  it "非公開レシピは削除できない" do
    expect {
      delete rails_admin.delete_path(model_name: "recipe", id: private_recipe.id)
    }.not_to change(Recipe, :count)
  end
end
