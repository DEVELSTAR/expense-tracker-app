# frozen_string_literal: true

Rails.application.routes.draw do
  resources :shopping_list_items do
    patch :toggle, on: :member
  end
  resources :categories
  # Authentication
  # Authentication
  devise_for :users, controllers: {
    registrations: "registrations",
    sessions: "sessions"
  }

  # Onboarding
  resources :onboarding, only: [ :index ] do
    collection do
      post :become_guardian
      post :become_dependent
    end
  end

  # Dashboard (root)
  root "dashboard#index"

  # Profile
  resource :profile, only: [ :show, :edit, :update ] do
    post :regenerate_guardian_uid, on: :member
  end

  # Guardian namespace for managing dependents and fund assignments
  namespace :guardian do
    resources :dependents, only: [ :index, :show ]
    resources :funds, only: [] do
      resources :fund_assignments, only: [ :new, :create ]
    end
    resources :fund_assignments, only: [ :destroy ]
  end

  # Expenses CRUD (for regular users)
  resources :expenses do
    get :export, on: :collection
  end

  # Recurring Expenses
  resources :recurring_expenses do
    post :toggle, on: :member
  end

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
