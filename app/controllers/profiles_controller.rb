# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def show
    load_role_specific_data

    # Render role-specific view
    case current_user.role
    when "admin"
      render :admin_show
    when "guardian"
      render :guardian_show
    when "dependent"
      render :dependent_show
    else
      render :show
    end
  end

  def edit
    # Standard edit view for all roles
  end

  def update
    # Handle password update only if password fields are provided
    update_params = profile_params
    if update_params[:password].blank?
      update_params = update_params.except(:password, :password_confirmation)
    end

    if @user.update(update_params)
      bypass_sign_in(@user) if update_params[:password].present?
      redirect_to profile_path, notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def regenerate_guardian_uid
    if current_user.guardian?
      current_user.regenerate_guardian_uid!
      redirect_to profile_path, notice: "Your Guardian UID has been regenerated successfully."
    else
      redirect_to profile_path, alert: "Only guardians can regenerate a UID."
    end
  end

  private

  def set_user
    @user = current_user
  end

  def profile_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def load_role_specific_data
    case current_user.role
    when "admin"
      load_admin_data
    when "guardian"
      load_guardian_data
    when "dependent"
      load_dependent_data
    end
  end

  def load_admin_data
    @total_users = User.count
    @total_guardians = User.guardians.count
    @total_dependents = User.dependents_role.count
    @total_funds = Fund.count
    @total_expenses = Expense.count
    @total_amount = Expense.sum(:amount)
    @recent_activities = ActivityLog.includes(:user).recent.limit(10)
  end

  def load_guardian_data
    @expense_count = current_user.expenses.count
    @total_spent = current_user.expenses.sum(:amount)
    @funds_count = current_user.funds.count
    @managed_funds_count = current_user.managed_funds.count

    # My dependents
    @dependents = current_user.dependents.includes(:expenses, :funds)
    @dependents_count = @dependents.count

    # My managed funds
    @managed_funds = current_user.managed_funds.includes(:users, :expenses).limit(5)

    # My recent expenses
    @recent_expenses = current_user.expenses.includes(:fund).recent.limit(5)

    # Dependents' recent expenses
    @dependent_expenses = Expense.where(user: @dependents)
                                 .includes(:user, :fund)
                                 .recent
                                 .limit(5)
    @dependents_total_spent = @dependent_expenses.sum(:amount)
  end

  def load_dependent_data
    @expense_count = current_user.expenses.count
    @total_spent = current_user.expenses.sum(:amount)
    @funds_count = current_user.funds.count

    # My guardian info
    @guardian = current_user.guardian

    # Assigned funds (funds I can spend from)
    @assigned_funds = current_user.funds.includes(:expenses).limit(5)

    # My recent expenses
    @recent_expenses = current_user.expenses.includes(:fund).recent.limit(5)
  end
end
