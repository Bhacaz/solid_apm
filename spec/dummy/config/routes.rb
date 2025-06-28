Rails.application.routes.draw do
  root to: 'home#index'
  get 'home', to: 'home#index'
  get 'span', to: 'home#span'
  get 'generate_n_plus_one', to: 'home#generate_n_plus_one'
  mount SolidApm::Engine => "/solid_apm"
end
