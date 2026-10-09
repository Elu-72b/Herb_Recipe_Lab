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
end
