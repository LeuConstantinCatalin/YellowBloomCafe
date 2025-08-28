Rails.application.routes.draw do
  # Root/Home Page
  root "home#index"

  # Pages
  get "menu",    to: "menu#index"
  get "gallery", to: "gallery#index"
  get "account", to: "account#index"

  # Employee dashboard
  get "employee", to: "employee_controls#index", as: :employee
  patch "employee/ingredients/:id", to: "employee_controls#update_ingredient", as: :employee_ingredient

  resources :users, only: [:create]
  resources :account, only: [:index, :create]
  patch "account", to: "account#update"
  delete "account", to: "account#destroy"
  post "logout", to: "account#logout", as: :logout

  # Email verification flow
  get  "verify_email", to: "email_verifications#new",    as: :verify_email
  post "verify_email", to: "email_verifications#create"
  post "verify_email/resend", to: "email_verifications#resend", as: :resend_verification

  # Letter Opener web UI (development only)
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
