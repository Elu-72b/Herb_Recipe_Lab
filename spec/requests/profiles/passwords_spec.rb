require "rails_helper"

RSpec.describe "Profiles::Passwords", type: :request do
  describe "PATCH /profile/password" do
    let(:user) { create(:user) }
    let(:params) { { user: { current_password: "password123", password: "newpass123", password_confirmation: "newpass123" } } }

    before { sign_in user }

    it "変更でき、ログイン状態が維持され、通知メールが届く" do
      expect { patch profile_password_path, params: params }
        .to change { ActionMailer::Base.deliveries.size }.by(1)
      expect(response).to redirect_to(profile_path)
      expect(user.reload.valid_password?("newpass123")).to be true

      get profile_path
      expect(response).to have_http_status(:ok)
    end

    it "現在のパスワードが誤っていると変更されない" do
      patch profile_password_path, params: { user: params[:user].merge(current_password: "wrong") }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(user.reload.valid_password?("password123")).to be true
    end

    it "新しいパスワードが空だと変更されない" do
      patch profile_password_path, params: { user: { current_password: "password123", password: "", password_confirmation: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "確認用が一致しないと変更されない" do
      patch profile_password_path, params: { user: params[:user].merge(password_confirmation: "mismatch") }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "Google ユーザー" do
    before { sign_in create(:user, :google) }

    it "編集画面にアクセスするとプロフィールへリダイレクトする" do
      get edit_profile_password_path
      expect(response).to redirect_to(profile_path)
    end
  end
end
