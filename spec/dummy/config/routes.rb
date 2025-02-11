Rails.application.routes.draw do
  mount SolidApm::Engine => "/solid_apm"
end
