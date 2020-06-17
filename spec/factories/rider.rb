FactoryBot.define do
  factory :rider do
    first_name  { Faker::TvShows::Simpsons.character.gsub(/\W/, '') }
    last_name   { Faker::TvShows::Simpsons.character.gsub(/\W/, '') }
    phone       { Faker::PhoneNumber.cell_phone }
    email       { Faker::Internet.email(separators: %w(_ -)) }
  end
end
