FactoryBot.define do
  factory :transaction do
    association :trip, factory: :trip
    association :payment_method, factory: :payment_method
  end
end
