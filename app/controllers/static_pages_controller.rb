class StaticPagesController < ApplicationController
  before_action :authenticate_user!, only: [:home]
  def top
    # ログイン済みなら home へリダイレクト
    redirect_to home_path if user_signed_in?
  end

  def signup
    # 新規登録画面用
  end

  def home
    # 公開レシピ OR 自分のレシピ（非公開含む）を取得
    @recipes = Recipe
      .includes(:user, :drinking_log, recipe_herbs: :herb)
      .where("is_public = ? OR user_id = ?", true, current_user.id)
      .recent
  end
end
