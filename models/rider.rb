# models/rider.rb

class Rider < ActiveRecord::Base
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  has_many :trips
  belongs_to :payment_method

  VALID_EMAIL = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
end
