resources :companies, except: [:destroy] do
  get :logos, on: :member
  resources :galleries, only: [] do
    get :logos, on: :collection
  end
end
