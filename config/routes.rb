Rails.application.routes.draw do
  get "memberships/index"
  get "memberships/update"
  get "memberships/destroy"

  resources :workspaces do
    collection do
      get :join_with_link
      post :perform_join
    end
    resources :channels
    resources :memberships, only: [ :index, :update, :destroy ]
  end

  devise_for :users

  get "home/index"
  get "join/:invited_token", to: "workspaces#join", as: :join_workspace

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
