# frozen_string_literal: true

module Guardian
  class FundAssignmentsController < BaseController
    before_action :set_fund, only: [ :new, :create ]

    def new
      @available_users = assignable_users
    end

    def create
      user = User.find_by(id: params[:user_id])

      unless user && can_assign_to?(user)
        redirect_to fund_path(@fund), alert: "Cannot assign fund to this user."
        return
      end

      if @fund.fund_users.exists?(user: user)
        redirect_to fund_path(@fund), alert: "#{user.display_name} is already assigned to this fund."
        return
      end

      @fund.fund_users.create!(user: user, assigned_by: current_user)
      redirect_to fund_path(@fund), notice: "#{user.display_name} has been assigned to this fund."
    end

    def destroy
      fund_user = FundUser.find(params[:id])
      fund = fund_user.fund

      unless fund.admin_id == current_user.id
        redirect_to funds_path, alert: "You can only manage assignments for your own funds."
        return
      end

      # Don't allow removing yourself
      if fund_user.user_id == current_user.id
        redirect_to fund_path(fund), alert: "You cannot remove yourself from your own fund."
        return
      end

      user_name = fund_user.user.display_name
      fund_user.destroy
      redirect_to fund_path(fund), notice: "#{user_name} has been removed from this fund."
    end

    private

    def set_fund
      @fund = current_user.managed_funds.find(params[:fund_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to funds_path, alert: "Fund not found or you don't have access."
    end

    def assignable_users
      # Guardian can assign to themselves and their dependents
      [ current_user ] + current_user.dependents - @fund.users
    end

    def can_assign_to?(user)
      user.id == current_user.id || current_user.dependents.include?(user)
    end
  end
end
