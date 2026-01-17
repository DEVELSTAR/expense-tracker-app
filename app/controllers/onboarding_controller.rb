# frozen_string_literal: true

class OnboardingController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_independent

  def index
  end

  def become_guardian
    if current_user.update(role: "guardian")
      current_user.regenerate_guardian_uid!
      redirect_to root_path, notice: "Welcome! You are now a Guardian."
    else
      redirect_to onboarding_index_path, alert: "Something went wrong. Please try again."
    end
  end

  def become_dependent
    guardian_uid = params[:guardian_uid_input].to_s.strip.upcase
    guardian = User.find_guardian_by_uid(guardian_uid)

    if guardian
      if current_user.update(role: "dependent", guardian: guardian)
        redirect_to root_path, notice: "Welcome! You are now linked to your guardian."
      else
        redirect_to onboarding_index_path, alert: "Could not update your profile."
      end
    else
      redirect_to onboarding_index_path, alert: "Invalid Guardian UID. Please check and try again."
    end
  end

  private

  def ensure_independent
    unless current_user.independent?
      redirect_to root_path
    end
  end
end
