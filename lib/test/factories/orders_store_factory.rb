FactoryGirl.define do
  factory :orders_store do
    # associations:
    store { FactoryGirl.create(:store) }
    order { FactoryGirl.create(:order) }
    state 'inactive'
    
    trait :open do
      state 'open'
    end
    
    trait :past_due do
      state 'past_due'
      order { FactoryGirl.create(:late_order) }
    end
    
    trait :complete do
      state 'complete'
    end
    
    trait :closed_late do
      state 'closed_late'
      order { FactoryGirl.create(:late_order) }
    end
    
    trait :canceled do
      state 'canceled'
    end
        
    trait :shipment_not_shipped do
      order do 
        order = Factory.custom_order(:shipment_store => self.store) 
        orders_store = order.orders_stores.find_by_order_id_and_store_id(order, self.store)
        if orders_store
          orders_store.destroy
          order.orders_stores.delete(orders_store)
        end
        order
      end
    end
    
    trait :late_shipment_not_shipped do
      order do
        order = Factory.custom_order(:late => true, :shipment_store => self.store) 
        orders_store = order.orders_stores.find_by_order_id_and_store_id(order, self.store)
        if orders_store
          orders_store.destroy
          order.orders_stores.delete(orders_store)
        end
        order
      end
    end
    
    trait :shipment_shipped do
      order do
        order = Factory.custom_order(:shipped => true, :shipment_store => self.store)
        orders_store = order.orders_stores.find_by_order_id_and_store_id(order, self.store)
        if orders_store
          orders_store.destroy
          order.orders_stores.delete(orders_store)
        end
        order
      end
    end
    
    trait :late_shipment_shipped do
      order do
        order = Factory.custom_order(:late => true, :shipped => true, :shipment_store => self.store)
        orders_store = order.orders_stores.find_by_order_id_and_store_id(order, self.store)
        if orders_store
          orders_store.destroy
          order.orders_stores.delete(orders_store)
        end
        order
      end
    end
    
    factory :open_orders_store, :traits => [:open, :shipment_not_shipped]
    factory :open_late_orders_store, :traits => [:open, :late_shipment_not_shipped]
    factory :past_due_orders_store, :traits => [:past_due, :late_shipment_not_shipped]
    factory :complete_orders_store, :traits => [:complete, :shipment_shipped]
    factory :closed_late_orders_store, :traits => [:closed_late, :late_shipment_shipped]
    factory :canceled_orders_store, :traits => [:canceled]
    
    after(:build) do |orders_store|
      #orders_store.
    end
  end
  
end

