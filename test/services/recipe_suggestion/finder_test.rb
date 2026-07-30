require "test_helper"

module RecipeSuggestion
  class FinderTest < ActiveSupport::TestCase
    # fixture の構成:
    #   public_sleep_safe    公開 / リンデン（睡眠サポート・甘味・禁忌なし）
    #   public_sleep_caution 公開 / カモミール（妊娠中注意）＋リンデン
    #   private_sleep_safe   非公開 / リンデン
    #   public_skin_care     公開 / ローズヒップ（美肌ケア・酸味）

    test "条件未指定なら公開レシピをすべて返す" do
      titles = Finder.new({}).call.map(&:title)

      assert_includes titles, recipes(:public_sleep_safe).title
      assert_includes titles, recipes(:public_skin_care).title
      assert_equal 3, titles.size
    end

    test "非公開レシピを含まない" do
      titles = Finder.new({}).call.map(&:title)

      assert_not_includes titles, recipes(:private_sleep_safe).title
    end

    test "効能タグで絞り込める" do
      titles = Finder.new(functional_names: [ "睡眠サポート" ]).call.map(&:title)

      assert_includes titles, recipes(:public_sleep_safe).title
      assert_includes titles, recipes(:public_sleep_caution).title
      assert_not_includes titles, recipes(:public_skin_care).title
    end

    test "効能と風味を両方指定するとAND条件で絞り込む" do
      titles = Finder.new(
        functional_names: [ "睡眠サポート" ],
        flavor_names: [ "酸味" ]
      ).call.map(&:title)

      # 睡眠サポートと酸味を両方満たすレシピは存在しない
      assert_empty titles
    end

    test "複数の効能タグを指定するとすべて含むレシピだけを返す" do
      titles = Finder.new(
        functional_names: [ "睡眠サポート", "美肌ケア" ]
      ).call.map(&:title)

      assert_empty titles
    end

    test "禁忌タグを持つハーブを含むレシピを除外する" do
      titles = Finder.new(
        functional_names: [ "睡眠サポート" ],
        flavor_names: [ "甘味" ],
        exclude_caution_tags: [ "妊娠中注意" ]
      ).call.map(&:title)

      assert_includes titles, recipes(:public_sleep_safe).title
      assert_not_includes titles, recipes(:public_sleep_caution).title
    end

    test "禁忌未指定なら除外しない" do
      titles = Finder.new(
        functional_names: [ "睡眠サポート" ],
        flavor_names: [ "甘味" ]
      ).call.map(&:title)

      assert_includes titles, recipes(:public_sleep_caution).title
    end

    test "空文字やnilの条件は無視する" do
      titles = Finder.new(
        functional_names: [ "", nil, " 睡眠サポート " ],
        flavor_names: [],
        exclude_caution_tags: [ "" ]
      ).call.map(&:title)

      assert_includes titles, recipes(:public_sleep_safe).title
      assert_not_includes titles, recipes(:public_skin_care).title
    end

    test "該当0件でも例外にせず空を返す" do
      result = Finder.new(functional_names: [ "存在しないタグ" ]).call

      assert_empty result
    end

    test "limitで件数を制限できる" do
      assert_equal 1, Finder.new({}).call(limit: 1).size
    end

    test "新しい順に並ぶ" do
      titles = Finder.new({}).call.map(&:title)

      assert_equal recipes(:public_skin_care).title, titles.first
    end
  end
end
