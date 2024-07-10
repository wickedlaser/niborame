Rails.application.routes.draw do
  resources :shoplist, only: %i[index show]
  root 'pages#index'

  get 'pages/index'
  get 'shoplist/index'
  get 'data_check', to: 'pages#data_check'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Define other routes as needed
end
