# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @current_month = params[:month].present? ? Date.parse(params[:month]) : Date.current
    
    # Base query for the current month
    expenses_base = current_user.expenses.by_month(@current_month)

    # Apply user filter if present (for admin viewing)
    if params[:user_id].present? && current_user.admin?
      expenses_base = Expense.by_month(@current_month).by_user(params[:user_id])
    end

    # Calculate aggregations before applying ORDER BY
    @monthly_total = expenses_base.sum(:amount)
    @category_totals = expenses_base.group(:category).sum(:amount)
    
    # Group by user for breakdown
    @user_totals = expenses_base.joins(:user).group("users.name").sum(:amount)

    # Get sorted expenses list for display
    @expenses = expenses_base.includes(:user).recent
    @expense_count = @expenses.size
    
    # For admin: get all users for filter dropdown
    @users = User.non_admins if current_user.admin?
  end
end
