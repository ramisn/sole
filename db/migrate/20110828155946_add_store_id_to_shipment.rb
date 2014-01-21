class AddStoreIdToShipment < ActiveRecord::Migration
  def self.up
    add_column :shipments, :store_id, :integer
    add_index :shipments, :store_id
  end

  def self.down
    remove_column :shipments, :store_id
  end
end
