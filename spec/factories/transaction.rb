FactoryBot.define do
  factory :transaction do
    pay_reference  { Faker::Alphanumeric.alphanumeric(number: 7) }

    association :trip, factory: :trip
    association :payment_method, factory: :payment_method
  end
end
