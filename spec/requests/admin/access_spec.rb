require "rails_helper"

# /admin（rails_admin）へのアクセス制御の確認
RSpec.describe "管理画面のアクセス制限", type: :request do
  subject { get rails_admin.dashboard_path }

  context "未ログインの場合" do
    it "ログイン画面へリダイレクトする" do
      subject
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "一般ユーザーの場合" do
    before { sign_in create(:user) }

    it "トップページへリダイレクトし、アラートを表示する" do
      # rails_admin へのリクエスト後はパスに /admin が付与されるため、リクエスト前に解決しておく
      top_path = root_path
      subject
      expect(response).to redirect_to(top_path)
      expect(flash[:alert]).to eq "管理者権限が必要です"
    end
  end

  context "管理者の場合" do
    before { sign_in create(:user, :admin) }

    it "ダッシュボードが表示される" do
      subject
      expect(response).to have_http_status(:ok)
    end
  end
end
