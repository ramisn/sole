FactoryGirl.define do
  sequence :store_tier_name do |n|
    "tier #{rand(1000)}#{n}"
  end
  
  factory :store_tier do
    # associations:
    name { FactoryGirl.generate(:store_tier_name) } if Spree::User.attribute_method? :name
    discount { rand(100) }
  end
end
