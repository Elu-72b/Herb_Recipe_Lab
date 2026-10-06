require "rails_helper"

# ユーザー管理（閲覧・削除・admin 付与のみ。自分自身は変更・削除不可）
RSpec.describe "管理画面のユーザー管理", type: :request do
  let(:admin) { create(:user, :admin) }
  let!(:other_user) { create(:user) }

  before { sign_in admin }

  it "ユーザー一覧が表示される" do
    get rails_admin.index_path(model_name: "user")
    expect(response).to have_http_status(:ok)
  end

  it "編集画面にメールアドレス・パスワードの入力欄が出ない" do
    get rails_admin.edit_path(model_name: "user", id: other_user.id)
    expect(response.body).not_to include('name="user[email]"')
    expect(response.body).not_to include('name="user[password]"')
  end

  it "他ユーザーに admin を付与できる（メールアドレスは変更されない）" do
    original_email = other_user.email
    put rails_admin.edit_path(model_name: "user", id: other_user.id),
        params: { user: { admin: "1", email: "changed@example.com" } }

    other_user.reload
    expect(other_user).to be_admin
    expect(other_user.email).to eq original_email
  end

  it "他ユーザーの admin を剥奪できる" do
    other_user.update!(admin: true)
    put rails_admin.edit_path(model_name: "user", id: other_user.id), params: { user: { admin: "0" } }
    expect(other_user.reload).not_to be_admin
  end

  it "他ユーザーを削除すると、そのユーザーのレシピも削除される" do
    create(:recipe, user: other_user)
    expect {
      delete rails_admin.delete_path(model_name: "user", id: other_user.id)
    }.to change(User, :count).by(-1).and change(Recipe, :count).by(-1)
  end

  describe "自分自身" do
    it "admin を剥奪できない" do
      top_path = root_path
      put rails_admin.edit_path(model_name: "user", id: admin.id), params: { user: { admin: "0" } }
      expect(response).to redirect_to(top_path)
      expect(admin.reload).to be_admin
    end

    it "削除できない" do
      expect {
        delete rails_admin.delete_path(model_name: "user", id: admin.id)
      }.not_to change(User, :count)
    end
  end
end
