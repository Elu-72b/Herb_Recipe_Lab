require "test_helper"

module RecipeSuggestion
  class GeneratorTest < ActiveSupport::TestCase
    # fixture のハーブは3件。「妊娠中注意」を持つのは カモミールジャーマン のみ。
    #   linden    リンデン           禁忌なし
    #   chamomile カモミールジャーマン 妊娠中注意・アレルギー注意
    #   rosehip   ローズヒップ        禁忌なし

    test "禁忌未指定なら全ハーブが候補になる" do
      client = fake_client(proposal("お試し", [ "リンデン", "カモミールジャーマン" ]))
      Generator.new({}, client: client).call

      assert_includes client.prompt, "カモミールジャーマン"
    end

    test "禁忌に該当するハーブを候補から除外する" do
      client = fake_client(proposal("お試し", [ "リンデン" ]))
      Generator.new({ exclude_caution_tags: [ "妊娠中注意" ] }, client: client).call

      assert_not_includes client.prompt, "カモミールジャーマン"
      assert_includes client.prompt, "リンデン"
    end

    test "候補外ハーブを除去し有効なハーブは残す" do
      client = fake_client(proposal("混在", [ "リンデン", "セントジョーンズワート" ]))
      result = Generator.new({}, client: client).call

      assert_equal [ "リンデン" ], result[:proposals].first["herbs"].map { |h| h["name"] }
    end

    test "候補外ハーブだけのレシピは破棄する" do
      client = fake_client(
        proposal("偽物", [ "セントジョーンズワート" ]),
        proposal("本物", [ "リンデン" ])
      )
      result = Generator.new({}, client: client).call

      assert_equal [ "本物" ], result[:proposals].map { |p| p["title"] }
    end

    test "禁忌で除外したハーブを含む提案も除去する" do
      client = fake_client(proposal("禁忌入り", [ "リンデン", "カモミールジャーマン" ]))
      result = Generator.new({ exclude_caution_tags: [ "妊娠中注意" ] }, client: client).call

      assert_equal [ "リンデン" ], result[:proposals].first["herbs"].map { |h| h["name"] }
    end

    test "上限を超える提案は切り詰める" do
      proposals = 5.times.map { |i| proposal("提案#{i}", [ "リンデン" ]) }
      result = Generator.new({}, client: fake_client(*proposals)).call

      assert_equal Generator::MAX_PROPOSALS, result[:proposals].size
    end

    test "正常時はerrorがnilになる" do
      result = Generator.new({}, client: fake_client(proposal("お試し", [ "リンデン" ]))).call

      assert_nil result[:error]
    end

    test "API失敗時は例外を投げずerrorを返す" do
      result = Generator.new({}, client: failing_client).call

      assert_empty result[:proposals]
      assert_equal Generator::ERROR_MESSAGE, result[:error]
    end

    test "候補が0件ならAPIを呼ばない" do
      client = fake_client(proposal("呼ばれないはず", [ "リンデン" ]))
      all_cautions = CautionTag.pluck(:name)
      Herb.find_each { |herb| herb.caution_tags = CautionTag.all }

      result = Generator.new({ exclude_caution_tags: all_cautions }, client: client).call

      assert_nil client.prompt, "候補0件のときは generate_json を呼ばないこと"
      assert_equal Generator::ERROR_MESSAGE, result[:error]
    end

    private

    # 呼ばれたプロンプトを記録するスタブ
    class FakeClient
      attr_reader :prompt

      def initialize(response) = @response = response

      def generate_json(prompt:, schema:)
        @prompt = prompt
        @response
      end
    end

    class FailingClient
      def generate_json(**) = raise(Gemini::Client::Error, "テスト用の失敗")
    end

    def fake_client(*proposals)
      FakeClient.new("proposals" => proposals)
    end

    def failing_client = FailingClient.new

    def proposal(title, herb_names)
      {
        "title"  => title,
        "reason" => "理由",
        "effect" => "効果",
        "flavor" => "風味",
        "herbs"  => herb_names.map { |name| { "name" => name, "parts" => 1 } }
      }
    end
  end
end
