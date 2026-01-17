# frozen_string_literal: true

class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    @users_count = User.non_admins.count
    @funds_count = Fund.count
    @total_fund_amount = Fund.sum(:amount)
    @total_expenses = Expense.sum(:amount)

    @recent_funds = Fund.includes(:users).order(created_at: :desc).limit(5)
    @recent_expenses = Expense.includes(:user, :fund).recent.limit(10)
  end

  private

  def require_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
