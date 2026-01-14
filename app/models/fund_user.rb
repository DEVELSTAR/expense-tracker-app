# frozen_string_literal: true

class FundUser < ApplicationRecord
  belongs_to :fund
  belongs_to :user

  validates :user_id, uniqueness: { scope: :fund_id, message: "is already assigned to this fund" }
end
