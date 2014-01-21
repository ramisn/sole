class AddShippingStateToOrdersStores < ActiveRecord::Migration
  def self.up
    change_table :orders_stores do |t|
      t.string :state, :null => false, :default => 'inactive'
      t.datetime :completed_at
    end
    
    add_index :orders_stores, :state
  end

  def self.down
    change_table :orders_stores do |t|
      t.remove :state
      t.remove :completed_at
    end
  end
end
