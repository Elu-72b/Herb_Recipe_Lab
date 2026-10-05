require "rails_helper"

RSpec.describe "Herbs", type: :request do
  let(:user) { create(:user) }

  describe "GET /herbs" do
    it "未ログインでも一覧が表示される" do
      create(:herb, name: "カモミール")
      get herbs_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("カモミール")
    end
  end

  describe "GET /herbs/:id" do
    it "未ログインでも詳細が表示される" do
      herb = create(:herb, name: "カモミール")
      get herb_path(herb)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("カモミール")
    end

    it "存在しないハーブは 404 になる" do
      get herb_path(id: 0)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /herbs/autocomplete" do
    before do
      create(:herb, name: "カモミール")
      create(:herb, name: "ペパーミント")
    end

    it "部分一致するハーブ名を JSON で返す" do
      get autocomplete_herbs_path, params: { q: "カモ" }
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq [ "カモミール" ]
    end

    it "ひらがなで入力してもカタカナのハーブ名に一致する" do
      get autocomplete_herbs_path, params: { q: "かも" }
      expect(response.parsed_body).to eq [ "カモミール" ]
    end

    it "検索語がなければ全件を名前順で返す" do
      get autocomplete_herbs_path
      expect(response.parsed_body).to eq [ "カモミール", "ペパーミント" ]
    end
  end

  # ハーブの登録・編集・削除は管理画面に一本化したため、一般画面からは行えない
  # （管理者による操作は spec/requests/admin/herbs_spec.rb で確認する）
  describe "一般画面からのハーブ編集" do
    let!(:herb) { create(:herb, user: user, name: "レモンバーム") }

    before { sign_in user }

    it "POST /herbs のルートがなく、ハーブは登録されない" do
      expect {
        post "/herbs", params: { herb: { name: "ペパーミント" } }
      }.not_to change(Herb, :count)
      expect(response).to have_http_status(:not_found)
    end

    it "PATCH /herbs/:id のルートがなく、ハーブは更新されない" do
      patch "/herbs/#{herb.id}", params: { herb: { description: "レモンの香り" } }
      expect(response).to have_http_status(:not_found)
      expect(herb.reload.description).to be_nil
    end

    it "DELETE /herbs/:id のルートがなく、ハーブは削除されない" do
      expect {
        delete "/herbs/#{herb.id}"
      }.not_to change(Herb, :count)
      expect(response).to have_http_status(:not_found)
    end
  end
end
