FactoryGirl.define do
  factory :adjustment do
    order { FactoryGirl.create(:order) }
    amount "100.0"
    label 'Shipping'
    source { FactoryGirl.create(:shipment) }
  end
end
