class AddVendorShippingMethodToShipment < ActiveRecord::Migration
  def self.up
    add_column :shipments, :vendor_shipping_method, :string
  end

  def self.down
    remove_column :shipments, :vendor_shipping_method
  end
end
