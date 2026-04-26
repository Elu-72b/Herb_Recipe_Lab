Rails.application.routes.draw do
  devise_for :users

  # 未ログインなら static_pages#top（ログインフォーム付き）を表示し、
  # ログイン済みなら Controller 側で home へリダイレクトさせます。
  root 'static_pages#top'

  resources :herbs, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  resources :recipes do
    resources :drinking_logs, only: [:new, :create, :show, :edit, :update]
  end

  devise_scope :user do
    get '/signup', to: 'devise/registrations#new'
  end

  get 'home', to: 'static_pages#home'
  get 'profile', to: 'profiles#show'
  get 'bookmarks', to: 'bookmarks#index'

  get "up" => "rails/health#show", as: :rails_health_check
end