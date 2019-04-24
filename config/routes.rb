Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    resources :comments, only: [] do
      resources :comments, only: [:index, :create], controller: 'comments/comments'
    end
    resources :posts, only: [:index, :show] do
      resources :comments, only: [:index, :create], controller: 'posts/comments'
    end
    resources :users, only: [:create, :update, :destroy] do
      resources :posts, only: [:index, :create, :update, :destroy], controller: 'users/posts'
    end
    resource :session, only: [:create, :show, :destroy]
  end
end
