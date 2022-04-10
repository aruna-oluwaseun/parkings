# frozen_string_literal: true

Rails.application.routes.draw do

  root 'dashboard/application#index'
  mount ActionCable.server => '/cable'
  apipie
  devise_for :users, only: []
  devise_for :admins, path: 'dashboard', only: :sessions

  authenticate :admin, lambda { |u| u.try(:admin?) } do
    mount Sidekiq::Web => '/sidekiq'
  end

  namespace :dashboard do
    resources :payments
    resources :users do
      member do
        post :notifications_and_messages
        post :message_push_notifications
        post :notification_push_notifications
      end
    end
    resources :parking_zones
    resources :parking_history, only: [:show]
    resources :kiosks
    resources :manufacturers
    resources :agencies
    resources :locations
    resources :cameras do
      get :vmarkup, on: :member
    end
    resources :roles do
      resources :permissions, module: :roles do
        resources :attributes, module: :permissions
      end
    end

    namespace :ai do
      resources :logs
      resources :tokens
      resources :error_reports, except: %i[update destroy]
    end

    namespace :paper_trail do
      resources :version
    end

    namespace :ksk do
      resources :tokens do
        collection do
          get :seed
        end
      end
    end

    scope path: :ksk do
      resources :parking_lots do
        get :outline, on: :member
        member do
          post :reset_sessions
        end
      end
      resources :vehicles, except: [:destroy] do
        member do
          post :reset_sessions
          post :park_car
          post :car_enter_lot
          post :car_exit_slot
          post :car_exit_lot
        end
        collection do
          get :search
        end
      end
      resources :parking_slots do
        member do
          post :reset_sessions
        end
      end
      resources :parking_sessions do
        member do
          post :reset_session
        end
        collection do
          get :search
        end
      end
    end

    namespace :parking do
      resources :settings
    end

    root to: "parking_sessions#index"
    get 'env', to: 'application#env'
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :dropdowns, only: :show, param: :dropdown_class
      resources :pages, only: [:show] do
        get :home, on: :collection
      end

      ['cardconnect_merchant_id_test', 'cardconnect_merchant_id_production'].each do |id|
        get "env/#{id}", to: "env##{id}"
      end

      namespace :ksk do
        resources :parking_lots do
          member do
            get :parking_zones
            get :kiosks
          end
        end
        resources :parking_zones do
          member do
            get :parking_slots
          end
        end
        resources :parking_sessions, only: [:index, :show] do
          member do
            put :confirm
            put :lpn, action: :update_lpn
            get :payment
          end
        end
        resources :parking_slots
        resources :vehicles
        resources :kiosks
      end
      namespace :ai do
        resources :cameras, only: [] do
          collection do
            put :down
            put :up
          end
        end

        resources :parking_sessions, only: [:index] do
          collection do
            post :car_entrance
            post :car_parked
            post :car_left
            post :car_exit
            post :violation_commited
          end
        end
      end
      resources :users, only: [] do

        collection do
          get :check_credit_card
          post :check_reset_password_token
          post :sign_in
          post :sign_up
          post :send_reset_password_instructions
          post :send_confirmation_instructions
          put :confirm
          put :update_password
          put :reset_password
          get :me
          post :check_password
          put :update_settings
          post :push_notification_token
        end
      end
      resources :vehicles, only: [:create, :destroy, :index] do
        collection do
          get :verify
        end

        member do
          put :active
          put :inactive
          put :rejected
          put :inactive
        end

      end
      resources :parking_sessions, only: [:index, :show] do
        collection do
          get :current
          get :recent
        end

        member do
          get :payment
          put :confirm
          post :pay
          put :pay_later
        end
      end
      resources :messages, only: [:index, :show] do
        collection do
          put :read, action: :mark_read
          get :unread
          get :types
          delete :delete, action: :destroy
        end
      end
      resources :notifications, only: [:update, :index] do
        collection do
          get :read
          put :read, action: :mark_read
          get :unread
          get :types
          put :mark_all, action: :mark_all_as_read
        end
      end
      resources :parking_lots, only: [:index, :show]
      resources :disputes, only: [:create]
      resources :alerts, only: [:index] do
        member do
          get :resolve
        end
      end
      resources :payments, only: [:index]
      resource :user do
        put :wallet, on: :member, to: 'wallets#update'
      end
    end
    namespace :meo do
      namespace :v1 do
        post 'auth/sign_in', to: 'auth#sign_in'
      end
    end
    namespace :dashboard do
      post 'auth/sign_in', to: 'auth#sign_in'
      post 'auth/send_reset_password_instructions', to: 'auth#send_reset_password_instructions'
      post 'auth/check_reset_password_token', to: 'auth#check_reset_password_token'
      put 'auth/reset_password', to: 'auth#reset_password'
      post 'auth/push_notification_token', to: 'auth#push_notification_token'
      resources :dropdowns, only: :show, param: :dropdown_class
      resources :reports, only: [:index, :show]
      resources :logs, only: [:show]
      resources :statistics, only: [:index]
      resources :vehicles, only: [:index, :show, :update]
      resources :admins, only: [:create, :update, :index, :show] do
        collection do
          put :me, to: "admins#update_me"
          get :me
          get :search
          get :managed_users
          post :check_password
        end
      end

      resources :vehicles, only: [:show, :destroy, :index, :update] do
        member do
          put :active
          put :inactive
          put :rejected
          put :inactive
          get :parking_sessions, to: 'vehicles_parking_sessions#index'
        end
      end

      resources :notifications, only: [:index, :show, :update] do
        collection do
          get :types
        end
      end

      resources :users, only: [:index, :show, :update]

      resources :parking_sessions, only: [:index, :show] do
        collection do
          get :report
        end
        member do
          get :logs
        end
      end
      resources :parking_lots, only: [:create, :update, :index, :show] do
        resources :parking_slots, only: [:index]
        resources :parking_plans, only: [:create, :destroy, :update]
        resources :places, only: :index
        resources :parking_violations, only: :index
      end

      resources :parking_slots, only: [:show, :update]

      resources :parking_rules, path: :parking_rules, only: [:index], controller: 'parking/rules' do
        collection do
          put :update
          patch :update
        end
      end

      resources :agencies, only: [:create, :update, :index, :show, :destroy] do
        get :search, on: :collection
      end

      namespace :parking do
        resources :tickets, only: [:index, :update, :show]
        resources :vehicle_rules, path: '/lots/:lot_id/vehicle_rules', only: [:create, :index, :update] do
          collection do
            put :archive
          end
        end
        resources :violations, only: [:index, :show, :update] do
          resources :violation_history_logs, only: [:index]
        end
        resources :citation_tickets, only: [:create, :index, :show, :update] do
          resources :citation_ticket_history_logs, only: [:index]
        end
      end

      namespace :reports do
        namespace :detailed do
          resources :voi_matches, only: [:index]
          resources :violations, only: [:index]
          resources :citation_tickets, only: [:index]
          resources :revenues, only: [:index]
        end
      end

      get 'pdf_pages/download', to: 'pdf_pages#download'
      get 'parking_slots/:id/sessions', to: 'parking_slots#sessions'
      get 'permissions/permissions_available', to: 'roles#permissions'

      resources :disputes, only: [:index, :show]
      resources :payments, only: [:index, :show]
      resources :cameras, only: [:index, :show, :create, :update, :destroy]
      resources :comments, only: [:index, :create, :destroy, :update]
      resources :agency_types, only: [:index, :show, :create, :update, :destroy]
      resources :voi_vehicles, only: :index
      resources :roles, only: [:index, :show, :create, :update, :destroy]
      resources :vehicles, only: :show do
        member do
          get :parking_sessions, to: 'vehicles_parking_sessions#index'
        end
      end
    end
  end

  resources :parking_lots do
    member do
      get :parking_zones
      get :kiosks
    end
  end
  resources :parking_zones do
    member do
      get :parking_slots
    end
  end
  resources :parking_slots
  resources :vehicles
  resources :kiosks
  resources :parking_sessions
  resources :payment_transactions
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
