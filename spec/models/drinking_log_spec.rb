require "rails_helper"

RSpec.describe DrinkingLog, type: :model do
  describe "バリデーション" do
    it "factory のデフォルト値なら有効" do
      drinking_log = build(:drinking_log)
      expect(drinking_log).to be_valid
    end

    it "recipe がないと無効" do
      drinking_log = build(:drinking_log, recipe: nil)
      expect(drinking_log).not_to be_valid
      expect(drinking_log.errors).to be_of_kind(:recipe, :blank)
    end
  end

  describe "rating" do
    it "ないと無効" do
      drinking_log = build(:drinking_log, rating: nil)
      expect(drinking_log).not_to be_valid
      expect(drinking_log.errors).to be_of_kind(:rating, :blank)
    end

    it "0 だと無効" do
      drinking_log = build(:drinking_log, rating: 0)
      expect(drinking_log).not_to be_valid
      expect(drinking_log.errors).to be_of_kind(:rating, :inclusion)
    end

    it "6 だと無効" do
      drinking_log = build(:drinking_log, rating: 6)
      expect(drinking_log).not_to be_valid
      expect(drinking_log.errors).to be_of_kind(:rating, :inclusion)
    end

    it "1 から 5 はすべて有効" do
      (1..5).each do |rating|
        expect(build(:drinking_log, rating: rating)).to be_valid
      end
    end
  end

  describe "風味評価" do
    it "風味タグ名と 8 つのカラムが対応している" do
      expect(described_class::FLAVOR_MAPPING).to eq(
        "甘味" => :sweetness,
        "酸味" => :acidity,
        "苦味" => :bitterness,
        "渋味" => :astringency,
        "フルーティー" => :fruity,
        "スパイシー" => :spicy,
        "清涼感" => :freshness,
        "華やかさ" => :flowery
      )
    end

    described_class::FLAVOR_MAPPING.each do |label, column|
      describe "#{label}（#{column}）" do
        it "1 から 5 はすべて有効" do
          (1..5).each do |value|
            expect(build(:drinking_log, column => value)).to be_valid
          end
        end

        it "6 だと無効" do
          drinking_log = build(:drinking_log, column => 6)
          expect(drinking_log).not_to be_valid
          expect(drinking_log.errors).to be_of_kind(column, :less_than_or_equal_to)
        end

        it "負の値だと無効" do
          drinking_log = build(:drinking_log, column => -1)
          expect(drinking_log).not_to be_valid
          expect(drinking_log.errors).to be_of_kind(column, :greater_than_or_equal_to)
        end

        it "小数だと無効" do
          drinking_log = build(:drinking_log, column => 1.5)
          expect(drinking_log).not_to be_valid
          expect(drinking_log.errors).to be_of_kind(column, :not_an_integer)
        end

        it "未入力（nil）でも有効" do
          drinking_log = build(:drinking_log, column => nil)
          expect(drinking_log).to be_valid
        end

        # 0 は「未入力」として扱い、nil に正規化する
        it "0 は nil に正規化されて有効" do
          drinking_log = build(:drinking_log, column => 0)
          expect(drinking_log).to be_valid
          expect(drinking_log.public_send(column)).to be_nil
        end
      end
    end

    # flowery は DB のデフォルト値が 0 のため、何も指定しなくても正規化の対象になる
    it "flowery を指定しなくても nil で保存される" do
      drinking_log = create(:drinking_log)
      expect(drinking_log.reload.flowery).to be_nil
    end
  end

  describe "レシピとの関連" do
    it "レシピから感想を参照できる" do
      drinking_log = create(:drinking_log)
      expect(drinking_log.recipe.drinking_log).to eq drinking_log
    end
  end
end
