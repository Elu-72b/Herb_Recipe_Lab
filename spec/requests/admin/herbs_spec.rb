require "rails_helper"

# ハーブ図鑑の登録・編集・削除（管理画面）
RSpec.describe "管理画面のハーブ図鑑", type: :request do
  let(:admin) { create(:user, :admin) }

  context "管理者の場合" do
    before { sign_in admin }

    it "登録画面が表示される" do
      get rails_admin.new_path(model_name: "herb")
      expect(response).to have_http_status(:ok)
    end

    it "ハーブを登録できる" do
      expect {
        post rails_admin.new_path(model_name: "herb"), params: { herb: { name: "レモンバーム" } }
      }.to change(Herb, :count).by(1)
    end

    it "name がないと登録されない" do
      expect {
        post rails_admin.new_path(model_name: "herb"), params: { herb: { name: "" } }
      }.not_to change(Herb, :count)
    end

    it "ハーブを更新できる" do
      herb = create(:herb)
      put rails_admin.edit_path(model_name: "herb", id: herb.id), params: { herb: { description: "レモンの香り" } }
      expect(herb.reload.description).to eq "レモンの香り"
    end

    it "ハーブを削除できる" do
      herb = create(:herb)
      expect {
        delete rails_admin.delete_path(model_name: "herb", id: herb.id)
      }.to change(Herb, :count).by(-1)
    end
  end

  context "一般ユーザーの場合" do
    before { sign_in create(:user) }

    it "ハーブを登録できない" do
      expect {
        post rails_admin.new_path(model_name: "herb"), params: { herb: { name: "レモンバーム" } }
      }.not_to change(Herb, :count)
    end
  end
end
