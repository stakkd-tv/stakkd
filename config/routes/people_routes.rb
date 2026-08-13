resources :people, except: [:destroy] do
  get :images, on: :member
  resources :galleries, only: [] do
    get :images, on: :collection
  end
end
