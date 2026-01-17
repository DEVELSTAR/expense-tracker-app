class RegistrationsController < Devise::RegistrationsController
  protected

  # Redirect after sign up
  def after_sign_up_path_for(resource)
    root_path
  end

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
