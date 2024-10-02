SolidApm::Engine.routes.draw do
  root 'transactions#index'

  get 'transactions', to: 'transactions#index'
  get 'transactions/count_time_aggregations',
      default: { format: 'json' }

  get 'transactions/:id', to: 'transactions#show', as: 'transaction', constraints: { id: /\d+/ }
  get 'transactions/:name', to: 'transactions#show_by_name', as: 'transaction_by_name'
  get 'transactions/:id/spans', to: 'transactions#spans', as: 'transaction_spans'
end
