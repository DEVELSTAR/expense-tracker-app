# frozen_string_literal: true

Rails.application.routes.draw do
  # Authentication
  devise_for :users

  # Dashboard (root)
  root "dashboard#index"

  # Expenses CRUD
  resources :expenses

  # Admin namespace
  namespace :admin do
    resources :users
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
