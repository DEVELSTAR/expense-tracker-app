# frozen_string_literal: true

class RecurringExpensesController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_admin!
  before_action :set_recurring_expense, only: [ :show, :edit, :update, :destroy, :toggle ]

  def index
    @recurring_expenses = current_user.recurring_expenses.includes(:fund).order(active: :desc, next_run_date: :asc)
    @active_count = @recurring_expenses.active.count
    @total_monthly = calculate_monthly_total
  end

  def show
  end

  def new
    @recurring_expense = current_user.recurring_expenses.build(
      next_run_date: Date.current,
      frequency: "monthly",
      active: true
    )
    @funds = available_funds
  end

  def edit
    @funds = available_funds
  end

  def create
    @recurring_expense = current_user.recurring_expenses.build(recurring_expense_params)

    # Validate fund access
    if @recurring_expense.fund_id.present? && !can_use_fund?(@recurring_expense.fund_id)
      @funds = available_funds
      @recurring_expense.errors.add(:fund_id, "is not accessible to you")
      render :new, status: :unprocessable_entity
      return
    end

    if @recurring_expense.save
      redirect_to recurring_expenses_path, notice: "Recurring expense '#{@recurring_expense.name}' created successfully."
    else
      @funds = available_funds
      render :new, status: :unprocessable_entity
    end
  end

  def update
    # Validate fund access
    if recurring_expense_params[:fund_id].present? && !can_use_fund?(recurring_expense_params[:fund_id])
      @funds = available_funds
      @recurring_expense.errors.add(:fund_id, "is not accessible to you")
      render :edit, status: :unprocessable_entity
      return
    end

    if @recurring_expense.update(recurring_expense_params)
      redirect_to recurring_expenses_path, notice: "Recurring expense updated successfully."
    else
      @funds = available_funds
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    name = @recurring_expense.name
    @recurring_expense.destroy
    redirect_to recurring_expenses_path, notice: "Recurring expense '#{name}' deleted."
  end

  def toggle
    @recurring_expense.update(active: !@recurring_expense.active)
    status = @recurring_expense.active? ? "activated" : "paused"
    redirect_to recurring_expenses_path, notice: "Recurring expense '#{@recurring_expense.name}' #{status}."
  end

  private

  def set_recurring_expense
    @recurring_expense = current_user.recurring_expenses.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to recurring_expenses_path, alert: "Recurring expense not found."
  end

  def recurring_expense_params
    params.require(:recurring_expense).permit(:name, :amount, :category_id, :note, :fund_id, :frequency, :next_run_date)
  end

  def available_funds
    current_user.funds
  end

  def can_use_fund?(fund_id)
    return true if fund_id.blank?
    current_user.funds.exists?(fund_id)
  end

  def redirect_admin!
    if current_user.admin?
      redirect_to admin_root_path, alert: "Admins cannot manage recurring expenses."
    end
  end

  def calculate_monthly_total
    # Calculate approximate monthly cost of all active recurring expenses
    total = 0
    current_user.recurring_expenses.active.each do |re|
      monthly_factor = case re.frequency
      when "daily" then 30
      when "weekly" then 4.33
      when "biweekly" then 2.17
      when "monthly" then 1
      when "quarterly" then 0.33
      when "yearly" then 0.083
      else 1
      end
      total += re.amount * monthly_factor
    end
    total
  end
end
