class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :configure_ransack

  protected

  def require_login_with_alert
    unless user_signed_in?
      flash[:alert] = "ログインまたは新規登録が必要です"
      redirect_to new_user_session_path
    end
  end

  def configure_permitted_parameters
    # サインアップ時に name カラムの保存を許可する
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def configure_ransack
    Ransack.configure do |config|
      config.sanitize_custom_scope_booleans = false
    end
  end

  def after_sign_up_path_for(resource)
    home_path
  end

  def after_sign_in_path_for(resource)
    home_path
  end
end
