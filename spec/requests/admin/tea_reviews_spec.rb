require "rails_helper"

# 既製ブレンド管理（作成・商品情報の編集・削除。感想・評価は編集不可）
RSpec.describe "管理画面の既製ブレンド管理", type: :request do
  let(:admin) { create(:user, :admin) }
  let!(:tea_review) { create(:tea_review, brand: "元のメーカー", impression: "投稿者の感想", rating: 3) }

  before { sign_in admin }

  it "既製ブレンドを作成できる" do
    expect {
      post rails_admin.new_path(model_name: "tea_review"),
           params: { tea_review: { user_id: admin.id, brand: "メーカー", name: "商品", rating: "4" } }
    }.to change(TeaReview, :count).by(1)
  end

  it "商品情報を更新できる" do
    put rails_admin.edit_path(model_name: "tea_review", id: tea_review.id), params: { tea_review: { brand: "新しいメーカー" } }
    expect(tea_review.reload.brand).to eq "新しいメーカー"
  end

  it "感想・評価は更新されない" do
    put rails_admin.edit_path(model_name: "tea_review", id: tea_review.id),
        params: { tea_review: { impression: "改ざん", rating: "1" } }

    tea_review.reload
    expect(tea_review.impression).to eq "投稿者の感想"
    expect(tea_review.rating).to eq 3
  end

  it "既製ブレンドを削除できる" do
    expect {
      delete rails_admin.delete_path(model_name: "tea_review", id: tea_review.id)
    }.to change(TeaReview, :count).by(-1)
  end
end
