# frozen_string_literal: true

class Admin::FundsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_fund, only: %i[show edit update destroy]

  def index
    @funds = Fund.includes(:admin, :users, :expenses).order(created_at: :desc)
  end

  def show
    @expenses = @fund.expenses.includes(:user).recent.limit(20)
    @user_breakdown = @fund.expenses.joins(:user).group("users.name").sum(:amount)
  end

  def new
    @fund = Fund.new
    @users = User.non_admins.order(:name)
  end

  def edit
    @users = User.non_admins.order(:name)
  end

  def create
    @fund = Fund.new(fund_params)
    @fund.admin = current_user

    if @fund.save
      # Assign users to fund
      if params[:fund][:user_ids].present?
        params[:fund][:user_ids].reject(&:blank?).each do |user_id|
          @fund.fund_users.create(user_id: user_id)
        end
      end
      redirect_to admin_funds_path, notice: "Fund was successfully created."
    else
      @users = User.non_admins.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @fund.update(fund_params)
      # Update user assignments
      @fund.fund_users.destroy_all
      if params[:fund][:user_ids].present?
        params[:fund][:user_ids].reject(&:blank?).each do |user_id|
          @fund.fund_users.create(user_id: user_id)
        end
      end
      redirect_to admin_funds_path, notice: "Fund was successfully updated."
    else
      @users = User.non_admins.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @fund.destroy
    redirect_to admin_funds_path, notice: "Fund was successfully deleted."
  end

  private

  def set_fund
    @fund = Fund.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_funds_path, alert: "Fund not found."
  end

  def fund_params
    params.require(:fund).permit(:name, :amount)
  end

  def require_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
