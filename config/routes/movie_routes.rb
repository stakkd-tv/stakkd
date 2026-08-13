resources :movies, except: [:destroy] do
  resources :alternative_names, only: [:index, :create, :update], path: "alternative-names"
  resources :cast_members, only: [:index, :create, :update, :destroy], path: "cast-members" do
    post :move, on: :member
  end
  resources :crew_members, only: [:index, :create, :update, :destroy], path: "crew-members"
  resources :genre_assignments, only: [:index, :create, :destroy], path: "genre-assignments"
  resources :keywords, only: [:index, :create, :destroy]
  resources :company_assignments, only: [:index, :create, :destroy], path: "company-assignments"
  resources :releases, only: [:index, :create, :update, :destroy] do
    get :editor, on: :collection
  end
  resources :taglines, only: [:index, :create, :update, :destroy] do
    post :move, on: :member
  end
  resources :videos, only: [:index, :create, :destroy]
  resources :galleries, only: [] do
    get :posters, on: :collection
    get :backgrounds, on: :collection
    get :logos, on: :collection
    get :videos, on: :collection
  end

  get :posters, on: :member
  get :poster, on: :member
  get :backgrounds, on: :member
  get :logos, on: :member
  get :cast, on: :member

  post :add_to_history, on: :member

  delete :remove_from_history, on: :member
end
