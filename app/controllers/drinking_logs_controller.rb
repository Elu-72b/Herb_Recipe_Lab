class DrinkingLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_recipe

  def new
    @drinking_log = @recipe.build_drinking_log
  end

  def create
    @drinking_log = @recipe.build_drinking_log(drinking_log_params)
    if @drinking_log.save
      redirect_to home_path, notice: "研究記録を完了しました！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @drinking_log = @recipe.drinking_log
  end

  def edit
    @drinking_log = @recipe.drinking_log
  end

  def update
    @drinking_log = @recipe.drinking_log
    if @drinking_log.update(drinking_log_params)
      redirect_to home_path, notice: "感想を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_recipe
    @recipe = current_user.recipes.find(params[:recipe_id])
  end

  def drinking_log_params
    params.require(:drinking_log).permit(
      :rating, :sweetness, :bitterness, :astringency, :freshness,
      :savory, :spicy, :fruity, :acidity, :impression
    )
  end
end
