# カバレッジ計測はアプリのコードが読み込まれる前に開始する必要があるため、最初に require する
require "simplecov"
SimpleCov.command_name "Minitest"

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "active_record/testing/query_assertions"

class ActiveSupport::TestCase
  include ActiveRecord::Assertions::QueryAssertions
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # 並列実行では worker プロセスごとに計測されるため、名前を分けて結果を合算する
    parallelize_setup do |worker|
      SimpleCov.command_name "Minitest-#{worker}"
    end

    parallelize_teardown do
      SimpleCov.result
    end

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
