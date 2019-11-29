Rails.application.routes.draw do
  root 'tasks#index'

  resources :tasks
  resources :sessions, only: [:new, :create, :destroy]
  resources :users, only: [:new, :create]

  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  get 'signup', to: 'users#new', as: 'signup'
  get 'maintenance', to: 'maintenance#show', as: 'maintenance'

  namespace :admin do
    resources :users
  end
end
