FactoryGirl.define do
  factory :product_property do
    product { FactoryGirl.create(:product) }
    property { FactoryGirl.create(:property) }
  end
end
