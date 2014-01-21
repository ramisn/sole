class AddUseBillAddressToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :use_bill_address, :boolean, :default => 1
  end

  def self.down
    remove_column :orders, :use_bill_address
  end
end
