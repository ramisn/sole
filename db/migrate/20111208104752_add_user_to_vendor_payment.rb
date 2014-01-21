class AddUserToVendorPayment < ActiveRecord::Migration
  def self.up
    change_table :payments do |t|
      t.integer :admin_id
      t.decimal :product_sales, :precision => 8, :scale => 2, :default => 0.0
      t.decimal :coupons, :precision => 8, :scale => 2, :default => 0.0
      t.decimal :shipping, :precision => 8, :scale => 2, :default => 0.0
      t.decimal :sales_tax, :precision => 8, :scale => 2, :default => 0.0
    end
    
    change_table :inventory_units do |t|
      t.integer :vendor_payment_reversal_id
    end
  end

  def self.down
    change_table :payments do |t|
      t.remove :admin_id
      t.remove :product_sales
      t.remove :coupons
      t.remove :shipping
      t.remove :sales_tax
    end
    
    change_table :inventory_units do |t|
      t.remove :vendor_payment_reversal_id
    end
  end
end
