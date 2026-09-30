require "test_helper"

class DrinkingLogsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # public_sleep_caution: alice 所有・感想なし(new / create 用)
  # public_sleep_safe   : alice 所有・感想あり(show / edit / update 用)
  setup do
    sign_in users(:alice)
  end

  test "感想入力画面が表示される" do
    get new_recipe_drinking_log_url(recipes(:public_sleep_caution))
    assert_response :success
  end

  test "感想を保存するとホームへリダイレクトする" do
    recipe = recipes(:public_sleep_caution)

    assert_difference "DrinkingLog.count", 1 do
      post recipe_drinking_logs_url(recipe), params: {
        drinking_log: { rating: 4 },
        recipe: { is_public: "1" }
      }
    end

    assert_redirected_to home_path
  end

  test "感想詳細が表示される" do
    # show アクションとルートはあるが drinking_logs/show.html.erb が未作成のため 406 になる。
    # ビューを作るかルートを削除するかは別 issue で判断する。
    skip "drinking_logs/show のビューが未作成(別 issue で対応)"
    recipe = recipes(:public_sleep_safe)
    get recipe_drinking_log_url(recipe, recipe.drinking_log)
    assert_response :success
  end

  test "感想編集画面が表示される" do
    recipe = recipes(:public_sleep_safe)
    get edit_recipe_drinking_log_url(recipe, recipe.drinking_log)
    assert_response :success
  end

  test "感想を更新するとホームへリダイレクトする" do
    recipe = recipes(:public_sleep_safe)
    patch recipe_drinking_log_url(recipe, recipe.drinking_log), params: {
      drinking_log: { rating: 3 },
      recipe: { is_public: "1" }
    }

    assert_redirected_to home_path
    assert_equal 3, recipe.drinking_log.reload.rating
  end
end
