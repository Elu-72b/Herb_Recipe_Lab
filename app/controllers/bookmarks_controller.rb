class BookmarksController < ApplicationController
  before_action :require_login_with_alert

  def index
    @bookmarks = current_user.bookmarks.includes(recipe: [:drinking_log, :user, recipe_herbs: :herb]).order(created_at: :desc)
    # N+1対策: パーシャルで使う bookmarked_recipe_ids を一括取得
    @bookmarked_recipe_ids = current_user.bookmarks.pluck(:recipe_id).to_set
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
