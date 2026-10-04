RailsAdmin.config do |config|
  config.asset_source = :sprockets

  # ApplicationController を継承させ、rescue_from CanCan::AccessDenied を /admin にも効かせる
  config.parent_controller = "::ApplicationController"

  # Devise 連携（未ログインはログイン画面へ）
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  # 認可は cancancan の Ability に委譲
  config.authorize_with :cancancan

  # bulk_delete は誤操作防止のため含めない。
  # history_* は監査アダプタ（paper_trail 等）が無いと動かないため含めない。
  config.actions do
    dashboard
    index
    new
    export
    show
    edit
    delete
  end
end
