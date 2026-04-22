require "test_helper"

class DrinkingLogsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get drinking_logs_new_url
    assert_response :success
  end

  test "should get create" do
    get drinking_logs_create_url
    assert_response :success
  end

  test "should get show" do
    get drinking_logs_show_url
    assert_response :success
  end

  test "should get edit" do
    get drinking_logs_edit_url
    assert_response :success
  end

  test "should get update" do
    get drinking_logs_update_url
    assert_response :success
  end
end
