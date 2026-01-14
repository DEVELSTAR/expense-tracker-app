# frozen_string_literal: true

class Fund < ApplicationRecord
  belongs_to :admin, class_name: "User"
  has_many :fund_users, dependent: :destroy
  has_many :users, through: :fund_users
  has_many :expenses, dependent: :nullify

  validates :name, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 100 }

  # Scopes
  scope :active, -> { where("amount > 0") }

  # Calculate total spent from this fund
  def total_spent
    expenses.sum(:amount)
  end

  # Calculate remaining balance
  def remaining_balance
    amount - total_spent
  end

  # Calculate spent by a specific user
  def spent_by_user(user)
    expenses.where(user: user).sum(:amount)
  end

  # Calculate spent by other users (excluding given user)
  def spent_by_others(user)
    expenses.where.not(user: user).sum(:amount)
  end

  # Get user-wise breakdown
  def user_breakdown
    expenses.joins(:user).group("users.id", "users.name").sum(:amount)
  end

  def formatted_amount
    "₹#{format('%.2f', amount)}"
  end

  def formatted_remaining
    "₹#{format('%.2f', remaining_balance)}"
  end
end
