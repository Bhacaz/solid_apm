SolidApm::Engine.routes.draw do
  root 'transactions#index'

  get 'transactions', to: 'transactions#index'
  get 'transactions/:uuid/spans', to: 'transactions#spans', as: 'transaction_spans'
end
