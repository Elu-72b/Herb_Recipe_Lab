require "rails_helper"
require "cancan/matchers"

RSpec.describe Ability, type: :model do
  subject(:ability) { described_class.new(user) }

  let(:other_user) { create(:user) }
  let(:public_recipe) { create(:recipe, :public, user: other_user) }
  let(:private_recipe) { create(:recipe, user: other_user) }

  context "管理者の場合" do
    let(:user) { create(:user, :admin) }

    it { is_expected.to be_able_to(:access, :rails_admin) }
    it { is_expected.to be_able_to(:read, :dashboard) }

    it "ハーブ図鑑・タグマスタ・既製ブレンドを管理できる" do
      [ Herb, FlavorTag, FunctionalTag, CautionTag, TeaReview ].each do |model|
        expect(ability).to be_able_to(:manage, model)
      end
    end

    describe "公開ブレンドレシピ" do
      it { is_expected.to be_able_to(:read, public_recipe) }
      it { is_expected.to be_able_to(:update, public_recipe) }
      it { is_expected.to be_able_to(:destroy, public_recipe) }
      it { is_expected.not_to be_able_to(:create, Recipe) }
    end

    describe "非公開レシピ" do
      it { is_expected.not_to be_able_to(:read, private_recipe) }
      it { is_expected.not_to be_able_to(:update, private_recipe) }
      it { is_expected.not_to be_able_to(:destroy, private_recipe) }
    end

    describe "ユーザー" do
      it { is_expected.to be_able_to(:read, other_user) }
      it { is_expected.to be_able_to(:update, other_user) }
      it { is_expected.to be_able_to(:destroy, other_user) }
      it { is_expected.not_to be_able_to(:create, User) }
      it { is_expected.not_to be_able_to(:update, user) }
      it { is_expected.not_to be_able_to(:destroy, user) }
    end

    it "感想（DrinkingLog）は扱えない" do
      expect(ability).not_to be_able_to(:read, DrinkingLog)
    end
  end

  context "一般ユーザーの場合" do
    let(:user) { create(:user) }

    it { is_expected.not_to be_able_to(:access, :rails_admin) }
    it { is_expected.not_to be_able_to(:manage, Herb) }
    it { is_expected.not_to be_able_to(:read, public_recipe) }
  end

  context "未ログインの場合" do
    let(:user) { nil }

    it { is_expected.not_to be_able_to(:access, :rails_admin) }
  end
end
