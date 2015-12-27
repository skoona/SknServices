Rails.application.routes.draw do
  resources :users
  resources :user_group_roles
  resources :content_profiles
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :sessions, only:  [:new, :create, :destroy]

  delete '/signout',                to:     'sessions#destroy'
  get '/signin',                    to:     'sessions#new'
  get '/home',                      to:     'pages#home'
  get '/about',                     to:     'pages#about'
  get '/developer',                 to:     'pages#developer'
  get '/details_model',             to:     'pages#details_model'
  get '/learn_more',                to:     'pages#learn_more'
  get '/details_content',           to:     'pages#details_content'
  get '/details_access',            to:     'pages#details_access'
  get '/details_auth',              to:     'pages#details_auth'

  # Warden Failure Thrown
  get '/unauthenticated',           to:     'pages#home'

  root to: 'pages#home'
end
