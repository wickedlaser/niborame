Rails.application.routes.draw do
  resources :shoplist, only: %i[index show]
  get 'admin/login', to: 'admin_sessions#new', as: :admin_login
  post 'admin/login', to: 'admin_sessions#create'
  delete 'admin/logout', to: 'admin_sessions#destroy', as: :admin_logout
  resources :admin_shops, path: 'admin/shops', only: %i[index new create edit update destroy]
  delete 'admin/shops/:id/image', to: 'admin_shops#remove_image', as: :remove_image_admin_shop
  get 'contact', to: 'contacts#new', as: :contact
  post 'contact', to: 'contacts#create'
  get 'terms', to: 'pages#terms', as: :terms
  get 'privacy', to: 'pages#privacy', as: :privacy
  root 'pages#index'

  get 'pages/index'
  get 'data_check', to: 'pages#data_check'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Define other routes as needed
end
