# models/payment_method.rb

class PaymentMethod < ActiveRecord::Base
  validates :method_type, :token, presence: true

  belongs_to :rider
  has_many :transactions
end
