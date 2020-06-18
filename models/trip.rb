# models/trip.rb

class Trip < ActiveRecord::Base
  validates :from, presence: true
  validates :to, presence: true
  validates :starts_at, presence: true
  validates :ends_at, presence: true

  validates :status, inclusion: { in: %w(unstarted onway finished), message: "%{value} is not a valid status" }

  belongs_to :rider
  belongs_to :driver
end
