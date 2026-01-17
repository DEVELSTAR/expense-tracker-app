# frozen_string_literal: true

class FundsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_admin!
  before_action :authorize_fund_creation!, only: [ :new, :create ]
  before_action :set_fund, only: %i[show edit update destroy]
  before_action :authorize_fund_modification!, only: [ :edit, :update, :destroy ]

  def index
    @funds = accessible_funds.includes(:users, :expenses).order(created_at: :desc)

    # Separate managed funds (created by user) and assigned funds
    if current_user.guardian?
      @managed_funds = @funds.select { |f| f.admin_id == current_user.id }
      @assigned_funds = @funds.reject { |f| f.admin_id == current_user.id }
    else
      # Dependents only see assigned funds
      @assigned_funds = @funds
      @managed_funds = []
    end
  end

  def show
    @recent_expenses = @fund.expenses.includes(:user).order(spent_on: :desc).limit(10)
    @user_breakdown = @fund.user_breakdown
    @can_edit = can_modify_fund?(@fund)
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
      log_activity("create_fund", @fund, amount: @fund.amount)
      redirect_to funds_path, notice: "Fund created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @fund.update(fund_params)
      log_activity("update_fund", @fund, changes: @fund.previous_changes.keys)
      redirect_to funds_path, notice: "Fund updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    log_activity("delete_fund", @fund, name: @fund.name)
    @fund.destroy
    redirect_to funds_path, notice: "Fund deleted successfully."
  end

  private

  def accessible_funds
    if current_user.guardian?
      # Guardians can see their own funds + assigned funds
      Fund.where(admin_id: current_user.id)
          .or(Fund.joins(:fund_users).where(fund_users: { user_id: current_user.id }))
          .distinct
    else
      # Dependents can only see funds assigned to them
      current_user.funds
    end
  end

  def set_fund
    @fund = accessible_funds.find_by(id: params[:id])

    unless @fund
      redirect_to funds_path, alert: "Fund not found or you don't have access."
    end
  end

  def can_modify_fund?(fund)
    fund.admin_id == current_user.id
  end

  def authorize_fund_creation!
    unless current_user.guardian?
      redirect_to funds_path, alert: "Only guardians can create funds."
    end
  end

  def authorize_fund_modification!
    unless can_modify_fund?(@fund)
      redirect_to funds_path, alert: "You can only edit funds you created."
    end
  end

  def redirect_admin!
    if current_user.admin?
      redirect_to admin_funds_path, alert: "Use the admin panel to manage funds."
    end
  end

  def fund_params
    params.require(:fund).permit(:name, :amount)
  end
end
