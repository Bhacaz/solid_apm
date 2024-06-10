SolidApm::Engine.routes.draw do
  root 'transactions#index'

  get 'transactions', to: 'transactions#index'
  get 'transactions/:id', to: 'transactions#show', as: 'transaction'
  get 'transactions/:id/spans', to: 'transactions#spans', as: 'transaction_spans'
end
