require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "未ログインならログイン画面へリダイレクトする" do
    get profile_url

    assert_redirected_to new_user_session_path
  end

  test "ログイン済みならプロフィールが表示される" do
    sign_in users(:alice)
    get profile_url

    assert_response :success
    assert_select "p", text: users(:alice).email
  end

  # フッターの「ブックマーク」を「AI提案」に差し替えたため、
  # ブックマーク一覧への導線はこの画面が唯一になっている。
  test "ブックマーク一覧への導線がある" do
    sign_in users(:alice)
    get profile_url

    assert_select "a[href=?]", bookmarks_path
  end
end
