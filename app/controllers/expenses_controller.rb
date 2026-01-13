# frozen_string_literal: true

class ExpensesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_expense, only: %i[show edit update destroy]

  def index
    @expenses = current_user.expenses.recent
  end

  def show
  end

  def new
    @expense = current_user.expenses.build(spent_on: Date.current)
  end

  def edit
  end

  def create
    @expense = current_user.expenses.build(expense_params)

    respond_to do |format|
      if @expense.save
        format.html { redirect_to root_path, notice: "Expense was successfully created." }
        format.turbo_stream { redirect_to root_path, notice: "Expense was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @expense.update(expense_params)
        format.html { redirect_to root_path, notice: "Expense was successfully updated." }
        format.turbo_stream { redirect_to root_path, notice: "Expense was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @expense.destroy

    respond_to do |format|
      format.html { redirect_to root_path, notice: "Expense was successfully deleted." }
      format.turbo_stream { redirect_to root_path, notice: "Expense was successfully deleted." }
    end
  end

  private

  def set_expense
    @expense = current_user.expenses.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Expense not found."
  end

  def expense_params
    params.require(:expense).permit(:amount, :spent_by, :category, :note, :spent_on)
  end
end
