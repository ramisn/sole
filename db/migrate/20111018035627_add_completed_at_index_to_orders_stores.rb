class AddCompletedAtIndexToOrdersStores < ActiveRecord::Migration
  def self.up
    add_index :orders_stores, :completed_at
  end

  def self.down
    remove_index :orders_stores, :completed_at
  end
end
