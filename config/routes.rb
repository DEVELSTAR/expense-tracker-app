# frozen_string_literal: true

Rails.application.routes.draw do
  # Authentication
  devise_for :users

  # Dashboard (root)
  root "dashboard#index"

  # Profile
  resource :profile, only: [ :show ] do
    post :regenerate_guardian_uid, on: :member
  end

  # Expenses CRUD (for regular users)
  resources :expenses
  # Personal Funds CRUD
  resources :funds

  # Admin namespace
  namespace :admin do
    root "dashboard#index"
    resources :users
    resources :funds
    resources :expenses, only: [ :index, :show, :edit, :update, :destroy ]
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
