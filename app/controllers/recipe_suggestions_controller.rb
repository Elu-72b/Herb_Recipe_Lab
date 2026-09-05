# AI ブレンド提案。聞き取り（show）→ 提案（create）の2アクション構成。
#
# create では Finder と Generator の両方を呼ぶ。Generator は例外を投げず error を返すため、
# Gemini が落ちても Finder（DB 由来）の結果は表示され続ける。
# 詳細: .agent/development_plan/20260723_gemini_suggestion_verified_flow_plan.md §2-2
class RecipeSuggestionsController < ApplicationController
  before_action :authenticate_user!

  def show
    load_choices
  end

  def create
    @existing_recipes = RecipeSuggestion::Finder.new(suggestion_params).call
    # 一覧と同じカード（recipes/_card）を使うため、ブックマーク状態もまとめて引く
    @user_bookmarks = current_user.bookmarks.where(recipe: @existing_recipes).to_a

    generated  = RecipeSuggestion::Generator.new(suggestion_params).call
    @proposals = generated[:proposals]
    @ai_error  = generated[:error]

    # 聞き取りフォームを残したまま結果を差し込むため show を再描画する。
    # Turbo は turbo_frame "suggestion_result" だけを差し替える（JS 無効時は全体が再描画される）。
    load_choices
    render :show
  end

  private

  # チップの選択肢。show / create（再描画）で共通に使う。
  def load_choices
    @functional_categories = FunctionalTag.grouped_by_category
    @flavor_tags           = FlavorTag.order(:name)
    @caution_categories    = CautionTag.grouped_by_category
  end

  # パラメータ名は既存の検索フォームと揃えてある（Finder / Generator がそのまま解釈できる）。
  def suggestion_params
    params.permit(:free_text,
                  functional_names: [], flavor_names: [], exclude_caution_tags: [])
  end
end
