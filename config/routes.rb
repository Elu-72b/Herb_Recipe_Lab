Rails.application.routes.draw do
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  # 未ログインなら static_pages#top（ログインフォーム付き）を表示し、
  # ログイン済みなら Controller 側で home へリダイレクトさせます。
  root 'static_pages#top'

  resources :herbs, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    collection do
      get :autocomplete
    end
  end
  resources :tea_reviews, only: [:index, :new, :create, :show, :edit, :update, :destroy]
  resources :recipes do
    resources :drinking_logs, only: [:new, :create, :show, :edit, :update]
  end

  devise_scope :user do
    get '/signup', to: 'devise/registrations#new'
  end

  get 'home', to: 'static_pages#home'
  get 'profile', to: 'profiles#show'

  # 利用規約・プライバシーポリシー（未ログインでも閲覧可）
  get 'terms',   to: 'static_pages#terms'
  get 'privacy', to: 'static_pages#privacy'

  resources :bookmarks, only: [:index, :create, :destroy]

  get "up" => "rails/health#show", as: :rails_health_check
end