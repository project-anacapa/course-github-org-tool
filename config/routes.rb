Rails.application.routes.draw do
  root to: 'visitors#index'

  get 'course' => 'course#show'
  get 'course/setup'
  post 'course/set_org'

  post '/students/import'
  resources :students

  get '/settings' => 'users#settings'
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
