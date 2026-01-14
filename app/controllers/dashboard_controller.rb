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

    # Get all funds associated with the user
    all_funds = current_user.funds.includes(:expenses, :users)

    # Split into Personal (created by user) and Assigned (created by admin/others)
    @personal_funds = all_funds.select { |f| f.admin_id == current_user.id }
    @assigned_funds = all_funds.select { |f| f.admin_id != current_user.id }

    # For guardians, show dependents overview
    if current_user.guardian?
      @dependents = current_user.dependents.includes(:expenses)
      @dependents_expenses_this_month = Expense.where(user: @dependents).by_month(@current_month)
      @dependents_total_spent = @dependents_expenses_this_month.sum(:amount)
    end
  end
end
