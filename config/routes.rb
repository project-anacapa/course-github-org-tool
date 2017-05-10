Rails.application.routes.draw do
  root to: 'visitors#index'

  get 'course_error' => 'visitors#course_error'

  get 'course' => 'course#show'

  post '/students/import'
  resources :students

  resources :assignments, only: [:index, :show]
  resources :admin, only: [:index]
  resource :github_webhooks, only: :create, defaults: { formats: :json }

  get '/settings' => 'users#settings'
  post '/settings' => 'users#update_settings', :as => :update_settings
  resources :users do
    member do
      post 'toggle_instructor_privilege'
      post 'match' => 'users#match_to_student'
    end
  end

  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'
end
