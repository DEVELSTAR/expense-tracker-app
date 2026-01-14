# frozen_string_literal: true

class FundsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_fund, only: %i[show edit update destroy]

  def index
    @funds = current_user.managed_funds.includes(:users, :expenses).order(created_at: :desc)
  end

  def show
    @recent_expenses = @fund.expenses.includes(:category).order(spent_on: :desc).limit(10)
    @user_breakdown = @fund.user_breakdown
  end

  def new
    @fund = current_user.managed_funds.build
  end

  def edit
  end

  def create
    @fund = current_user.managed_funds.build(fund_params)

    if @fund.save
      # Automatically assign the creator to the fund
      @fund.fund_users.create(user: current_user)
      redirect_to funds_path, notice: "Personal fund created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @fund.update(fund_params)
      redirect_to funds_path, notice: "Fund updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @fund.destroy
    redirect_to funds_path, notice: "Fund deleted successfully."
  end

  private

  def set_fund
    @fund = current_user.managed_funds.find(params[:id])
  end

  def fund_params
    params.require(:fund).permit(:name, :amount)
  end
end
