require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "未ログインならトップページが表示される" do
    get root_url
    assert_response :success
  end
end
