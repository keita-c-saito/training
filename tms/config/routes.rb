Rails.application.routes.draw do
  get     'login',   to: 'sessions#new'
  post    'login',   to: 'sessions#create'
  delete  'logout',  to: 'sessions#destroy'

  resources :tasks
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # root setting
  root to: 'tasks#index'
end
