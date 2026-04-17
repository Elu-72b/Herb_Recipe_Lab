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
    # ホーム画面用
  end
end
