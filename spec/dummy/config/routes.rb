Rails.application.routes.draw do
  root to: 'home#index'
  get 'home', to: 'home#index'
  get 'span', to: 'home#span'
  mount SolidApm::Engine => "/solid_apm"
end
