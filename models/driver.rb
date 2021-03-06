# models/driver.rb

class Driver < ActiveRecord::Base
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true
  validates :email, presence: true, uniqueness: true
  validates :status, presence: true

  validates :status, inclusion: { in: %w(occupated available), message: "%{value} is not a valid status" }

  has_many :trips

  VALID_EMAIL = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
end
