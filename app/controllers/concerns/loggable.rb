# frozen_string_literal: true

module Loggable
  extend ActiveSupport::Concern

  included do
    def log_activity(action, trackable = nil, details = {})
      return unless current_user

      ActivityLog.create!(
        user: current_user,
        action: action,
        trackable: trackable,
        details: details,
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      )
    rescue StandardError => e
      Rails.logger.error("Failed to log activity: #{e.message}")
    end
  end
end
