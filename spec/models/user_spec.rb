require "rails_helper"

RSpec.describe User, type: :model do
  describe "バリデーション" do
    it "factory のデフォルト値なら有効" do
      user = build(:user)
      expect(user).to be_valid
    end

    it "email がないと無効" do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors).to be_added(:email, :blank)
    end

    it "email が重複していると無効" do
      create(:user, email: "taken@example.com")
      user = build(:user, email: "taken@example.com")
      expect(user).not_to be_valid
      expect(user.errors).to be_of_kind(:email, :taken)
    end

    it "email の形式が不正だと無効" do
      user = build(:user, email: "invalid")
      expect(user).not_to be_valid
      expect(user.errors).to be_of_kind(:email, :invalid)
    end

    it "password がないと無効" do
      user = build(:user, password: nil)
      expect(user).not_to be_valid
      expect(user.errors).to be_added(:password, :blank)
    end

    it "password が5文字だと無効" do
      user = build(:user, password: "a" * 5)
      expect(user).not_to be_valid
      expect(user.errors).to be_of_kind(:password, :too_short)
    end

    it "password が6文字なら有効" do
      user = build(:user, password: "a" * 6)
      expect(user).to be_valid
    end

    # name にはバリデーションを設けていない（現仕様の固定）
    it "name がなくても有効" do
      user = build(:user, name: nil)
      expect(user).to be_valid
    end
  end

  describe "関連の削除" do
    it "ユーザーを削除するとレシピも削除される" do
      user = create(:user)
      create(:recipe, user: user)
      expect { user.destroy }.to change(Recipe, :count).by(-1)
    end
  end

  describe "admin フラグ" do
    it "既定値は false" do
      expect(create(:user).admin).to be false
    end
  end

  describe ".create_from_omniauth" do
    let(:auth) do
      OmniAuth::AuthHash.new(
        provider: "google_oauth2",
        uid: "123456",
        info: { email: "google_user@example.com", name: "Google ユーザー" }
      )
    end

    before { ActionMailer::Base.deliveries.clear }

    it "確認済みのユーザーとして作成される" do
      user = User.create_from_omniauth(auth)
      expect(user).to be_persisted
      expect(user).to be_confirmed
    end

    it "確認メールは送信されない" do
      expect { User.create_from_omniauth(auth) }.not_to change { ActionMailer::Base.deliveries.size }
    end
  end
end
