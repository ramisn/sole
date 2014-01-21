class AddStoreToVendorPaymentPeriod < ActiveRecord::Migration
  def self.up
    change_table :vendor_payment_periods do |t|
      t.references :store, :null => false
    end
    
    add_index :vendor_payment_periods, :store_id
    add_index :vendor_payment_periods, [:month, :store_id], :unique => true
  end

  def self.down
    change_table :vendor_payment_periods do |t|
      t.remove :store_id
    end
  end
end
