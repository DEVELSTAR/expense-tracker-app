class ActivityLog < ApplicationRecord
  belongs_to :user
  belongs_to :trackable, polymorphic: true, optional: true

  # Validations
  validates :action, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_action, ->(action) { where(action: action) }
end
