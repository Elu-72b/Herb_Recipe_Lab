class StaticPagesController < ApplicationController
  before_action :authenticate_user!, only: [:home]
  def top
    # ログイン済みなら home へリダイレクト
    redirect_to home_path if user_signed_in?
  end

  def signup
    # 新規登録画面用
  end

  # 利用規約（未ログインでも閲覧可。authenticate_user! の対象外）
  def terms
  end

  # プライバシーポリシー（未ログインでも閲覧可）
  def privacy
  end

  def home
    @active_tab = params[:tab] == "my" ? "my" : "public"

    if @active_tab == "public"
      @q = Recipe.public_recipes.ransack(params[:q])
      base = apply_herb_based_filters(Recipe.public_recipes.where(id: @q.result.select(:id)), model: Recipe)
      @public_recipes = base
        .includes(:user, :drinking_log, recipe_herbs: :herb)
        .recent
        .page(params[:page]).per(10)
    else
      @q = current_user.recipes.ransack(params[:q])
      base = apply_herb_based_filters(current_user.recipes.where(id: @q.result.select(:id)), model: Recipe)
      @my_recipes = base
        .includes(:user, :drinking_log, recipe_herbs: :herb)
        .recent
        .page(params[:my_page]).per(10)
    end

    loaded_recipes = @public_recipes || @my_recipes || []
    @user_bookmarks = current_user.bookmarks.where(recipe: loaded_recipes).to_a
  end
end
