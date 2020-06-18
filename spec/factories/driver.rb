FactoryBot.define do
  factory :driver do
    first_name  { Faker::TvShows::Simpsons.character.gsub(/\W/, '') }
    last_name   { Faker::TvShows::Simpsons.character.gsub(/\W/, '') }
    phone       { Faker::PhoneNumber.cell_phone }
    email       { Faker::Internet.email(separators: %w(_ -)) }
    status      { :occupated }
  end
end
