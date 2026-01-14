# frozen_string_literal: true

class ExpensesController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_admin!
  before_action :set_expense, only: %i[show edit update destroy]

  def index
    @expenses = current_user.expenses.includes(:fund).recent
  end

  def show
  end

  def new
    @expense = current_user.expenses.build(spent_on: Date.current)
    @funds = current_user.funds
  end

  def edit
    @funds = current_user.funds
  end

  def create
    @expense = current_user.expenses.build(expense_params)

    if @expense.save
      redirect_to root_path, notice: "Expense was successfully created."
    else
      @funds = current_user.funds
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @expense.update(expense_params)
      redirect_to root_path, notice: "Expense was successfully updated."
    else
      @funds = current_user.funds
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @expense.destroy
    redirect_to root_path, notice: "Expense was successfully deleted."
  end

  private

  def set_expense
    @expense = current_user.expenses.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Expense not found."
  end

  def expense_params
    params.require(:expense).permit(:amount, :category, :note, :spent_on, :fund_id)
  end

  def redirect_admin!
    if current_user.admin?
      redirect_to admin_root_path, alert: "Admins cannot add expenses. Use the admin panel to manage user expenses."
    end
  end
end
