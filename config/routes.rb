SolidApm::Engine.routes.draw do
  root 'transactions#index'

  get 'transactions', to: 'transactions#index'
  get 'transactions/count_by_minutes',
      to: 'transactions#count_by_minutes',
      as: 'transactions_count_by_minutes',
      default: { format: 'json' }

  get 'transactions/:id', to: 'transactions#show', as: 'transaction', constraints: { id: /\d+/ }
  get 'transactions/:name', to: 'transactions#show_by_name', as: 'transaction_by_name'
  get 'transactions/:id/spans', to: 'transactions#spans', as: 'transaction_spans'
end
