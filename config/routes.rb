Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  resources :users, only: [ :create, :index ]
  mount ActionCable.server => "/cable"
end
