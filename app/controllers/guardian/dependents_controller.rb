# frozen_string_literal: true

module Guardian
  class DependentsController < BaseController
    def index
      @dependents = current_user.dependents.includes(:expenses, :funds)
    end

    def show
      @dependent = current_user.dependents.find(params[:id])
      @expenses = @dependent.expenses.includes(:fund).recent.limit(20)
      @funds = @dependent.funds
      @total_spent = @dependent.expenses.sum(:amount)
    rescue ActiveRecord::RecordNotFound
      redirect_to guardian_dependents_path, alert: "Dependent not found."
    end
  end
end
