FactoryGirl.define do
  factory :shipping_method, class: Spree::ShippingMethod do
    zone { |a| a.association(:global_zone) }
    name { Faker::Company.name + " Ground Shipping" }
    calculator { |sm| FactoryGirl.create(:basic_shipping_calculator, :calculable_id => sm.object_id, :calculable_type => "ShippingMethod") }
  end

  factory :free_shipping_method, :class => Spree::ShippingMethod do
    zone { |a| a.association(:global_zone) }
    name { Faker::Company.name + " Ground Shipping (Free)" }
    calculator { |sm| FactoryGirl.create(:no_amount_calculator, :calculable_id => sm.object_id, :calculable_type => "ShippingMethod") }
  end
end
