FactoryGirl.define do
  factory :vendor_payment_period do
    state 'inactive'
    month { Time.new(2011, 11) }
    total 0.00
    payment_total 0.00
    store { FactoryGirl.create(:store_with_usa_epay) }
    
    trait :paid do
      state 'paid'
      total 100.00
      payment_total 100.00
    end
    
    trait :payable do
      state 'payable'
      total 100.00
      payment_total 0.00
    end
    
    trait :chargeback do
      state 'chargeback_required'
      total 100.00
      payment_total 125.00
    end
    
    factory :paid_vendor_payment_period, :traits => [:paid]
    factory :payable_vendor_payment_period, :traits => [:payable]
    factory :chargeback_vendor_payment_period, :traits => [:chargeback]
  end
end

def Factory.custom_vendor_payment_period(options={})
  store = Store.joins(:taxon).where(:taxons => {:name => options[:merchant]}).limit(1).first
  if store.nil?
    store =FactoryGirl.create(:store_with_usa_epay, :taxon => FactoryGirl.create(:store_taxon, :name => options[:merchant]))
  end
  vendor_payment_period = FactoryGirl.create(:vendor_payment_period, :store => store, :state => options[:state], :month => Time.new(options[:year], options[:month]), :total => options[:total], :payment_total => options[:payment_total])
  
  if options[:paid]
    vendor_payment_period.vendor_payments << FactoryGirl.create(:vendor_payment, :vendor_payment_period => vendor_payment_period, :amount => options[:payment_total], :state => 'settled', :updated_at => options[:paid], :created_at => options[:paid])
  end
  options[:num_orders].times do
    vendor_payment_period.orders_stores.create(:store => store, :order => FactoryGirl.create(:order))
  end
  vendor_payment_period
end

def Factory.setup_store_payments(store)
  variant = FactoryGirl.create(:variant, :product => FactoryGirl.create(:product, :name => 'Hi Heels', :taxons => [FactoryGirl.create(:category_taxon_with_commission, :commission_rate => 40.0), store.taxon]), :price => 20.00, :is_master => true, :sku => 1)
  line_item1 = FactoryGirl.create(:line_item, :store => store, :variant => variant, :quantity => 2, :order => FactoryGirl.create(:order, :number => '234', :completed_at => Time.new(2011, 11, 16, 10, 7, 30)))
  line_item2 = FactoryGirl.create(:line_item, :store => store, :variant => variant, :quantity => 1, :order => FactoryGirl.create(:order, :number => '123', :completed_at => Time.new(2011, 11, 1, 10, 7, 30)))
  
  order1 = line_item1.order
  order1.ensure_all_orders_stores
  order1.calculate_orders_stores
  
  inventory_units1 = [FactoryGirl.create(:inventory_unit, :variant => line_item1.variant, :order => order1), FactoryGirl.create(:inventory_unit, :variant => line_item1.variant, :order => order1)]
  shipment1 = order1.shipments.create(:store_id => order1.line_items.first.store, :shipping_method => FactoryGirl.create(:shipping_method), :inventory_units => inventory_units1) 
  inventory_units1.each do |iu|
    iu.update_attribute_without_callbacks 'shipment_id', shipment1.id
  end
  
  order2 = line_item2.order
  order2.ensure_all_orders_stores
  order2.calculate_orders_stores
  inventory_units2 = [FactoryGirl.create(:inventory_unit, :variant => line_item2.variant, :order => order2)]
  shipment2 = order2.shipments.create(:store_id => order2.line_items.first.store, :shipping_method => FactoryGirl.create(:shipping_method), :inventory_units => inventory_units2) 
  inventory_units2.each do |iu|
    iu.update_attribute_without_callbacks 'shipment_id', shipment2.id
  end
  
  coupon1 = FactoryGirl.create(:promotion_credit, :source => FactoryGirl.create(:promotion), :order => line_item1.order, :amount => -4)
  coupon1.source = FactoryGirl.create(:promotion)
  coupon1.save!
  
  line_item1.orders_store.update_attributes_without_callbacks :shipping => 5.99, :coupons => -2.40, :total_reimbursement => 27.59
  line_item2.orders_store.update_attributes_without_callbacks :shipping => 4.99, :coupons => 0, :total_reimbursement => 16.99
  
  [order1, order2].each do |order| 
    order.orders_stores.each do |orders_store| 
      orders_store.update_attribute_without_callbacks 'completed_at', Time.new(2011, 11, 20, 5, 6, 3)
      VendorPaymentPeriod.check_orders_store_for_period(orders_store)
    end
  end
  VendorPaymentPeriod.where(:store_id => store).limit(1).first
end

