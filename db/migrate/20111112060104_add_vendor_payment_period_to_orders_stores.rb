class AddVendorPaymentPeriodToOrdersStores < ActiveRecord::Migration
  def self.up
    change_table :orders_stores do |t|
      t.references :vendor_payment_period
    end
    
    add_index :orders_stores, :vendor_payment_period_id
  end

  def self.down
    change_table :orders_stores do |t|
      t.remove :vendor_payment_period_id
    end
  end
end
