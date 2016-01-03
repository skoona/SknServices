Rails.application.routes.draw do
  resources :users
  resources :user_group_roles
  resources :content_profiles
  resources :password_resets, only: [:new, :create, :edit, :update]

  resources :sessions, only:  [:new, :create, :destroy] do
    collection do
      get :unauthenticated
    end
  end

  resources :pages, only: :none do
    collection do
      get :home
      get :learn_more
      get :about
      get :developer
      get :details_model
      get :details_content
      get :details_access
      get :details_auth
    end
  end

  resources :profiles, only: :none do
    member do
      get :accessible_content
    end
    collection do
      get :content_profile_demo
      get :access_profile_demo
    end
  end


  delete '/signout',     to: 'sessions#destroy'
  get    '/signin',      to: 'sessions#new'

  root  to: 'pages#home'

end
