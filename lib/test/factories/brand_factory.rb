FactoryGirl.define do
  factory :brand do
    name { Faker::Lorem.words.first }
  end
end
