# Gemini generateContent を叩く薄いラッパー。
# JSON Schema(Structured Output) を渡し、レスポンス本文(JSON文字列)をパースして返す。
#
# 設計方針（.agent/development_plan/20260723_gemini_suggestion_verified_flow_plan.md §4 Fix-1/2）:
# - 専用 gem は導入せず Faraday を直接利用する。
# - 設定値はクラス内定数に集約する（initializer は作らない = Zeitwerk 名前空間の二重定義を回避）。
# - API キーは URL クエリではなくヘッダ(x-goog-api-key)で送る（ログ漏洩対策）。
module Gemini
  class Client
    class Error < StandardError; end

    ENDPOINT     = "https://generativelanguage.googleapis.com/v1beta".freeze
    # 既定モデル。2026-09-02 に実APIで疎通を確認したものを指定する。
    # 使用不可を確認済み:
    #   gemini-2.0-flash  … 提供終了(404)
    #   gemini-2.5-flash  … 新規ユーザーには未提供(404)
    #   gemini-flash-latest … 恒常的に高負荷(503)
    DEFAULT_MODEL = "gemini-flash-lite-latest".freeze
    TIMEOUT      = 20
    OPEN_TIMEOUT = 5

    def self.configured?
      ENV["GEMINI_API_KEY"].present?
    end

    # connection: テストで Faraday のスタブを差し込むための注入口。
    #             本番では nil のまま、内部で組み立てた接続を使う。
    # ENV.fetch は空文字を既定値に落とさないため presence で判定する
    # （本番で GEMINI_MODEL="" が設定された場合の事故を防ぐ）
    def initialize(model: ENV["GEMINI_MODEL"].presence || DEFAULT_MODEL, connection: nil)
      @model = model
      @connection = connection
    end

    # prompt: String / schema: Hash(responseSchema)
    # 返り値: パース済み Hash（responseSchema に沿った構造）
    def generate_json(prompt:, schema:, temperature: 0.7)
      raise Error, "GEMINI_API_KEY 未設定" unless self.class.configured?

      response = connection.post("models/#{@model}:generateContent") do |req|
        # Fix-2: API キーはクエリではなくヘッダで送る
        req.headers["x-goog-api-key"] = ENV["GEMINI_API_KEY"]
        req.body = request_body(prompt, schema, temperature)
      end
      raise Error, error_message(response.status) unless response.success?

      extract_json(response.body)
    rescue Faraday::TimeoutError
      raise Error, "Gemini API タイムアウト"
    rescue Faraday::Error => e
      raise Error, "Gemini 接続エラー: #{e.message}"
    end

    private

    # 原因ごとに文言を分ける。利用側がそのまま画面に出せる粒度にする。
    def error_message(status)
      case status
      when 400      then "リクエストが不正です（モデル名やスキーマを確認してください）"
      when 401, 403 then "Gemini API の認証に失敗しました（APIキーを確認してください）"
      when 404      then "モデル「#{@model}」は利用できません（提供終了の可能性があります）"
      when 429      then "Gemini API の利用上限に達しました。しばらく待ってからお試しください"
      when 503      then "Gemini API が混み合っています。しばらく待ってからお試しください"
      else "Gemini API エラー: #{status}"
      end
    end

    def connection
      @connection ||= Faraday.new(url: ENDPOINT) do |f|
        f.request :json
        f.response :json
        f.options.timeout      = TIMEOUT
        f.options.open_timeout = OPEN_TIMEOUT
      end
    end

    def request_body(prompt, schema, temperature)
      {
        contents: [ { parts: [ { text: prompt } ] } ],
        generationConfig: {
          temperature: temperature,
          responseMimeType: "application/json",
          responseSchema: schema
        }
      }
    end

    def extract_json(body)
      text = body.dig("candidates", 0, "content", "parts", 0, "text")
      raise Error, "空レスポンス" if text.blank?

      JSON.parse(text)
    rescue JSON::ParserError
      raise Error, "JSON パース失敗"
    end
  end
end
