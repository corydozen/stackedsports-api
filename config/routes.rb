Rails.application.routes.draw do
  require 'sidekiq/web'
  # ActiveAdmin.routes(self)
  # Whitelisted routes
  root to: 'athletes#index'
  mount Sidekiq::Web => '/sidekiq'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    scope module: :v1, constraints: Stitches::ApiVersionConstraint.new(1) do
      resource 'ping', only: [:create]

      resource 'rate_limits', only: [:show]

      post 'oauth/callback' => 'oauths#callback'
      get 'oauth/callback' => 'oauths#callback' # for use with Github, Facebook
      get 'oauth/:provider' => 'oauths#oauth', :as => :auth_at_provider

      # Add your V1 resources here
      put 'messages/cancel/:id', to: 'messages#cancel'
      resources :messages
      scope :media do
        post 'upload', to: 'media#create', as: 'media_upload'
        post 'search', to: 'media#search', as: 'media_search'
        resources :tags
      end
      resources :media, except: :create do
        post 'add_tag', to: 'media#add_tag', as: 'add_tag'
        delete 'remove_tag', to: 'media#remove_tag', as: 'remove_tag'
      end

      resources :athletes
      resources :teams
      resources :organizations
      resources :users
      resources :users, only: [] do
        member do
          get :activate, to: 'users#activate', as: 'activate'
        end
      end

      resources :platforms
      resources :temp_athletes
    end

    scope module: :v2, constraints: Stitches::ApiVersionConstraint.new(2) do
      resource 'ping', only: [:create]
      # This is here simply to validate that versioning is working
      # as well as for your client to be able to validate this as well.
      put 'messages/cancel/:id', to: 'messages#cancel'
      resources :messages
    end

    scope module: :v3, constraints: Stitches::ApiVersionConstraint.new(3) do
      put 'messages/cancel/:id', to: 'messages#cancel'
      resources :messages do
        collection do
          get 'inbox', to: 'inboxes#index'
          post 'mark_as_read', to: 'messages#mark_as_read'
          post 'mark_as_unread', to: 'messages#mark_as_unread'
        end
      end
    end
  end

  get 'app_login', to: redirect('https://app.recruitsuite.co/login'), as: 'app_login'
  resources :users do
    member do
      get :activate, to: 'users#activate', as: 'activate'
    end
  end
  resources :user_sessions
  get 'login', to: 'user_sessions#new', as: :login
  # post 'login', to: 'user_sessions#create'
  post 'logout', to: 'user_sessions#destroy', as: :logout
  resources :password_resets
  get 'reset-password', to: 'password_resets#new'
  get 'success', to: 'users#successful_view'
  # get 'password_reset_request', to: 'password_resets#create'
  # get 'password_reset', to: 'password_resets#update'
  get 'request_access', to: 'users#new'

  get 'admin', to: redirect('/dashboard'), as: 'admin'
  get 'dashboard', to: 'admin#index', as: 'dashboard'

  scope :admin do
    resources :temp_commit_offers, path: 'commit-offers'
    delete 'delete_selected_co', to: 'temp_commit_offers#delete_selected'
    get 'get_daily_co_email', to: 'temp_commit_offers#get_daily_email'
    post 'send_daily_co_email', to: 'temp_commit_offers#send_daily_email'
    resources :temp_athletes
    resources :co_email_recipients
    resources :co_email_groupings
    resources :conferences
    resources :sports
    resources :users, controller: 'users'
    resources :teams, controller: 'teams'
    resources :organizations, controller: 'organizations'
    resources :board_uploads

    get 'import_board', to: 'rs#prepare_board_import'
    post 'import_board', to: 'rs#import_board'
  end

  post 'athlete_filter', to: 'athletes#filter'
  post 'athletes_search', to: 'athletes#search'
  resources :athletes do
    get 'report/active_hours', to: 'athletes#active_hours'
    get 'report/active_days', to: 'athletes#active_days'
    get 'report/program_engagement', to: 'athletes#program_engagement'
    get 'report/coach_engagement', to: 'athletes#coach_engagement'
    get 'report/sentiment', to: 'athletes#sentiment_analysis'
    get 'report', to: 'athletes#report'
  end
  resources :positions

  get 'inbox', to: 'messages#inbox'
  get 'conversation/:athlete_id', to: 'messages#conversation'
  resources :messages

  resources :media, path: 'media-library' do
    post 'add_tag', to: 'media#add_tag', as: 'add_tag'
    delete 'remove_tag', to: 'media#remove_tag', as: 'remove_tag'

    collection do
      post 'add_tags', to: 'media#add_tags_to_multiple', as: 'add_tags'
      post 'upload', to: 'media#create'
      post 'search', to: 'media#search'
      post 'archive', to: 'media#archive'
      resources :tags
    end
  end

  resources :filters

  # resources :positions

  resources :sms_events, only: [:create]

  api_docs = Rack::Auth::Basic.new(Apitome::Engine) do |_, password|
    password == ENV['HTTP_AUTH_PASSWORD']
  end
  mount api_docs, at: 'docs'
  # mount ForestLiana::Engine => '/forest'
end
