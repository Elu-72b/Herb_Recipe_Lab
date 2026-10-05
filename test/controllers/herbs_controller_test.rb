require "test_helper"

class HerbsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # 一般画面から編集できないことの検証用に、alice 所有のハーブを作る
  setup do
    @own_herb = Herb.create!(name: "レモンバーム", user: users(:alice))
  end

  test "未ログインでもハーブ一覧が表示される" do
    get herbs_url
    assert_response :success
  end

  test "未ログインでもハーブ詳細が表示される" do
    get herb_url(herbs(:linden))
    assert_response :success
  end

  # ハーブの登録・編集・削除は管理画面に一本化したため、一般画面からは行えない
  test "一般画面の POST /herbs はルートがなく、ハーブは登録されない" do
    sign_in users(:alice)

    assert_no_difference "Herb.count" do
      post "/herbs", params: { herb: { name: "ペパーミント" } }
    end
    assert_response :not_found
  end

  test "一般画面の PATCH /herbs/:id はルートがなく、ハーブは更新されない" do
    sign_in users(:alice)
    patch "/herbs/#{@own_herb.id}", params: { herb: { description: "レモンの香り" } }

    assert_response :not_found
    assert_nil @own_herb.reload.description
  end

  test "一般画面の DELETE /herbs/:id はルートがなく、ハーブは削除されない" do
    sign_in users(:alice)

    assert_no_difference "Herb.count" do
      delete "/herbs/#{@own_herb.id}"
    end
    assert_response :not_found
  end

  test "管理者は管理画面でハーブを登録できる" do
    users(:alice).update!(admin: true)
    sign_in users(:alice)

    assert_difference "Herb.count", 1 do
      post rails_admin.new_path(model_name: "herb"), params: { herb: { name: "ペパーミント" } }
    end
  end

  test "一般ユーザーは管理画面でハーブを登録できない" do
    sign_in users(:alice)

    assert_no_difference "Herb.count" do
      post rails_admin.new_path(model_name: "herb"), params: { herb: { name: "ペパーミント" } }
    end
  end
end
