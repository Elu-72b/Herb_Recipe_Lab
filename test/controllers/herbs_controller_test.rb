require "test_helper"

class HerbsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # fixtures のハーブは user を持たないため、編集・削除の検証用に alice 所有のハーブを作る
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

  test "ログイン済みならハーブ登録画面が表示される" do
    sign_in users(:alice)
    get new_herb_url
    assert_response :success
  end

  test "ハーブを登録すると詳細画面へリダイレクトする" do
    sign_in users(:alice)

    assert_difference "Herb.count", 1 do
      post herbs_url, params: { herb: { name: "ペパーミント" } }
    end

    assert_redirected_to herb_path(Herb.find_by!(name: "ペパーミント"))
  end

  test "自分が登録したハーブの編集画面が表示される" do
    sign_in users(:alice)
    get edit_herb_url(@own_herb)
    assert_response :success
  end

  test "自分が登録したハーブを更新すると詳細画面へリダイレクトする" do
    sign_in users(:alice)
    patch herb_url(@own_herb), params: { herb: { description: "レモンの香り" } }

    assert_redirected_to herb_path(@own_herb)
    assert_equal "レモンの香り", @own_herb.reload.description
  end

  test "自分が登録したハーブを削除すると一覧へリダイレクトする" do
    sign_in users(:alice)

    assert_difference "Herb.count", -1 do
      delete herb_url(@own_herb)
    end

    assert_redirected_to herbs_path
  end
end
