# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  before_action :ensure_valid_role, only: [ :create ]

  protected

  # Redirect after sign up based on role
  def after_sign_up_path_for(resource)
    if resource.guardian?
      flash[:notice] = "Welcome! Your Guardian UID is #{resource.guardian_uid}. Share this with your dependents so they can link to you."
    end
    root_path
  end

  private

  # Ensure only valid roles can be selected during registration
  def ensure_valid_role
    role = sign_up_params[:role]

    unless User.registerable_roles.include?(role)
      flash[:alert] = "Invalid role selected. Only Guardian and Dependent can sign up."
      redirect_to new_user_registration_path and return
    end
  end

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role, :guardian_uid_input)
  end
end
