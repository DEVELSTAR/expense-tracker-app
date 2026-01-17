# frozen_string_literal: true

class RecurringExpense < ApplicationRecord
  belongs_to :user
  belongs_to :fund, optional: true

  # Frequencies
  FREQUENCIES = %w[daily weekly biweekly monthly quarterly yearly].freeze

  # Validations
  validates :name, presence: true, length: { maximum: 100 }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :category, presence: true, inclusion: { in: Expense::CATEGORIES }
  validates :frequency, presence: true, inclusion: { in: FREQUENCIES }
  validates :next_run_date, presence: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :due, -> { active.where("next_run_date <= ?", Date.current) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }

  # Process this recurring expense - creates an expense and updates next run date
  def process!
    return unless active? && due?

    transaction do
      # Create the expense
      expense = user.expenses.create!(
        amount: amount,
        category: category,
        note: "#{name} (recurring)",
        spent_on: Date.current,
        fund_id: fund_id
      )

      # Update next run date
      update!(next_run_date: calculate_next_run_date)

      expense
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to process recurring expense ##{id}: #{e.message}"
    nil
  end

  def due?
    next_run_date <= Date.current
  end

  def formatted_amount
    "₹#{format('%.2f', amount)}"
  end

  def frequency_label
    case frequency
    when "daily" then "Daily"
    when "weekly" then "Weekly"
    when "biweekly" then "Every 2 weeks"
    when "monthly" then "Monthly"
    when "quarterly" then "Every 3 months"
    when "yearly" then "Yearly"
    else frequency.titleize
    end
  end

  private

  def calculate_next_run_date
    case frequency
    when "daily"
      next_run_date + 1.day
    when "weekly"
      next_run_date + 1.week
    when "biweekly"
      next_run_date + 2.weeks
    when "monthly"
      next_run_date + 1.month
    when "quarterly"
      next_run_date + 3.months
    when "yearly"
      next_run_date + 1.year
    else
      next_run_date + 1.month
    end
  end
end
