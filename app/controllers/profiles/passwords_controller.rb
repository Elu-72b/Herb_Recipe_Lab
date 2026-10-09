module Profiles
  class PasswordsController < ApplicationController
    before_action :require_login_with_alert
    before_action :reject_google_user

    def edit
    end

    def update
      if current_user.update_password(password_params)
        # パスワード変更でセッションが無効になるため、再ログインさせずに維持する
        bypass_sign_in(current_user)
        redirect_to profile_path, notice: "パスワードを変更しました"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def password_params
      params.require(:user).permit(:current_password, :password, :password_confirmation)
    end

    def reject_google_user
      return unless current_user.google_user?

      redirect_to profile_path, alert: "Google ログインのアカウントはパスワードを変更できません"
    end
  end
end
