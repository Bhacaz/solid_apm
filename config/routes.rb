Rails.application.routes.draw do
  root 'home#index'

  get "up" => "rails/health#show", as: :rails_health_check

  get 'home/index'

  get 'transactions', to: 'transactions#index'
  get 'transactions/:id', to: 'transactions#show', as: 'transaction'
  get 'transactions/:id/spans', to: 'transactions#spans', as: 'transaction_spans'
end
