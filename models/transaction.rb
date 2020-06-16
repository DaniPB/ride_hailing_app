# models/transaciton.rb

class Transaction < ActiveRecord::Base
  belongs_to :payment_method
  belongs_to :trip
end
