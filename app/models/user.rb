# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :expenses, dependent: :destroy
  has_many :fund_users, dependent: :destroy
  has_many :funds, through: :fund_users
  has_many :managed_funds, class_name: "Fund", foreign_key: :admin_id, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  # Scopes
  scope :admins, -> { where(admin: true) }
  scope :non_admins, -> { where(admin: false) }

  # Instance methods
  def admin?
    admin == true
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
end
