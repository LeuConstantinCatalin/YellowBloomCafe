Rails.application.routes.draw do
  # Root/Home Page
  root "home#index"

  # Pages
  get "menu",    to: "menu#index"
  get "gallery", to: "gallery#index"
  get "account", to: "account#index"

  get "angajat", to: "angajat_controls#index"

  resources :users, only: [:create]
  resources :account, only: [:index, :create]
end
