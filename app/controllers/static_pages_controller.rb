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
    # みんなのブレンド（公開レシピ全件。自分のも含む）
    @public_recipes = Recipe
      .includes(:user, :drinking_log, recipe_herbs: :herb)
      .public_recipes
      .recent
      .page(params[:page]).per(10)

    # 自分のブレンド（非公開含む）
    @my_recipes = current_user.recipes
      .includes(:drinking_log, recipe_herbs: :herb)
      .recent
      .page(params[:my_page]).per(10)
  end
end
