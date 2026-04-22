Rails.application.routes.draw do
  devise_for :users

  # 1. ルートパス（/）の設定
  # 未ログインなら static_pages#top（ログインフォーム付き）を表示し、
  # ログイン済みなら Controller 側で home へリダイレクトさせます。
  root 'static_pages#top'

  resources :herbs, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  resources :recipes do
    resources :drinking_logs, only: [:new, :create, :show, :edit, :update]
  end
  # 2. 新規登録画面のURLをシンプルにする（任意）
  # /users/sign_up ではなく /signup でアクセスしたい場合に残します。
  devise_scope :user do
    get '/signup', to: 'devise/registrations#new'
  end

  # 3. 認証後のメイン画面
  get 'home', to: 'static_pages#home'

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
