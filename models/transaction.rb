# models/transaciton.rb

class Transaction < ActiveRecord::Base
  validates :pay_reference, presence: true

  belongs_to :payment_method
  belongs_to :trip
end
