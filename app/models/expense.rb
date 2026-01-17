# frozen_string_literal: true

class Expense < ApplicationRecord
  belongs_to :user
  belongs_to :fund, optional: true
  belongs_to :category # Replaces string column

  # Receipt attachment
  has_one_attached :receipt

  # Validate receipt file type and size
  validate :acceptable_receipt

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :category, presence: true # Validates association presence
  validates :spent_on, presence: true
  validate :amount_within_fund_balance, if: -> { fund.present? }

  # Scopes
  scope :by_month, ->(date) { where(spent_on: date.beginning_of_month..date.end_of_month) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_fund, ->(fund_id) { where(fund_id: fund_id) }
  scope :recent, -> { order(spent_on: :desc, created_at: :desc) }

  # Instance methods
  def formatted_amount
    "₹#{format('%.2f', amount)}"
  end

  def creator_name
    user&.display_name || "Unknown"
  end

  def fund_name
    fund&.name || "Personal"
  end

  def has_receipt?
    receipt.attached?
  end

  private

  def amount_within_fund_balance
    return unless fund.present? && amount.present?

    existing_amount = persisted? ? amount_was : 0
    available = fund.remaining_balance + existing_amount

    if amount > available
      errors.add(:amount, "exceeds available fund balance (₹#{format('%.2f', available)} available)")
    end
  end

  def acceptable_receipt
    return unless receipt.attached?

    # Check file size (max 5MB)
    if receipt.blob.byte_size > 5.megabytes
      errors.add(:receipt, "is too large (maximum 5MB)")
    end

    # Check file type
    acceptable_types = [ "image/jpeg", "image/png", "image/gif", "image/webp", "application/pdf" ]
    unless acceptable_types.include?(receipt.blob.content_type)
      errors.add(:receipt, "must be an image (JPEG, PNG, GIF, WebP) or PDF")
    end
  end
end
