FactoryGirl.define do
  factory :stores_user do
    user { FactoryGirl.create(:user) }
    store { FactoryGirl.create(:store) }
  end
end
