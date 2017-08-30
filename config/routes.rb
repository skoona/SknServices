Rails.application.routes.draw do
  resources :users
  resources :user_group_roles
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
      get :about
      get :help
      get :details_access
      get :details_architecture
      get :details_auth
      get :details_content
      get :details_sysinfo
      get :api_sysinfo_actions
    end
  end

  resources :profiles, only: :none do
    collection do
      get :runtime_demo
      get :content_profile_demo
      get :api_accessible_content
      get :api_get_content_object
      get :api_get_demo_content_object
      get :members
      get :manage_content_profiles
      post :create_profile_for_user
      post :update_profile_for_user
      delete :delete_profile_for_user
      post :create_entries_for_user
      delete :delete_entry_for_user
    end
    member do
      get :member
      put :member_update
    end
  end


  delete '/signout',     to: 'sessions#destroy'
  get    '/signout',     to: 'sessions#destroy'
  get    '/signin',      to: 'sessions#new'

  root  to: 'pages#home'

end
