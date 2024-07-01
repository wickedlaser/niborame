Rails.application.routes.draw do
  resources :shoplist, only: [:index, :show]
  root 'pages#index'

  get 'pages/index'
  get 'shoplist/index'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Define other routes as needed
end