require "rails_helper"

RSpec.describe "Profiles", type: :request do
  describe "PATCH /profile" do
    context "通常ユーザー" do
      let(:user) { create(:user, name: "旧名", email: "old@example.com") }

      before { sign_in user }

      it "パスワードなしで名前を変更できる" do
        patch profile_path, params: { user: { name: "新名", email: user.email } }
        expect(response).to redirect_to(profile_path)
        expect(user.reload.name).to eq "新名"
      end

      it "名前を空にすると更新されない" do
        patch profile_path, params: { user: { name: "", email: user.email } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(user.reload.name).to eq "旧名"
      end

      it "正しい現在のパスワードでメールを変更でき、旧アドレスに通知が届く" do
        expect {
          patch profile_path, params: { user: { name: user.name, email: "new@example.com", current_password: "password123" } }
        }.to change { ActionMailer::Base.deliveries.size }.by(1)
        expect(user.reload.email).to eq "new@example.com"
        expect(ActionMailer::Base.deliveries.last.to).to eq [ "old@example.com" ]
      end

      it "通知メールにアプリのリンクと送信元が記載されている" do
        patch profile_path, params: { user: { name: user.name, email: "new@example.com", current_password: "password123" } }
        body = ActionMailer::Base.deliveries.last.body.encoded
        expect(body).to include("Herb Recipe Lab")
        expect(body).to include("http://www.example.com/")
      end

      it "現在のパスワードが誤っているとメールは変更されない" do
        patch profile_path, params: { user: { name: user.name, email: "new@example.com", current_password: "wrong" } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(user.reload.email).to eq "old@example.com"
      end
    end

    context "Google ユーザー" do
      let(:user) { create(:user, :google, email: "g@example.com") }

      before { sign_in user }

      it "名前は変更でき、メールは送っても変更されない" do
        patch profile_path, params: { user: { name: "新名", email: "hack@example.com" } }
        expect(user.reload.name).to eq "新名"
        expect(user.email).to eq "g@example.com"
      end
    end

    context "未ログイン" do
      it "ログイン画面へリダイレクトする" do
        patch profile_path, params: { user: { name: "x" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "DELETE /profile" do
    let(:user) { create(:user) }
    let(:other) { create(:user) }
    let!(:own_recipe) { create(:recipe, user: user) }
    let!(:other_recipe) { create(:recipe, user: other) }
    let!(:own_herb) { create(:herb, user: user) }
    let!(:own_review) { create(:tea_review, user: user) }

    before do
      create(:drinking_log, recipe: own_recipe)
      Bookmark.create!(user: user, recipe: other_recipe)  # 自分が付けたもの
      Bookmark.create!(user: other, recipe: own_recipe)   # 他人が自分のレシピに付けたもの
      sign_in user
    end

    it "退会するとログアウトされ、トップへリダイレクトする" do
      delete profile_path
      expect(response).to redirect_to(root_path)
      get profile_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "本人の関連データは削除され、他人のデータとハーブは残る" do
      expect { delete profile_path }
        .to change(User, :count).by(-1)
        .and change(Recipe, :count).by(-1)
        .and change(DrinkingLog, :count).by(-1)
        .and change(TeaReview, :count).by(-1)
        .and change(Bookmark, :count).by(-2)
        .and change(Herb, :count).by(0)

      expect(Recipe.exists?(other_recipe.id)).to be true
      expect(own_herb.reload.user_id).to be_nil
    end

    context "管理者が1人だけの場合" do
      let(:user) { create(:user, :admin) }

      it "退会できない" do
        expect { delete profile_path }.not_to change(User, :count)
        expect(response).to redirect_to(profile_path)
      end
    end
  end
end
