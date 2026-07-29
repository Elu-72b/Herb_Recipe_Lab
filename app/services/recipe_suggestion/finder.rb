# 聞き取りパラメータから、条件に合う「公開レシピ」を DB から探す。
#
# Gemini を使わないため無料・確実に動く。AI 提案（Generator）が失敗しても
# この結果は表示され続ける、というフォールバックの役割も担う。
#
# 絞り込みは ApplicationController#apply_herb_based_filters と同じ考え方:
#   - 効能・風味は「指定タグをすべて含む」AND 条件
#   - 禁忌は「該当タグを持つハーブを含むレシピ」を除外
# いずれもハーブ経由（recipe → herbs → tags）で判定する。
module RecipeSuggestion
  class Finder
    DEFAULT_LIMIT = 5

    def initialize(params)
      @params = params || {}
    end

    def call(limit: DEFAULT_LIMIT)
      scope = Recipe.public_recipes
      scope = filter_by_all_tags(scope, :functional_tags, @params[:functional_names])
      scope = filter_by_all_tags(scope, :flavor_tags, @params[:flavor_names])
      scope = exclude_by_caution(scope, @params[:exclude_caution_tags])

      scope.includes(:user, :drinking_log, recipe_herbs: :herb)
           .recent
           .limit(limit)
    end

    private

    # 指定タグを「すべて」含むレシピに絞る。
    # タグごとにサブクエリで id を絞るため、join による重複行は発生しない。
    def filter_by_all_tags(scope, tag_association, names)
      normalize(names).each do |name|
        matched_ids = Recipe.joins(herbs: tag_association)
                            .where(tag_association => { name: name })
                            .select(:id)
        scope = scope.where(id: matched_ids)
      end
      scope
    end

    # 指定した禁忌タグを持つハーブを含むレシピを除外する。
    def exclude_by_caution(scope, names)
      names = normalize(names)
      return scope if names.empty?

      excluded_ids = Recipe.joins(herbs: :caution_tags)
                           .where(caution_tags: { name: names })
                           .select(:id)
      scope.where.not(id: excluded_ids)
    end

    def normalize(names)
      Array(names).map { |name| name.to_s.strip }.reject(&:blank?)
    end
  end
end
