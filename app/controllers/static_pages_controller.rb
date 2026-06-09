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
    @active_tab = params[:tab] == "my" ? "my" : "public"
    # bookmarks をオブジェクトごとロードしてビューで find できるようにする
    @user_bookmarks = current_user.bookmarks.to_a

    if @active_tab == "public"
      @public_recipes = Recipe
        .includes(:user, :drinking_log, recipe_herbs: :herb)
        .public_recipes
        .recent
        .page(params[:page]).per(10)
    else
      @my_recipes = current_user.recipes
        .includes(:drinking_log, recipe_herbs: :herb)
        .recent
        .page(params[:my_page]).per(10)
    end
  end
end
