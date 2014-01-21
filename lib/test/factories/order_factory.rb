FactoryGirl.define do
  factory :order, class: Spree::Order do
    # associations:
    association(:user, :factory => :user)
    association(:bill_address, :factory => :address)
    completed_at nil
    bill_address_id nil
    ship_address_id nil
    email 'foo@example.com'
    
    trait :complete do
      state 'complete'
      association :bill_address, factory: :address
      association :ship_address, factory: :address
      payments { |payments| [payments.association(:payment)] }
      completed_at { Time.now.utc }
    end
    
    trait :late do
      state 'complete'
      completed_at { Time.now.utc - 4.days }
    end
    
    trait :not_shipped do 
      shipments { [FactoryGirl.build(:shipment, :pending)] }
      #shipments { [FactoryGirl.build(:pending_shipment, :order => nil)] }
    end
    
    trait :shipped do
      shipments { [FactoryGirl.build(:shipment, :shipped)] }
      #shipments { [FactoryGirl.build(:shipped_shipment, :order => nil)] }
    end
    
    trait :canceled do
      state 'canceled'
    end
    
    after(:build) do |order|
      order.shipments.each do |shipment|
        shipment.order = order
        shipment.save
      end
      order.payments.each do |payment|
        payment.order = order
        payment.save
      end
    end
    #after(:create) do |order|
    #end
    
    factory :complete_not_shipped_order, :traits => [:complete, :not_shipped]
    factory :complete_shipped_order, :traits => [:complete, :shipped]
    factory :late_not_shipped_order, :traits => [:late, :not_shipped]
    factory :late_shipped_order, :traits => [:late, :shipped]
    factory :late_order, :traits => [:late]
    factory :late_complete_order, :traits => [:late, :complete]
    factory :canceled_order, :traits => [:canceled]
    
    after(:create) do |order|
      order.shipments.each do |shipment|
        shipment.order = order
        shipment.save
      end
      order.payments.each do |payment|
        payment.order = order
        payment.save
      end
      if order.completed?
        order.ensure_all_orders_stores
        order.open_orders_stores
        #order.payments.each do |payment|
        #  payment.order = order
        #  payment.save
        #end
      end
    end
  end

  factory :order_with_totals, :parent => :order do
    after(:create) { |order| FactoryGirl.create(:line_item, :order => order) }
  end

  factory :order_with_inventory_unit_shipped, :parent => :order do
    after(:create) { |order| FactoryGirl.create(:inventory_unit, :order => order, :state => 'shipped') }
  end
  
  factory :order_with_coupon, :parent => :order do
    coupon_code 'Facebooktest'
  end
  
  factory :complete_order, :parent => :order_with_coupon do
    after(:create) do |order|
      #puts "in after(:create)"
      store1 = FactoryGirl.create(:store_with_tier)
      store2 = FactoryGirl.create(:store)
      store3 = FactoryGirl.create(:store)
      order.line_items << FactoryGirl.create(:line_item, :order => order, :store => store1)
      order.line_items << FactoryGirl.create(:line_item, :order => order, :store => store1)
      order.line_items << FactoryGirl.create(:line_item, :order => order, :store => store1)
      order.line_items << FactoryGirl.create(:line_item, :order => order, :store => store2)
      order.line_items << FactoryGirl.create(:line_item, :order => order, :store => store2)
      order.line_items << FactoryGirl.create(:line_item, :order => order, :store => store3)
      order.create_shipment!
      order.update_totals
      order.ensure_all_orders_stores
      order.open_orders_stores
    end
  end
end


###
# This custom function was written so that orders_stores could assign their store to the store
# of the shipment that is created by the order factory
###
def Factory.custom_order(options={})
  ###
  # Need to temporarily override this to create the entire order
  ###
  products_to_keep = Product.all
  original_config = Spree::Config[:allow_backorders]
  Spree::Config.set(:allow_backorders => true)
  
  order = FactoryGirl.create(:order, :ship_address => FactoryGirl.create(:address))
  #if options[:late]
  #  FactoryGirl.create(:late_order)
  #else
  #  FactoryGirl.create(:order)
  #end
  
  order.shipments = []
  order.save
  
  if options[:shipped]
    order.shipments << FactoryGirl.create(:shipped_shipment, :order =>  order)
  else
    order.shipments << FactoryGirl.create(:ready_shipment, :order => order)
  end
  
  shipment = order.shipments.first
  
  shipment.inventory_units.destroy_all
  
  store = if options[:shipment_store]
    options[:shipment_store]
  else
    FactoryGirl.create(:store)
  end
  
  # allow partial updates to get to work
  Spree::LineItem.partial_updates = false
    
  shipment.store = store
  inventory_unit_type = shipment.shipped? ? :shipped_inventory_unit : :inventory_unit
  line_item_type = shipment.shipped? ? :shipped_line_item : :open_line_item
  1.times do
    product = FactoryGirl.create(:product)
    products_to_keep << product
    product.taxons.delete(product.taxons.where("spree_taxons.store_id IS NOT NULL").first)
    product.taxons << FactoryGirl.create(:store_taxon, :store => store)
    line_item = FactoryGirl.create(line_item_type, :order => order, :variant => FactoryGirl.create(:variant, :product => product), :store => store, quantity: 1)
    line_item.inventory_units.each do |inventory_unit|
      old_shipment = inventory_unit.shipment
      inventory_unit.shipment = shipment
      inventory_unit.save
      old_shipment.inventory_units = []
      old_shipment.save
      old_shipment.destroy
    end
    #line_item.quantity.times do |i|
    #  shipment.inventory_units << FactoryGirl.create(inventory_unit_type, :line_item => line_item, :order => order, :shipment => shipment, :variant => line_item.variant)
    #end
  end
  
  shipment.save
  shipment.reload
  store.reload
  
  order.state = 'complete'
  order.completed_at = if options[:late]
    Time.now.utc - 4.days
  else
    Time.now.utc
  end
  order.save
  
  order.update!
  order.ensure_all_orders_stores
  order.open_orders_stores
  if options[:shipped]
    order.orders_stores.each do |orders_store|
      if options[:late]
        orders_store.update_attribute_without_callbacks :state, 'closed_late'
      else
        orders_store.update_attribute_without_callbacks :state, 'complete'
      end
    end
  end
  order.calculate_orders_stores
  order.update!
  order.save
  order.reload
  order.line_items.reload
  
  order.payments.destroy_all
  order.payments << FactoryGirl.create(:payment, :amount => order.total, :order => order)
  payment = order.payments.first
  payment.update_attributes_without_callbacks :amount => order.total, :state => 'completed'
  #puts "order.payments #{order.payments}"

  order.line_items.each do |line_item|
    line_item.update_attribute_without_callbacks(:state, 'open')
  end
  #payment = order.payments.first
  #payment.update_attributes_without_callbacks :amount => order.total, :state => 'completed'
  
  if options[:credit_owed]
    order.inventory_units.first.cancel
    #order.update!
    #order.save
    order.reload
    order.line_items.reload
  end
  
  order.shipments.reload
  order.shipments.each do |shipment|
    if options[:shipped]
      shipment.update_attribute_without_callbacks 'state', :shipped
    else
      shipment.update_attribute_without_callbacks 'state', :ready
    end
  end
  
  if options[:shipped]
    order.update_attribute_without_callbacks 'shipment_state', :shipped
  else
    order.update_attribute_without_callbacks 'shipment_state', :ready
  end
  
  Spree::Product.where('id NOT IN (?)', products_to_keep).destroy_all
  
  Spree::Config.set(:allow_backorders => original_config)
  Spree::Order.find(order.id)
end
