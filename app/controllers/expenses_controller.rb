# frozen_string_literal: true

class ExpensesController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_admin!
  before_action :set_expense, only: %i[show edit update destroy]
  before_action :authorize_expense_modification!, only: [ :edit, :update, :destroy ]

  def index
    @own_expenses = current_user.expenses.includes(:fund).recent

    # Guardians can also view their dependents' expenses
    if current_user.guardian?
      @dependent_expenses = Expense.where(user: current_user.dependents)
                                   .includes(:fund, :user)
                                   .recent
      @show_dependent_expenses = @dependent_expenses.any?
    else
      @dependent_expenses = []
      @show_dependent_expenses = false
    end

    respond_to do |format|
      format.html
      format.csv { send_expenses_csv }
    end
  end

  def export
    # Export all expenses as CSV
    @expenses = exportable_expenses
    send_expenses_csv
  end

  def show
    @can_edit = @expense.user_id == current_user.id
  end

  def new
    @expense = current_user.expenses.build(spent_on: Date.current)
    @funds = available_funds

    if @funds.empty?
      redirect_to root_path, alert: "You don't have any funds to spend from. Ask your guardian to assign funds."
    end
  end

  def edit
    @funds = available_funds
  end

  def create
    @expense = current_user.expenses.build(expense_params)

    # Validate fund access
    unless can_use_fund?(@expense.fund_id)
      @funds = available_funds
      @expense.errors.add(:fund_id, "is not accessible to you")
      render :new, status: :unprocessable_entity
      return
    end

    if @expense.save
      log_activity("create_expense", @expense, amount: @expense.amount, fund: @expense.fund_name)
      redirect_to root_path, notice: "Expense was successfully created."
    else
      @funds = available_funds
      render :new, status: :unprocessable_entity
    end
  end

  def update
    # Validate fund access
    unless can_use_fund?(expense_params[:fund_id])
      @funds = available_funds
      @expense.errors.add(:fund_id, "is not accessible to you")
      render :edit, status: :unprocessable_entity
      return
    end

    if @expense.update(expense_params)
      log_activity("update_expense", @expense, changes: @expense.previous_changes.keys)
      redirect_to root_path, notice: "Expense was successfully updated."
    else
      @funds = available_funds
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    log_activity("delete_expense", @expense, amount: @expense.amount, category: @expense.category)
    @expense.destroy
    redirect_to root_path, notice: "Expense was successfully deleted."
  end

  private

  def available_funds
    current_user.funds.where("funds.amount > 0")
  end

  def can_use_fund?(fund_id)
    return true if fund_id.blank?
    current_user.funds.exists?(fund_id)
  end

  def set_expense
    # Users can view their own expenses
    # Guardians can also view their dependents' expenses
    @expense = current_user.expenses.find_by(id: params[:id])

    if @expense.nil? && current_user.guardian?
      # Check if it's a dependent's expense
      @expense = Expense.joins(:user)
                        .where(users: { guardian_id: current_user.id })
                        .find_by(id: params[:id])
    end

    unless @expense
      redirect_to expenses_path, alert: "Expense not found."
    end
  end

  def authorize_expense_modification!
    unless @expense.user_id == current_user.id
      redirect_to expenses_path, alert: "You can only edit your own expenses."
    end
  end

  def expense_params
    params.require(:expense).permit(:amount, :category_id, :note, :spent_on, :fund_id, :receipt)
  end

  def redirect_admin!
    if current_user.admin?
      redirect_to admin_root_path, alert: "Admins cannot add expenses. Use the admin panel to manage user expenses."
    end
  end

  def exportable_expenses
    expenses = current_user.expenses.includes(:fund)

    if current_user.guardian?
      dependent_expenses = Expense.where(user: current_user.dependents).includes(:fund, :user)
      expenses = Expense.where(id: expenses.pluck(:id) + dependent_expenses.pluck(:id))
                        .includes(:fund, :user)
                        .order(spent_on: :desc)
    end

    expenses
  end

  def send_expenses_csv
    require "csv"

    expenses = @expenses || exportable_expenses
    filename = "expenses_#{Date.current.strftime('%Y%m%d')}.csv"

    csv_data = CSV.generate(headers: true) do |csv|
      csv << [ "Date", "Category", "Amount", "Fund", "Note", "Created By" ]

      expenses.each do |expense|
        csv << [
          expense.spent_on.strftime("%Y-%m-%d"),
          expense.category&.name&.titleize || "Unknown",
          expense.amount.to_f,
          expense.fund&.name || "No Fund",
          expense.note || "",
          expense.user&.display_name || "Unknown"
        ]
      end
    end

    send_data csv_data, filename: filename, type: "text/csv", disposition: "attachment"
  end
end
