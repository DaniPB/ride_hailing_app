# models/payment_method.rb

class PaymentMethod < ActiveRecord::Base
  validates :method_type, presence: true
  validates :token, presence: true
  validates :source_id, presence: true

  belongs_to :rider
  has_many :transactions
end
