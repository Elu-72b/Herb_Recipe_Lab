require "test_helper"
require "minitest/mock" # Gemini::Client.new をスタブに差し替えるため

class RecipeSuggestionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # fixture の構成（test/fixtures/recipes.yml・herbs.yml のコメントも参照）:
  #   public_sleep_safe    公開 / リンデン（睡眠サポート・甘味・禁忌なし）
  #   public_sleep_caution 公開 / カモミールジャーマン（妊娠中注意）＋リンデン
  #   private_sleep_safe   非公開 / リンデン
  #   public_skin_care     公開 / ローズヒップ（美肌ケア・酸味）

  test "未ログインで聞き取り画面を開くとログイン画面へリダイレクトする" do
    get recipe_suggestion_url

    assert_redirected_to new_user_session_path
  end

  test "未ログインで送信するとログイン画面へリダイレクトする" do
    post recipe_suggestion_url, params: { functional_names: [ "睡眠サポート" ] }

    assert_redirected_to new_user_session_path
  end

  test "ログイン済みなら聞き取り画面が表示される" do
    sign_in users(:alice)
    get recipe_suggestion_url

    assert_response :success
    assert_select "input[name='functional_names[]'][value='睡眠サポート']"
    assert_select "input[name='flavor_names[]'][value='甘味']"
    assert_select "input[name='exclude_caution_tags[]'][value='妊娠中注意']"
    assert_select "textarea[name='free_text']"
    assert_select "turbo-frame#suggestion_result"
  end

  test "ログイン済みならフッターに聞き取り画面への導線がある" do
    sign_in users(:alice)
    get home_url # root はログイン済みだと home へリダイレクトする

    assert_select "footer a[href=?]", recipe_suggestion_path
  end

  test "未ログインのフッターには聞き取り画面への導線を出さない" do
    get root_url

    assert_select "footer a[href=?]", recipe_suggestion_path, count: 0
  end

  test "送信すると既存の公開レシピとAI提案の両方が表示される" do
    sign_in users(:alice)
    post_suggestion(client: fake_client(proposal("すやすやリンデン", [ "リンデン" ])))

    assert_response :success
    assert_select "turbo-frame#suggestion_result" do
      assert_select "h2", text: "すやすやリンデン"
      assert_select "a[href=?]", recipe_path(recipes(:public_sleep_safe))
    end
  end

  # 分量は比率ではなく「200ml あたりの小さじ杯数」として出す
  test "提案カードにハーブ名と小さじ杯数が表示される" do
    sign_in users(:alice)
    post_suggestion(client: fake_client(proposal("すやすやリンデン", [ "リンデン" ])))

    assert_select "span.tag-herb", text: "リンデン：小さじ1"
    assert_select "p", text: /抽出量 #{RecipeSuggestion::PromptBuilder::BREW_AMOUNT_ML}ml あたり/
  end

  # フレーム内リンクはページ全体で遷移させる（仕様書 §4 Fix-3b）
  test "結果フレームは target=_top を持つ" do
    sign_in users(:alice)
    post_suggestion(client: fake_client(proposal("すやすやリンデン", [ "リンデン" ])))

    assert_select "turbo-frame#suggestion_result[target=?]", "_top"
  end

  test "禁忌を指定すると該当ハーブを含む公開レシピが除外される" do
    sign_in users(:alice)
    post_suggestion(
      params: { functional_names: [ "睡眠サポート" ], exclude_caution_tags: [ "妊娠中注意" ] },
      client: fake_client(proposal("すやすやリンデン", [ "リンデン" ]))
    )

    assert_match recipes(:public_sleep_safe).title, response.body
    assert_no_match recipes(:public_sleep_caution).title, response.body
  end

  test "非公開レシピは提案結果に含まれない" do
    sign_in users(:alice)
    post_suggestion(client: fake_client(proposal("すやすやリンデン", [ "リンデン" ])))

    assert_no_match recipes(:private_sleep_safe).title, response.body
  end

  test "Gemini が失敗しても既存の公開レシピは表示され続ける" do
    sign_in users(:alice)
    post_suggestion(client: failing_client)

    assert_response :success
    assert_match RecipeSuggestion::Generator::ERROR_MESSAGE, response.body
    assert_match recipes(:public_sleep_safe).title, response.body
  end

  test "候補外ハーブだけの提案は表示されない" do
    sign_in users(:alice)
    post_suggestion(client: fake_client(proposal("架空ブレンド", [ "セントジョーンズワート" ])))

    assert_no_match "架空ブレンド", response.body
    assert_match "新しい提案はありませんでした", response.body
  end

  test "送信後もチップの選択状態が残る" do
    sign_in users(:alice)
    post_suggestion(
      params: { functional_names: [ "睡眠サポート" ], free_text: "寝つきが悪い" },
      client: fake_client(proposal("すやすやリンデン", [ "リンデン" ]))
    )

    assert_select "input[name='functional_names[]'][value='睡眠サポート'][checked='checked']"
    assert_select "textarea[name='free_text']", text: "寝つきが悪い"
  end

  private

  # Generator は内部で Gemini::Client.new を呼ぶため、生成をスタブに差し替える。
  def post_suggestion(params: { functional_names: [ "睡眠サポート" ] }, client:)
    Gemini::Client.stub(:new, client) do
      post recipe_suggestion_url, params: params
    end
  end

  class FakeClient
    def initialize(response) = @response = response

    def generate_json(prompt:, schema:) = @response
  end

  class FailingClient
    def generate_json(**) = raise(Gemini::Client::Error, "テスト用の失敗")
  end

  def fake_client(*proposals) = FakeClient.new("proposals" => proposals)

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
