class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    auth = request.env["omniauth.auth"]
    @user = User.find_for_oauth(auth)

    if @user
      # 連携済み：ログイン画面・新規登録画面どちらから来てもログインさせる
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
    elsif signup_intent?
      create_and_sign_in(auth)
    else
      # 未登録のアカウントでログインしようとした場合はアカウントを作らず新規登録画面へ誘導する
      redirect_to new_user_registration_path,
                  alert: "このGoogleアカウントはまだ登録されていません。「Google で新規登録」からアカウントを作成してください。"
    end
  end

  def failure
    redirect_to root_path, alert: "Google ログインに失敗しました。"
  end

  private

  # 新規登録画面のボタンにだけ付いている signup=true を判定する。
  # OmniAuth は request.GET のみを omniauth.params に載せる仕様。
  def signup_intent?
    request.env["omniauth.params"].try(:[], "signup") == "true"
  end

  def create_and_sign_in(auth)
    @user = User.create_from_omniauth(auth)

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
    else
      session["devise.google_data"] = auth.except("extra")
      redirect_to new_user_registration_path, alert: @user.errors.full_messages.join("\n")
    end
  end
end
