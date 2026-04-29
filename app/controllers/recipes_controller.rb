# app/controllers/recipes_controller.rb
class RecipesController < ApplicationController
  before_action :authenticate_user!

  def index
    @recipes = Recipe.includes(:user).where(is_public: true).order(created_at: :desc)
  end

  def new
    @recipe = Recipe.new
    @recipe.recipe_herbs.build  # フォームに最初から1行表示するため
    @herbs = Herb.order(:name)
  end

  def create
    @recipe = current_user.recipes.build(recipe_params)

    if @recipe.save
      redirect_to new_recipe_drinking_log_path(@recipe), notice: "ブレンドを記録しました！続いて感想を入力しましょう。"
    else
      # バリデーション失敗時はフォームを再表示
      @recipe.recipe_herbs.build if @recipe.recipe_herbs.empty?
      @herbs = Herb.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @recipe = Recipe.includes(:user, :drinking_log,
      recipe_herbs: { herb: [:flavor_tags, :functional_tags, :caution_tags] }
    ).find(params[:id])
  end

  def edit
    @recipe = current_user.recipes.find(params[:id])
    @herbs = Herb.order(:name)
  end

  def update
    @recipe = current_user.recipes.find(params[:id])

    if @recipe.update(recipe_params)
      redirect_to recipe_path(@recipe), notice: "レシピを更新しました！"
    else
      @herbs = Herb.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recipe = current_user.recipes.find(params[:id])
    @recipe.destroy
    redirect_to home_path, notice: "レシピを削除しました"
  end

  private

  def recipe_params
    params.require(:recipe).permit(
      :title,
      :brewed_at,
      :amount,
      :memo,
      :is_public,
      recipe_herbs_attributes: [:id, :herb_id, :quantity, :unit, :_destroy, :custom_herb_name]
    )
  end
end