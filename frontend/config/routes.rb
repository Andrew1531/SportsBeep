SportsbeepWeb::Application.routes.draw do
  # mount RailsAdmin::Engine => '/cpanel', as: 'rails_admin'
  # mount Avocado::Engine, at: '/api-docs', constraints: -> (_) { Rails.env.staging? }

  devise_for :users, path_names: {
    sign_in: 'login', sign_out: 'logout', sign_up: 'register',
  }, controllers: {
    registrations: 'registrations',
    sessions: 'sessions'
  }

  # Fallback support channel: manual reset-request form (delivers to the
  # support inbox via Web3Forms) for users whose email flow fails.
  get  'reset-password', to: 'pages#reset_request', as: :reset_request
  post 'reset-password', to: 'pages#submit_reset_request'

  devise_for :administrators, path_names: { sign_in: 'login', sign_out: 'logout' }, controllers: { sessions: 'admin/sessions' }
  namespace :admin do
    resources :approved_tokens, except: :show
    resources :swap_assets, except: :show
  end

  # require 'sidekiq/web'
  # require 'sidetiq/web'
  # authenticate :administrator do
  #   mount Sidekiq::Web => '/sidekiq'
  # end

  get 'play', to: 'dashboard#index'
  get 'dashboard', to: 'dashboard#index', as: :user_dashboard
  get 'games', to: 'games#index', as: :browse_games
  get 'sportsbook', to: 'sportsbook#index', as: :sportsbook
  post 'sportsbook/place_wager', to: 'sportsbook#place_wager', as: :place_wager
  get 'my-bets', to: 'sportsbook#my_bets', as: :my_bets
  get 'fantasy', to: 'fantasy#index', as: :fantasy
  get  'fantasy/game/:id', to: 'fantasy#show', as: :fantasy_game
  post 'fantasy/enter', to: 'fantasy#enter_contest', as: :fantasy_enter_contest
  get  'fantasy/my-entries', to: 'fantasy#my_entries', as: :my_entries
  get 'wallet', to: 'dashboard#wallet', as: :wallet
  get 'vending', to: redirect('/wallet')
  post 'wallet/cardano_nonce', to: 'dashboard#cardano_nonce', as: :cardano_nonce
  post 'wallet/connect_cardano', to: 'dashboard#connect_cardano', as: :connect_cardano
  delete 'wallet/disconnect_cardano', to: 'dashboard#disconnect_cardano', as: :disconnect_cardano
  post 'wallet/load_beep', to: 'dashboard#load_beep', as: :load_beep
  post 'wallet/build_deposit', to: 'dashboard#build_deposit', as: :build_deposit
  post 'wallet/record_deposit', to: 'dashboard#record_deposit', as: :record_deposit
  post 'wallet/check_deposits', to: 'dashboard#check_deposits', as: :check_deposits
  get 'wallet/swap_assets', to: 'dashboard#swap_assets', as: :swap_assets
  post 'wallet/swap_quote', to: 'dashboard#swap_quote', as: :swap_quote
  post 'wallet/build_swap', to: 'dashboard#build_swap', as: :build_swap
  post 'wallet/record_swap', to: 'dashboard#record_swap', as: :record_swap
  post 'wallet/check_swaps', to: 'dashboard#check_swaps', as: :check_swaps
  post 'wallet/withdraw_beep', to: 'dashboard#withdraw_beep', as: :withdraw_beep
  get 'transactions', to: 'dashboard#transactions', as: :user_transactions
  get 'redeem', to: 'dashboard#redeem_promo', as: :redeem_promo
  post 'redeem', to: 'dashboard#apply_promo', as: :apply_promo
  patch 'profile/photo', to: 'users#update_profile_photo', as: :update_profile_photo
  root to: 'application#landing'

  get 'how-to-play', to: 'pages#how_to_play', as: :how_to_play
  get 'tos', to: 'pages#tos'
  get 'refund_policy', to: 'pages#refund_policy'
  get 'privacy_policy', to: 'pages#privacy_policy'

  resources :users, only: [:show], constraints: { id: /\d+/ }

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
    root to: 'dashboard#index'
    get 'dashboard', to: 'dashboard#index', as: :dashboard
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
