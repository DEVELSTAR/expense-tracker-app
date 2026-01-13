# frozen_string_literal: true

class Expense < ApplicationRecord
  belongs_to :user

  # Enum for spent_by field
  enum :spent_by, { self_expense: 0, wife: 1 }, prefix: true

  # Predefined categories
  CATEGORIES = %w[groceries rent travel shopping bills other].freeze

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :spent_by, presence: true
  validates :category, presence: true
  validates :spent_on, presence: true

  # Scopes
  scope :by_month, ->(date) { where(spent_on: date.beginning_of_month..date.end_of_month) }
  scope :by_spent_by, ->(spent_by) { where(spent_by: spent_by) }
  scope :recent, -> { order(spent_on: :desc, created_at: :desc) }

  # Instance methods
  def formatted_amount
    "$#{format('%.2f', amount)}"
  end

  def spent_by_label
    spent_by_self_expense? ? "Self" : "Wife"
  end
end
