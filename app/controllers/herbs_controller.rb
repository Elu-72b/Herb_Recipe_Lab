class HerbsController < ApplicationController
  before_action :set_herb, only: [:show, :edit, :update, :destroy]
  before_action :set_tags, only: [:new, :create, :edit, :update]

  def index
    @herbs = Herb.all.includes(:flavor_tags, :functional_tags)
  end

  def show
  end

  def new
    @herb = Herb.new
  end

  def create
    @herb = Herb.new(herb_params)
    if @herb.save
      redirect_to @herb, notice: "ハーブを登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @herb.update(herb_params)
      redirect_to @herb, notice: "更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @herb.destroy
    redirect_to herbs_path, notice: "削除しました"
  end

  private

  def set_herb
    @herb = Herb.find(params[:id])
  end

  def set_tags
    @flavor_tags = FlavorTag.all
    @grouped_functional_tags = FunctionalTag.grouped_by_category
    @grouped_caution_tags = CautionTag.grouped_by_category
  end

  private

  def herb_params
    params.require(:herb).permit(
      :name, :description, :caution, :image,
      flavor_tag_ids: [],      # 複数選択のため配列で受け取る
      functional_tag_ids: [],
      caution_tag_ids: []
    )
  end
end
