FactoryBot.define do
  factory :trip do
    from      { { latitude: Faker::Address.latitude, longitude: Faker::Address.longitude } }
    to        { { latitude: Faker::Address.latitude, longitude: Faker::Address.longitude } }
    price     { 0.0 }
    starts_at { Faker::Time.between(from: DateTime.now - 1.hour, to: DateTime.now - 30.minutes) }
    ends_at   { Faker::Time.between(from: DateTime.now - 31.minutes, to: DateTime.now) }

    association :rider, factory: :rider
    association :driver, factory: :driver
  end
end
