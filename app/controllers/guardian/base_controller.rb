# frozen_string_literal: true

module Guardian
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_guardian!

    private

    def ensure_guardian!
      unless current_user.guardian?
        redirect_to root_path, alert: "Access denied. Guardian role required."
      end
    end
  end
end
