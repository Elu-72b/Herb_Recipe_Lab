Rails.application.routes.draw do
  devise_for :users

  resources :herbs

  root 'static_pages#top'

  devise_scope :user do
    get '/signup', to: 'devise/registrations#new'
  end

  get 'home', to: 'static_pages#home'

  get "up" => "rails/health#show", as: :rails_health_check
end