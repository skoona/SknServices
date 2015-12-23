Rails.application.routes.draw do
  resources :user_roles
  resources :user_group_roles
  resources :content_profile_entries
  resources :topic_type_opts
  resources :topic_types
  resources :content_type_opts
  resources :content_types
  resources :content_profiles
  resources :profile_types
  resources :sessions, only:  [:new, :create, :destroy]
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :users

  delete '/signout',                to:     'sessions#destroy'
  get '/signin',                    to:     'sessions#new'
  get '/home',                      to:     'pages#home'
  get '/about',                     to:     'pages#about'
  get '/developer',                 to:     'pages#developer'
  get '/model_details',             to:     'pages#model_details'

  root to: 'pages#home'
end
