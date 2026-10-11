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

  def destroy
    if current_user.destroy
      sign_out(:user)
      redirect_to root_path, notice: t("devise.registrations.destroyed"), status: :see_other
    else
      redirect_to profile_path, alert: current_user.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :email, :current_password)
  end
end
