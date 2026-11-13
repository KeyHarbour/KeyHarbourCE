Rails.application.routes.draw do
  mount MissionControl::Jobs::Engine => "/jobs"
  # mount KeyHarbourApi::Engine => "/api"
  get 'locations/provinces', to: 'locations#provinces'

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # namespace :statefiles do
  #   namespace :v1 do
  #     get ":workspace_uuid/:environment", to: "statefiles#get"
  #     post ":workspace_uuid/:environment", to: "statefiles#update"
  #     put ":workspace_uuid/:environment", to: "statefiles#lock"
  #     delete ":workspace_uuid/:environment", to: "statefiles#unlock"
  #   end
  # end

  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    namespace :admin do
      resources :processed_dates, only: %i[destroy]
      resources :accounts, shallow: true do
        member do
          put :activate
          put :unactivate
          put :unarchived
        end
        resources :users
        resources :organizations, except: %i[new create]
      end
      resources :organizations do
        resources :users, except: %i[show]
        resources :environments
        resources :workspaces, only: [ :index ]
        resources :tokens, only: %i[index create destroy new]
        resources :projects do
          resources :tokens, only: %i[index create destroy new show]
          resources :workspaces do
            resources :tokens, only: %i[index create destroy new]
          end
        end
      end
      resources :users
      resources :coupons, only: %i[index new create destroy] do
        member do
          put :activate
          put :desactivate
        end
      end
      root "dashboard#index"
    end

    namespace :member do
      get 'errors/e403', to: 'errors#e403_member'
      resources :pricings, only: [ :index ]
      resources :accounts
      resources :teams
      resources :team_users
      resources :team_roles
      resources :users
      resources :carts
      resources :events
      namespace :wizard do
        namespace :statefiles do
          get  'organization', to: 'statefiles#new_organization', as: :new_organization
          post 'organization', to: 'statefiles#create_organization', as: :create_organization
          post 'project', to: 'statefiles#create_project', as: :create_project
          post 'workspace', to: 'statefiles#create_workspace', as: :create_workspace
        end
        namespace :key_values do
          get  'organization', to: 'key_values#new_organization', as: :new_organization
          post 'organization', to: 'key_values#create_organization', as: :create_organization
          post 'project', to: 'key_values#create_project', as: :create_project
          post 'workspace', to: 'key_values#create_workspace', as: :create_workspace
        end
        namespace :trust_assets do
          get  'organization', to: 'trust_assets#new_organization', as: :new_organization
          post 'organization', to: 'trust_assets#create_organization', as: :create_organization
          post 'project', to: 'trust_assets#create_project', as: :create_project
          post 'workspace', to: 'trust_assets#create_workspace', as: :create_workspace
        end
      end
      # resources :applications, only: [ :index ]
      namespace :license do
        root "dashboard#index"
        resources :providers
        resources :applications, shallow: true do
          resources :quotes do
            collection do
              get :compare
            end
          end
          resources :quote_applications
          resources :quote_instances do
            member do
              get :deactivate
              get :activate
            end
          end
          resources :quote_add_ons do
            member do
              get :deactivate
              get :activate
            end
          end
          resources :instances do
            resources :add_ons
            resources :licensees
          end
        end
        resources :team_members
      end      
      resources :subscription_coupons, only: %i[new create]
      resources :subscriptions, only: [ :index, :update, :create ] do
        resources :invoices, only: [ :show ]
        member do
          get :success
          get :fail
        end
        collection do
          post :webhook
        end
      end
      resources :organizations, shallow: true do
        get "select2_workspace_ids", to: "select2#workspace_ids", as: "select2_workspace_ids"
        get "select2_environment_ids", to: "select2#environment_ids", as: "select2_environment_ids"
        get "select2_model_category_ids", to: "select2#model_category_ids", as: "select2_model_category_ids"
        get "select2_model_family_ids", to: "select2#model_family_ids", as: "select2_model_family_ids"

        namespace :license do
          resources :applications do
            resources :instances do
              resources :licensees
            end
          end
          resources :team_members
        end
        resources :environments
        resources :invites
        resources :teams
        # resources :workspaces, only: [ :index ]
        resources :org_tokens, only: %i[index create destroy new]
        resources :tokens, only: %i[index create destroy new]


        resources :projects do
          resources :tokens, only: %i[index create destroy new]
          resources :workspaces do
            member do
              put :activate
              put :unactivate
            end
            resources :statefiles
            resources :key_value_stores
            resources :trust_assets
          end
        end
        resources :key_value_stores do
          member do
            put :duplicate
          end
        end
        resources :statefiles do
          member do
            put :duplicate
            put :push
            delete :instance
          end
          resources :statefile_tags, only: %i[new create destroy]
        end
        namespace :inventory do
          resources :model_categories do
            resources :model_category_attrs, as: "attrs"
          end
          resources :model_families
          resources :instances do
            collection do
              get :export
            end
          end
        end
      end

      root "dashboard#index"
    end

    resource :session
    resources :passwords, param: :token
    resource :registration, only: %i[new create]
    resources :email_verifications, only: %i[create edit], param: :token
    resources :users, only: %i[edit update show]
    root "member/dashboard#index"
  end
  get "up" => "rails/health#show", as: :rails_health_check
  get 'errors/feature403', to: 'errors#feature403'
  get 'errors/e403', to: 'errors#e403'
  get 'errors/e403_invite', to: 'errors#e403_invite'
  get '/auth/:provider/callback', to: 'sessions#omniauth'
  get '/auth/failure', to: redirect('/')
  draw(:custom) if Rails.root.join("config/routes/custom.rb").exist?
end