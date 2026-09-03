# 聞き取り条件から Gemini に新規ブレンドを生成させる。
#
# Finder（既存レシピ検索）と対になるサービス。Gemini が落ちても例外を投げず、
# error にメッセージを入れて返すことで、Finder の結果表示を壊さない。
module RecipeSuggestion
  class Generator
    MAX_PROPOSALS = PromptBuilder::MAX_PROPOSALS
    ERROR_MESSAGE = "提案の生成に失敗しました。しばらく待ってからお試しください。".freeze

    # client: テストでスタブに差し替えるための注入口
    def initialize(params, client: nil)
      @params = params || {}
      @client = client
    end

    # 返り値: { proposals: [...], error: nil | "メッセージ" }
    def call
      herbs  = available_herbs
      return { proposals: [], error: ERROR_MESSAGE } if herbs.empty?

      prompt = PromptBuilder.new(params: @params, available_herbs: herbs).build
      result = client.generate_json(prompt: prompt, schema: PromptBuilder::SCHEMA)

      { proposals: sanitize(result["proposals"], herbs), error: nil }
    rescue Gemini::Client::Error => e
      Rails.logger.warn("[RecipeSuggestion::Generator] #{e.message}")
      { proposals: [], error: ERROR_MESSAGE }
    end

    private

    def client
      @client ||= Gemini::Client.new
    end

    # 禁忌タグに該当するハーブを除いた候補を、プロンプト用の Hash 配列で返す
    def available_herbs
      scope = Herb.includes(:flavor_tags, :functional_tags, :caution_tags)
      excluded = normalize(@params[:exclude_caution_tags])

      if excluded.present?
        ng_ids = Herb.joins(:caution_tags).where(caution_tags: { name: excluded }).select(:id)
        scope = scope.where.not(id: ng_ids)
      end

      scope.map do |herb|
        {
          name:      herb.name,
          flavors:   herb.flavor_tags.map(&:name),
          functions: herb.functional_tags.map(&:name),
          cautions:  herb.caution_tags.map(&:name)
        }
      end
    end

    # 候補外ハーブ（ハルシネーション）を除去し、全滅したレシピは破棄して件数を絞る
    def sanitize(proposals, herbs)
      valid_names = herbs.map { |herb| herb[:name] }.to_set

      Array(proposals).filter_map { |proposal|
        kept = Array(proposal["herbs"]).select { |herb| valid_names.include?(herb["name"]) }
        next if kept.empty?

        proposal.merge("herbs" => kept)
      }.first(MAX_PROPOSALS)
    end

    def normalize(names)
      Array(names).map { |name| name.to_s.strip }.reject(&:blank?)
    end
  end
end
