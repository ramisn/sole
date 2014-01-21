FactoryGirl.define do
  factory :product_scope do
    product_group { FactoryGirl.create(:product_group) }
    name 'on_hand'
    arguments 'some arguments'
  end
end
