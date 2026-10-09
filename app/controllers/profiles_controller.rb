class ProfilesController < ApplicationController
  before_action :require_login_with_alert

  def show
  end

  def edit
  end

  def update
    if current_user.update_profile(profile_params)
      notice = current_user.try(:pending_reconfirmation?) ? t("devise.registrations.update_needs_confirmation") : "プロフィールを更新しました"
      redirect_to profile_path, notice: notice
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :email, :current_password)
  end
end
