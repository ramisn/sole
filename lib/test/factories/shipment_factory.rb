FactoryGirl.define do
  factory :shipment, class: Spree::Shipment do
    order { FactoryGirl.create(:order, :completed_at => Time.now.utc) }
    shipping_method { FactoryGirl.create(:shipping_method) }
    tracking 'U10000'
    number '100'
    cost 100.00
    address { FactoryGirl.create(:address) }
    inventory_units do
      units = []
      3.times do |i| 
        units << FactoryGirl.build(:inventory_unit, :line_item => nil, :order => nil, :shipment => nil)
      end
      units
    end
    
    trait :pending do
      state 'pending'
    end
    
    trait :shipped do
      state 'shipped'
      shipped_at { Time.now.utc }
    end
    
    trait :late do
      order { FactoryGirl.create(:late_order) }
    end
    
    trait :canceled do
      state 'canceled'
    end
    
    trait :ready do
      state 'ready'
    end
    #trait :late_pending_shipment do
    #  state 'pending'
    #  order { FactoryGirl.create(:late_not_shipped_order) }
    #end
    #
    #trait :late_shipped_shipment do
    #  state 'shipped'
    #  shipped_at { Time.now.utc }
    #  order { FactoryGirl.create(:late_shipped_order) }
    #end
    
    after(:build) do |shipment|
      shipment.inventory_units.each do |inventory_unit|
        inventory_unit.save
        if shipment.shipped?
          inventory_unit.update_attribute_without_callbacks 'state', 'shipped'
        elsif shipment.canceled?
          inventory_unit.update_attribute_without_callbacks 'state', 'canceled'
        else
          inventory_unit.update_attribute_without_callbacks 'state', 'sold'
        end
      end
    end
    
    factory :pending_shipment, :traits => [:pending]
    factory :shipped_shipment, :traits => [:shipped]
    factory :canceled_shipment, :traits => [:canceled]
    factory :ready_shipment, :traits => [:ready]
    #factory :complete_shipment, :traits => [:shipped, :complete]
    #factory :pending_complete_shipment, :traits => [:shipped, :complete]
    factory :late_pending_shipment, :traits => [:pending, :late]
    factory :late_shipped_shipment, :traits => [:shipped, :late]
  end
end
