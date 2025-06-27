Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # Defines the root path route ("/")
  root "pages#index"

  resource :session
  resources :passwords, param: :token
  resources :movies, except: [:destroy] do
    resources :alternative_names, only: [:index, :create, :update]
    resources :genre_assignments, only: [:index, :create, :destroy]
    resources :keywords, only: [:index, :create, :destroy]
    resources :releases, only: [:index, :create, :update, :destroy]
    resources :taglines, only: [:index, :create, :update, :destroy] do
      post :move, on: :member
    end

    get :posters, on: :member
    get :backgrounds, on: :member
    get :logos, on: :member
  end
  resources :users, only: [:new, :create]
  resources :genres, only: [:index]
  resources :countries, only: [:index]
  resources :languages, only: [:index]
  resources :people, except: [:destroy] do
    get :images, on: :member
  end
  resources :companies, except: [:destroy] do
    get :logos, on: :member
  end

  get "about" => "pages#about", :as => :about
  get "contribute" => "pages#contribute", :as => :contribute

  post "uploads" => "images#upload", :as => :upload
end
