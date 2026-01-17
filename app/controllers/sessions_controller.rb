# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  include Loggable

  # POST /resource/sign_in
  def create
    super do |resource|
      log_activity("login", resource) if resource.persisted?
    end
  end

  # DELETE /resource/sign_out
  def destroy
    # Capture user before sign out
    user = current_user
    super do
      log_activity("logout", user) if user
    end
  end
end
