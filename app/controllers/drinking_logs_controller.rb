class DrinkingLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_recipe

  def new
    @drinking_log = @recipe.build_drinking_log
    @flavor_tags = FlavorTag.all
  end

  def create
    @drinking_log = @recipe.build_drinking_log(drinking_log_params)
    if @drinking_log.save
      @recipe.update(is_public: params.dig(:recipe, :is_public) == "1")
      redirect_to home_path, notice: "研究記録を完了しました！"
    else
      @flavor_tags = FlavorTag.all
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @drinking_log = @recipe.drinking_log
  end

  def edit
    @drinking_log = @recipe.drinking_log
    @flavor_tags = FlavorTag.all
  end

  def update
    @drinking_log = @recipe.drinking_log
    if @drinking_log.update(drinking_log_params)
      redirect_to home_path, notice: "感想を更新しました"
    else
      @flavor_tags = FlavorTag.all
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_recipe
    @recipe = current_user.recipes.includes(recipe_herbs: :herb).find(params[:recipe_id])
  end

  def drinking_log_params
    params.require(:drinking_log).permit(
      :rating, :sweetness, :bitterness, :astringency, :freshness,
      :spicy, :fruity, :acidity, :flowery, :impression
    )
  end
end
