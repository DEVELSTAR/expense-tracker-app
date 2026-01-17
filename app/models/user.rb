# frozen_string_literal: true

class User < ApplicationRecord
  # Roles
  ROLES = %w[admin guardian dependent independent].freeze

  # Virtual attribute for guardian UID input during registration
  attr_accessor :guardian_uid_input

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  # Associations
  has_many :expenses, dependent: :destroy
  has_many :recurring_expenses, dependent: :destroy
  has_many :fund_users, dependent: :destroy
  has_many :funds, through: :fund_users
  has_many :managed_funds, class_name: "Fund", foreign_key: :admin_id, dependent: :destroy

  # Guardian-Dependent relationship
  belongs_to :guardian, class_name: "User", optional: true
  has_many :dependents, class_name: "User", foreign_key: :guardian_id, dependent: :nullify

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :role, presence: true, inclusion: { in: ROLES }
  validates :guardian_uid, uniqueness: true, allow_nil: true

  # Dependent must have a guardian
  validates :guardian, presence: { message: "UID is invalid or not found" }, if: :dependent?
  validate :guardian_must_be_guardian_role, if: :dependent?
  validate :guardian_cannot_have_guardian, if: :guardian?

  # Scopes
  scope :admins, -> { where(role: "admin") }
  scope :guardians, -> { where(role: "guardian") }
  scope :dependents_role, -> { where(role: "dependent") }
  scope :non_admins, -> { where.not(role: "admin") }
  scope :registerable, -> { where(role: %w[guardian dependent independent]) }

  # Callbacks
  before_validation :set_default_role, on: :create
  before_validation :resolve_guardian_from_uid, if: :dependent?
  before_create :generate_guardian_uid, if: :guardian?
  after_save :ensure_guardian_uid, if: :guardian?

  # Role check methods
  def admin?
    role == "admin"
  end

  def guardian?
    role == "guardian"
  end

  def dependent?
    role == "dependent"
  end

  def independent?
    role == "independent"
  end

  # Check if user can register (admin cannot sign up)
  def self.registerable_roles
    %w[independent]
  end

  # Find a guardian by their UID
  def self.find_guardian_by_uid(uid)
    return nil if uid.blank?
    guardians.find_by(guardian_uid: uid.to_s.strip.upcase)
  end

  # Generate a new unique Guardian UID
  def regenerate_guardian_uid!
    return false unless guardian?

    new_uid = self.class.generate_unique_uid
    update!(guardian_uid: new_uid)
  end

  # Generate a unique UID
  def self.generate_unique_uid
    loop do
      # Format: 6 alphanumeric characters (e.g., "GRD-A1B2C3")
      uid = "GRD-#{SecureRandom.alphanumeric(6).upcase}"
      break uid unless exists?(guardian_uid: uid)
    end
  end

  def display_name
    name.presence || email.split("@").first.capitalize
  end

  # Get all funds this user has access to
  def available_funds
    funds.where("funds.amount > 0")
  end

  # Check if user has any assigned funds
  def has_funds?
    funds.exists?
  end

  # Get the label for the role
  def role_label
    case role
    when "admin" then "Admin"
    when "guardian" then "Guardian"
    when "dependent" then "Dependent"
    else role.to_s.titleize
    end
  end

  # Guardians this user can select (for dependent registration)
  def self.available_guardians
    guardians.order(:name)
  end

  private

  def set_default_role
    # Set default role to independent if not specified
    self.role ||= "independent"
  end

  # Look up guardian by UID input
  def resolve_guardian_from_uid
    return if guardian_id.present? || guardian_uid_input.blank?

    found_guardian = self.class.find_guardian_by_uid(guardian_uid_input)
    if found_guardian
      self.guardian = found_guardian
    else
      errors.add(:guardian_uid_input, "is invalid or not found")
    end
  end

  def generate_guardian_uid
    self.guardian_uid ||= self.class.generate_unique_uid
  end

  def ensure_guardian_uid
    if guardian? && guardian_uid.blank?
      update_column(:guardian_uid, self.class.generate_unique_uid)
    elsif !guardian? && guardian_uid.present?
      update_column(:guardian_uid, nil)
    end
  end

  def guardian_must_be_guardian_role
    return unless guardian.present?

    unless guardian.guardian?
      errors.add(:guardian, "must be a guardian role user")
    end
  end

  def guardian_cannot_have_guardian
    if guardian_id.present?
      errors.add(:guardian, "can only be assigned to dependents")
    end
  end
end
