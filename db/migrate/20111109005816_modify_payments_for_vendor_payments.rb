class ModifyPaymentsForVendorPayments < ActiveRecord::Migration
  def self.up
    change_table :payments do |t|
      t.string :type
      t.references :vendor_payment_period
    end
  end

  def self.down
    change_table :payments do |t|
      t.remove :type
      t.remove :vendor_payment_period_id
    end
  end
end
