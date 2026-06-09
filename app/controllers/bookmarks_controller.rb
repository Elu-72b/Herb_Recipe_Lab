class BookmarksController < ApplicationController
  before_action :require_login_with_alert

  def index
    @active_tab = params[:tab] == "my" ? "my" : "public"

    if @active_tab == "public"
      # 他人がブックマークしたレシピ（自分以外のレシピ）
      @bookmarks = current_user.bookmarks
                              .joins(:recipe)
                              .where.not(recipes: { user_id: current_user.id })
                              .includes(recipe: [:drinking_log, :user, recipe_herbs: :herb])
                              .order(created_at: :desc)
                              .page(params[:page]).per(10)
    else
      # 自分のレシピのブックマーク
      @bookmarks = current_user.bookmarks
                              .joins(:recipe)
                              .where(recipes: { user_id: current_user.id })
                              .includes(recipe: [:drinking_log, :user, recipe_herbs: :herb])
                              .order(created_at: :desc)
                              .page(params[:my_page]).per(10)
    end
  end

  def create
    @recipe = Recipe.find(params[:recipe_id])
    @bookmark = current_user.bookmarks.find_or_initialize_by(recipe: @recipe)
    @bookmark.save
    render_bookmark_turbo
  end

  def destroy
    @bookmark = current_user.bookmarks.find(params[:id])
    @recipe = @bookmark.recipe
    @bookmark.destroy
    render_bookmark_turbo
  end

  private

  def render_bookmark_turbo
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: recipe_path(@recipe) }
    end
  end
end
