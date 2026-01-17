# frozen_string_literal: true

class FundUser < ApplicationRecord
  belongs_to :fund
  belongs_to :user
  belongs_to :assigned_by, class_name: "User", optional: true

  validates :user_id, uniqueness: { scope: :fund_id, message: "is already assigned to this fund" }

  # Set assigned_at timestamp
  before_create :set_assigned_at

  # Scopes
  scope :recent, -> { order(assigned_at: :desc) }

  def assigned_by_name
    assigned_by&.display_name || "System"
  end

  private

  def set_assigned_at
    self.assigned_at ||= Time.current
  end
end
