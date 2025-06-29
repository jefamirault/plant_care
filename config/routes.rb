Rails.application.routes.draw do
  resources :locations
  resources :tanks do
    resources :water_tests
  end
  resources :sensor_types
  resources :sensors
  resources :zones
  resource :session
  resources :registrations
  resource :password
  resource :password_reset

  resources :users

  get 'plants/archive', to: 'plants#archive'
  get 'plants/import', to: 'plants#import'
  post 'plants/import', to: 'plants#process_file'
  resources :plants do
    get 'water'
    resources :log_entries
  end

  get 'waterings/import', to: 'waterings#import'
  post 'waterings/import', to: 'waterings#process_file'
  resources :waterings

  root "plants#index"

  get 'settings', to: 'settings#index'
  get 'en', to: 'settings#english'
  get 'es', to: 'settings#spanish'

  resources :projects do
    post 'add_collaborator'
    put 'remove_collaborator/:user_id', to: 'projects#remove_collaborator', as: 'remove_collaborator'
  end

  get 'sensor_readings/import', to: 'sensor_readings#import'
  post 'sensor_readings/import', to: 'sensor_readings#process_file'
  get 'transmit', to: 'sensor_readings#transmit', as: 'transmit'
  get 'sensor_readings', to: 'sensor_readings#readings', as: 'sensor_readings'

  match '/404' => 'errors#not_found', :via => :all
  match '/422' => 'errors#unprocessable_entity', :via => :all
  match '/500' => 'errors#internal_server_error', :via => :all
end
