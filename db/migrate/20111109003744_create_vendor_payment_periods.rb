class CreateVendorPaymentPeriods < ActiveRecord::Migration
  def self.up
    create_table :vendor_payment_periods do |t|
      t.date :month, :null => false
      t.string :state, :null => false, :default => 'not_yet'
      t.decimal :total, :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.decimal :payment_total, :precision => 8, :scale => 2, :default => 0.0, :null => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :vendor_payment_periods
  end
end
