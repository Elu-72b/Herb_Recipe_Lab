require "rails_helper"

RSpec.describe Recipe, type: :model do
  describe "バリデーション" do
    it "factory のデフォルト値なら有効" do
      recipe = build(:recipe)
      expect(recipe).to be_valid
    end

    it "title がないと無効" do
      recipe = build(:recipe, title: nil)
      expect(recipe).not_to be_valid
      expect(recipe.errors).to be_of_kind(:title, :blank)
    end

    it "brewed_at がないと無効" do
      recipe = build(:recipe, brewed_at: nil)
      expect(recipe).not_to be_valid
      expect(recipe.errors).to be_of_kind(:brewed_at, :blank)
    end

    it "user がないと無効" do
      recipe = build(:recipe, user: nil)
      expect(recipe).not_to be_valid
      expect(recipe.errors).to be_of_kind(:user, :blank)
    end

    # 2-Step Flow: STEP 1（配合）の時点では感想がまだ存在しない
    it "感想（DrinkingLog）がなくても保存できる" do
      recipe = build(:recipe)
      expect(recipe.save).to be true
      expect(recipe.drinking_log).to be_nil
    end
  end

  describe "スコープ" do
    let(:user) { create(:user) }
    let(:other) { create(:user) }
    let!(:own_private) { create(:recipe, user: user) }
    let!(:own_public) { create(:recipe, :public, user: user) }
    let!(:others_private) { create(:recipe, user: other) }
    let!(:others_public) { create(:recipe, :public, user: other) }

    describe ".public_recipes" do
      it "公開レシピだけを返す" do
        expect(Recipe.public_recipes).to contain_exactly(own_public, others_public)
      end
    end

    describe ".visible_to" do
      it "公開レシピと自分の非公開レシピを返し、他人の非公開レシピは返さない" do
        expect(Recipe.visible_to(user)).to contain_exactly(own_private, own_public, others_public)
      end
    end

    describe ".recent" do
      it "作成日時の新しい順に返す" do
        own_private.update!(created_at: 3.days.ago)
        own_public.update!(created_at: 1.day.ago)
        others_private.update!(created_at: 2.days.ago)
        others_public.update!(created_at: 4.days.ago)

        expect(Recipe.recent).to eq [ own_public, others_private, own_private, others_public ]
      end
    end
  end

  describe "配合ハーブのネスト保存" do
    let(:herb) { create(:herb) }

    it "配合行を一緒に保存できる" do
      recipe = build(:recipe, recipe_herbs_attributes: [
        { herb_id: herb.id, quantity: 2, unit: "g" }
      ])

      expect { recipe.save! }.to change(RecipeHerb, :count).by(1)
      expect(recipe.herbs).to contain_exactly(herb)
    end

    it "全項目が空の配合行は無視される" do
      recipe = build(:recipe, recipe_herbs_attributes: [
        { herb_id: herb.id, quantity: 2, unit: "g" },
        { herb_id: "", quantity: "", unit: "", custom_herb_name: "" }
      ])

      expect(recipe).to be_valid
      expect(recipe.recipe_herbs.size).to eq 1
    end

    it "配合行が不正だとレシピも無効" do
      recipe = build(:recipe, recipe_herbs_attributes: [
        { herb_id: herb.id, quantity: 0, unit: "g" }
      ])

      expect(recipe).not_to be_valid
    end

    it "_destroy を指定した配合行は削除される" do
      recipe = create(:recipe)
      recipe_herb = create(:recipe_herb, recipe: recipe, herb: herb)

      expect {
        recipe.update!(recipe_herbs_attributes: [ { id: recipe_herb.id, _destroy: "1" } ])
      }.to change(RecipeHerb, :count).by(-1)
    end
  end

  describe "関連の削除" do
    let(:recipe) { create(:recipe) }

    it "レシピを削除すると配合ハーブも削除される" do
      create(:recipe_herb, recipe: recipe)
      expect { recipe.destroy }.to change(RecipeHerb, :count).by(-1)
    end

    it "レシピを削除してもハーブ自体は削除されない" do
      create(:recipe_herb, recipe: recipe)
      expect { recipe.destroy }.not_to change(Herb, :count)
    end

    it "レシピを削除すると感想も削除される" do
      recipe.create_drinking_log!(rating: 4)
      expect { recipe.destroy }.to change(DrinkingLog, :count).by(-1)
    end
  end
end
