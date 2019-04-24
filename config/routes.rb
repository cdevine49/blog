Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    resources :comments, only: [:create]
    resources :posts, only: [:index, :show]
    resources :users, only: [:create, :update, :destroy] do
      resources :posts, only: [:index, :create, :update, :destroy], controller: 'users/posts'
    end
    resource :session, only: [:create, :show, :destroy]
  end
end
