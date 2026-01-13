# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @current_month = params[:month].present? ? Date.parse(params[:month]) : Date.current
    
    # Base query for the current month
    expenses_base = current_user.expenses.by_month(@current_month)

    # Apply spent_by filter if present
    if params[:spent_by].present? && Expense.spent_bys.key?(params[:spent_by])
      expenses_base = expenses_base.by_spent_by(params[:spent_by])
    end

    # Calculate aggregations before applying ORDER BY
    @monthly_total = expenses_base.sum(:amount)
    @category_totals = expenses_base.group(:category).sum(:amount)
    @spent_by_totals = expenses_base.group(:spent_by).sum(:amount)

    # Get sorted expenses list for display
    @expenses = expenses_base.recent
    @expense_count = @expenses.count
  end
end
