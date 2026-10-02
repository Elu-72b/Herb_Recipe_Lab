# SimpleCov の共通設定。`require "simplecov"` した時点で自動的に読み込まれる。
# RSpec（spec/spec_helper.rb）と Minitest（test/test_helper.rb）の両方から使う。
SimpleCov.start "rails" do
  enable_coverage :branch

  # RSpec と Minitest を続けて実行したとき、両方の結果を合算する（秒）
  merge_timeout 3600

  add_group "Services", "app/services"
end
