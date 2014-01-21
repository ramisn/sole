Given /^an open order exists for #{capture_model}$/ do |store_name|
  store = find_model!(store_name)
  orders_store = FactoryGirl.create(:open_orders_store, :store => store)
  step %{an order: "Order" should exist with number: "#{orders_store.order.number}"}
  step %{an orders_store: "Store's Order" should exist with order: order "Order"}
  step %{an inventory_unit: "Inventory Unit" should exist with order: order "Order"}
end

Given /^only an open order exists for #{capture_model}$/ do |store_name|
  step %{an open order exists for #{store_name}}
  order = find_model!("order \"Order\"")
  orders_store = find_model!("orders_store \"Store's Order\"")
  Spree::Order.where('id != ?', order.id).each do |order|
    order.destroy
  end
end

Given /^a shipped order exists for #{capture_model}$/ do |store_name|
  store = find_model!(store_name)
  orders_store = FactoryGirl.create(:complete_orders_store, :store => store)
  step %{an order: "Order" should exist with number: "#{orders_store.order.number}"}
  step %{an orders_store: "Store's Order" should exist with order: order "Order"}
  step %{an inventory_unit: "Inventory Unit" should exist with order: order "Order"}
end

Given /^only a shipped order exists for #{capture_model}$/ do |store_name|
  step %{a shipped order exists for #{store_name}}
  order = find_model!("order \"Order\"")
  Spree::Order.where('id != ?', order.id).each do |order|
    order.destroy
  end
end

Given /^a credit owed order exists$/ do
  order = Factory.custom_order(:credit_owed => true)
  step %{an order: "Order" should exist with number: "#{order.number}"}
  step %{an orders_store: "Store's Order" should exist with order: order "Order"}
  step %{an inventory_unit: "Inventory Unit" should exist with order: order "Order"}
end

Given /^I have orders that are credit owed$/ do
  order = FactoryGirl.create(:complete_not_shipped_order)
  order.update_attributes_without_callbacks :number => 'R123', :total => 100.00, :payment_state => 'credit_owed', :payment_total => 150.00
  
  order1 = FactoryGirl.create(:complete_not_shipped_order)
  order1.update_attributes_without_callbacks :number => 'R234', :total => 0.00, :payment_state => 'credit_owed', :payment_total => 25.00
  
  order2 = FactoryGirl.create(:complete_not_shipped_order)
  order2.update_attributes_without_callbacks :number => 'R345', :total => 25.00, :payment_state => 'credit_owed', :payment_total => 45.00
  
  order3 = FactoryGirl.create(:complete_not_shipped_order)
  order3.update_attributes_without_callbacks :number => 'R456', :total => 10.00, :payment_state => 'credit_owed', :payment_total => 15.00
end

Given /^I have no orders that are credit owed$/ do
  
end
