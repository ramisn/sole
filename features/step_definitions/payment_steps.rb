Given /^there are refunded payments$/ do
  now = Time.now.utc
  FactoryGirl.create(:payment, :created_at => now, :amount => -25.00, :source => FactoryGirl.create(:payment), :order => FactoryGirl.create(:order, :number => 'R135'))
  FactoryGirl.create(:payment, :created_at => now - 1.seconds, :amount => -15.00, :source => FactoryGirl.create(:payment), :order => FactoryGirl.create(:order, :number => 'R246'))
  FactoryGirl.create(:payment, :created_at => now - 2.seconds, :amount => -50.00, :source => FactoryGirl.create(:payment), :order => FactoryGirl.create(:order, :number => 'R357'))
end

Given /^there are no refunded payments$/ do
  Payment.refunds.destroy_all
end

Given /^there are vendor payments for many months$/ do
  Factory.custom_vendor_payment_period(:state => 'inactive', :merchant => 'Nooka', :month => 1, :year => 2012, :num_orders => 1, :total => 100.00, :payment_total => 0.00)
  Factory.custom_vendor_payment_period(:state => 'paid', :merchant => 'Jarjar', :month => 12, :year => 2011, :num_orders => 1, :total => 20.00, :payment_total => 20.00, :paid => Time.new(2012, 1, 15, 10, 0, 0))
  Factory.custom_vendor_payment_period(:state => 'payable', :merchant => 'Nooka', :month => 12, :year => 2011, :num_orders => 2, :total => 200.00, :payment_total => 0.00)
  Factory.custom_vendor_payment_period(:state => 'payable', :merchant => 'Dunkel', :month => 12, :year => 2011, :num_orders => 1, :total => 50.00, :payment_total => 0.00)
  Factory.custom_vendor_payment_period(:state => 'chargeback_required', :merchant => 'Nooka', :month => 11, :year => 2011, :num_orders => 3, :total => 300.00, :payment_total => 350.00, :paid => Time.new(2011, 12, 15, 10, 0, 0))
end

Given /^#{capture_model} has payments in the system$/ do |store_name|
  store = find_model!(store_name)
  puts store
  vendor_payment_period = Factory.setup_store_payments(store)
  step %{a vendor_payment_period: "Vendor Payment Period" should exist with id: #{vendor_payment_period.id}}
end

