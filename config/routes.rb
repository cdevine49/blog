Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    resources :users, only: [:create, :update]
  end
end
