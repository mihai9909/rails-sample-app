Rails.application.routes.draw do
  get 'password_resets/new'
  get 'password_resets/edit'
  get 'sessions/new'
  resources :users
  get '/help', to: 'static_pages#help'
  get '/about', to: 'static_pages#about'
  get '/signup', to: 'users#new'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  resources :account_activations, only: [:edit]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root "static_pages#home"
  resources :password_resets, only: [:new, :create, :edit, :update]
end
