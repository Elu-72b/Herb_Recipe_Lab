require "test_helper"

# 一覧・詳細画面の SQL 発行数を固定する（#190 の再発防止）。
# preload 漏れや View 内クエリの混入を検出するためのテスト。
#
# ■ 期待値を変更するときは、増減の根拠を PR に書くこと。
#
# ■ 注意1: ウォームアップしてはいけない
#   Rails のクエリキャッシュはテスト内でリクエストをまたいで効くため、
#   2回目以降のリクエストは全て cached となり 0 件になる。必ず最初の1回を計測する。
#
# ■ 注意2: development のログ上の本数とは一致しない
#   - test は cache_store = :null_store のため、TagCacheable の `ordered_cached` が
#     毎回 SQL を発行する（検索フォームの FlavorTag / CautionTag 分が上乗せされる）
#   - fixture の件数が少なく1ページに収まるため、Kaminari が COUNT を省略する
#   - Devise のセッション復元による User Load が加わる
class QueryCountTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # Herb 1 / 中間3 / マスタ4（うち検索フォーム2）/ ActiveStorage 1
  test "GET /herbs" do
    assert_queries_count(10) { get herbs_url }
    assert_response :success
  end

  # set_herb が preload していないため Exists? ×3 と個別 Load が出ている。
  # 減らす場合は set_herb に includes を足したうえでこの値を更新すること。
  test "GET /herbs/:id" do
    assert_queries_count(8) { get herb_url(herbs(:linden)) }
    assert_response :success
  end

  # 未ログイン。ログイン時は @bookmark の取得で +1 になる。
  test "GET /recipes/:id" do
    assert_queries_count(11) { get recipe_url(recipes(:public_sleep_safe)) }
    assert_response :success
  end

  test "GET /tea_reviews" do
    sign_in users(:alice)
    assert_queries_count(7) { get tea_reviews_url }
    assert_response :success
  end

  # ハーブ3行（うち1行は herb_id なし）。preload が効いていれば行数に比例しない。
  test "GET /tea_reviews/:id" do
    sign_in users(:alice)
    assert_queries_count(12) { get tea_review_url(tea_reviews(:alice_sleep_blend)) }
    assert_response :success
  end
end
