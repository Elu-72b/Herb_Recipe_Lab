require "rails_helper"

RSpec.describe Herb, type: :model do
  # PNG のシグネチャ。content_type が中身から判定されても image/png になるようにする
  let(:png_data) { "\x89PNG\r\n\x1A\n".b }

  describe "バリデーション" do
    it "factory のデフォルト値（user なし）なら有効" do
      herb = build(:herb)
      expect(herb).to be_valid
    end

    it "name がないと無効" do
      herb = build(:herb, name: nil)
      expect(herb).not_to be_valid
      expect(herb.errors).to be_added(:name, :blank)
    end

    it "name が重複していると無効" do
      create(:herb, name: "カモミール")
      herb = build(:herb, name: "カモミール")
      expect(herb).not_to be_valid
      expect(herb.errors).to be_of_kind(:name, :taken)
    end

    it "user を紐づけても有効" do
      herb = build(:herb, user: create(:user))
      expect(herb).to be_valid
    end
  end

  describe "画像のバリデーション" do
    it "PNG 画像なら有効" do
      herb = build(:herb)
      herb.image.attach(io: StringIO.new(png_data), filename: "herb.png", content_type: "image/png")
      expect(herb).to be_valid
    end

    it "許可されていない content_type だと無効" do
      herb = build(:herb)
      herb.image.attach(io: StringIO.new("text"), filename: "herb.txt", content_type: "text/plain")
      expect(herb).not_to be_valid
      expect(herb.errors[:image]).to be_present
    end

    it "5MB を超えると無効" do
      herb = build(:herb)
      oversized = png_data + ("0" * 5.megabytes)
      herb.image.attach(io: StringIO.new(oversized), filename: "herb.png", content_type: "image/png")
      expect(herb).not_to be_valid
      expect(herb.errors[:image]).to be_present
    end
  end
end
