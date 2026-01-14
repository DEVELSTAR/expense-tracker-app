# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @expense_count = current_user.expenses.count
    @total_spent = current_user.expenses.sum(:amount)
    @funds_count = current_user.funds.count if current_user.admin? == false
  end

  def regenerate_guardian_uid
    if current_user.guardian?
      current_user.regenerate_guardian_uid!
      redirect_to profile_path, notice: "Your Guardian UID has been regenerated successfully."
    else
      redirect_to profile_path, alert: "Only guardians can regenerate a UID."
    end
  end
end
