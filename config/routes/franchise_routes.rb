resources :franchises, except: [:destroy] do
  resources :galleries, only: [] do
    get :posters, on: :collection
    get :backgrounds, on: :collection
    get :logos, on: :collection
  end
  resources :franchise_items, only: [:create, :destroy], path: "items" do
    get :editor, on: :collection
  end

  get :posters, on: :member
  get :backgrounds, on: :member
  get :logos, on: :member
end
