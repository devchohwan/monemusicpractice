Rails.application.routes.draw do
  get 'password_reset', to: 'password_reset#new', as: :password_reset
  post 'password_reset', to: 'password_reset#create'
  get 'password_reset/edit', to: 'password_reset#edit', as: :edit_password_reset
  patch 'password_reset', to: 'password_reset#update'
  
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }
  
  authenticated :user do
    get 'profile/edit', to: 'profile#edit', as: :edit_profile
    patch 'profile/update_password', to: 'profile#update_password', as: :update_password
  end
  
  root 'home#index'
  
  authenticated :user do
    resources :reservations do
      member do
        patch :cancel
      end
      collection do
        get :calendar
        get :time_slots
        get :available_rooms
      end
    end
  end
  
  namespace :admin do
    get "reservations/index"
    root 'dashboard#index'
    resources :users, only: [:index, :destroy] do
      member do
        patch :approve
        patch :reject
        patch :reset_password
        patch :update_teacher
      end
    end
    resources :reservations, only: [:index, :destroy] do
      member do
        patch :update_status
      end
    end
    resources :penalties, only: [:index] do
      member do
        patch :reset
      end
    end
  end
  
  get "up" => "rails/health#show", as: :rails_health_check
  
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end