# frozen_string_literal: true

module Admin
  class ExpensesController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_admin!
    before_action :set_expense, only: %i[show edit update destroy]

    def index
      @expenses = Expense.includes(:user, :category, :fund).order(spent_on: :desc)
    end

    def show
    end

    def edit
      @funds = @expense.user.funds
    end

    def update
      if @expense.update(expense_params)
        redirect_to admin_expenses_path, notice: "Expense updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @expense.destroy
      redirect_to admin_expenses_path, notice: "Expense deleted."
    end

    private

    def set_expense
      @expense = Expense.find(params[:id])
    end

    def expense_params
      params.require(:expense).permit(:amount, :category_id, :fund_id, :note, :spent_on)
    end

    def ensure_admin!
      unless current_user.admin?
        redirect_to root_path, alert: "Access denied."
      end
    end
  end
end
