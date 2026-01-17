class Category < ApplicationRecord
  belongs_to :user, optional: true
  has_many :expenses, dependent: :nullify # If category deleted, set expense category to null? Or restrict?

  validates :name, presence: true

  # Scopes
  scope :global, -> { where(global: true) }
  scope :custom_for, ->(user) { where(user_id: user.id) }

  def self.available_to(user)
    # Global categories + My custom categories
    query = where(global: true).or(where(user_id: user.id))

    # If dependent, also seeing Guardian's categories
    if user.dependent? && user.guardian_id
      query = query.or(where(user_id: user.guardian_id))
    end

    query.distinct
  end
end
