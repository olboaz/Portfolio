Rails.application.routes.draw do
  get 'admin/index'
  devise_for :users, skip: [:registrations]
  root to: 'pages#home'
  get "/confidentialite", to: "pages#privacy", as: :privacy
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :projects
  resources :contacts, only: :create
  resources :tools

  get "/admin", to: "admin#index", as: :admin

end
