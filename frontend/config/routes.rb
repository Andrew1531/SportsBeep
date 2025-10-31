SportsbeepWeb::Application.routes.draw do
  # mount RailsAdmin::Engine => '/cpanel', as: 'rails_admin'
  # mount Avocado::Engine, at: '/api-docs', constraints: -> (_) { Rails.env.staging? }

  devise_for :users, path_names: {
    sign_in: 'login', sign_out: 'logout', sign_up: 'register',
  }, controllers: {
    registrations: 'registrations',
    sessions: 'sessions'
  }

  devise_for :administrators, path_names: { sign_in: 'login', sign_out: 'logout' }, controllers: { sessions: 'admin/sessions' }

  # require 'sidekiq/web'
  # require 'sidetiq/web'
  # authenticate :administrator do
  #   mount Sidekiq::Web => '/sidekiq'
  # end

  get 'play', to: 'application#app'
  root to: 'application#landing'

  get 'tos', to: 'pages#tos'
  get 'refund_policy', to: 'pages#refund_policy'
  get 'privacy_policy', to: 'pages#privacy_policy'

  resources :users, only: [:show]

  namespace :api, defaults: { format: 'json' } do
    devise_for :users, path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'register' }

    resource  :favorite_team, only: :update

    concern :sport do
      resources :contests, only: [:index, :show] do
        resources :tickets, only: :index
      end

      resources :games, only: [:index, :show] do
        resources :league_picks, only: :index
        resources :players, only: :index do
          get :previous, on: :collection
        end
        resources :pools, only: :index
      end

      resources :players, only: :show do
        resources :stats, only: :index
      end

      resources :teams, only: :index do
        get :rankings, on: :member
      end

      resources :tickets, only: [:create, :show, :update] do
        get :league_pick, on: :member
        resources :players, only: :index do
          resource :scoresheet, only: :show
        end
        resources :questions, only: :index
        resources :timer_states, only: :index
        resources :question_answers, only: [:create, :index], path: :answers, as: :answers
        resources :squads, only: :show
      end
    end

    namespace(:mlb) { concerns :sport }
    namespace(:nfl) { concerns :sport }
  end

  namespace :admin do
    root to: 'mlb/games#index'
    resources :administrators, only: [:index, :new, :create, :destroy]
    resources :users, only: [:index, :show, :update]

    resources :promo_codes do
      resources :users, only: [:index]
    end

    resource  :setting, only: [:update, :show, :edit]
    resources :push, only: [:new, :create]

    concern :sport do
      root to: 'games#index'
      resources :games, only: [:index, :show, :update]
      resources :questions, except: :show
    end

    namespace(:mlb) { concerns :sport }
    namespace(:nfl) { concerns :sport }
  end

  namespace :mobile do
    resources :pages do
      collection do
        get :how_it_works
      end
    end
  end
end
