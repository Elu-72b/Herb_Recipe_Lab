require "test_helper"

class TagCacheableTest < ActiveSupport::TestCase
  setup do
    @original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
  end

  teardown do
    Rails.cache = @original_cache
  end

  test "find_cached はキャッシュから name 昇順で返す" do
    ids = [ flavor_tags(:sour).id, flavor_tags(:sweet).id ]
    assert_equal %w[甘味 酸味], FlavorTag.find_cached(ids).map(&:name)
  end

  test "find_cached は id を渡さなければ空配列を返す" do
    assert_equal [], FlavorTag.find_cached([])
  end

  test "find_cached はキャッシュ生成後に追加されたタグも取りこぼさない" do
    FlavorTag.ordered_cached # 先にキャッシュを作る
    added = FlavorTag.create!(name: "うま味")

    result = FlavorTag.find_cached([ flavor_tags(:sweet).id, added.id ])

    assert_includes result.map(&:name), "うま味", "キャッシュに無いタグが欠落している"
    assert_equal %w[うま味 甘味], result.map(&:name)
  end

  test "取りこぼしを検出したらキャッシュを破棄して次回作り直す" do
    FlavorTag.ordered_cached
    added = FlavorTag.new(name: "うま味")
    added.save!(validate: false)
    Rails.cache.write(FlavorTag.cache_key_for(:ordered_by_name), FlavorTag.where.not(id: added.id).order(:name).to_a)

    FlavorTag.find_cached([ added.id ])

    assert_nil Rails.cache.read(FlavorTag.cache_key_for(:ordered_by_name)), "古いキャッシュが残っている"
  end

  test "マスタ更新時に after_commit でキャッシュが破棄される" do
    FlavorTag.ordered_cached
    assert_not_nil Rails.cache.read(FlavorTag.cache_key_for(:ordered_by_name))

    flavor_tags(:sweet).update!(name: "甘み")

    assert_nil Rails.cache.read(FlavorTag.cache_key_for(:ordered_by_name))
  end
end
