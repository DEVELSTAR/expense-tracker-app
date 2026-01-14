# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Devise: Permit additional parameters for sign up and account update
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :sanitize_role_on_signup, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :role, :guardian_uid_input ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  # Prevent admin role from being set via registration
  def sanitize_role_on_signup
    return unless params[:user].present? && action_name == "create"

    allowed_roles = User.registerable_roles
    if params[:user][:role].present? && !allowed_roles.include?(params[:user][:role])
      params[:user][:role] = "dependent"
    end
  end
end
