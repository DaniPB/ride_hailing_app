FactoryBot.define do
  factory :payment_method do
    method_type  { :CARD }
    token { Faker::Internet.password(min_length: 10, max_length: 20, mix_case: true) }

    rider factory: :rider
  end
end
