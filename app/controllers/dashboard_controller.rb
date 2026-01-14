# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    # Redirect admin to admin dashboard
    if current_user.admin?
      redirect_to admin_root_path
      return
    end

    @current_month = params[:month].present? ? Date.parse(params[:month]) : Date.current
    
    # User's expenses for the current month
    expenses_base = current_user.expenses.by_month(@current_month)

    # Calculate aggregations
    @monthly_total = expenses_base.sum(:amount)
    @category_totals = expenses_base.group(:category).sum(:amount)

    # Get sorted expenses list for display
    @expenses = expenses_base.includes(:fund).recent
    @expense_count = @expenses.size

    # Get user's assigned funds
    @funds = current_user.funds.includes(:expenses, :users)
  end
end
