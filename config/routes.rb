# frozen_string_literal: true

Rails.application.routes.draw do
  # Authentication
  devise_for :users

  # Dashboard (root)
  root "dashboard#index"

  # Expenses CRUD
  resources :expenses

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA files
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
