# frozen_string_literal: true

class Expense < ApplicationRecord
  belongs_to :user

  # Predefined categories
  CATEGORIES = %w[groceries rent travel shopping bills other].freeze

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :category, presence: true
  validates :spent_on, presence: true

  # Scopes
  scope :by_month, ->(date) { where(spent_on: date.beginning_of_month..date.end_of_month) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :recent, -> { order(spent_on: :desc, created_at: :desc) }

  # Instance methods
  def formatted_amount
    "₹#{format('%.2f', amount)}"
  end

  def creator_name
    user&.display_name || "Unknown"
  end
end
