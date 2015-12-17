Rails.application.routes.draw do
  resources :sessions, only:  [:new, :create, :destroy]
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :users

  delete '/signout',                to:     'sessions#destroy'
  get '/signin',                    to:     'sessions#new'
  get '/home',                      to:     'pages#home'
  get '/about',                     to:     'pages#about'

  root to: 'pages#home'
end
