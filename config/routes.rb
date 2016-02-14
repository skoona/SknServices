Rails.application.routes.draw do
  resources :users
  resources :user_group_roles
  resources :content_profiles
  resources :password_resets, only: [:new, :create, :edit, :update]

  resources :sessions, only:  [:new, :create, :destroy] do
    collection do
      get :unauthenticated
      get :not_authorized
    end
  end

  resources :pages, only: :none do
    collection do
      get :home
      get :learn_more
      get :about
      get :details_access
      get :details_architecture
      get :details_auth
      get :details_content
      get :details_sysinfo
    end
  end

  resources :profiles, only: :none do
    collection do
      get :content_profile_demo
      get :api_accessible_content
      get :manage_content_profiles
      get :api_content_profiles
    end
  end


  delete '/signout',     to: 'sessions#destroy'
  get    '/signout',     to: 'sessions#destroy'
  get    '/signin',      to: 'sessions#new'

  root  to: 'pages#home'

end
