require "test_helper"

module Gemini
  class ClientTest < ActiveSupport::TestCase
    SCHEMA = { type: "OBJECT", properties: { name: { type: "STRING" } } }.freeze

    setup do
      # .env の値に左右されないよう退避してから固定する
      @original = ENV.to_h.slice("GEMINI_API_KEY", "GEMINI_MODEL")
      ENV["GEMINI_API_KEY"] = "test-key"
      ENV.delete("GEMINI_MODEL")
    end

    teardown do
      ENV.delete("GEMINI_API_KEY")
      ENV.delete("GEMINI_MODEL")
      @original.each { |key, value| ENV[key] = value }
    end

    test "既定モデルは提供終了したものを指さない" do
      assert_not_equal "gemini-2.0-flash", Client::DEFAULT_MODEL
      assert_equal "gemini-3.1-flash-lite", Client::DEFAULT_MODEL
    end

    test "既定モデルでリクエストする" do
      path = nil
      client = build_client { |env| path = env.url.path; [ 200, {}, success_body ] }
      client.generate_json(prompt: "x", schema: SCHEMA)

      assert_includes path, "models/#{Client::DEFAULT_MODEL}:generateContent"
    end

    test "GEMINI_MODELで既定モデルを上書きできる" do
      ENV["GEMINI_MODEL"] = "gemini-flash-latest"
      path = nil
      client = build_client { |env| path = env.url.path; [ 200, {}, success_body ] }
      client.generate_json(prompt: "x", schema: SCHEMA)

      assert_includes path, "models/gemini-flash-latest:generateContent"
    end

    test "GEMINI_MODELが空文字なら既定モデルを使う" do
      ENV["GEMINI_MODEL"] = ""
      path = nil
      client = build_client { |env| path = env.url.path; [ 200, {}, success_body ] }
      client.generate_json(prompt: "x", schema: SCHEMA)

      assert_includes path, "models/#{Client::DEFAULT_MODEL}:generateContent"
    end

    test "APIキーをヘッダで送る" do
      key = nil
      client = build_client { |env| key = env.request_headers["x-goog-api-key"]; [ 200, {}, success_body ] }
      client.generate_json(prompt: "x", schema: SCHEMA)

      assert_equal "test-key", key
    end

    test "正常応答のJSONをパースして返す" do
      client = build_client { [ 200, {}, success_body({ "name" => "リンデン" }) ] }

      assert_equal({ "name" => "リンデン" }, client.generate_json(prompt: "x", schema: SCHEMA))
    end

    test "404はモデル名を含むメッセージになる" do
      client = build_client { [ 404, {}, "{}" ] }
      error = assert_raises(Client::Error) { client.generate_json(prompt: "x", schema: SCHEMA) }

      assert_match(/利用できません/, error.message)
      assert_match Client::DEFAULT_MODEL, error.message
    end

    test "503は一時的な混雑と分かるメッセージになる" do
      client = build_client { [ 503, {}, "{}" ] }
      error = assert_raises(Client::Error) { client.generate_json(prompt: "x", schema: SCHEMA) }

      assert_match(/混み合っています/, error.message)
    end

    test "401は認証エラーと分かるメッセージになる" do
      client = build_client { [ 401, {}, "{}" ] }
      error = assert_raises(Client::Error) { client.generate_json(prompt: "x", schema: SCHEMA) }

      assert_match(/認証に失敗/, error.message)
    end

    test "タイムアウトをErrorに変換する" do
      client = build_client { raise Faraday::TimeoutError }
      error = assert_raises(Client::Error) { client.generate_json(prompt: "x", schema: SCHEMA) }

      assert_match(/タイムアウト/, error.message)
    end

    test "JSONとして壊れた本文はErrorにする" do
      client = build_client { [ 200, {}, success_body_raw("これはJSONではない") ] }
      error = assert_raises(Client::Error) { client.generate_json(prompt: "x", schema: SCHEMA) }

      assert_match(/パース失敗/, error.message)
    end

    test "候補が空ならErrorにする" do
      client = build_client { [ 200, {}, { "candidates" => [] }.to_json ] }
      error = assert_raises(Client::Error) { client.generate_json(prompt: "x", schema: SCHEMA) }

      assert_match(/空レスポンス/, error.message)
    end

    test "APIキー未設定ならリクエストせずErrorにする" do
      ENV.delete("GEMINI_API_KEY")
      error = assert_raises(Client::Error) do
        Client.new.generate_json(prompt: "x", schema: SCHEMA)
      end

      assert_match(/GEMINI_API_KEY 未設定/, error.message)
    end

    private

    def build_client(&stub)
      stubs = Faraday::Adapter::Test::Stubs.new
      # f.response :json は Content-Type を見てパースするため、スタブ側で必ず付与する
      stubs.post(/generateContent/) do |env|
        status, headers, body = stub.call(env)
        [ status, { "Content-Type" => "application/json" }.merge(headers || {}), body ]
      end

      connection = Faraday.new do |f|
        f.request :json
        f.response :json
        f.adapter :test, stubs
      end

      Client.new(connection: connection)
    end

    # Gemini のレスポンス構造（candidates → content → parts → text）を再現する
    def success_body(payload = { "name" => "リンデン" })
      success_body_raw(payload.to_json)
    end

    def success_body_raw(text)
      { "candidates" => [ { "content" => { "parts" => [ { "text" => text } ] } } ] }.to_json
    end
  end
end
