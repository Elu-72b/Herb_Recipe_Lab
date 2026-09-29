require "test_helper"

# 表示用のタグ取得は必ず Herb#cached_* を使う。
#
# flavor_tags / functional_tags / caution_tags の association は検索（ransack の join）で
# 必要なため削除できず、表示用のキャッシュ経由メソッドと並存している。
# View で association を直接叩くと preload されていないため静かに N+1 になるので、
# ここで機械的に検出する。
class ViewTagAssociationTest < ActiveSupport::TestCase
  # `.flavor_tags` `&:caution_tags` などを拾う。`cached_flavor_tags` は直前が `_` なので一致しない。
  FORBIDDEN = /[.&:](?:flavor|functional|caution)_tags\b/

  test "View がタグ association を直接参照していない" do
    offenders = Dir.glob(Rails.root.join("app/views/**/*.erb")).flat_map do |path|
      File.readlines(path).each_with_index.filter_map do |line, index|
        next unless line.match?(FORBIDDEN)
        "#{path.delete_prefix(Rails.root.to_s + '/')}:#{index + 1}  #{line.strip}"
      end
    end

    assert_empty offenders, <<~MSG
      View でタグ association を直接参照しています。preload されないため N+1 になります。
      Herb#cached_flavor_tags / #cached_functional_tags / #cached_caution_tags を使ってください。

      #{offenders.join("\n")}
    MSG
  end
end
