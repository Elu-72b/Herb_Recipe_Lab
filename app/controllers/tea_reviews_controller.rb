class TeaReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tea_review, only: [:show, :edit, :update, :destroy]

  def index
    @tea_reviews = current_user.tea_reviews.includes(:herbs).order(created_at: :desc)
  end

  def new
    @tea_review = current_user.tea_reviews.build
    @herbs = Herb.order(:name)
    @flavor_tags = FlavorTag.all
  end

  def create
    @tea_review = current_user.tea_reviews.build(tea_review_params)
    if @tea_review.save
      redirect_to tea_reviews_path, notice: "レビューを登録しました！"
    else
      @herbs = Herb.order(:name)
      @flavor_tags = FlavorTag.all
      render :new, status: :unprocessable_entity
    end
  end

  def show; end

  def edit
    @herbs = Herb.order(:name)
    @flavor_tags = FlavorTag.all
  end

  def update
    if @tea_review.update(tea_review_params)
      redirect_to @tea_review, notice: "レビューを更新しました"
    else
      @herbs = Herb.order(:name)
      @flavor_tags = FlavorTag.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tea_review.destroy
    redirect_to tea_reviews_path, notice: "レビューを削除しました"
  end

  private

  def set_tea_review
    @tea_review = current_user.tea_reviews.find(params[:id])
  end

  def tea_review_params
    params.require(:tea_review).permit(
      :brand, :name, :purchase_place, :description, :rating,
      :sweetness, :acidity, :bitterness, :astringency,
      :fruity, :spicy, :freshness, :flowery, :impression,
      herb_ids: [],
      custom_herb_names: [],
      tea_review_herbs_attributes: [:id, :herb_id, :custom_herb_name, :_destroy]
    )
  end
end
