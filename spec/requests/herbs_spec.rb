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

  describe "GET /herbs/new" do
    it "ログイン済みなら登録画面が表示される" do
      sign_in user
      get new_herb_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /herbs" do
    before { sign_in user }

    it "ハーブを登録し、詳細画面へリダイレクトする" do
      expect {
        post herbs_path, params: { herb: { name: "レモンバーム" } }
      }.to change(Herb, :count).by(1)

      herb = Herb.find_by!(name: "レモンバーム")
      expect(herb.user).to eq user
      expect(response).to redirect_to(herb_path(herb))
    end

    it "name がないと登録されず、フォームを再表示する" do
      expect {
        post herbs_path, params: { herb: { name: "" } }
      }.not_to change(Herb, :count)

      expect(response).to have_http_status(422)
    end
  end

  describe "自分が登録したハーブ" do
    let!(:herb) { create(:herb, user: user, name: "レモンバーム") }

    before { sign_in user }

    it "編集画面が表示される" do
      get edit_herb_path(herb)
      expect(response).to have_http_status(:ok)
    end

    it "更新すると詳細画面へリダイレクトする" do
      patch herb_path(herb), params: { herb: { description: "レモンの香り" } }

      expect(response).to redirect_to(herb_path(herb))
      expect(herb.reload.description).to eq "レモンの香り"
    end

    it "削除すると一覧へリダイレクトする" do
      expect {
        delete herb_path(herb)
      }.to change(Herb, :count).by(-1)

      expect(response).to redirect_to(herbs_path)
    end
  end
end
