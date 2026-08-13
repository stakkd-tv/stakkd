Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # Defines the root path route ("/")
  root "pages#index"

  resource :session
  resources :passwords, param: :token

  draw :movie_routes
  draw :show_routes
  draw :franchise_routes
  draw :people_routes
  draw :company_routes

  resources :users, only: [:show, :new, :create, :update] do
    get :confirm, on: :collection
  end
  get "settings", to: "users#settings", as: :user_settings
  resources :confirmation_tokens, only: [:new, :create], path: "confirmations"

  resources :genres, only: [:index]
  resources :countries, only: [:index]
  resources :languages, only: [:index]

  resources :search, only: [:index, :show]

  get "about" => "pages#about", :as => :about
  get "contribute" => "pages#contribute", :as => :contribute

  post "uploads" => "images#upload", :as => :upload
end
