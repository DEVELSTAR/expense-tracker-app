# frozen_string_literal: true

class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_user, only: %i[show edit update destroy]
  before_action :set_guardians, only: %i[new edit create update]

  def index
    @users = User.order(created_at: :desc)
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)
    @user.password = user_params[:password]
    @user.password_confirmation = user_params[:password_confirmation]

    # Clear guardian if not dependent
    @user.guardian_id = nil unless @user.dependent?

    if @user.save
      redirect_to admin_users_path, notice: "User was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    update_params = user_params.reject { |_, v| v.blank? }

    # If password fields are blank, don't update password
    if update_params[:password].blank?
      update_params.delete(:password)
      update_params.delete(:password_confirmation)
    end

    # Clear guardian if not dependent
    if update_params[:role].present? && update_params[:role] != "dependent"
      update_params[:guardian_id] = nil
    end

    if @user.update(update_params)
      redirect_to admin_users_path, notice: "User was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      redirect_to admin_users_path, alert: "You cannot delete yourself."
    elsif @user.admin?
      redirect_to admin_users_path, alert: "You cannot delete another admin."
    else
      # Reassign or delete dependents if deleting a guardian
      if @user.guardian?
        @user.dependents.update_all(guardian_id: nil, role: "guardian")
      end
      @user.destroy
      redirect_to admin_users_path, notice: "User was successfully deleted."
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_users_path, alert: "User not found."
  end

  def set_guardians
    @guardians = User.guardians.order(:name)
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role, :guardian_id)
  end

  def require_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
