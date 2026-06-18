class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :search_active?

  # 検索条件（ransack の q[] もしくは独立パラメーター）が1つでも指定されているか
  def search_active?
    return true if params[:q]&.values&.any?(&:present?)

    %i[herb_names flavor_names functional_categories functional_names exclude_caution_tags]
      .any? { |key| Array(params[key]).any?(&:present?) }
  end

  protected

  def require_login_with_alert
    unless user_signed_in?
      flash[:alert] = "ログインまたは新規登録が必要です"
      redirect_to new_user_session_path
    end
  end

  def configure_permitted_parameters
    # サインアップ時に name カラムの保存を許可する
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  # ── リッチ絞り込みのまとめ適用 ──────────────────────────────
  # Recipe / TeaReview のように配合ハーブ（has_many :herbs through）経由でタグが
  # 紐づくモデル向け。ハーブAND・風味・効能・禁忌除外をまとめて適用する。
  def apply_herb_based_filters(scope, model:)
    scope = filter_by_herb_names(scope, model: model)
    scope = filter_by_flavor_names(scope, model: model, tag_join: { herbs: :flavor_tags })
    scope = filter_by_functional_categories(scope, model: model, tag_join: { herbs: :functional_tags })
    filter_by_excluded_caution_tags(scope, model: model, tag_join: { herbs: :caution_tags })
  end

  # Herb 図鑑のようにタグが直結するモデル向け。
  # ハーブAND・評価は存在しないため、風味・効能・禁忌除外のみ適用する。
  def apply_herb_self_filters(scope)
    scope = filter_by_flavor_names(scope, model: Herb, tag_join: :flavor_tags)
    scope = filter_by_functional_categories(scope, model: Herb, tag_join: :functional_tags)
    filter_by_excluded_caution_tags(scope, model: Herb, tag_join: :caution_tags)
  end

  # ── 個別フィルター（モデルと join 経路を受け取る） ──────────
  # herb_names[] で AND 絞り込み（全ハーブを含むレコードのみ）。has_many :herbs 前提。
  def filter_by_herb_names(scope, model:)
    names = Array(params[:herb_names]).map(&:strip).reject(&:blank?)
    names.each do |name|
      ids = model.joins(:herbs).where(herbs: { name: name }).select(:id)
      scope = scope.where(id: ids)
    end
    scope
  end

  # exclude_caution_tags[] で除外検索（指定タグを持つレコードを除外）
  def filter_by_excluded_caution_tags(scope, model:, tag_join:)
    names = Array(params[:exclude_caution_tags]).map(&:strip).reject(&:blank?)
    return scope if names.empty?

    excluded_ids = model.joins(tag_join).where(caution_tags: { name: names }).select(:id)
    scope.where.not(id: excluded_ids)
  end

  # flavor_names[] で AND 絞り込み（最大2件、全ての風味を持つレコードのみ）
  def filter_by_flavor_names(scope, model:, tag_join:)
    names = Array(params[:flavor_names]).map(&:strip).reject(&:blank?).first(2)
    names.each do |name|
      ids = model.joins(tag_join).where(flavor_tags: { name: name }).select(:id)
      scope = scope.where(id: ids)
    end
    scope
  end

  # functional_categories[] / functional_names[] による効能絞り込み（ペアごとに AND 検索）
  # 各ペアについて functional_names[i] 指定時はそのタグ、未指定で functional_categories[i] 指定時はその分類に属する全タグを OR 検索
  def filter_by_functional_categories(scope, model:, tag_join:)
    categories = Array(params[:functional_categories])
    names      = Array(params[:functional_names])

    categories.each_with_index do |category, i|
      category = category.to_s.strip
      name     = names[i].to_s.strip
      next if category.blank? && name.blank?

      tag_names = name.present? ? [name] : (FunctionalTag::CATEGORIES[category] || [])
      ids = model.joins(tag_join).where(functional_tags: { name: tag_names }).select(:id)
      scope = scope.where(id: ids)
    end

    scope
  end

  def after_sign_up_path_for(resource)
    home_path
  end

  def after_sign_in_path_for(resource)
    home_path
  end
end
