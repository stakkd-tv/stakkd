Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "pages#index"

  resource :session
  resources :passwords, param: :token
  resources :movies
  resources :users, only: [:new, :create]
  resources :genres, only: [:index]
  resources :countries, only: [:index]
  resources :languages, only: [:index]
end
