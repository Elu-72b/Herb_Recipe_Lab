require "rails_helper"

RSpec.describe RecipeHerb, type: :model do
  describe "バリデーション" do
    it "factory のデフォルト値（ハーブを選択）なら有効" do
      recipe_herb = build(:recipe_herb)
      expect(recipe_herb).to be_valid
    end

    it "recipe がないと無効" do
      recipe_herb = build(:recipe_herb, recipe: nil)
      expect(recipe_herb).not_to be_valid
      expect(recipe_herb.errors).to be_of_kind(:recipe, :blank)
    end
  end

  describe "ハーブの指定" do
    it "ハーブを選択せずカスタムハーブ名を入力しても有効" do
      recipe_herb = build(:recipe_herb, :custom)
      expect(recipe_herb).to be_valid
    end

    it "ハーブもカスタムハーブ名もないと無効" do
      recipe_herb = build(:recipe_herb, herb: nil, custom_herb_name: nil)
      expect(recipe_herb).not_to be_valid
      expect(recipe_herb.errors).to be_of_kind(:herb_id, :blank)
      expect(recipe_herb.errors).to be_of_kind(:custom_herb_name, :blank)
    end

    it "カスタムハーブ名が空文字だと無効" do
      recipe_herb = build(:recipe_herb, herb: nil, custom_herb_name: "")
      expect(recipe_herb).not_to be_valid
    end

    # フォームで「その他」を選ぶと herb_id に 0 が入るため、nil に正規化している
    it "herb_id が 0 のときは nil に正規化される" do
      recipe_herb = build(:recipe_herb, :custom, herb_id: 0)
      expect(recipe_herb).to be_valid
      expect(recipe_herb.herb_id).to be_nil
    end

    it "herb_id が 0 でカスタムハーブ名もないと無効" do
      recipe_herb = build(:recipe_herb, herb: nil, herb_id: 0, custom_herb_name: nil)
      expect(recipe_herb).not_to be_valid
    end
  end

  describe "quantity" do
    it "ないと無効" do
      recipe_herb = build(:recipe_herb, quantity: nil)
      expect(recipe_herb).not_to be_valid
      expect(recipe_herb.errors).to be_of_kind(:quantity, :blank)
    end

    it "0 だと無効" do
      recipe_herb = build(:recipe_herb, quantity: 0)
      expect(recipe_herb).not_to be_valid
      expect(recipe_herb.errors).to be_of_kind(:quantity, :greater_than)
    end

    it "負の値だと無効" do
      recipe_herb = build(:recipe_herb, quantity: -1)
      expect(recipe_herb).not_to be_valid
    end

    it "数値でないと無効" do
      recipe_herb = build(:recipe_herb, quantity: "abc")
      expect(recipe_herb).not_to be_valid
    end

    it "小数でも有効" do
      recipe_herb = build(:recipe_herb, quantity: 0.5)
      expect(recipe_herb).to be_valid
    end
  end

  describe "unit" do
    it "seeds.rb の設計どおりの単位が定義されている" do
      expect(described_class.units).to eq(
        "teaspoon" => 0, "tablespoon" => 1, "g" => 2, "piece" => 3, "individual" => 4
      )
    end

    it "定義済みの単位はすべて有効" do
      described_class.units.each_key do |unit|
        expect(build(:recipe_herb, unit: unit)).to be_valid
      end
    end

    it "未定義の単位を指定するとエラーになる" do
      expect { build(:recipe_herb, unit: "cup") }.to raise_error(ArgumentError)
    end

    # 現状 unit にはバリデーションがない（現仕様の固定）
    it "unit がなくても有効" do
      recipe_herb = build(:recipe_herb, unit: nil)
      expect(recipe_herb).to be_valid
    end
  end
end
