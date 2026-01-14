# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @expense_count = current_user.expenses.count
    @total_spent = current_user.expenses.sum(:amount)
    @funds_count = current_user.funds.count if current_user.admin? == false
  end
end
