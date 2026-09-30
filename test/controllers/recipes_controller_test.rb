require "test_helper"

class RecipesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "未ログインでも公開レシピ一覧が表示される" do
    get recipes_url
    assert_response :success
  end

  test "ログイン済みならレシピ作成画面が表示される" do
    sign_in users(:alice)
    get new_recipe_url
    assert_response :success
  end

  test "レシピを作成すると感想入力画面へリダイレクトする" do
    sign_in users(:alice)

    assert_difference "Recipe.count", 1 do
      post recipes_url, params: {
        recipe: {
          title: "テスト用ブレンド",
          brewed_at: "2026-09-30",
          recipe_herbs_attributes: {
            "0" => { herb_id: herbs(:linden).id, quantity: 2, unit: "g" }
          }
        }
      }
    end

    recipe = Recipe.find_by!(title: "テスト用ブレンド")
    assert_redirected_to new_recipe_drinking_log_path(recipe)
  end

  test "未ログインでも公開レシピの詳細が表示される" do
    get recipe_url(recipes(:public_sleep_safe))
    assert_response :success
  end
end
